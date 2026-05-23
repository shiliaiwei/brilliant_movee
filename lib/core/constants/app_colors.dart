import 'package:flutter/material.dart';

/// Obsidian Pure Black / GitHub-Vercel High Contrast palette for Stupid Brilliant.
abstract final class AppColors {
  // ── Backgrounds ──────────────────────────────────────────────────────────
  static const Color backgroundDeep = Color(0xFF000000); // Base (Pure Black)
  static const Color backgroundSurface = Color(0xFF111111); // Panels (Color 1)
  static const Color backgroundElevated = Color(0xFF161616); // Deep grey

  // ── Component States (Requested Colors 1–3) ─────────────────────────────
  static const Color color1 = Color(0xFF111111); // Default background
  static const Color color2 = Color(0xFF222222); // Hover background
  static const Color color3 = Color(0xFF333333); // Active background

  // ── High Contrast (Requested Colors 7–8) ────────────────────────────────
  static const Color color7 = Color(0xFFEDEDED); // High contrast background
  static const Color color8 = Color(0xFFFFFFFF); // Hover high contrast

  // ── Text & Icons (Requested Colors 9–10) ────────────────────────────────
  static const Color color9 = Color(0xFF999999); // Secondary text and icons
  static const Color color10 = Color(0xFFEDEDED); // Primary text and icons

  // ── Semantic & Aliases ──────────────────────────────────────────────────
  static const Color primary = Color(0xFF00BFA5);
  static const Color secondary = Color(0xFF222222);
  static const Color tertiary = Color(0xFF333333);

  static const Color textPrimary = color10;
  static const Color textSecondary = color9;
  static const Color textDisabled = Color(0xFF444444);

  // ── Move Quality ─────────────────────────────────────────────────────────
  static const Color brilliant = Color(0xFFE9B200);
  static const Color great = Color(0xFF009688);
  static const Color best = Color(0xFF00BFA5);
  static const Color good = Color(0xFF43A047);
  static const Color book = Color(0xFF0288D1);
  static const Color inaccuracy = Color(0xFFF57C00);
  static const Color mistake = Color(0xFFE64A19);
  static const Color blunder = Color(0xFFD32F2F);
  static const Color miss = Color(0xFF8E24AA);

  // ── Semantic Status ──────────────────────────────────────────────────────
  static const Color win = Color(0xFF00C853);
  static const Color loss = Color(0xFFD32F2F);
  static const Color draw = Color(0xFF999999);
  static const Color error = Color(0xFFBA1A1A);
  static const Color success = Color(0xFF00BFA5);

  // ── Board ────────────────────────────────────────────────────────────────
  static const Color boardHighlightFrom = Color(0x4000BFA5);
  static const Color boardHighlightTo = Color(0x6000BFA5);
  static const Color boardArrow = Color(0xCC00BFA5);
  static const Color boardArrowBest = Color(0xCC6200EE);

  static const List<Color> heroGradient = [
    Color(0xFF000000),
    Color(0xFF111111),
  ];

  static const List<Color> ctaGradient = [
    Color(0xFF00BFA5),
    Color(0xFF00BFA5),
  ];

  static const List<Color> winGradient = [
    Color(0xFF00C853),
    Color(0xFF00C853),
  ];

  static const List<Color> loseGradient = [
    Color(0xFF1A0A0A),
    Color(0xFF2D0F0F),
  ];

  static const List<Color> evalWhiteGradient = [
    Color(0xFFEDEDED),
    Color(0xFF999999),
  ];

  static const List<Color> evalBlackGradient = [
    Color(0xFF111111),
    Color(0xFF000000),
  ];

  static const Color divider = Color(0xFF222222);
  static const Color primaryGlow = Color(0x1A00BFA5);
  static const Color primaryBorder = Color(0xFF222222);
  static const Color scrim = Color(0xCC000000);
  static const Color glassOverlay = Color(0x0DFFFFFF);

  // ── M3 ColorScheme ───────────────────────────────────────────────────────
  static ColorScheme get m3DarkScheme => const ColorScheme.dark().copyWith(
        surface: backgroundDeep,
        onSurface: textPrimary,
        primary: primary,
        onPrimary: Colors.white,
        secondary: color2,
        onSecondary: textPrimary,
        surfaceContainerHighest: backgroundSurface,
        outline: color3,
      );
}
