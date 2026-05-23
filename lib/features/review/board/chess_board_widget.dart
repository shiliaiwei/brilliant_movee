import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/asset_service.dart';
import '../../../engine/move_classifier.dart';
import 'board_state.dart';

/// 2D chess board rendered with local piece assets.
class ChessBoardWidget extends StatelessWidget {
  const ChessBoardWidget({
    super.key,
    required this.boardState,
    required this.pieceSetId,
    required this.boardThemeId,
    required this.showCoordinates,
    required this.highlightLastMove,
    this.moveQuality,
    this.onSquareTap,
    this.isFlipped = false,
    this.captureKey,
  });

  final BoardState boardState;
  final String pieceSetId;
  final String boardThemeId;
  final bool showCoordinates;
  final bool highlightLastMove;
  final MoveQuality? moveQuality;
  final void Function(String square)? onSquareTap;
  final bool isFlipped;
  final GlobalKey? captureKey;

  @override
  Widget build(BuildContext context) {
    const double boardMargin = 22.0;

    return Container(
      key: captureKey,
      decoration: BoxDecoration(
        color: AppColors.backgroundDeep,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: RepaintBoundary(
        child: AspectRatio(
          aspectRatio: 1,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalSize = constraints.maxWidth;
              final boardSize =
                  showCoordinates ? totalSize - (boardMargin * 2) : totalSize;
              final squareSize = boardSize / 8;

              return Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Actual Board with pieces
                  SizedBox(
                    width: boardSize,
                    height: boardSize,
                    child: Stack(
                      children: [
                        // Board background
                        _BoardBackground(
                          boardThemeId: boardThemeId,
                          size: boardSize,
                        ),

                        // Squares grid with pieces
                        Positioned.fill(
                          child: _PiecesLayer(
                            boardState: boardState,
                            squareSize: squareSize,
                            pieceSetId: pieceSetId,
                            highlightLastMove: highlightLastMove,
                            isFlipped: isFlipped,
                            onSquareTap: onSquareTap,
                          ),
                        ),

                        // Classification Icon Overlay (Small icon with piece)
                        if (moveQuality != null &&
                            boardState.lastMoveTo != null)
                          _ClassificationIcon(
                            square: boardState.lastMoveTo!,
                            quality: moveQuality!,
                            squareSize: squareSize,
                            isFlipped: isFlipped,
                          ),

                        // Best move arrow overlay
                        if (boardState.bestMoveFrom != null &&
                            boardState.bestMoveTo != null)
                          Positioned.fill(
                            child: _ArrowOverlay(
                              from: boardState.bestMoveFrom!,
                              to: boardState.bestMoveTo!,
                              squareSize: squareSize,
                              isFlipped: isFlipped,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Coordinates (Placed OUTSIDE the board)
                  if (showCoordinates)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: _OutsideCoordinatesOverlay(
                          boardSize: boardSize,
                          margin: boardMargin,
                          isFlipped: isFlipped,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OutsideCoordinatesOverlay extends StatelessWidget {
  const _OutsideCoordinatesOverlay({
    required this.boardSize,
    required this.margin,
    required this.isFlipped,
  });

  final double boardSize;
  final double margin;
  final bool isFlipped;

  @override
  Widget build(BuildContext context) {
    final squareSize = boardSize / 8;
    final textStyle = AppTextStyles.monoSmall.copyWith(
      fontSize: 10,
      color: Colors.white.withValues(alpha: 0.5),
      fontWeight: FontWeight.bold,
    );

    return Stack(
      children: [
        // Files (a-h) - Bottom
        ...List.generate(8, (i) {
          final file = isFlipped
              ? String.fromCharCode('h'.codeUnitAt(0) - i)
              : String.fromCharCode('a'.codeUnitAt(0) + i);
          return Positioned(
            left: margin + (i * squareSize) + (squareSize / 2) - 4,
            bottom: 4,
            child: Text(file, style: textStyle),
          );
        }),
        // Ranks (1-8) - Left
        ...List.generate(8, (i) {
          final rank = isFlipped ? '${i + 1}' : '${8 - i}';
          return Positioned(
            left: 6,
            top: margin + (i * squareSize) + (squareSize / 2) - 6,
            child: Text(rank, style: textStyle),
          );
        }),
      ],
    );
  }
}

class _ClassificationIcon extends StatelessWidget {
  const _ClassificationIcon({
    required this.square,
    required this.quality,
    required this.squareSize,
    required this.isFlipped,
  });

  final String square;
  final MoveQuality quality;
  final double squareSize;
  final bool isFlipped;

  @override
  Widget build(BuildContext context) {
    if (square.length < 2) return const SizedBox.shrink();
    int col = square.codeUnitAt(0) - 'a'.codeUnitAt(0);
    int row = 8 - int.parse(square[1]);
    if (isFlipped) {
      col = 7 - col;
      row = 7 - row;
    }

    final (icon, color) = _config();

    return Positioned(
      left: col * squareSize + squareSize * 0.55,
      top: row * squareSize - squareSize * 0.15,
      child: Container(
        padding: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 1.5),
        ),
        child: Icon(icon, color: color, size: squareSize * 0.35),
      ),
    );
  }

  (IconData, Color) _config() {
    return switch (quality) {
      MoveQuality.brilliant => (Icons.auto_awesome, AppColors.brilliant),
      MoveQuality.great => (Icons.thumb_up_rounded, AppColors.great),
      MoveQuality.best => (Icons.star_rounded, AppColors.primary),
      MoveQuality.good => (Icons.check_circle_rounded, AppColors.good),
      MoveQuality.book => (Icons.menu_book_rounded, AppColors.book),
      MoveQuality.inaccuracy => (Icons.help_rounded, AppColors.inaccuracy),
      MoveQuality.mistake => (Icons.warning_rounded, AppColors.mistake),
      MoveQuality.blunder => (Icons.error_rounded, AppColors.blunder),
      MoveQuality.miss => (Icons.cancel_rounded, AppColors.miss),
      MoveQuality.forced => (
          Icons.arrow_forward_rounded,
          AppColors.textSecondary
        ),
    };
  }
}

class _BoardBackground extends StatelessWidget {
  const _BoardBackground({
    required this.boardThemeId,
    required this.size,
  });

  final String boardThemeId;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = AssetService.instance.boardThemeById(boardThemeId);
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        theme.file,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _FallbackBoard(size: size),
      ),
    );
  }
}

class _FallbackBoard extends StatelessWidget {
  const _FallbackBoard({required this.size});
  final double size;
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _FallbackBoardPainter(),
    );
  }
}

class _FallbackBoardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final squareSize = size.width / 8;
    final lightPaint = Paint()..color = const Color(0xFFB58863);
    final darkPaint = Paint()..color = const Color(0xFFF0D9B5);
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final isLight = (row + col) % 2 == 0;
        canvas.drawRect(
          Rect.fromLTWH(
              col * squareSize, row * squareSize, squareSize, squareSize),
          isLight ? darkPaint : lightPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_FallbackBoardPainter old) => false;
}

class _PiecesLayer extends StatelessWidget {
  const _PiecesLayer({
    required this.boardState,
    required this.squareSize,
    required this.pieceSetId,
    required this.highlightLastMove,
    required this.isFlipped,
    this.onSquareTap,
  });

  final BoardState boardState;
  final double squareSize;
  final String pieceSetId;
  final bool highlightLastMove;
  final bool isFlipped;
  final void Function(String square)? onSquareTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Highlight squares
        if (highlightLastMove && boardState.lastMoveFrom != null)
          _HighlightSquare(
            square: boardState.lastMoveFrom!,
            squareSize: squareSize,
            color: AppColors.boardHighlightFrom,
            isFlipped: isFlipped,
          ),
        if (highlightLastMove && boardState.lastMoveTo != null)
          _HighlightSquare(
            square: boardState.lastMoveTo!,
            squareSize: squareSize,
            color: AppColors.boardHighlightTo,
            isFlipped: isFlipped,
          ),

        // Pieces
        ...boardState.pieces.entries.map((entry) {
          final square = entry.key;
          final piece = entry.value;
          final (col, row) = _squareToColRow(square, isFlipped);

          return Positioned(
            left: col * squareSize,
            top: row * squareSize,
            child: GestureDetector(
              onTap: () => onSquareTap?.call(square),
              child: SizedBox(
                width: squareSize,
                height: squareSize,
                child: _PieceImage(
                  piece: piece,
                  pieceSetId: pieceSetId,
                  size: squareSize,
                ),
              ),
            ),
          );
        }),

        // Tap targets for empty squares
        ...List.generate(64, (i) {
          final col = i % 8;
          final row = i ~/ 8;
          final square = _colRowToSquare(col, row, isFlipped);
          if (boardState.pieces.containsKey(square)) {
            return const SizedBox.shrink();
          }
          return Positioned(
            left: col * squareSize,
            top: row * squareSize,
            child: GestureDetector(
              onTap: () => onSquareTap?.call(square),
              child: SizedBox(width: squareSize, height: squareSize),
            ),
          );
        }),
      ],
    );
  }

  (int col, int row) _squareToColRow(String square, bool flipped) {
    if (square.length < 2) return (0, 0);
    final col = square.codeUnitAt(0) - 'a'.codeUnitAt(0);
    final row = 8 - int.parse(square[1]);
    if (flipped) return (7 - col, 7 - row);
    return (col, row);
  }

  String _colRowToSquare(int col, int row, bool flipped) {
    final actualCol = flipped ? 7 - col : col;
    final actualRow = flipped ? 7 - row : row;
    return '${String.fromCharCode('a'.codeUnitAt(0) + actualCol)}${8 - actualRow}';
  }
}

class _PieceImage extends StatelessWidget {
  const _PieceImage({
    required this.piece,
    required this.pieceSetId,
    required this.size,
  });

