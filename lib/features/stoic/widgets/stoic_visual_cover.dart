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
      height: 70,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: AppColors.backgroundDeep,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColorFiltered(
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
                imageUrl: _getCategoryImageUrl(),
                fit: BoxFit.cover,
                color: Colors.white.withValues(alpha: 0.05),
                colorBlendMode: BlendMode.lighten,
                placeholder: (context, url) =>
                    Container(color: AppColors.backgroundElevated),
                errorWidget: (context, url, error) => _buildFallback(),
              ),
            ),
          ),
          if (category == StoicCategory.pragmatism) _buildFinanceGraph(),
          _buildIntensityIndicator(),
        ],
      ),
    );
  }

  String _getCategoryImageUrl() {
    // 4K High-Contrast Illustrator/Minimalist Source Images
    switch (category) {
      case StoicCategory.dominance:
        return 'https://images.unsplash.com/photo-1550684848-fac1c5b4e853?q=80&w=1000&auto=format'; // Dark Lightning
      case StoicCategory.unshakeable:
        return 'https://images.unsplash.com/photo-1494145904049-0dca59b4bbad?q=80&w=1000&auto=format'; // Brutalist Architecture
      case StoicCategory.theVoid:
        return 'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?q=80&w=1000&auto=format'; // Deep Horizon
      case StoicCategory.pragmatism:
        return 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?q=80&w=1000&auto=format'; // Geometric Data
      case StoicCategory.humanNature:
        return 'https://images.unsplash.com/photo-1549490349-8643362247b5?q=80&w=1000&auto=format'; // Classical Torso
      case StoicCategory.asceticism:
        return 'https://images.unsplash.com/photo-1491843384429-30494622eb90?q=80&w=1000&auto=format'; // Ancient Scrolls
      case StoicCategory.wisdom:
        return 'https://images.unsplash.com/photo-1506318137071-a8e063b4b4bf?q=80&w=1000&auto=format'; // Cosmos Diagram
      case StoicCategory.technology:
        return 'https://images.unsplash.com/photo-1518770660439-4636190af475?q=80&w=1000&auto=format'; // Circuit Board
      case StoicCategory.modernSociety:
        return 'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?q=80&w=1000&auto=format'; // Urban Grid
      case StoicCategory.purpose:
        return 'https://images.unsplash.com/photo-1500673922987-e212871fec22?q=80&w=1000&auto=format'; // Target/Path
      case StoicCategory.emotionalControl:
        return 'https://images.unsplash.com/photo-1502481851512-e9e2529bbbf5?q=80&w=1000&auto=format'; // Still Lake
    }
  }

  Widget _buildFinanceGraph() {
    return Center(
      child: Opacity(
        opacity: 0.6,
        child: CustomPaint(
          size: const Size(200, 30),
          painter: _GraphPainter(color: AppColors.primary),
        ),
      ),
    );
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
          height: 30,
        ),
      ),
    );
  }

  Widget _buildIntensityIndicator() {
    return Positioned(
      right: 12,
      top: 12,
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index < intensity;
          return Container(
            width: 3,
            height: 3,
            margin: const EdgeInsets.only(left: 3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? AppColors.primary : AppColors.textDisabled,
            ),
          );
        }),
      ),
    );
  }
}

class _GraphPainter extends CustomPainter {
  final Color color;
  _GraphPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.lineTo(size.width * 0.2, size.height * 0.6);
    path.lineTo(size.width * 0.4, size.height * 0.9);
    path.lineTo(size.width * 0.6, size.height * 0.3);
    path.lineTo(size.width * 0.8, size.height * 0.4);
    path.lineTo(size.width, size.height * 0.1);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
