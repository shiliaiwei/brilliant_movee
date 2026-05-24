import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/audio_service.dart';

/// FUI (Futuristic User Interface) inspired button with line-art styling.
///
/// This component maintains Brilliant Movee's brand colors while using
/// geometric shapes, angular corners, and striped patterns.
///
/// Parameters:
/// - [label]: The text displayed on the button. Must be non-empty.
/// - [onPressed]: Callback when the button is tapped. Null disables interaction.
/// - [variant]: The visual style (primary, secondary, or tertiary).
/// - [size]: Controls the button's dimensions and internal scaling.
/// - [isLoading]: If true, displays a rotation animation and disables interaction.
/// - [icon]: Optional leading icon.
enum CyberButtonVariant { primary, secondary, tertiary }

enum CyberButtonSize { small, medium, large }

extension CyberButtonSizeX on CyberButtonSize {
  double get height => switch (this) {
        CyberButtonSize.small => 36,
        CyberButtonSize.medium => 44,
        CyberButtonSize.large => 52,
      };

  double get horizontalPadding => switch (this) {
        CyberButtonSize.small => 14,
        CyberButtonSize.medium => 18,
        CyberButtonSize.large => 22,
      };

  double get lineThickness => switch (this) {
        CyberButtonSize.small => 1.5,
        CyberButtonSize.medium => 2.0,
        CyberButtonSize.large => 2.5,
      };

  double get lineGap => switch (this) {
        CyberButtonSize.small => 6,
        CyberButtonSize.medium => 5,
        CyberButtonSize.large => 4,
      };

  double get fontSize => switch (this) {
        CyberButtonSize.small => 12.0,
        CyberButtonSize.medium => 14.0,
        CyberButtonSize.large => 16.0,
      };

  double get iconSize => switch (this) {
        CyberButtonSize.small => 14,
        CyberButtonSize.medium => 16,
        CyberButtonSize.large => 18,
      };

  double get cornerCut => switch (this) {
        CyberButtonSize.small => 8,
        CyberButtonSize.medium => 10,
        CyberButtonSize.large => 12,
      };
}

class CyberButton extends ConsumerStatefulWidget {
  const CyberButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = CyberButtonVariant.primary,
    this.size = CyberButtonSize.medium,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final CyberButtonVariant variant;
  final CyberButtonSize size;
  final bool isLoading;
  final IconData? icon;

  @override
  ConsumerState<CyberButton> createState() => _CyberButtonState();
}