  final String piece; // e.g. 'wK', 'bQ'
  final String pieceSetId;
  final double size;

  @override
  Widget build(BuildContext context) {
    // Standard piece mapping for 2D assets
    // We expect pieces like 'wP', 'wN', 'wB', 'wR', 'wQ', 'wK'
    // Ensure naming is consistent: first char lowercase color, second char uppercase type
    final color = piece[0].toLowerCase();
    final type = piece[1].toUpperCase();
    final normalizedPiece = '$color$type';

    final assetPath = 'assets/pieces/$pieceSetId/$normalizedPiece.png';

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Log error and fallback
          return _FallbackPiece(piece: piece, size: size);
        },
      ),
    );
  }
}

class _FallbackPiece extends StatelessWidget {
  const _FallbackPiece({required this.piece, required this.size});
  final String piece;
  final double size;

  String get _symbol => switch (piece.toLowerCase()) {
        'wk' => '♔',
        'wq' => '♕',
        'wr' => '♖',
        'wb' => '♗',
        'wn' => '♘',
        'wp' => '♙',
        'bk' => '♚',
        'bq' => '♛',
        'br' => '♜',
        'bb' => '♝',
        'bn' => '♞',
        'bp' => '♟',
        _ => '?',
      };

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        _symbol,
        style: TextStyle(
          fontSize: size * 0.7,
          color: piece.startsWith('w') ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}

class _HighlightSquare extends StatelessWidget {
  const _HighlightSquare({
    required this.square,
    required this.squareSize,
    required this.color,
    required this.isFlipped,
  });
  final String square;
  final double squareSize;
  final Color color;
  final bool isFlipped;
  @override
  Widget build(BuildContext context) {
    if (square.length < 2) return const SizedBox.shrink();
    int col = square.codeUnitAt(0) - 'a'.codeUnitAt(0);
    int row = 8 - int.parse(square[1]);
    if (isFlipped) {
      col = 7 - col;
      row = 7 - row;
    }
    return Positioned(
      left: col * squareSize,
      top: row * squareSize,
      child: Container(width: squareSize, height: squareSize, color: color),
    );
  }
}

class _ArrowOverlay extends StatelessWidget {
  const _ArrowOverlay({
    required this.from,
    required this.to,
    required this.squareSize,
    required this.isFlipped,
  });
  final String from;
  final String to;
  final double squareSize;
  final bool isFlipped;
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ArrowPainter(
          from: from, to: to, squareSize: squareSize, isFlipped: isFlipped),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  const _ArrowPainter(
      {required this.from,
      required this.to,
      required this.squareSize,
      required this.isFlipped});
  final String from;
  final String to;
  final double squareSize;
  final bool isFlipped;

