import 'package:chess/chess.dart' as chess_lib;
import '../../../engine/pgn_parser.dart';

/// Immutable board state for a single ply.
class BoardState {
  const BoardState({
    required this.fen,
    required this.pieces,
    required this.plyIndex,
    this.lastMoveFrom,
    this.lastMoveTo,
    this.bestMoveFrom,
    this.bestMoveTo,
    this.isCheck = false,
    this.isCheckmate = false,
    this.isStalemate = false,
  });

  final String fen;
  final Map<String, String> pieces; // square -> piece code (e.g. 'e4' -> 'wP')
  final int plyIndex;
  final String? lastMoveFrom;
  final String? lastMoveTo;
  final String? bestMoveFrom;
  final String? bestMoveTo;
  final bool isCheck;
  final bool isCheckmate;
  final bool isStalemate;

  static const String startFen =
      'rnbqkbnr/pppppppp/8/8/8/8/PPPP1PPP/RNBQKBNR w KQkq - 0 1';

  BoardState copyWith({
    String? bestMoveFrom,
    String? bestMoveTo,
  }) {
    return BoardState(
      fen: fen,
      pieces: pieces,
      plyIndex: plyIndex,
      lastMoveFrom: lastMoveFrom,
      lastMoveTo: lastMoveTo,
      bestMoveFrom: bestMoveFrom ?? this.bestMoveFrom,
      bestMoveTo: bestMoveTo ?? this.bestMoveTo,
      isCheck: isCheck,
      isCheckmate: isCheckmate,
      isStalemate: isStalemate,
    );
  }
}

/// Builds board states from a PGN game.
/// Implements the PGN Playback Engine algorithm from the spec.
abstract final class BoardStateBuilder {
  /// Build all board states for a game.
  /// Returns list of states: index 0 = starting position, index N = after move N.
  static List<BoardState> buildFromPgn(PgnGame game) {
    final states = <BoardState>[];

    // Starting position
    final startChess = chess_lib.Chess();
    states.add(_buildState(startChess, 0, null, null));

    // Apply each move
    final chessGame = chess_lib.Chess();
    for (int i = 0; i < game.moves.length; i++) {
      final move = game.moves[i];
      final fromSquare = _getFromSquare(chessGame, move.san);
      final success = chessGame.move(move.san);

      if (!success) {
        // Invalid move — stop here
        break;
      }

      final toSquare = _getLastMoveToSquare(chessGame);
      states.add(_buildState(chessGame, i + 1, fromSquare, toSquare));
    }

    return states;
  }

  static BoardState fromFen(String fen) {
    final chessGame = chess_lib.Chess.fromFEN(fen);
    return _buildState(chessGame, 0, null, null);
  }

  static BoardState _buildState(
    chess_lib.Chess game,
    int plyIndex,
    String? fromSquare,
    String? toSquare,
  ) {
    final pieces = <String, String>{};

    // Extract piece positions from chess library
    for (final square in _allSquares) {
      final piece = game.get(square);
      if (piece != null) {
        final color = piece.color == chess_lib.Color.WHITE ? 'w' : 'b';
        final type = _pieceTypeToChar(piece.type);
        pieces[square] = '$color$type';
      }
    }

    return BoardState(
      fen: game.fen,
      pieces: pieces,
      plyIndex: plyIndex,
      lastMoveFrom: fromSquare,
      lastMoveTo: toSquare,
      isCheck: game.in_check,
      isCheckmate: game.in_checkmate,
      isStalemate: game.in_stalemate,
    );
  }

  static String? _getFromSquare(chess_lib.Chess game, String san) {
    // Get legal moves and find which one matches the SAN
    final moves = game.generate_moves();
    for (final move in moves) {
      if (game.move_to_san(move) == san) {
        return move.fromAlgebraic;
      }
    }
    return null;
  }

  static String? _getLastMoveToSquare(chess_lib.Chess game) {
    final history = game.getHistory({'verbose': true});
    if (history.isEmpty) return null;
    final last = history.last;
    return last['to'] as String?;
  }

  static String _pieceTypeToChar(chess_lib.PieceType type) {
    if (type == chess_lib.PieceType.KING) return 'K';
    if (type == chess_lib.PieceType.QUEEN) return 'Q';
    if (type == chess_lib.PieceType.ROOK) return 'R';
    if (type == chess_lib.PieceType.BISHOP) return 'B';
    if (type == chess_lib.PieceType.KNIGHT) return 'N';
    if (type == chess_lib.PieceType.PAWN) return 'P';
    return '?';
  }

  static const List<String> _allSquares = [
    'a1',
    'b1',
    'c1',
    'd1',
    'e1',
    'f1',
    'g1',
    'h1',
    'a2',
    'b2',
    'c2',
    'd2',
    'e2',
    'f2',
    'g2',
    'h2',
    'a3',
    'b3',
    'c3',
    'd3',
    'e3',
    'f3',
    'g3',
    'h3',
    'a4',
    'b4',
    'c4',
    'd4',
    'e4',
    'f4',
    'g4',
    'h4',
    'a5',
    'b5',
    'c5',
    'd5',
    'e5',
    'f5',
    'g5',
    'h5',
    'a6',
    'b6',
    'c6',
    'd6',
    'e6',
    'f6',
    'g6',
    'h6',
    'a7',
    'b7',
    'c7',
    'd7',
    'e7',
    'f7',
    'g7',
    'h7',
    'a8',
    'b8',
    'c8',
    'd8',
    'e8',
    'f8',
    'g8',
    'h8',
  ];
}