class _CyberButtonState extends ConsumerState<CyberButton>
    with TickerProviderStateMixin {
  late final AnimationController _hoverController;
  late final AnimationController _loadingController;
  late final AnimationController _flashController;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    if (widget.isLoading) {
      _loadingController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant CyberButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      _loadingController.repeat();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _loadingController.stop();
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _loadingController.dispose();
    _flashController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onPressed == null || widget.isLoading) return;

    // Trigger celebration mechanic: flash and audio
    _flashController.forward(from: 0);
    ref.read(audioServiceProvider).play(SoundEvent.brilliant);

    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.label.isNotEmpty, 'CyberButton label cannot be empty');

    final isDisabled = widget.onPressed == null || widget.isLoading;
    final palette = _resolvePalette(widget.variant, isDisabled);

    return Opacity(
      opacity: isDisabled ? 0.6 : 1.0,
      child: MouseRegion(
        onEnter: (_) => _hoverController.forward(),
        onExit: (_) => _hoverController.reverse(),
        cursor:
            isDisabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
        child: SizedBox(
          height: widget.size.height,
          child: Material(
            color: Colors.transparent,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Animated Background/Lines Layer
                AnimatedBuilder(
                  animation: Listenable.merge(
                      [_hoverController, _loadingController, _flashController]),
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _CyberButtonPainter(
                        variant: widget.variant,
                        size: widget.size,
                        palette: palette,
                        hoverValue: _hoverController.value,
                        loadingValue: _loadingController.value,
                        flashValue: _flashController.value,
                        isLoading: widget.isLoading,
                      ),
                    );
                  },
                ),

                // Label & Icon Layer
                IgnorePointer(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: widget.size.horizontalPadding),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null && !widget.isLoading) ...[
                            Icon(
                              widget.icon,
                              size: widget.size.iconSize,
                              color: palette.label,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.label.toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'GoogleSans',
                              fontWeight: FontWeight.w600,
                              fontSize: widget.size.fontSize,
                              color: palette.label,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Material Inkwell for ripple effect
                Positioned.fill(
                  child: InkWell(
                    onTap: isDisabled ? null : _handleTap,
                    splashColor: const Color(0xFF311B92).withValues(alpha: 0.3),
                    highlightColor: Colors.transparent,
                    customBorder:
                        _CyberButtonShape(cornerCut: widget.size.cornerCut),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _CyberPalette _resolvePalette(CyberButtonVariant variant, bool disabled) {
    if (disabled) {
      return const _CyberPalette(
        border: Color(0xFF424242),
        accent: Color(0xFF757575),
        corner: Color(0xFF9E9E9E),
        background: Color(0xFF121212),
        label: Color(0xFF9E9E9E),
      );
    }
    return switch (variant) {
      CyberButtonVariant.primary => const _CyberPalette(
          border: Color(0xFF311B92), // Deep Purple 900
          accent: Color(0xFF00BCD4), // Cyan
          corner: Color(0xFFFFC107), // Gold
          background: Color(0xFF0D0221), // Deepest Purple
          label: Colors.white,
        ),
      CyberButtonVariant.secondary => const _CyberPalette(
          border: Color(0xFFFFC107), // Gold
          accent: Color(0xFFFFC107),
          corner: Color(0xFF00BCD4), // Cyan
          background: Color(0xFF1A1A1A),
          label: Colors.white,
        ),
      CyberButtonVariant.tertiary => const _CyberPalette(
          border: Color(0xFF311B92),
          accent: Color(0xFF7C4DFF),
          corner: Color(0xFF00BCD4),
          background: Colors.transparent,
          label: Colors.white,
        ),
    };
  }
}

class _CyberPalette {
  const _CyberPalette({
    required this.border,
    required this.accent,
    required this.corner,
    required this.background,
    required this.label,
  });

  final Color border;
  final Color accent;
  final Color corner;
  final Color background;
  final Color label;
}

class _CyberButtonPainter extends CustomPainter {
  _CyberButtonPainter({
    required this.variant,
    required this.size,
    required this.palette,
    required this.hoverValue,
    required this.loadingValue,
    required this.flashValue,
    required this.isLoading,
  });

  final CyberButtonVariant variant;
  final CyberButtonSize size;
  final _CyberPalette palette;
  final double hoverValue;
  final double loadingValue;
  final double flashValue;
  final bool isLoading;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final cut = size.cornerCut;
    final w = canvasSize.width;
    final h = canvasSize.height;

    final borderPath = Path()
      ..moveTo(cut, 0)
      ..lineTo(w - cut, 0)
      ..lineTo(w, cut)
      ..lineTo(w, h - cut)
      ..lineTo(w - cut, h)
      ..lineTo(cut, h)
      ..lineTo(0, h - cut)
      ..lineTo(0, cut)
      ..close();

    // Fill
    final fillPaint = Paint()
      ..color = palette.background.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    canvas.drawPath(borderPath, fillPaint);

    // Border
    final borderPaint = Paint()
      ..color = palette.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.lineThickness;
    canvas.drawPath(borderPath, borderPaint);

    // Horizontal Stripes
    _paintStripes(canvas, canvasSize, cut);

    // Side Bars
    _paintSideBars(canvas, canvasSize);

    // Corner Brackets
    _paintBrackets(canvas, canvasSize, cut);

    // Loading Animation
    if (isLoading) {
      _paintLoading(canvas, canvasSize);
    }

    // Flash Effect
    if (flashValue > 0) {
      final flashPaint = Paint()
        ..color = palette.accent.withValues(alpha: 0.4 * (1 - flashValue))
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.lineThickness * 2;
      canvas.drawPath(borderPath, flashPaint);
    }
  }

  void _paintStripes(Canvas canvas, Size canvasSize, double cut) {
    final stripePaint = Paint()
      ..color = palette.accent
          .withValues(alpha: 0.1 + 0.1 * hoverValue + 0.3 * flashValue)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final gap = size.lineGap;
    for (double y = gap; y < canvasSize.height - gap; y += gap) {
      // Calculate horizontal bounds based on the cut corners
      double startX = 0;
      double endX = canvasSize.width;

      if (y < cut) {
        startX = cut - y;
        endX = canvasSize.width - (cut - y);
      } else if (y > canvasSize.height - cut) {
        final diff = y - (canvasSize.height - cut);
        startX = diff;
        endX = canvasSize.width - diff;
      }

      // FUI style: don't draw full line, make it more technological
      const dashWidth = 8.0;
      const dashGap = 4.0;
      for (double x = startX + 4; x < endX - 4; x += dashWidth + dashGap) {
        canvas.drawLine(Offset(x, y),
            Offset(math.min(x + dashWidth, endX - 4), y), stripePaint);
      }
    }
  }

  void _paintSideBars(Canvas canvas, Size canvasSize) {
    final barWidth = size.lineThickness * 1.5;
    final barPaint = Paint()
      ..color = palette.border
      ..style = PaintingStyle.fill;

    const barHeight = 12.0;
    final yPos = (canvasSize.height - barHeight) / 2;

    // Left Bar
    canvas.drawRect(Rect.fromLTWH(0, yPos, barWidth, barHeight), barPaint);
    // Right Bar
    canvas.drawRect(
        Rect.fromLTWH(canvasSize.width - barWidth, yPos, barWidth, barHeight),
        barPaint);

    // Periodic dots
    final dotPaint = Paint()
      ..color = palette.accent
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(barWidth / 2, yPos - 4), 1.5, dotPaint);
    canvas.drawCircle(
        Offset(barWidth / 2, yPos + barHeight + 4), 1.5, dotPaint);
    canvas.drawCircle(
        Offset(canvasSize.width - barWidth / 2, yPos - 4), 1.5, dotPaint);
    canvas.drawCircle(
        Offset(canvasSize.width - barWidth / 2, yPos + barHeight + 4),
        1.5,
        dotPaint);
  }

  void _paintBrackets(Canvas canvas, Size canvasSize, double cut) {
    final bracketPaint = Paint()
      ..color = palette.corner
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.lineThickness;

    const len = 8.0;

    // Top Left (⌐)
    canvas.drawLine(const Offset(0, 0), const Offset(len, 0), bracketPaint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, len), bracketPaint);

    // Top Right (¬)
    canvas.drawLine(Offset(canvasSize.width, 0),
        Offset(canvasSize.width - len, 0), bracketPaint);
    canvas.drawLine(Offset(canvasSize.width, 0), Offset(canvasSize.width, len),
        bracketPaint);

    // Bottom Left (⌞)
    canvas.drawLine(Offset(0, canvasSize.height),
        Offset(len, canvasSize.height), bracketPaint);
    canvas.drawLine(Offset(0, canvasSize.height),
        Offset(0, canvasSize.height - len), bracketPaint);

    // Bottom Right (⌟)
    canvas.drawLine(Offset(canvasSize.width, canvasSize.height),
        Offset(canvasSize.width - len, canvasSize.height), bracketPaint);
    canvas.drawLine(Offset(canvasSize.width, canvasSize.height),
        Offset(canvasSize.width, canvasSize.height - len), bracketPaint);
  }

  void _paintLoading(Canvas canvas, Size canvasSize) {
    canvas.save();
    canvas.translate(canvasSize.width / 2, canvasSize.height / 2);
    canvas.rotate(loadingValue * 2 * math.pi);

    final paint = Paint()
      ..color = palette.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: 10),
      0,
      math.pi / 2,
      false,
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CyberButtonPainter oldDelegate) {
    return oldDelegate.hoverValue != hoverValue ||
        oldDelegate.loadingValue != loadingValue ||
        oldDelegate.flashValue != flashValue ||
        oldDelegate.isLoading != isLoading ||
        oldDelegate.variant != variant ||
        oldDelegate.palette != palette;
  }
}

class _CyberButtonShape extends ShapeBorder {
  const _CyberButtonShape({required this.cornerCut});
  final double cornerCut;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect, textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final cut = cornerCut;
    return Path()
      ..moveTo(rect.left + cut, rect.top)
      ..lineTo(rect.right - cut, rect.top)
      ..lineTo(rect.right, rect.top + cut)
      ..lineTo(rect.right, rect.bottom - cut)
      ..lineTo(rect.right - cut, rect.bottom)
      ..lineTo(rect.left + cut, rect.bottom)
      ..lineTo(rect.left, rect.bottom - cut)
      ..lineTo(rect.left, rect.top + cut)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => _CyberButtonShape(cornerCut: cornerCut * t);
}