  Offset _squareCenter(String square) {
    if (square.length < 2) return Offset.zero;
    int col = square.codeUnitAt(0) - 'a'.codeUnitAt(0);
    int row = 8 - int.parse(square[1]);
    if (isFlipped) {
      col = 7 - col;
      row = 7 - row;
    }
    return Offset(
        col * squareSize + squareSize / 2, row * squareSize + squareSize / 2);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final start = _squareCenter(from);
    final end = _squareCenter(to);
    final paint = Paint()
      ..color = AppColors.boardArrowBest
      ..strokeWidth = squareSize * 0.15
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(start, end, paint);
    final angle = math.atan2(end.dy - start.dy, end.dx - start.dx);
    const arrowSize = 12.0;
    final arrowPath = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(end.dx - arrowSize * math.cos(angle - 0.5),
          end.dy - arrowSize * math.sin(angle - 0.5))
      ..lineTo(end.dx - arrowSize * math.cos(angle + 0.5),
          end.dy - arrowSize * math.sin(angle + 0.5))
      ..close();
    canvas.drawPath(
        arrowPath,
        Paint()
          ..color = AppColors.boardArrowBest
          ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(_ArrowPainter old) => old.from != from || old.to != to;
}

class _CoordinatesOverlay extends StatelessWidget {
  const _CoordinatesOverlay(
      {required this.squareSize, required this.isFlipped});
  final double squareSize;
  final bool isFlipped;
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
