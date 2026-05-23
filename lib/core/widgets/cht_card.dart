import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

/// Branded card with optional glow border and glass effect.
class ChtCard extends StatefulWidget {
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
  State<ChtCard> createState() => _ChtCardState();
}

class _ChtCardState extends State<ChtCard> with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.98).animate(_anim);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBg = widget.backgroundColor ?? AppColors.backgroundSurface;
    final effectiveBorder = widget.borderColor ?? AppColors.primaryBorder;

    return ScaleTransition(
      scale: _scale,
      child: Container(
        margin: widget.margin,
        decoration: BoxDecoration(
          color: effectiveBg,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: effectiveBorder, width: 1),
          boxShadow: widget.glowColor != null
              ? [
                  BoxShadow(
                    color: widget.glowColor!.withValues(alpha: 0.2),
                    blurRadius: 12,
                    spreadRadius: -2,
                  )
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: (_) => _anim.forward(),
            onTapUp: (_) => _anim.reverse(),
            onTapCancel: () => _anim.reverse(),
            borderRadius: BorderRadius.circular(AppRadius.card),
            splashColor: AppColors.primaryGlow,
            highlightColor: Colors.white.withValues(alpha: 0.05),
            child: Padding(
              padding: widget.padding ??
                  const EdgeInsets.all(AppSpacing.cardPadding),
              child: widget.child,
            ),
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
