import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../engine/pgn_parser.dart';
import '../../../engine/move_classifier.dart';
import '../../../engine/stockfish_isolate.dart';
import '../../../engine/opening_book.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/audio_service.dart';
import '../board/board_state.dart';

class ReviewState {
  const ReviewState({
    this.pgn = '',
    this.game,
    this.boardStates = const [],
    this.currentPlyIndex = 0,
    this.classifications = const [],
    this.isLoading = false,
    this.isAnalyzing = false,
    this.error,
    this.analysisProgress = 0,
  });

  final String pgn;
  final PgnGame? game;
  final List<BoardState> boardStates;
  final int currentPlyIndex;
  final List<MoveClassification?> classifications;
  final bool isLoading;
  final bool isAnalyzing;
  final String? error;
  final double analysisProgress; // 0.0 - 1.0

  BoardState? get currentBoardState =>
      boardStates.isNotEmpty && currentPlyIndex < boardStates.length
          ? boardStates[currentPlyIndex]
          : null;

  bool get isAtStart => currentPlyIndex == 0;
  bool get isAtEnd =>
      boardStates.isEmpty || currentPlyIndex >= boardStates.length - 1;

  int get totalPlies => boardStates.length > 0 ? boardStates.length - 1 : 0;

  MoveClassification? classificationAt(int plyIndex) {
    if (plyIndex <= 0 || plyIndex > classifications.length) return null;
    return classifications[plyIndex - 1];
  }

  ReviewState copyWith({
    String? pgn,
    PgnGame? game,
    List<BoardState>? boardStates,
    int? currentPlyIndex,
    List<MoveClassification?>? classifications,
    bool? isLoading,
    bool? isAnalyzing,
    String? error,
    double? analysisProgress,
  }) {
    return ReviewState(
      pgn: pgn ?? this.pgn,
      game: game ?? this.game,
      boardStates: boardStates ?? this.boardStates,
      currentPlyIndex: currentPlyIndex ?? this.currentPlyIndex,
      classifications: classifications ?? this.classifications,
      isLoading: isLoading ?? this.isLoading,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      error: error,
      analysisProgress: analysisProgress ?? this.analysisProgress,
    );
  }
}

class ReviewNotifier extends StateNotifier<ReviewState> {
  ReviewNotifier(this._storage, this._audio) : super(const ReviewState());

  final StorageService _storage;
  final AudioService _audio;
  final StockfishIsolate _engine = StockfishIsolate.instance;

