import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_spacing.dart';
import 'cht_button.dart';

/// Error state widget with icon, title, description, and retry button.
class ChtErrorState extends StatelessWidget {
  const ChtErrorState({
    super.key,
    required this.title,
    required this.description,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
  });

  final String title;
  final String description;
  final VoidCallback? onRetry;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(icon, color: AppColors.error, size: 32),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              title,
              style: AppTextStyles.title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              description,
              style: AppTextStyles.bodyMuted,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              ChtButton(
                label: 'Try Again',
                onPressed: onRetry,
                isFullWidth: false,
                variant: ChtButtonVariant.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty state widget with illustration prompt, title, and CTA.
class ChtEmptyState extends StatelessWidget {
  const ChtEmptyState({
    super.key,
    required this.title,
    required this.description,
    this.ctaLabel,
    this.onCta,
    this.icon = Icons.inbox_rounded,
  });

  final String title;
  final String description;
  final String? ctaLabel;
  final VoidCallback? onCta;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryGlow,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryBorder, width: 1),
              ),
              child: Icon(icon, color: AppColors.primary, size: 36),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              title,
              style: AppTextStyles.title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              description,
              style: AppTextStyles.bodyMuted,
              textAlign: TextAlign.center,
            ),
            if (ctaLabel != null && onCta != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              ChtButton(
                label: ctaLabel!,
                onPressed: onCta,
                isFullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
