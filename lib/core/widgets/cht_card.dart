import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

/// Branded card with optional glow border and glass effect.
class ChtCard extends StatelessWidget {
  const ChtCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.glowColor,
    this.onTap,
    this.borderColor,
    this.backgroundColor,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? glowColor;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? AppColors.backgroundSurface;
    final effectiveBorder = borderColor ?? AppColors.primaryBorder;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: effectiveBorder, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.card),
          splashColor: AppColors.primaryGlow,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Elevated card for modals and sheets.
class ChtElevatedCard extends StatelessWidget {
  const ChtElevatedCard({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.primaryBorder, width: 1),
      ),
      padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
      child: child,
    );
  }
}
