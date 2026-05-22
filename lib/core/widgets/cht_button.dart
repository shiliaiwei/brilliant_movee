import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_spacing.dart';

enum ChtButtonVariant { primary, secondary, ghost, danger }

/// Primary branded button with gradient, glow, and glassmorphism variants.
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
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: isDisabled
            ? null
            : LinearGradient(
                colors: colors,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
        color: isDisabled ? AppColors.backgroundElevated : null,
        borderRadius: BorderRadius.circular(AppRadius.button),
        boxShadow: isDisabled
            ? null
            : [
                BoxShadow(
                  color: colors.first.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(AppRadius.button),
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
                          fontFamily: 'SpaceGrotesk',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          letterSpacing: 1.2,
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.glassOverlay,
        borderRadius: BorderRadius.circular(AppRadius.button),
        border: Border.all(color: AppColors.primary, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.button),
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
                          fontFamily: 'SpaceGrotesk',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          letterSpacing: 1.2,
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
