import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography system for Stupid Brilliant.
/// Uses Inter for technical/general text, Roboto for labels, and Google Sans for Khmer.
abstract final class AppTextStyles {
  // ── Base configuration ──────────────────────────────────────────────────
  static const String khmerFontFamily = 'GoogleSans';

  // ── Display — Inter 700 32sp ─────────────────────────────────────────────
  static TextStyle get display => GoogleFonts.inter(
        fontWeight: FontWeight.w700,
        fontSize: 32,
        letterSpacing: -0.5,
        color: AppColors.textPrimary,
        height: 1.1,
      );

  // ── Headline — Inter 600 24sp ────────────────────────────────────────────
  static TextStyle get headline => GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 24,
        letterSpacing: -0.2,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  // ── Title — Inter 600 18sp ───────────────────────────────────────────────
  static TextStyle get title => GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 18,
        color: AppColors.textPrimary,
        height: 1.3,
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

  // ── Label — Roboto 500 12sp ──────────────────────────────────────────────
  static TextStyle get label => GoogleFonts.roboto(
        fontWeight: FontWeight.w500,
        fontSize: 12,
        color: AppColors.textPrimary,
        height: 1.4,
        letterSpacing: 0.1,
      );

  // ── Caption — Roboto 400 11sp ────────────────────────────────────────────
  static TextStyle get caption => GoogleFonts.roboto(
        fontWeight: FontWeight.w400,
        fontSize: 11,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  // ── Badge — Inter 700 10sp ───────────────────────────────────────────────
  static TextStyle get badge => GoogleFonts.inter(
        fontWeight: FontWeight.w700,
        fontSize: 10,
        letterSpacing: 0.5,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  // ── Mono large — Roboto Mono 700 20sp ────────────────────────────────────
  static TextStyle get monoLarge => GoogleFonts.robotoMono(
        fontWeight: FontWeight.w700,
        fontSize: 20,
        color: AppColors.textPrimary,
        letterSpacing: 0.5,
      );

  static TextStyle get monoSmall => GoogleFonts.robotoMono(
        fontWeight: FontWeight.w400,
        fontSize: 11,
        color: AppColors.textSecondary,
        letterSpacing: 0.1,
      );

  // ── App name / brand ─────────────────────────────────────────────────────
  static TextStyle get appName => GoogleFonts.inter(
        fontWeight: FontWeight.w800,
        fontSize: 28,
        letterSpacing: -1.0,
        color: AppColors.textPrimary,
        height: 1.1,
      );

  static TextStyle get tagline => GoogleFonts.roboto(
        fontWeight: FontWeight.w400,
        fontSize: 13,
        letterSpacing: 0.5,
        color: AppColors.primary,
        height: 1.4,
      );

  // ── Khmer Specific — Google Sans ─────────────────────────────────────────
  static TextStyle get khmerBody => const TextStyle(
        fontFamily: khmerFontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 14,
        color: AppColors.textPrimary,
      );

  // ── Muted variants ───────────────────────────────────────────────────────
  static TextStyle get bodyMuted =>
      body.copyWith(color: AppColors.textSecondary);
  static TextStyle get captionPrimary =>
      caption.copyWith(color: AppColors.primary);
  static TextStyle get labelMuted =>
      label.copyWith(color: AppColors.textSecondary);
}
