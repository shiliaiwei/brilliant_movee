import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../stoic_model.dart';

class StoicVisualCover extends StatelessWidget {
  final StoicCategory category;
  final int intensity;

  const StoicVisualCover({
    super.key,
    required this.category,
    required this.intensity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: AppColors.backgroundDeep,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: _getCategoryImageUrl(),
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                Container(color: AppColors.backgroundElevated),
            errorWidget: (context, url, error) => _buildFallback(),
          ),
          // Subtle dark gradient to improve text contrast on top
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.18),
                  Colors.black.withValues(alpha: 0.36)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryImageUrl() {
    switch (category) {
      case StoicCategory.dominance:
        return 'https://images.unsplash.com/photo-1550684848-fac1c5b4e853?q=80&w=1000&auto=format';
      case StoicCategory.unshakeable:
        return 'https://images.unsplash.com/photo-1494145904049-0dca59b4bbad?q=80&w=1000&auto=format';
      case StoicCategory.theVoid:
        return 'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?q=80&w=1000&auto=format';
      case StoicCategory.pragmatism:
        return 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?q=80&w=1000&auto=format';
      case StoicCategory.humanNature:
        return 'https://images.unsplash.com/photo-1549490349-8643362247b5?q=80&w=1000&auto=format';
      case StoicCategory.asceticism:
        return 'https://images.unsplash.com/photo-1491843384429-30494622eb90?q=80&w=1000&auto=format';
      case StoicCategory.wisdom:
        return 'https://images.unsplash.com/photo-1506318137071-a8e063b4b4bf?q=80&w=1000&auto=format';
      case StoicCategory.technology:
        return 'https://images.unsplash.com/photo-1518770660439-4636190af475?q=80&w=1000&auto=format';
      case StoicCategory.modernSociety:
        return 'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?q=80&w=1000&auto=format';
      case StoicCategory.purpose:
        return 'https://images.unsplash.com/photo-1500673922987-e212871fec22?q=80&w=1000&auto=format';
      case StoicCategory.emotionalControl:
        return 'https://images.unsplash.com/photo-1502481851512-e9e2529bbbf5?q=80&w=1000&auto=format';
      default:
        // High-contrast professional abstract for other 30+ categories
        return 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=1000&auto=format';
    }
  }

  Widget _buildFallback() {
    String piece = 'wP.png';
    if (category == StoicCategory.dominance) piece = 'wK.png';
    if (category == StoicCategory.unshakeable) piece = 'wR.png';
    if (category == StoicCategory.theVoid) piece = 'bK.png';
    if (category == StoicCategory.humanNature) piece = 'wQ.png';
    if (category == StoicCategory.asceticism) piece = 'wN.png';

    return Center(
      child: Opacity(
        opacity: 0.2,
        child: Image.asset(
          'assets/pieces/cburnett/$piece',
          height: 40,
        ),
      ),
    );
  }
}
