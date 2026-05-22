import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/asset_service.dart';
import '../../core/router/app_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _taglineController;

  late Animation<double> _particleOpacity;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<double> _textSlide;

  int _typewriterIndex = 0;
  static const String _tagline = 'Replay. Analyze. Evolve.';
  final List<String> _displayedTagline = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSequence();
  }

  void _setupAnimations() {
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _particleOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.easeIn),
    );
    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );
    _textOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
    _textSlide = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );
  }

  Future<void> _startSequence() async {
    // Initialize services
    await AssetService.instance.initialize();

    // Particle burst
    await Future.delayed(const Duration(milliseconds: 200));
    _particleController.forward();

    // Logo materializes
    await Future.delayed(const Duration(milliseconds: 400));
    _logoController.forward();

    // App name fades in
    await Future.delayed(const Duration(milliseconds: 700));
    _textController.forward();

    // Typewriter tagline
    await Future.delayed(const Duration(milliseconds: 900));
    _startTypewriter();

    // Navigate after splash duration
    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) _navigate();
  }

  void _startTypewriter() {
    Future.doWhile(() async {
      if (!mounted || _typewriterIndex >= _tagline.length) return false;
      setState(() {
        _displayedTagline.add(_tagline[_typewriterIndex]);
        _typewriterIndex++;
      });
      await Future.delayed(const Duration(milliseconds: 55));
      return _typewriterIndex < _tagline.length;
    });
  }

  void _navigate() {
    final storage = ref.read(storageServiceProvider);
    if (!storage.hasSeenOnboarding) {
      context.go(AppRoutes.onboarding);
    } else if (storage.connectedUsername != null) {
      context.go(AppRoutes.home);
    } else {
      context.go('${AppRoutes.search}?from=onboarding');
    }
  }

  @override
  void dispose() {
    _particleController.dispose();
    _logoController.dispose();
    _textController.dispose();
    _taglineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: AppColors.heroGradient,
              ),
            ),
          ),

          // Particle field
          AnimatedBuilder(
            animation: _particleOpacity,
            builder: (context, _) => Opacity(
              opacity: _particleOpacity.value,
              child: const _ParticleField(),
            ),
          ),

          // Center content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo with glow
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, _) => Transform.scale(
                    scale: _logoScale.value,
                    child: Opacity(
                      opacity: _logoOpacity.value,
                      child: _LogoWidget(),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // App name
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, _) => Transform.translate(
                    offset: Offset(0, _textSlide.value),
                    child: Opacity(
                      opacity: _textOpacity.value,
                      child: Column(
                        children: [
                          Text(
                            'BRILLIANT MOVEE',
                            style: AppTextStyles.appName,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          // Typewriter tagline
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _displayedTagline.join(),
                                style: AppTextStyles.tagline,
                              ),
                              // Cursor blink
                              _BlinkingCursor(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Version at bottom
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Text(
              'v1.0.0',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption,
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 40,
            spreadRadius: 10,
          ),
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.2),
            blurRadius: 60,
            spreadRadius: 20,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/brand/logo.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: AppColors.backgroundElevated,
            child: const Icon(
              Icons.sports_esports_rounded,
              color: AppColors.primary,
              size: 48,
            ),
          ),
        ),
      ),
    );
  }
}

class _ParticleField extends StatefulWidget {
  const _ParticleField();

  @override
  State<_ParticleField> createState() => _ParticleFieldState();
}

class _ParticleFieldState extends State<_ParticleField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => CustomPaint(
        painter: _ParticlePainter(progress: _controller.value),
        size: MediaQuery.of(context).size,
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  const _ParticlePainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Draw 20 orbiting particles
    for (int i = 0; i < 20; i++) {
      final angle = (i / 20) * 3.14159 * 2 + progress * 3.14159 * 2;
      final radius = 80.0 + (i % 3) * 30.0;
      final x = cx + radius * _cos(angle);
      final y = cy + radius * _sin(angle);
      final opacity = (0.3 + (i % 5) * 0.1).clamp(0.0, 1.0);
      final size2 = 2.0 + (i % 3).toDouble();

      paint.color = AppColors.primary.withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), size2, paint);
    }
  }

  double _cos(double angle) {
    // Simple cos approximation
    return _sin(angle + 1.5708);
  }

  double _sin(double angle) {
    // Normalize angle
    double a = angle % (2 * 3.14159265);
    if (a < 0) a += 2 * 3.14159265;
    // Taylor series
    double result = a - (a * a * a) / 6 + (a * a * a * a * a) / 120;
    if (a > 3.14159265) result = -(a - 3.14159265) + (a - 3.14159265) * (a - 3.14159265) * (a - 3.14159265) / 6;
    return result.clamp(-1.0, 1.0);
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}

class _BlinkingCursor extends StatefulWidget {
  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Opacity(
        opacity: _controller.value,
        child: Text('|', style: AppTextStyles.tagline),
      ),
    );
  }
}
