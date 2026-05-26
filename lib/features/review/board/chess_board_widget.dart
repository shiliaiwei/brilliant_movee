import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;
import '../../../core/constants/app_colors.dart';
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
    this.animate = true,
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
  final bool animate;
  final GlobalKey? captureKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: captureKey,
      decoration: BoxDecoration(
        color: AppColors.backgroundDeep,
        borderRadius: BorderRadius.circular(4),
      ),
      child: RepaintBoundary(
        child: AspectRatio(
          aspectRatio: 1,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalSize = constraints.maxWidth;
              final boardSize = totalSize;
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
                            animate: animate,
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

                  // Coordinates (Inside and Blur style)
                  if (showCoordinates)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: _BlurInsideCoordinatesOverlay(
                          squareSize: squareSize,
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

class _BlurInsideCoordinatesOverlay extends StatelessWidget {
  const _BlurInsideCoordinatesOverlay({
    required this.squareSize,
    required this.isFlipped,
  });

  final double squareSize;
  final bool isFlipped;

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      fontFamily: 'StackSansNotch',
      fontSize: 8.5,
      color: Colors.black, // High contrast black as requested
      fontWeight: FontWeight.w900,
    );

    return Stack(
      children: [
        // Files (a-h) - Bottom Right of each square in last row
        ...List.generate(8, (i) {
          final file = isFlipped
              ? String.fromCharCode('h'.codeUnitAt(0) - i)
              : String.fromCharCode('a'.codeUnitAt(0) + i);
          return Positioned(
            left: (i * squareSize) + squareSize - 10,
            bottom: 1,
            child: Opacity(opacity: 0.2, child: Text(file, style: textStyle)),
          );
        }),
        // Ranks (1-8) - Top Left of each square in first column
        ...List.generate(8, (i) {
          final rank = isFlipped ? '${i + 1}' : '${8 - i}';
          return Positioned(
            left: 2,
            top: (i * squareSize) + 1,
            child: Opacity(opacity: 0.2, child: Text(rank, style: textStyle)),
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

    final asset = _getAsset();

    return Positioned(
      left: col * squareSize + squareSize * 0.65,
      top: row * squareSize - squareSize * 0.1,
      child: Container(
        width: squareSize * 0.35, // Smaller as requested
        height: squareSize * 0.35,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black45, blurRadius: 4, spreadRadius: 1)
          ],
        ),
        padding: const EdgeInsets.all(0.5),
        child: _buildIcon(asset),
      ),
    );
  }

  Widget _buildIcon(String asset) {
    if (quality == MoveQuality.miss) {
      return Container(
        decoration: const BoxDecoration(
          color: Color(0xFF8E24AA), // Material Purple 700
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.priority_high_rounded,
          color: Colors.white,
          size: 14,
        ),
      );
    }

    return Image.asset(
      asset,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.help, size: 12, color: Colors.grey),
    );
  }

  String _getAsset() {
    return switch (quality) {
      MoveQuality.brilliant => 'assets/classification/brilliant.png',
      MoveQuality.great => 'assets/classification/excellent.png',
      MoveQuality.best => 'assets/classification/best.png',
      MoveQuality.good => 'assets/classification/very_good.png',
      MoveQuality.book => 'assets/classification/book.png',
      MoveQuality.inaccuracy => 'assets/classification/inaccuracy.png',
      MoveQuality.mistake => 'assets/classification/mistake.png',
      MoveQuality.blunder => 'assets/classification/blunder.png',
      MoveQuality.miss => 'assets/classification/sigma.png',
      MoveQuality.forced => 'assets/classification/good.png',
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

class _PiecesLayer extends StatefulWidget {
  const _PiecesLayer({
    required this.boardState,
    required this.squareSize,
    required this.pieceSetId,
    required this.highlightLastMove,
    required this.isFlipped,
    this.animate = true,
    this.onSquareTap,
  });

  final BoardState boardState;
  final double squareSize;
  final String pieceSetId;
  final bool highlightLastMove;
  final bool isFlipped;
  final bool animate;
  final void Function(String square)? onSquareTap;

  @override
  State<_PiecesLayer> createState() => _PiecesLayerState();
}

class _PiecesLayerState extends State<_PiecesLayer> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Highlight squares
        if (widget.highlightLastMove && widget.boardState.lastMoveFrom != null)
          _HighlightSquare(
            square: widget.boardState.lastMoveFrom!,
            squareSize: widget.squareSize,
            color: AppColors.boardHighlightFrom,
            isFlipped: widget.isFlipped,
          ),
        if (widget.highlightLastMove && widget.boardState.lastMoveTo != null)
          _HighlightSquare(
            square: widget.boardState.lastMoveTo!,
            squareSize: widget.squareSize,
            color: AppColors.boardHighlightTo,
            isFlipped: widget.isFlipped,
          ),

        // Pieces (Animated Arcade Style)
        ...widget.boardState.pieces.entries.map((entry) {
          final square = entry.key;
          final piece = entry.value;

          return _ArcadeAnimatedPiece(
            key: ValueKey(
                piece + square), // Identify piece by code+square for animation
            piece: piece,
            square: square,
            squareSize: widget.squareSize,
            pieceSetId: widget.pieceSetId,
            isFlipped: widget.isFlipped,
            animate: widget.animate,
          );
        }),

        // Tap targets for ALL squares (to ensure responsive tapping)
        ...List.generate(64, (i) {
          final col = i % 8;
          final row = i ~/ 8;
          final square = _colRowToSquare(col, row, widget.isFlipped);
          return Positioned(
            left: col * widget.squareSize,
            top: row * widget.squareSize,
            child: GestureDetector(
              onTap: () => widget.onSquareTap?.call(square),
              child: SizedBox(
                width: widget.squareSize,
                height: widget.squareSize,
                child: Container(color: Colors.transparent),
              ),
            ),
          );
        }),
      ],
    );
  }

  String _colRowToSquare(int col, int row, bool flipped) {
    final actualCol = flipped ? 7 - col : col;
    final actualRow = flipped ? 7 - row : row;
    return '${String.fromCharCode('a'.codeUnitAt(0) + actualCol)}${8 - actualRow}';
  }
}

class _ArcadeAnimatedPiece extends StatelessWidget {
  const _ArcadeAnimatedPiece({
    super.key,
    required this.piece,
    required this.square,
    required this.squareSize,
    required this.pieceSetId,
    required this.isFlipped,
    this.animate = true,
  });

  final String piece;
  final String square;
  final double squareSize;
  final String pieceSetId;
  final bool isFlipped;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final col = square.codeUnitAt(0) - 'a'.codeUnitAt(0);
    final row = 8 - int.parse(square[1]);

    final actualCol = isFlipped ? 7 - col : col;
    final actualRow = isFlipped ? 7 - row : row;

    if (!animate) {
      return Positioned(
        left: actualCol * squareSize,
        top: actualRow * squareSize,
        width: squareSize,
        height: squareSize,
        child: IgnorePointer(
          child: _PieceImage(
            piece: piece,
            pieceSetId: pieceSetId,
            size: squareSize,
          ),
        ),
      );
    }

    return AnimatedPositioned(
      duration: const Duration(
          milliseconds: 300), // Faster animation for responsiveness
      curve: Curves.easeOutCubic,
      left: actualCol * squareSize,
      top: actualRow * squareSize,
      width: squareSize,
      height: squareSize,
      child: IgnorePointer(
        child: _PieceImage(
          piece: piece,
          pieceSetId: pieceSetId,
          size: squareSize,
        ),
      ),
    );
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
    final color = piece[0].toLowerCase();
    final type = piece[1].toLowerCase();

    final bool isSvg = pieceSetId == 'defaultP' || pieceSetId == 'Merida15';
    String assetPath;

    if (pieceSetId == 'defaultP') {
      final colorLong = color == 'w' ? 'white' : 'black';
      final typeLong = switch (type) {
        'k' => 'king',
        'q' => 'queen',
        'r' => 'rook',
        'b' => 'bishop',
        'n' => 'knight',
        'p' => 'pawn',
        _ => 'pawn',
      };
      assetPath = 'assets/pieces/defaultP/${colorLong}_$typeLong.svg';
    } else if (pieceSetId == 'Merida15') {
      assetPath = 'assets/pieces/Merida15/$color$type.svg';
    } else {
      assetPath = 'assets/pieces/$pieceSetId/$color${type.toUpperCase()}.png';
    }

    // Wrap in a Stack to add a subtle shadow for "lifted" 2D look
    return Stack(
      alignment: Alignment.center,
      children: [
        // Subtle offset shadow
        if (isSvg)
          Opacity(
            opacity: 0.25,
            child: Transform.translate(
              offset: Offset(size * 0.04, size * 0.04),
              child: SvgPicture.asset(
                assetPath,
                width: size,
                height: size,
                colorFilter:
                    const ColorFilter.mode(Colors.black, BlendMode.srcIn),
              ),
            ),
          )
        else
          Opacity(
            opacity: 0.25,
            child: Transform.translate(
              offset: Offset(size * 0.04, size * 0.04),
              child: Image.asset(
                assetPath,
                width: size,
                height: size,
                color: Colors.black,
              ),
            ),
          ),

        // Main Piece
        isSvg
            ? SvgPicture.asset(
                assetPath,
                width: size,
                height: size,
                fit: BoxFit.contain,
                placeholderBuilder: (_) =>
                    _FallbackPiece(piece: piece, size: size),
              )
            : Image.asset(
                assetPath,
                width: size,
                height: size,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return _FallbackPiece(piece: piece, size: size);
                },
              ),
      ],
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
