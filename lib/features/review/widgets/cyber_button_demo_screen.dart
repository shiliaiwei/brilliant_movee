import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/cyber_button.dart';

/// Demo screen that showcases the cyber button system in a grid.
///
/// This is useful for quickly checking the line-art geometry, label contrast,
/// hover/focus transitions, loading states, and performance with many buttons.
class CyberButtonDemoScreen extends StatelessWidget {
  const CyberButtonDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final samples = <_CyberButtonSample>[
      const _CyberButtonSample(
          'Analyze', CyberButtonVariant.primary, CyberButtonSize.large),
      const _CyberButtonSample(
          'Retry', CyberButtonVariant.secondary, CyberButtonSize.medium),
      const _CyberButtonSample(
          'Export', CyberButtonVariant.tertiary, CyberButtonSize.medium),
      const _CyberButtonSample(
          'Primary Small', CyberButtonVariant.primary, CyberButtonSize.small),
      const _CyberButtonSample(
          'Primary Medium', CyberButtonVariant.primary, CyberButtonSize.medium),
      const _CyberButtonSample(
          'Primary Large', CyberButtonVariant.primary, CyberButtonSize.large),
      const _CyberButtonSample('Secondary Small', CyberButtonVariant.secondary,
          CyberButtonSize.small),
      const _CyberButtonSample('Secondary Medium', CyberButtonVariant.secondary,
          CyberButtonSize.medium),
      const _CyberButtonSample('Secondary Large', CyberButtonVariant.secondary,
          CyberButtonSize.large),
      const _CyberButtonSample(
          'Tertiary Small', CyberButtonVariant.tertiary, CyberButtonSize.small),
      const _CyberButtonSample('Tertiary Medium', CyberButtonVariant.tertiary,
          CyberButtonSize.medium),
      const _CyberButtonSample(
          'Tertiary Large', CyberButtonVariant.tertiary, CyberButtonSize.large),
      const _CyberButtonSample(
          'Loading', CyberButtonVariant.primary, CyberButtonSize.medium,
          isLoading: true),
      const _CyberButtonSample(
          'Loading', CyberButtonVariant.secondary, CyberButtonSize.medium,
          isLoading: true),
      const _CyberButtonSample(
          'Loading', CyberButtonVariant.tertiary, CyberButtonSize.medium,
          isLoading: true),
      const _CyberButtonSample(
          'Disabled', CyberButtonVariant.primary, CyberButtonSize.medium,
          disabled: true),
      const _CyberButtonSample(
          'Disabled', CyberButtonVariant.secondary, CyberButtonSize.medium,
          disabled: true),
      const _CyberButtonSample(
          'Disabled', CyberButtonVariant.tertiary, CyberButtonSize.medium,
          disabled: true),
      const _CyberButtonSample(
          'With Icon', CyberButtonVariant.primary, CyberButtonSize.medium,
          icon: Icons.psychology_rounded),
      const _CyberButtonSample(
          'With Icon', CyberButtonVariant.secondary, CyberButtonSize.medium,
          icon: Icons.rocket_launch_rounded),
      const _CyberButtonSample(
          'With Icon', CyberButtonVariant.tertiary, CyberButtonSize.medium,
          icon: Icons.video_camera_back_rounded),
      const _CyberButtonSample(
          'Tiny', CyberButtonVariant.primary, CyberButtonSize.small,
          icon: Icons.flash_on_rounded),
      const _CyberButtonSample(
          'Wide Action', CyberButtonVariant.secondary, CyberButtonSize.large,
          icon: Icons.arrow_forward_rounded),
      const _CyberButtonSample(
          'Replay', CyberButtonVariant.primary, CyberButtonSize.large,
          icon: Icons.replay_rounded),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppBar(
        title: const Text('Cyber Button Demo'),
        backgroundColor: AppColors.backgroundDeep,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: context.screenPadding,
          vertical: AppSpacing.screenV,
        ),
        child: ResponsiveContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FUTURISTIC BUTTON STYLES',
                style: AppTextStyles.headline.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Line-art borders, angular corners, and deep-brand colors.',
                style: AppTextStyles.bodyMuted,
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: samples.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 2.6,
                ),
                itemBuilder: (context, index) {
                  final sample = samples[index];
                  return CyberButton(
                    label: sample.label,
                    variant: sample.variant,
                    size: sample.size,
                    isLoading: sample.isLoading,
                    icon: sample.icon,
                    onPressed: sample.disabled ? null : () {},
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CyberButtonSample {
  const _CyberButtonSample(
    this.label,
    this.variant,
    this.size, {
    this.isLoading = false,
    this.disabled = false,
    this.icon,
  });

  final String label;
  final CyberButtonVariant variant;
  final CyberButtonSize size;
  final bool isLoading;
  final bool disabled;
  final IconData? icon;
}
