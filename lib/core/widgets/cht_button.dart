import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_spacing.dart';

enum ChtButtonVariant { primary, secondary, ghost, danger }

/// FUI-inspired branded button with clipped corners (45-degree cuts).
class ChtButton extends StatelessWidget {
  const ChtButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ChtButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height = 50,
  });

  final String label;
  final VoidCallback? onPressed;
  final ChtButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: _buildButton(),
    );
  }

  Widget _buildButton() {
    switch (variant) {
      case ChtButtonVariant.primary:
        return _GradientButton(
          label: label,
          onPressed: onPressed,
          icon: icon,
          isLoading: isLoading,
        );
      case ChtButtonVariant.secondary:
        return _GlassButton(
          label: label,
          onPressed: onPressed,
          icon: icon,
          isLoading: isLoading,
        );
      case ChtButtonVariant.ghost:
        return _GhostButton(
          label: label,
          onPressed: onPressed,
          icon: icon,
          isLoading: isLoading,
        );
      case ChtButtonVariant.danger:
        return _GradientButton(
          label: label,
          onPressed: onPressed,
          icon: icon,
          isLoading: isLoading,
          colors: const [Color(0xFFFF2D55), Color(0xFFFF6B35)],
        );
    }
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.colors = AppColors.ctaGradient,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;
    const shape = _ChtButtonShape(cornerCut: 10);

    return Material(
      color: Colors.transparent,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isDisabled
              ? null
              : LinearGradient(
                  colors: colors,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          color: isDisabled ? AppColors.backgroundElevated : null,
        ),
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          splashColor: Colors.white12,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.backgroundDeep,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 18, color: AppColors.backgroundDeep),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      Text(
                        label.toUpperCase(),
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 1.5,
                          color: isDisabled
                              ? AppColors.textSecondary
                              : AppColors.backgroundDeep,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    const shape = _ChtButtonShape(cornerCut: 10);
    return Material(
      color: AppColors.glassOverlay,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          shape: shape.copyWithBorder(color: AppColors.primary, width: 1),
        ),
        child: InkWell(
          onTap: onPressed,
          splashColor: AppColors.primaryGlow,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 18, color: AppColors.primary),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      Text(
                        label.toUpperCase(),
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 1.5,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        minimumSize: const Size(48, 48),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ChtButtonShape extends ShapeBorder {
  const _ChtButtonShape({
    required this.cornerCut,
    this.borderColor = Colors.transparent,
    this.borderWidth = 0,
  });

  final double cornerCut;
  final Color borderColor;
  final double borderWidth;

  _ChtButtonShape copyWithBorder({Color? color, double? width}) {
    return _ChtButtonShape(
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
  ShapeBorder scale(double t) => _ChtButtonShape(
        cornerCut: cornerCut * t,
        borderColor: borderColor,
        borderWidth: borderWidth * t,
      );
}
