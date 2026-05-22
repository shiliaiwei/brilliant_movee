import 'package:flutter/material.dart';

/// Aurora Obsidian color palette for Brilliant Movee.
/// All colors are tokens — never use raw hex values outside this file.
abstract final class AppColors {
  // ── Backgrounds ──────────────────────────────────────────────────────────
  static const Color backgroundDeep = Color(0xFF080C10);     // Void Black
  static const Color backgroundSurface = Color(0xFF0E1620);  // Abyss
  static const Color backgroundElevated = Color(0xFF141F2E); // Slate Glass

  // ── Primary ──────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF00E5C3);            // Biolume Teal
  static const Color primaryDim = Color(0xFF00A88D);         // Deep Teal
  static const Color primaryGlow = Color(0x4000E5C3);        // Teal glow 25%
  static const Color primaryBorder = Color(0x1A00E5C3);      // Teal border 10%

  // ── Secondary / Accent ───────────────────────────────────────────────────
  static const Color secondary = Color(0xFF7B5EFF);          // Aurora Violet
  static const Color tertiary = Color(0xFF39FF6A);           // Forest Pulse

  // ── Move Quality ─────────────────────────────────────────────────────────
  static const Color brilliant = Color(0xFFFFD700);          // Gold Prism
  static const Color brilliantGlow = Color(0x80FFD700);
  static const Color great = Color(0xFF00C97A);              // Emerald
  static const Color good = Color(0xFF4CAF50);               // Light Green
  static const Color book = Color(0xFF4FC3F7);               // Sky Rune
  static const Color inaccuracy = Color(0xFFFFB830);         // Amber
  static const Color mistake = Color(0xFFFF6B35);            // Ember
  static const Color blunder = Color(0xFFFF2D55);            // Crimson Pulse
  static const Color miss = Color(0xFF9C27B0);               // Purple

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFE8F4F0);        // Ice White
  static const Color textSecondary = Color(0xFF6B8A9A);      // Fog
  static const Color textDisabled = Color(0xFF3A4F5C);

  // ── Semantic ─────────────────────────────────────────────────────────────
  static const Color win = Color(0xFF39FF6A);
  static const Color loss = Color(0xFFFF2D55);
  static const Color draw = Color(0xFF6B8A9A);
  static const Color warning = Color(0xFFFF6B35);
  static const Color error = Color(0xFFFF2D55);
  static const Color success = Color(0xFF00E5C3);

  // ── Board ────────────────────────────────────────────────────────────────
  static const Color boardHighlightFrom = Color(0x8000E5C3);
  static const Color boardHighlightTo = Color(0x6000E5C3);
  static const Color boardArrow = Color(0xCC00E5C3);
  static const Color boardArrowBest = Color(0xCC7B5EFF);

  // ── Gradients ────────────────────────────────────────────────────────────
  static const List<Color> heroGradient = [
    Color(0xFF080C10),
    Color(0xFF0D1F1A),
  ];

  static const List<Color> ctaGradient = [
    Color(0xFF00E5C3),
    Color(0xFF7B5EFF),
  ];

  static const List<Color> winGradient = [
    Color(0xFF39FF6A),
    Color(0xFF00E5C3),
    Color(0xFF7B5EFF),
  ];

  static const List<Color> loseGradient = [
    Color(0xFF1A0A0A),
    Color(0xFF2D0F0F),
  ];

  static const List<Color> evalWhiteGradient = [
    Color(0xFFE8F4F0),
    Color(0xFF6B8A9A),
  ];

  static const List<Color> evalBlackGradient = [
    Color(0xFF141F2E),
    Color(0xFF080C10),
  ];

  // ── Overlay / Glass ──────────────────────────────────────────────────────
  static const Color glassOverlay = Color(0x1A00E5C3);
  static const Color scrim = Color(0xCC080C10);
  static const Color divider = Color(0x1A6B8A9A);

  // ── M3 ColorScheme seed (used for Material widgets) ──────────────────────
  static ColorScheme get m3DarkScheme => ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
      ).copyWith(
        surface: backgroundSurface,
        onSurface: textPrimary,
        primary: primary,
        onPrimary: backgroundDeep,
        secondary: secondary,
        onSecondary: textPrimary,
        tertiary: tertiary,
        error: error,
        onError: textPrimary,
        surfaceContainerHighest: backgroundElevated,
        outline: primaryBorder,
      );
}
