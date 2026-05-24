import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../engine/pgn_parser.dart';
import '../../../engine/move_classifier.dart';
import '../../../engine/stockfish_isolate.dart';
import '../../../engine/opening_book.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/recording_service.dart';
import '../board/board_state.dart';

class ReviewState {
  const ReviewState({
    this.pgn = '',
    this.gameId,
    this.game,
    this.boardStates = const [],
    this.currentPlyIndex = 0,
    this.classifications = const [],
    this.isLoading = false,
    this.isAnalyzing = false,
    this.error,
    this.analysisProgress = 0,
    this.isRetryMode = false,
    this.retryMove,
    this.retryFeedback,
    this.isExporting = false,
    this.exportProgress = 0,
    this.recordingMusicPath,
    this.recordingMusicVolume = 0.5,
    this.recordingResolution = const Size(1080, 1080),
    this.whiteTotals = const MoveQualityTotals(),
    this.blackTotals = const MoveQualityTotals(),
  });

  final String pgn;
  final String? gameId;
  final PgnGame? game;
  final List<BoardState> boardStates;
  final int currentPlyIndex;
  final List<MoveClassification?> classifications;
  final bool isLoading;
  final bool isAnalyzing;
  final String? error;
  final double analysisProgress; // 0.0 - 1.0
  final bool isRetryMode;
  final String? retryMove;
  final String? retryFeedback;
  final bool isExporting;
  final double exportProgress;
  final String? recordingMusicPath;
  final double recordingMusicVolume;
  final Size recordingResolution;
  final MoveQualityTotals whiteTotals;
  final MoveQualityTotals blackTotals;

  BoardState? get currentBoardState =>
      boardStates.isNotEmpty && currentPlyIndex < boardStates.length
          ? boardStates[currentPlyIndex]
          : null;

  bool get isAtStart => currentPlyIndex == 0;
  bool get isAtEnd =>
      boardStates.isEmpty || currentPlyIndex >= boardStates.length - 1;

  int get totalPlies => boardStates.isNotEmpty ? boardStates.length - 1 : 0;

  MoveClassification? classificationAt(int plyIndex) {
    if (plyIndex <= 0 || plyIndex > classifications.length) return null;
    return classifications[plyIndex - 1];
  }

  ReviewState copyWith({
    String? pgn,
    String? gameId,
    PgnGame? game,
    List<BoardState>? boardStates,
    int? currentPlyIndex,
    List<MoveClassification?>? classifications,
    bool? isLoading,
    bool? isAnalyzing,
    String? error,
    double? analysisProgress,
    bool? isRetryMode,
    String? retryMove,
    String? retryFeedback,
    bool? isExporting,
    double? exportProgress,
    String? recordingMusicPath,
    double? recordingMusicVolume,
    Size? recordingResolution,
    MoveQualityTotals? whiteTotals,
    MoveQualityTotals? blackTotals,
  }) {
    return ReviewState(
      pgn: pgn ?? this.pgn,
      gameId: gameId ?? this.gameId,
      game: game ?? this.game,
      boardStates: boardStates ?? this.boardStates,
      currentPlyIndex: currentPlyIndex ?? this.currentPlyIndex,
      classifications: classifications ?? this.classifications,
      isLoading: isLoading ?? this.isLoading,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      error: error,
      analysisProgress: analysisProgress ?? this.analysisProgress,
      isRetryMode: isRetryMode ?? this.isRetryMode,
      retryMove: retryMove ?? this.retryMove,
      retryFeedback: retryFeedback ?? this.retryFeedback,
      isExporting: isExporting ?? this.isExporting,
      exportProgress: exportProgress ?? this.exportProgress,
      recordingMusicPath: recordingMusicPath ?? this.recordingMusicPath,
      recordingMusicVolume: recordingMusicVolume ?? this.recordingMusicVolume,
      recordingResolution: recordingResolution ?? this.recordingResolution,
      whiteTotals: whiteTotals ?? this.whiteTotals,
      blackTotals: blackTotals ?? this.blackTotals,
    );
  }
}

class ReviewNotifier extends StateNotifier<ReviewState> {
  ReviewNotifier(this._storage, this._audio) : super(const ReviewState());

  final StorageService _storage;
  final AudioService _audio;
  final StockfishIsolate _engine = StockfishIsolate.instance;

