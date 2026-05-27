import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/asset_service.dart';
import '../../core/router/app_router.dart';

import 'package:package_info_plus/package_info_plus.dart';

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
  bool _didNavigate = false;
  String _version = '...';
  String _startupStage = 'Starting…';
  static const String _tagline = 'Replay. Analyze. Evolve.';
  final List<String> _displayedTagline = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadVersion();
    // Safety net: never allow startup to stay on splash indefinitely.
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && !_didNavigate) {
        _navigate();
      }
    });
    _startSequence();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _version = 'v${info.version}');
    } catch (_) {}
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
    try {
      _setStage('Loading assets');
      // Keep startup resilient: continue even if asset manifest loading is slow.
      await AssetService.instance
          .initialize()
          .timeout(const Duration(seconds: 2));
    } catch (_) {
      // Ignore and continue; AssetService has internal defaults.
    }

    if (!mounted) return;
    _setStage('Preparing splash');
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _particleController.forward();

    _setStage('Animating logo');
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _logoController.forward();

    _setStage('Showing title');
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    _textController.forward();

    _setStage('Typing tagline');
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    _startTypewriter();

    _setStage('Routing to app');
    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted && !_didNavigate) {
      _navigate();
    }
  }

  void _setStage(String stage) {
    if (!mounted) return;
    setState(() => _startupStage = stage);
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
    if (_didNavigate || !mounted) return;
    _didNavigate = true;
    _setStage('Opening app');
    developer.log('splash: navigating', name: 'BrilliantMovee.startup');

    try {
      final storage = ref.read(storageServiceProvider);
      if (!storage.hasSeenOnboarding) {
        developer.log('splash: onboarding route',
            name: 'BrilliantMovee.startup');
        context.go(AppRoutes.onboarding);
      } else {
        // Direct to Home screen. If no username is set, Home shows "Connect Account".
        developer.log('splash: home route', name: 'BrilliantMovee.startup');
        context.go(AppRoutes.home);
      }
    } catch (_) {
      // Last-resort fallback to keep the app usable after splash.
      developer.log('splash: fallback home route',
          name: 'BrilliantMovee.startup');
      context.go(AppRoutes.home);
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

                AnimatedOpacity(
                  opacity: _startupStage.isEmpty ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Text(
                      _startupStage,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white70,
                        fontSize: 11,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

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
              _version,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                color: Colors.white24,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
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
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
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
    if (a > 3.14159265) {
      result = -(a - 3.14159265) +
          (a - 3.14159265) * (a - 3.14159265) * (a - 3.14159265) / 6;
    }
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
