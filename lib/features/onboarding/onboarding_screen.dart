import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/cht_button.dart';
import '../../core/services/storage_service.dart';
import '../../core/router/app_router.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _currentStep = 0;
  static const int _totalSteps = 3;

  static final _slides = [
    const _OnboardingSlide(
      title: 'Replay Every Battle',
      subtitle:
          'Load any Chess.com or Lichess game and watch it unfold move by move with full board animation.',
      icon: Icons.replay_rounded,
      gradientColors: [Color(0xFF000000), Color(0xFF111111)],
      accentColor: AppColors.primary,
    ),
    const _OnboardingSlide(
      title: 'Stockfish Sees All',
      subtitle:
          'Every move analyzed by Stockfish 16. See the eval bar shift, best moves highlighted, and your mistakes exposed.',
      icon: Icons.psychology_rounded,
      gradientColors: [Color(0xFF000000), Color(0xFF111111)],
      accentColor: AppColors.brilliant,
    ),
    const _OnboardingSlide(
      title: 'Your Stats. Your Story.',
      subtitle:
          'Track accuracy, brilliant moves, blunders, and your improvement over time.',
      icon: Icons.bar_chart_rounded,
      gradientColors: [Color(0xFF000000), Color(0xFF111111)],
      accentColor: AppColors.great,
    ),
  ];

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    }
  }

  Future<void> _getStarted() async {
    await ref.read(storageServiceProvider).setHasSeenOnboarding(true);
    if (mounted) context.go('${AppRoutes.search}?from=onboarding');
  }

  void _skip() {
    ref.read(storageServiceProvider).setHasSeenOnboarding(true);
    context.go('${AppRoutes.search}?from=onboarding');
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_currentStep];
    final isLast = _currentStep == _totalSteps - 1;

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      body: Stack(
        children: [
          // Background
          Container(color: AppColors.backgroundDeep),

          SafeArea(
            child: Column(
              children: [
                // Skip button (Simplified, no highlight)
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: GestureDetector(
                      onTap: _skip,
                      child: Text(
                        'Skip',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),

                // Slide content
                Expanded(
                  child: IndexedStack(
                    index: _currentStep,
                    children:
                        _slides.map((s) => _SlideContent(slide: s)).toList(),
                  ),
                ),

                // Dot indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_totalSteps, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _currentStep ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _currentStep
                            ? slide.accentColor
                            : AppColors.divider,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Action buttons
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenH,
                  ),
                  child: isLast
                      ? ChtButton(
                          label: 'Get Started',
                          onPressed: _getStarted,
                          icon: Icons.arrow_forward_rounded,
                        )
                      : ChtButton(
                          label: 'Next',
                          onPressed: _nextStep,
                          icon: Icons.arrow_forward_rounded,
                        ),
                ),

                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.accentColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final Color accentColor;
}

class _SlideContent extends StatelessWidget {
  const _SlideContent({required this.slide});

  final _OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon (No shadow as requested)
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: slide.accentColor.withValues(alpha: 0.1),
              border: Border.all(
                color: slide.accentColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(slide.icon, size: 56, color: slide.accentColor),
          ),

          const SizedBox(height: AppSpacing.xxxl),

          Text(
            slide.title,
            style: AppTextStyles.headline,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.lg),

          Text(
            slide.subtitle,
            style: AppTextStyles.bodyMuted,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
