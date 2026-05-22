import 'package:flutter/material.dart';

/// Premium White color palette for Brilliant Movee.
/// All colors are tokens — never use raw hex values outside this file.
abstract final class AppColors {
  // ── Backgrounds ──────────────────────────────────────────────────────────
  static const Color backgroundDeep = Color(0xFFFFFFFF); // Pure White
  static const Color backgroundSurface = Color(0xFFF8FAFB); // Off White
  static const Color backgroundElevated = Color(0xFFF0F4F7); // Light Grey

  // ── Primary ──────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF00BFA5); // Premium Teal
  static const Color primaryDim = Color(0xFF00897B);
  static const Color primaryGlow = Color(0x1A00BFA5); // 10% opacity
  static const Color primaryBorder = Color(0x1F00BFA5); // 12% opacity

  // ── Secondary / Accent ───────────────────────────────────────────────────
  static const Color secondary = Color(0xFF6200EE); // Premium Purple
  static const Color tertiary = Color(0xFF00C853); // Success Green

  // ── Move Quality ─────────────────────────────────────────────────────────
  static const Color brilliant = Color(0xFFE9B200); // Premium Gold
  static const Color brilliantGlow = Color(0x33E9B200);
  static const Color great = Color(0xFF009688);
  static const Color good = Color(0xFF43A047);
  static const Color book = Color(0xFF0288D1);
  static const Color inaccuracy = Color(0xFFF57C00);
  static const Color mistake = Color(0xFFE64A19);
  static const Color blunder = Color(0xFFD32F2F);
  static const Color miss = Color(0xFF8E24AA);

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1C1E); // Near Black
  static const Color textSecondary = Color(0xFF44474E); // Grey
  static const Color textDisabled = Color(0xFFC4C7CF);

  // ── Semantic ─────────────────────────────────────────────────────────────
  static const Color win = Color(0xFF00C853);
  static const Color loss = Color(0xFFD32F2F);
  static const Color draw = Color(0xFF74777F);
  static const Color warning = Color(0xFFF57C00);
  static const Color error = Color(0xFFBA1A1A);
  static const Color success = Color(0xFF00BFA5);

  // ── Board ────────────────────────────────────────────────────────────────
  static const Color boardHighlightFrom = Color(0x4D00BFA5);
  static const Color boardHighlightTo = Color(0x3300BFA5);
  static const Color boardArrow = Color(0xB300BFA5);
  static const Color boardArrowBest = Color(0xB36200EE);

  // ── Gradients (Simplified/Solid equivalents) ─────────────────────────────
  static const List<Color> heroGradient = [
    Color(0xFFFFFFFF),
    Color(0xFFF8FAFB),
  ];

  static const List<Color> ctaGradient = [
    Color(0xFF00BFA5),
    Color(0xFF00BFA5), // No more gradient
  ];

  static const List<Color> winGradient = [
    Color(0xFF00C853),
    Color(0xFF00C853),
  ];

  static const List<Color> loseGradient = [
    Color(0xFFFDF7F7),
    Color(0xFFFDF7F7),
  ];

  static const List<Color> evalWhiteGradient = [
    Color(0xFFFFFFFF),
    Color(0xFFE1E2E4),
  ];

  static const List<Color> evalBlackGradient = [
    Color(0xFF44474E),
    Color(0xFF1A1C1E),
  ];

  // ── Overlay / Glass ──────────────────────────────────────────────────────
  static const Color glassOverlay = Color(0x0D00BFA5);
  static const Color scrim = Color(0x80000000);
  static const Color divider = Color(0xFFE1E2E4);

  // ── M3 ColorScheme ───────────────────────────────────────────────────────
  static ColorScheme get m3LightScheme => ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ).copyWith(
        surface: backgroundSurface,
        onSurface: textPrimary,
        primary: primary,
        onPrimary: Colors.white,
        secondary: secondary,
        onSecondary: Colors.white,
        tertiary: tertiary,
        error: error,
        onError: Colors.white,
        surfaceContainerHighest: backgroundElevated,
        outline: divider,
      );
}
