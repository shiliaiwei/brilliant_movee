import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../tip_model.dart';

class TipVisualCover extends StatelessWidget {
  final Tip tip;
  final bool isDetailed;

  const TipVisualCover({
    super.key,
    required this.tip,
    this.isDetailed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main Opening Diagram (White Illustrator Style)
        if (tip.imageUrl != null && tip.imageUrl!.isNotEmpty)
          _buildWhiteIllustratorImage(tip.imageUrl!, isDetailed ? 160 : 80)
        else
          _buildFallback(isDetailed ? 160 : 80),

        // Author Profile Overlay (White Illustrator Style)
        if (tip.authorImageUrl != null && tip.authorImageUrl!.isNotEmpty)
          Positioned(
            right: 12,
            bottom: 8,
            child: Container(
              width: isDetailed ? 48 : 32,
              height: isDetailed ? 48 : 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                  )
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildWhiteIllustratorImage(
                  tip.authorImageUrl!, isDetailed ? 48 : 32),
            ),
          ),
      ],
    );
  }

  Widget _buildWhiteIllustratorImage(String url, double height) {
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix([
        1.8,
        0,
        0,
        0,
        -20,
        0,
        1.8,
        0,
        0,
        -20,
        0,
        0,
        1.8,
        0,
        -20,
        0,
        0,
        0,
        1,
        0,
      ]), // Ultra-bright White Illustrator look
      child: ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]),
        child: CachedNetworkImage(
          imageUrl: url,
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: height,
            color: AppColors.backgroundElevated,
          ),
          errorWidget: (context, url, error) => _buildFallback(height),
        ),
      ),
    );
  }

  Widget _buildFallback(double height) {
    String piece = 'wP.png';
    if (tip.category == TipCategory.opening ||
        tip.category == TipCategory.openingNames) {
      piece = 'wN.png';
    }
    if (tip.category == TipCategory.middlegame) {
      piece = 'wR.png';
    }
    if (tip.category == TipCategory.endgame) {
      piece = 'wK.png';
    }
    if (tip.category == TipCategory.tactics) {
      piece = 'wQ.png';
    }
    if (tip.category == TipCategory.mindset ||
        tip.category == TipCategory.stoic) {
      piece = 'bB.png';
    }

    return Container(
      height: height,
      width: double.infinity,
      color: AppColors.backgroundElevated.withValues(alpha: 0.5),
      child: Center(
        child: Opacity(
          opacity: 0.15,
          child: Image.asset(
            'assets/pieces/cburnett/$piece',
            height: height * 0.5,
          ),
        ),
      ),
    );
  }
}
