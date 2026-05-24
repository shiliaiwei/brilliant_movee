export '../../../core/widgets/cyber_button.dart'
    show CyberButtonSize, CyberButtonVariant;

import 'package:flutter/material.dart';
import '../../../core/widgets/cyber_button.dart';

/// Thin review-feature wrapper for the shared cyber button.
///
/// Use this when you want review actions to stay full-width and visually
/// consistent without repeating the sizing logic in `review_screen.dart`.
class ReviewCyberActionButton extends StatelessWidget {
  const ReviewCyberActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = CyberButtonVariant.primary,
    this.size = CyberButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final CyberButtonVariant variant;
  final CyberButtonSize size;
  final bool isLoading;
  final IconData? icon;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final button = CyberButton(
      label: label,
      onPressed: onPressed,
      variant: variant,
      size: size,
      isLoading: isLoading,
      icon: icon,
    );

    if (!isFullWidth) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}