  Future<void> loadGame(String pgn, {String? gameId, int? startAtMove}) async {
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
        gameId: gameId,
        game: game,
        boardStates: boardStates,
        currentPlyIndex: startAtMove ?? 0,
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

  void toggleRetryMode() {
    if (state.isExporting) return;
    state = state.copyWith(
      isRetryMode: !state.isRetryMode,
      retryMove: null,
      retryFeedback: null,
    );
  }

  void _setCurrentPly(int ply) {
    if (state.isExporting &&
        !StackTrace.current.toString().contains('exportVideo')) {
      return; // Block manual moves during export
    }

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

      // Detect Sacrifice
      final materialBefore = _calculateMaterial(boardBefore.pieces);
      final materialAfter = _calculateMaterial(boardAfter.pieces);
      final isWhite = move.isWhite;
      final lostMaterial = isWhite
          ? materialBefore.white - materialAfter.white
          : materialBefore.black - materialAfter.black;
      final isSacrifice = lostMaterial > 0;

      // Check opening book
      final isBook = OpeningBook.isBookPosition(boardAfter.fen);

      // Request engine analysis for position before move
      final requestId = 'ply_$plyIndex';
      final responseFuture = _engine.responses
          .where((r) => r.requestId == requestId)
          .first
          .timeout(const Duration(seconds: 5));

      _engine.analyze(StockfishRequest(
        type: StockfishMessageType.analyze,
        fen: boardBefore.fen,
        depth: depth,
        multiPv: multiPv,
        requestId: requestId,
      ));

      // Wait for response
      StockfishResponse? response;
      try {
        response = await responseFuture;
      } catch (_) {
        // Timeout
      }

      final evalBefore =
          response?.lines.isNotEmpty == true ? response!.lines.first.eval : 0.0;

      // Request analysis for position after move
      final requestId2 = 'ply_${plyIndex}_after';
      final responseFuture2 = _engine.responses
          .where((r) => r.requestId == requestId2)
          .first
          .timeout(const Duration(seconds: 5));

      _engine.analyze(StockfishRequest(
        type: StockfishMessageType.analyze,
        fen: boardAfter.fen,
        depth: depth,
        multiPv: 1,
        requestId: requestId2,
      ));

      StockfishResponse? response2;
      try {
        response2 = await responseFuture2;
      } catch (_) {}

      final evalAfter = response2?.lines.isNotEmpty == true
          ? response2!.lines.first.eval
          : 0.0;

      final classification = MoveClassifier.classify(
        evalBefore: evalBefore,
        evalAfter: evalAfter,
        isBook: isBook,
        isForcedMove: false,
        isSacrifice: isSacrifice,
        shallowEval: evalBefore,
        engineLines: response?.lines ?? [],
        bestMove: response?.lines.isNotEmpty == true
            ? response!.lines.first.moves.isNotEmpty == true
                ? response.lines.first.moves.first
                : null
            : null,
        playedMove: move.san,
      );

      // PERSIST BRILLIANT MOVES
      if (classification.quality == MoveQuality.brilliant) {
        _storage.saveBrilliantGame(
          state.gameId ?? 'manual_${DateTime.now().millisecondsSinceEpoch}',
          state.pgn,
          plyIndex,
        );
      }

      classifications[plyIndex - 1] = classification;
      analyzed++;

      if (mounted) {
        state = state.copyWith(
          classifications: List.from(classifications),
          analysisProgress: analyzed / totalMoves,
          whiteTotals:
              MoveQualityTotals.fromClassifications(classifications, true),
          blackTotals:
              MoveQualityTotals.fromClassifications(classifications, false),
        );
      }
    }

    if (mounted) {
      state = state.copyWith(isAnalyzing: false, analysisProgress: 1.0);
    }
  }

  void startAnalysis() => _startAnalysis();

  ({int white, int black}) _calculateMaterial(Map<String, String> pieces) {
    int w = 0;
    int b = 0;
    for (final p in pieces.values) {
      final color = p[0];
      final type = p[1];
      final val = switch (type) {
        'P' => 100,
        'N' || 'B' => 300,
        'R' => 500,
        'Q' => 900,
        _ => 0,
      };
      if (color == 'w') {
        w += val;
      } else {
        b += val;
      }
    }
    return (white: w, black: b);
  }

  void setRecordingConfig(
      {String? musicPath, double? volume, Size? resolution}) {
    state = state.copyWith(
      recordingMusicPath: musicPath,
      recordingMusicVolume: volume,
      recordingResolution: resolution,
    );
  }

  Future<String?> exportVideo(GlobalKey captureKey) async {
    if (state.boardStates.isEmpty) return null;

    final totalPlies = state.boardStates.length;
    const frameDelay = Duration(milliseconds: 600); // Slower for stability
    final frames = <ui.Image>[];

    state = state.copyWith(isExporting: true, exportProgress: 0);

    // 1. Play background music in sync
    if (state.recordingMusicPath != null) {
      await RecordingService.instance.startBackgroundMusic(
        state.recordingMusicPath!,
        state.recordingMusicVolume,
      );
    }

    // 2. Capture Initial position
    _setCurrentPly(0);
    await Future.delayed(
        const Duration(milliseconds: 500)); // Wait for board layout
    final startFrame = await RecordingService.instance.captureFrame(captureKey,
        pixelRatio: state.recordingResolution.width / 1080);
    if (startFrame != null) frames.add(startFrame);

    // 3. Capture all moves
    for (int i = 1; i < totalPlies; i++) {
      if (!mounted) {
        await RecordingService.instance.stopBackgroundMusic();
        return null;
      }

      // Update state without triggering auto-move logic if any
      state = state.copyWith(currentPlyIndex: i);
      state = state.copyWith(exportProgress: (i / totalPlies) * 0.4);

      // Wait for UI to update (crucial for stability)
      await Future.delayed(frameDelay);

      final frame = await RecordingService.instance.captureFrame(captureKey,
          pixelRatio: state.recordingResolution.width / 1080);
      if (frame != null) frames.add(frame);
    }

    // 4. Capture "Win Celebration" frame/pause
    // We add a few identical frames at the end to hold the final result
    for (int i = 0; i < 5; i++) {
      if (frames.isNotEmpty) frames.add(frames.last);
    }

    if (frames.isEmpty) {
      state = state.copyWith(isExporting: false);
      await RecordingService.instance.stopBackgroundMusic();
      return null;
    }

    state = state.copyWith(exportProgress: 0.5);

    // 5. Generate Video with FFmpeg
    final videoPath = await RecordingService.instance.generateGameVideo(
      frames: frames,
      fps: 2,
      musicPath: state.recordingMusicPath,
      musicVolume: state.recordingMusicVolume,
      resolution: state.recordingResolution,
    );

    state = state.copyWith(isExporting: false, exportProgress: 1.0);
    return videoPath;
  }

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
