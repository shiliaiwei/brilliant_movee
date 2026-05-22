import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_spacing.dart';
import '../../engine/move_classifier.dart';

/// Vertical animated evaluation bar.
/// White advantage at top, black at bottom.
class ChtEvalBar extends StatelessWidget {
  const ChtEvalBar({
    super.key,
    required this.evalCp,
    this.height = 300,
    this.width = 20,
    this.showLabel = true,
  });

  final double evalCp; // centipawns, positive = white advantage
  final double height;
  final double width;
  final bool showLabel;

  double get _whiteFraction {
    final prob = MoveClassifier.winProbability(evalCp);
    return prob.clamp(0.05, 0.95);
  }

  String get _evalLabel {
    if (evalCp.abs() > 2000) {
      return evalCp > 0 ? 'M+' : 'M-';
    }
    final val = evalCp / 100;
    final sign = val >= 0 ? '+' : '';
    return '$sign${val.toStringAsFixed(1)}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel)
          Text(
            _evalLabel,
            style: AppTextStyles.monoSmall.copyWith(
              color: evalCp >= 0 ? AppColors.textPrimary : AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        const SizedBox(height: AppSpacing.xs),
        SizedBox(
          width: width,
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xs),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              child: CustomPaint(
                painter: _EvalBarPainter(whiteFraction: _whiteFraction),
                size: Size(width, height),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EvalBarPainter extends CustomPainter {
  const _EvalBarPainter({required this.whiteFraction});

  final double whiteFraction;

  @override
  void paint(Canvas canvas, Size size) {
    // Black section (top)
    final blackPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF141F2E), Color(0xFF080C10)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      blackPaint,
    );

    // White section (bottom, grows upward)
    final whiteHeight = size.height * whiteFraction;
    final whitePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFB0C4C0), Color(0xFFE8F4F0)],
      ).createShader(
        Rect.fromLTWH(0, size.height - whiteHeight, size.width, whiteHeight),
      );

    canvas.drawRect(
      Rect.fromLTWH(0, size.height - whiteHeight, size.width, whiteHeight),
      whitePaint,
    );

    // Teal glow line at boundary
    final glowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final boundaryY = size.height - whiteHeight;
    canvas.drawLine(
      Offset(0, boundaryY),
      Offset(size.width, boundaryY),
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(_EvalBarPainter old) => old.whiteFraction != whiteFraction;
}

/// Animated eval bar that smoothly transitions between values.
class AnimatedEvalBar extends StatefulWidget {
  const AnimatedEvalBar({
    super.key,
    required this.evalCp,
    this.height = 300,
    this.width = 20,
    this.showLabel = true,
  });

  final double evalCp;
  final double height;
  final double width;
  final bool showLabel;

  @override
  State<AnimatedEvalBar> createState() => _AnimatedEvalBarState();
}

class _AnimatedEvalBarState extends State<AnimatedEvalBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _evalAnimation;
  double _previousEval = 0;

  @override
  void initState() {
    super.initState();
    _previousEval = widget.evalCp;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _evalAnimation = Tween<double>(
      begin: widget.evalCp,
      end: widget.evalCp,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
  }

  @override
  void didUpdateWidget(AnimatedEvalBar old) {
    super.didUpdateWidget(old);
    if (old.evalCp != widget.evalCp) {
      _evalAnimation = Tween<double>(
        begin: _previousEval,
        end: widget.evalCp,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
      );
      _previousEval = widget.evalCp;
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _evalAnimation,
      builder: (context, _) {
        return ChtEvalBar(
          evalCp: _evalAnimation.value,
          height: widget.height,
          width: widget.width,
          showLabel: widget.showLabel,
        );
      },
    );
  }
}
