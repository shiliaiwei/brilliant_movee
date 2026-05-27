import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../engine/move_classifier.dart';
import '../board/chess_board_widget.dart';
import '../board/board_state.dart';

/// A 1:1 Clean layout specifically for video export.
class RecordingExportWidget extends StatelessWidget {
  const RecordingExportWidget({
    super.key,
    required this.boardState,
    required this.pieceSetId,
    required this.boardThemeId,
    required this.openingName,
    required this.moveNotation,
    required this.moveQuality,
    required this.showBestMoveArrows,
    required this.isFlipped,
    required this.captureKey,
  });

  final BoardState boardState;
  final String pieceSetId;
  final String boardThemeId;
  final String openingName;
  final String moveNotation;
  final MoveQuality? moveQuality;
  final bool showBestMoveArrows;
  final bool isFlipped;
  final GlobalKey captureKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: captureKey,
      width: 1080,
      height: 1080,
      color: AppColors.backgroundDeep,
      child: Column(
        children: [
          // Top Padding for layout
          const SizedBox(height: 60),

          // Opening Title
          Text(
            openingName.toUpperCase(),
            textAlign: TextAlign.center,
            style: AppTextStyles.headline.copyWith(
              color: AppColors.primary,
              fontSize: 32,
              letterSpacing: 2,
            ),
          ),

          const Spacer(),

          // Board (Center)
          Padding(
            padding: const EdgeInsets.all(40),
            child: ChessBoardWidget(
              boardState: boardState,
              pieceSetId: pieceSetId,
              boardThemeId: boardThemeId,
              showCoordinates: true,
              highlightLastMove: true,
              showBestMoveArrows: showBestMoveArrows,
              moveQuality: moveQuality,
              isFlipped: isFlipped,
              animate: false,
            ),
          ),

          const Spacer(),

          // Current Move Notation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.color1,
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Text(
              moveNotation,
              style: AppTextStyles.monoLarge.copyWith(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
