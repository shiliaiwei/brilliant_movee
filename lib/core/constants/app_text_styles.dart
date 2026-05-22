import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography system for Brilliant Movee.
/// Uses google_fonts for Space Grotesk, Inter, and JetBrains Mono.
/// All text styles are tokens — never use raw TextStyle outside this file.
abstract final class AppTextStyles {
  // ── Display — Space Grotesk 700 32sp ─────────────────────────────────────
  static TextStyle get display => GoogleFonts.spaceGrotesk(
        fontWeight: FontWeight.w700,
        fontSize: 32,
        letterSpacing: 0.5,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  // ── Headline — Space Grotesk 600 24sp ────────────────────────────────────
  static TextStyle get headline => GoogleFonts.spaceGrotesk(
        fontWeight: FontWeight.w600,
        fontSize: 24,
        letterSpacing: 0.2,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  // ── Title — Inter 600 18sp ───────────────────────────────────────────────
  static TextStyle get title => GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 18,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  // ── Body — Inter 400 14sp ────────────────────────────────────────────────
  static TextStyle get body => GoogleFonts.inter(
        fontWeight: FontWeight.w400,
        fontSize: 14,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontWeight: FontWeight.w500,
        fontSize: 14,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  // ── Label — JetBrains Mono 500 12sp ─────────────────────────────────────
  static TextStyle get label => GoogleFonts.jetBrainsMono(
        fontWeight: FontWeight.w500,
        fontSize: 12,
        color: AppColors.textPrimary,
        height: 1.4,
        letterSpacing: 0.5,
      );

  // ── Caption — Inter 400 11sp ─────────────────────────────────────────────
  static TextStyle get caption => GoogleFonts.inter(
        fontWeight: FontWeight.w400,
        fontSize: 11,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  // ── Badge — Space Grotesk 700 10sp ───────────────────────────────────────
  static TextStyle get badge => GoogleFonts.spaceGrotesk(
        fontWeight: FontWeight.w700,
        fontSize: 10,
        letterSpacing: 0.8,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  // ── Mono large — for eval/notation display ───────────────────────────────
  static TextStyle get monoLarge => GoogleFonts.jetBrainsMono(
        fontWeight: FontWeight.w700,
        fontSize: 20,
        color: AppColors.textPrimary,
        letterSpacing: 1.0,
      );

  static TextStyle get monoSmall => GoogleFonts.jetBrainsMono(
        fontWeight: FontWeight.w400,
        fontSize: 11,
        color: AppColors.textSecondary,
        letterSpacing: 0.3,
      );

  // ── App name / brand ─────────────────────────────────────────────────────
  static TextStyle get appName => GoogleFonts.spaceGrotesk(
        fontWeight: FontWeight.w700,
        fontSize: 28,
        letterSpacing: 4.0,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get tagline => GoogleFonts.jetBrainsMono(
        fontWeight: FontWeight.w400,
        fontSize: 13,
        letterSpacing: 2.0,
        color: AppColors.primary,
        height: 1.4,
      );

  // ── Muted variants ───────────────────────────────────────────────────────
  static TextStyle get bodyMuted => body.copyWith(color: AppColors.textSecondary);
  static TextStyle get captionPrimary => caption.copyWith(color: AppColors.primary);
  static TextStyle get labelMuted => label.copyWith(color: AppColors.textSecondary);
}
