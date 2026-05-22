import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

/// Shimmer skeleton loader for loading states.
class ChtShimmer extends StatefulWidget {
  const ChtShimmer({
    super.key,
    required this.child,
    this.enabled = true,
  });

  final Widget child;
  final bool enabled;

  @override
  State<ChtShimmer> createState() => _ChtShimmerState();
}

class _ChtShimmerState extends State<ChtShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: const [
                AppColors.backgroundSurface,
                AppColors.backgroundElevated,
                Color(0xFF1E3040),
                AppColors.backgroundElevated,
                AppColors.backgroundSurface,
              ],
              stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Shimmer placeholder box.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  final double? width;
  final double height;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.sm),
      ),
    );
  }
}

/// Game card shimmer skeleton.
class GameCardShimmer extends StatelessWidget {
  const GameCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ChtShimmer(
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.backgroundSurface,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Row(
          children: [
            const ShimmerBox(width: 64, height: 64, borderRadius: 8),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerBox(width: 120, height: 14),
                  const SizedBox(height: AppSpacing.sm),
                  const ShimmerBox(width: 80, height: 12),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const ShimmerBox(width: 48, height: 20, borderRadius: 10),
                      const SizedBox(width: AppSpacing.sm),
                      const ShimmerBox(width: 60, height: 20, borderRadius: 10),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
