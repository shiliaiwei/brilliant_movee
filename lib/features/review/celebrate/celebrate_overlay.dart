import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
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
  late AnimationController _mainController;
  late AnimationController _kingController;
  late AnimationController _particleController;

  late Animation<double> _scale;
  late Animation<double> _opacity;
  late Animation<double> _kingRotation;
  late Animation<double> _kingSlide;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _kingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _scale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.elasticOut),
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _mainController,
          curve: const Interval(0, 0.5, curve: Curves.easeIn)),
    );

    _kingRotation =
        Tween<double>(begin: 0, end: _isWin ? 0 : math.pi / 2.2).animate(
      CurvedAnimation(parent: _kingController, curve: Curves.bounceOut),
    );

    _kingSlide = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _kingController, curve: Curves.easeOutCubic),
    );

    _mainController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _kingController.forward();
    });

    // AUTO DISMISS - Short and impressive as requested
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) _dismiss();
    });
  }

  void _dismiss() {
    _mainController.reverse().then((_) {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _kingController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  bool get _isWhiteWin => widget.result == '1-0';
  bool get _isBlackWin => widget.result == '0-1';
  bool get _isDraw => widget.result == '1/2-1/2';

  bool get _userIsWhite =>
      widget.username.toLowerCase() == widget.whiteUsername.toLowerCase();

  bool get _isWin {
    if (_isWhiteWin && _userIsWhite) return true;
    if (_isBlackWin && !_userIsWhite) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final winnerText = widget.result == '1-0'
        ? 'WHITE WON BY CHECKMATE'
        : (widget.result == '0-1'
            ? 'BLACK WON BY CHECKMATE'
            : 'DRAW BY STALEMATE');
    final statusText =
        _isDraw ? 'STALEMATE' : (_isWin ? 'VICTORY' : 'DEFEATED');
    final mainColor =
        _isDraw ? AppColors.draw : (_isWin ? AppColors.win : AppColors.loss);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBuilder(
        animation: _mainController,
        builder: (context, _) => Stack(
          children: [
            // Dark Backdrop
            Positioned.fill(
              child: Opacity(
                opacity: _opacity.value * 0.9,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.2,
                      colors: [
                        mainColor.withValues(alpha: 0.3),
                        Colors.black.withValues(alpha: 0.95),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Particles for win
            if (_isWin && !_isDraw)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _particleController,
                  builder: (context, _) => CustomPaint(
                    painter: _ConfettiPainter(
                      progress: _particleController.value,
                      color: mainColor,
                    ),
                  ),
                ),
              ),

            // Content
            Center(
              child: Opacity(
                opacity: _opacity.value,
                child: Transform.scale(
                  scale: _scale.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Status Title
                      Text(
                        statusText,
                        style: AppTextStyles.display.copyWith(
                          fontSize: 48,
                          color: mainColor,
                          letterSpacing: 8,
                          shadows: [
                            Shadow(
                                color: mainColor.withValues(alpha: 0.5),
                                blurRadius: 20),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        winnerText,
                        style: AppTextStyles.monoLarge.copyWith(
                          fontSize: 16,
                          color: Colors.white70,
                          letterSpacing: 4,
                        ),
                      ),

                      const SizedBox(height: 60),

                      // Animated King Icon
                      AnimatedBuilder(
                        animation: _kingController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _kingSlide.value),
                            child: Transform.rotate(
                              angle: _kingRotation.value,
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: mainColor.withValues(alpha: 0.2),
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _isWin || _isDraw
                                      ? Icons.emoji_events_rounded
                                      : Icons.person_off_rounded,
                                  size: 140,
                                  color: mainColor,
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 80),

                      // Quick info
                      if (widget.analysisData != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _SummaryStat(
                                label: 'ACCURACY',
                                value:
                                    '${widget.analysisData!.accuracy.toInt()}%',
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 32),
                              _SummaryStat(
                                label: 'BRILLIANT',
                                value: '${widget.analysisData!.brilliantCount}',
                                color: AppColors.brilliant,
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 40),

                      // Dismiss hint
                      Text(
                        'TAP TO CONTINUE',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white24,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style:
                AppTextStyles.monoLarge.copyWith(color: color, fontSize: 24)),
        Text(label,
            style:
                AppTextStyles.caption.copyWith(fontSize: 9, letterSpacing: 1)),
      ],
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress, required this.color});
  final double progress;
  final Color color;
  final math.Random random = math.Random(42);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 50; i++) {
      final double x = random.nextDouble() * size.width;
      final double startY = random.nextDouble() * size.height;
      final double y = (startY + progress * size.height) % size.height;

      paint.color = color.withValues(alpha: 0.2 + random.nextDouble() * 0.4);
      final double s = 2.0 + random.nextDouble() * 4.0;

      canvas.drawRect(Rect.fromLTWH(x, y, s, s), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
