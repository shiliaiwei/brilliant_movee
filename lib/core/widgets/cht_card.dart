import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

/// Branded card with clipped corners (FUI style), optional glow border, and glass effect.
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
    this.cornerCut = 12.0,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? glowColor;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? backgroundColor;
  final double cornerCut;

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
    final shape = _ChtCardShape(cornerCut: widget.cornerCut);

    return ScaleTransition(
      scale: _scale,
      child: Container(
        margin: widget.margin,
        child: Material(
          color: effectiveBg,
          shape: shape.copyWithBorder(color: effectiveBorder, width: 1),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: (_) => _anim.forward(),
            onTapUp: (_) => _anim.reverse(),
            onTapCancel: () => _anim.reverse(),
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

/// Elevated card for modals and sheets with FUI clipped corners.
class ChtElevatedCard extends StatelessWidget {
  const ChtElevatedCard({
    super.key,
    required this.child,
    this.padding,
    this.cornerCut = 16.0,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double cornerCut;

  @override
  Widget build(BuildContext context) {
    final shape = _ChtCardShape(cornerCut: cornerCut);
    return Material(
      color: AppColors.backgroundElevated,
      shape: shape.copyWithBorder(color: AppColors.primaryBorder, width: 1),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
        child: child,
      ),
    );
  }
}

class _ChtCardShape extends ShapeBorder {
  const _ChtCardShape({
    required this.cornerCut,
    this.borderColor = Colors.transparent,
    this.borderWidth = 0,
  });

  final double cornerCut;
  final Color borderColor;
  final double borderWidth;

  _ChtCardShape copyWithBorder({Color? color, double? width}) {
    return _ChtCardShape(
      cornerCut: cornerCut,
      borderColor: color ?? borderColor,
      borderWidth: width ?? borderWidth,
    );
  }

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(borderWidth);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect.deflate(borderWidth),
        textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final cut = cornerCut;
    return Path()
      ..moveTo(rect.left + cut, rect.top)
      ..lineTo(rect.right - cut, rect.top)
      ..lineTo(rect.right, rect.top + cut)
      ..lineTo(rect.right, rect.bottom - cut)
      ..lineTo(rect.right - cut, rect.bottom)
      ..lineTo(rect.left + cut, rect.bottom)
      ..lineTo(rect.left, rect.bottom - cut)
      ..lineTo(rect.left, rect.top + cut)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (borderWidth > 0) {
      final paint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;
      canvas.drawPath(getOuterPath(rect, textDirection: textDirection), paint);
    }
  }

  @override
  ShapeBorder scale(double t) => _ChtCardShape(
        cornerCut: cornerCut * t,
        borderColor: borderColor,
        borderWidth: borderWidth * t,
      );
}
