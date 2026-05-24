import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/cht_button.dart';
import '../../../data/models/game_model.dart';

class CelebrateOverlay extends StatefulWidget {
  const CelebrateOverlay({
    super.key,
    required this.result,
    required this.username,
    required this.whiteUsername,
    this.analysisData,
    required this.onDismiss,
  });

  final String result;
  final String username;
  final String whiteUsername;
  final GameAnalysisData? analysisData;
  final VoidCallback onDismiss;

  @override
  State<CelebrateOverlay> createState() => _CelebrateOverlayState();
}

class _CelebrateOverlayState extends State<CelebrateOverlay>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _cardController;
  late AnimationController _particleController;

  late Animation<double> _bgOpacity;
  late Animation<double> _cardSlide;
  late Animation<double> _cardOpacity;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _bgOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeIn),
    );
    _cardSlide = Tween<double>(begin: 100, end: 0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOutBack),
    );
    _cardOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeIn),
    );

    _bgController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _cardController.forward();
    });

    // AUTO DISMISS after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _cardController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  bool get _isWin {
    final isWhite =
        widget.whiteUsername.toLowerCase() == widget.username.toLowerCase();
    return (widget.result == '1-0' && isWhite) ||
        (widget.result == '0-1' && !isWhite);
  }

  bool get _isWhiteWin => widget.result == '1-0';

  bool get _isDraw => widget.result == '1/2-1/2';

  String get _title {
    if (_isDraw) return 'DRAW';
    if (_isWin) return 'VICTORY';
    return 'DEFEATED';
  }

  List<Color> get _bgColors {
    if (_isDraw) return [const Color(0xFF0A0F14), const Color(0xFF141F2E)];
    if (_isWin) {
      // Different colors for white vs black victory
      if (_isWhiteWin) {
        return [const Color(0xFF080C10), const Color(0xFF0D2A1A)];
      }
      return [const Color(0xFF080C10), const Color(0xFF1A1A2E)];
    }
    return AppColors.loseGradient;
  }

  Color get _titleColor {
    if (_isDraw) return AppColors.draw;
    if (_isWin) return AppColors.win;
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bgOpacity,
      builder: (context, _) => Opacity(
        opacity: _bgOpacity.value,
        child: GestureDetector(
          onTap: widget.onDismiss,
          child: Container(
            color: Colors.transparent,
            child: Stack(
              children: [
                // Background
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: _bgColors,
                    ),
                  ),
                ),

                // Particle system
                AnimatedBuilder(
                  animation: _particleController,
                  builder: (context, _) => CustomPaint(
                    painter: _CelebratePainter(
                      progress: _particleController.value,
                      isWin: _isWin,
                      isDraw: _isDraw,
                    ),
                    size: MediaQuery.of(context).size,
                  ),
                ),

                // Summary card
                Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedBuilder(
                    animation: _cardController,
                    builder: (context, _) => Transform.translate(
                      offset: Offset(0, _cardSlide.value),
                      child: Opacity(
                        opacity: _cardOpacity.value,
                        child: _SummaryCard(
                          title: _title,
                          titleColor: _titleColor,
                          analysisData: widget.analysisData,
                          onDismiss: widget.onDismiss,
                          resultLabel: widget.result == '1-0'
                              ? 'White Won'
                              : (widget.result == '0-1' ? 'Black Won' : 'Draw'),
                        ),
                      ),
                    ),
                  ),
                ),

                // Centered King Animation
                Center(
                  child: AnimatedBuilder(
                    animation: _cardController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _cardOpacity.value,
                        child: Transform.scale(
                          scale: 1.0 + (0.2 * _particleController.value),
                          child: Icon(
                            _isWin
                                ? Icons.emoji_events_rounded
                                : Icons.cancel_rounded,
                            size: 120,
                            color: _titleColor.withValues(alpha: 0.8),
                          ),
                        ),
                      );
                    },
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.titleColor,
    required this.analysisData,
    required this.onDismiss,
    required this.resultLabel,
  });

  final String title;
  final Color titleColor;
  final GameAnalysisData? analysisData;
  final VoidCallback onDismiss;
  final String resultLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.primaryBorder),
        boxShadow: [
          BoxShadow(
            color: titleColor.withValues(alpha: 0.2),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppTextStyles.display.copyWith(
              color: titleColor,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            resultLabel.toUpperCase(),
            style: AppTextStyles.caption.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Stats row
          if (analysisData != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(
                  label: 'Accuracy',
                  value: '${analysisData!.accuracy.toStringAsFixed(1)}%',
                  color: AppColors.primary,
                ),
                _StatItem(
                  label: 'Brilliant',
                  value: '${analysisData!.brilliantCount}',
                  color: AppColors.brilliant,
                ),
                _StatItem(
                  label: 'Blunders',
                  value: '${analysisData!.blunderCount}',
                  color: AppColors.blunder,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],

          // Buttons
          ChtButton(
            label: 'Review Moves',
            onPressed: onDismiss,
            icon: Icons.replay_rounded,
          ),
          const SizedBox(height: AppSpacing.md),
          ChtButton(
            label: 'Back to History',
            onPressed: () {
              onDismiss();
              Navigator.of(context).pop();
            },
            variant: ChtButtonVariant.secondary,
            icon: Icons.history_rounded,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headline.copyWith(color: color),
        ),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

class _CelebratePainter extends CustomPainter {
  const _CelebratePainter({
    required this.progress,
    required this.isWin,
    required this.isDraw,
  });

  final double progress;
  final bool isWin;
  final bool isDraw;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final colors = isWin
        ? (isDraw
            ? [AppColors.draw, AppColors.textSecondary]
            : [AppColors.win, AppColors.primary, AppColors.brilliant])
        : [AppColors.loss, AppColors.backgroundElevated];

    for (int i = 0; i < 40; i++) {
      final color = colors[i % colors.length];
      final x = (size.width * ((i * 43 + 17) % 100) / 100);
      final baseY = isWin
          ? size.height * (1 - progress) - (i * 25 % 300)
          : size.height * progress + (i * 25 % 300);
      final y = baseY % size.height;
      final opacity = (0.2 + (i % 6) * 0.1).clamp(0.0, 0.7);
      final radius = 2.0 + (i % 5).toDouble();

      paint.color = color.withValues(alpha: opacity);

      // Draw dynamic shapes: Circles for win, Squares for others
      if (isWin && !isDraw) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      } else {
        canvas.drawRect(
            Rect.fromCenter(
                center: Offset(x, y), width: radius * 2, height: radius * 2),
            paint);
      }
    }
  }

  @override
  bool shouldRepaint(_CelebratePainter old) => old.progress != progress;
}
