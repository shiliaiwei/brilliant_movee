import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../tip_model.dart';

class TipVisualCover extends StatelessWidget {
  final Tip tip;

  const TipVisualCover({super.key, required this.tip});

  @override
  Widget build(BuildContext context) {
    if (tip.imageUrl != null && tip.imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: tip.imageUrl!,
        height: 80,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 80,
          color: AppColors.backgroundElevated,
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildFallback(),
      );
    }
    return _buildFallback();
  }

  Widget _buildFallback() {
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
      height: 80,
      width: double.infinity,
      color: AppColors.backgroundElevated.withValues(alpha: 0.5),
      child: Center(
        child: Opacity(
          opacity: 0.15,
          child: Image.asset(
            'assets/pieces/cburnett/$piece',
            height: 40,
          ),
        ),
      ),
    );
  }
}