  Future<void> loadGame(String pgn) async {
    if (pgn.isEmpty) {
      state = state.copyWith(
        error: 'No PGN data provided',
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final game = PgnParser.parse(pgn);
      final boardStates = BoardStateBuilder.buildFromPgn(game);

      state = state.copyWith(
        pgn: pgn,
        game: game,
        boardStates: boardStates,
        currentPlyIndex: 0,
        classifications: List.filled(game.moves.length, null),
        isLoading: false,
      );

      // Auto-analyze if enabled
      if (_storage.autoAnalyze) {
        _startAnalysis();
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to parse game: ${e.toString()}',
      );
    }
  }

  void goToStart() => _setCurrentPly(0);
  void goToEnd() => _setCurrentPly(state.boardStates.length - 1);
  void goBack() => _setCurrentPly(state.currentPlyIndex - 1);
  void goForward() => _setCurrentPly(state.currentPlyIndex + 1);
  void goToPly(int ply) => _setCurrentPly(ply);

  void _setCurrentPly(int ply) {
    final clamped = ply.clamp(0, state.boardStates.length - 1);
    if (clamped != state.currentPlyIndex) {
      state = state.copyWith(currentPlyIndex: clamped);

      // Play move sound
      if (clamped > 0) {
        final move = state.game?.moves[clamped - 1];
        if (move?.san.contains('x') ?? false) {
          _audio.play(SoundEvent.capture);
        } else {
          _audio.play(SoundEvent.move);
        }

        // Play special sound for brilliant moves
        final classification = state.classificationAt(clamped);
        if (classification?.quality == MoveQuality.brilliant) {
          _audio.play(SoundEvent.brilliant);
        }
      }
    }
  }

  Future<void> _startAnalysis() async {
    if (state.boardStates.isEmpty) return;

    state = state.copyWith(isAnalyzing: true, analysisProgress: 0);

    await _engine.start();

    final depth = _storage.engineDepth;
    final multiPv = _storage.multiPv;
    final totalMoves = state.game?.moves.length ?? 0;

    if (totalMoves == 0) {
      state = state.copyWith(isAnalyzing: false, analysisProgress: 1.0);
      return;
    }

    final classifications =
        List<MoveClassification?>.from(state.classifications);
    int analyzed = 0;

    // Progressive analysis: analyze current ply + next 3 plies first
    final priorityPlies = <int>[];
    for (int i = state.currentPlyIndex;
        i <= (state.currentPlyIndex + 3).clamp(0, totalMoves);
        i++) {
      priorityPlies.add(i);
    }

    // Then analyze all remaining plies
    final allPlies = List.generate(totalMoves, (i) => i + 1);
    final orderedPlies = [
      ...priorityPlies,
      ...allPlies.where((p) => !priorityPlies.contains(p)),
    ];

    for (final plyIndex in orderedPlies) {
      if (!mounted) break;
      if (plyIndex <= 0 || plyIndex >= state.boardStates.length) continue;

      final boardBefore = state.boardStates[plyIndex - 1];
      final boardAfter = state.boardStates[plyIndex];
      final move = state.game!.moves[plyIndex - 1];

      // Check opening book
      final isBook = OpeningBook.isBookPosition(boardAfter.fen);

      // Request engine analysis for position before move
      final requestId = 'ply_$plyIndex';
      _engine.analyze(StockfishRequest(
        type: StockfishMessageType.analyze,
        fen: boardBefore.fen,
        depth: depth,
        multiPv: multiPv,
        requestId: requestId,
      ));

      // Wait for response (with timeout)
      StockfishResponse? response;
      try {
        response = await _engine.responses
            .where((r) => r.requestId == requestId)
            .first
            .timeout(const Duration(seconds: 5));
      } catch (_) {
        // Timeout — use default classification
      }

      final evalBefore =
          response?.lines.isNotEmpty == true ? response!.lines.first.eval : 0.0;

      // Request analysis for position after move
      final requestId2 = 'ply_${plyIndex}_after';
      _engine.analyze(StockfishRequest(
        type: StockfishMessageType.analyze,
        fen: boardAfter.fen,
        depth: depth,
        multiPv: 1,
        requestId: requestId2,
      ));

      StockfishResponse? response2;
      try {
        response2 = await _engine.responses
            .where((r) => r.requestId == requestId2)
            .first
            .timeout(const Duration(seconds: 5));
      } catch (_) {}

      final evalAfter = response2?.lines.isNotEmpty == true
          ? response2!.lines.first.eval
          : 0.0;

      final classification = MoveClassifier.classify(
        evalBefore: evalBefore,
        evalAfter: evalAfter,
        isBook: isBook,
        isForcedMove: false,
        isSacrifice: false,
        shallowEval: evalBefore,
        engineLines: response?.lines ?? [],
        bestMove: response?.lines.isNotEmpty == true
            ? response!.lines.first.moves.isNotEmpty == true
                ? response.lines.first.moves.first
                : null
            : null,
        playedMove: move.san,
      );

      classifications[plyIndex - 1] = classification;
      analyzed++;

      if (mounted) {
        state = state.copyWith(
          classifications: List.from(classifications),
          analysisProgress: analyzed / totalMoves,
        );
      }
    }

    if (mounted) {
      state = state.copyWith(isAnalyzing: false, analysisProgress: 1.0);
    }
  }

  void startAnalysis() => _startAnalysis();

  @override
  void dispose() {
    _engine.stop();
    super.dispose();
  }
}

final reviewProvider =
    StateNotifierProvider.autoDispose<ReviewNotifier, ReviewState>((ref) {
  return ReviewNotifier(
    ref.read(storageServiceProvider),
    ref.read(audioServiceProvider),
  );
});
