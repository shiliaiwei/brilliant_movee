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
          CachedNetworkImage(
            imageUrl: _getCategoryImageUrl(),
            fit: BoxFit.cover,
            color: Colors.black.withValues(alpha: 0.4),
            colorBlendMode: BlendMode.darken,
            placeholder: (context, url) =>
                Container(color: AppColors.backgroundElevated),
            errorWidget: (context, url, error) => _buildFallback(),
          ),
          if (category == StoicCategory.pragmatism) _buildFinanceGraph(),
          _buildIntensityIndicator(),
        ],
      ),
    );
  }

  String _getCategoryImageUrl() {
    // HD 4K Source Images from Unsplash with specific keywords
    switch (category) {
      case StoicCategory.dominance:
        return 'https://images.unsplash.com/photo-1518156677180-95a2893f3e9f?q=80&w=1000&auto=format&fit=crop'; // Lightning/Power
      case StoicCategory.unshakeable:
        return 'https://images.unsplash.com/photo-1449156001447-f69973873981?q=80&w=1000&auto=format&fit=crop'; // Architecture/Solid
      case StoicCategory.theVoid:
        return 'https://images.unsplash.com/photo-1470770903676-69b98201ea1c?q=80&w=1000&auto=format&fit=crop'; // Minimalist Silence
      case StoicCategory.pragmatism:
        return 'https://images.unsplash.com/photo-1611974714158-bf8984920555?q=80&w=1000&auto=format&fit=crop'; // Trading/Graph
      case StoicCategory.humanNature:
        return 'https://images.unsplash.com/photo-1554188248-986adbb73be4?q=80&w=1000&auto=format&fit=crop'; // Statue/Human Nature
      case StoicCategory.asceticism:
        return 'https://images.unsplash.com/photo-1507413245164-6160d8298b31?q=80&w=1000&auto=format&fit=crop'; // Study/Books
      case StoicCategory.wisdom:
        return 'https://images.unsplash.com/photo-1519681393784-d120267933ba?q=80&w=1000&auto=format&fit=crop'; // Mountains/Vastness
      case StoicCategory.technology:
        return 'https://images.unsplash.com/photo-1550751827-4bd374c3f58b?q=80&w=1000&auto=format&fit=crop'; // Cyber/Tech
      case StoicCategory.modernSociety:
        return 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=1000&auto=format&fit=crop'; // Skyscraper/City
      case StoicCategory.purpose:
        return 'https://images.unsplash.com/photo-1508672019048-805c876b67e2?q=80&w=1000&auto=format&fit=crop'; // Horizon/Purpose
      case StoicCategory.emotionalControl:
        return 'https://images.unsplash.com/photo-1477332552946-cfb384aeaf1c?q=80&w=1000&auto=format&fit=crop'; // Storm/Calm
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
