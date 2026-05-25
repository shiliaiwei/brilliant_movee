import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// FUI-style progress indicator with fill animation and percentage.
class FuiLoading extends StatefulWidget {
  const FuiLoading({
    super.key,
    this.progress,
    this.label = 'LOADING DATA',
    this.height = 16,
    this.width = 280,
  });

  final double? progress; // null for indeterminate
  final String label;
  final double height;
  final double width;

  @override
  State<FuiLoading> createState() => _FuiLoadingState();
}

class _FuiLoadingState extends State<FuiLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double currentProgress =
        widget.progress ?? 0.5; // fallback for indeterminate visual
    final bool isIndeterminate = widget.progress == null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.label.toUpperCase(),
                style: AppTextStyles.badge.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 1.5,
                  fontSize: 9,
                ),
              ),
              if (!isIndeterminate)
                Text(
                  '${(currentProgress * 100).toInt()}%',
                  style: AppTextStyles.monoSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: widget.width,
          height: widget.height,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white10, width: 1),
          ),
          child: Stack(
            children: [
              // Progress Fill
              if (!isIndeterminate)
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: currentProgress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, Color(0xFF00E5FF)],
                      ),
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),

              // Animated Shimmer / Scanning line
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final offset = isIndeterminate
                      ? _controller.value * 2 - 1
                      : (_controller.value * 2 - 1) * currentProgress;

                  return Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: Transform.translate(
                        offset: Offset(offset * widget.width, 0),
                        child: Container(
                          width: isIndeterminate ? 100 : 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0),
                                Colors.white.withValues(
                                    alpha: isIndeterminate ? 0.3 : 0.15),
                                Colors.white.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        if (isIndeterminate)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'INITIALIZING CORE SYSTEMS',
              style: AppTextStyles.caption.copyWith(
                fontSize: 8,
                color: AppColors.textDisabled,
                letterSpacing: 1,
              ),
            ),
          ),
      ],
    );
  }
}
