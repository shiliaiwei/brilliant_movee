import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography system for Brilliant Movee.
/// Inherits font family from Theme (GoogleSans or StackSansNotch).
abstract final class AppTextStyles {
  // ── Display ─────────────────────────────────────────────────────────────
  static TextStyle get display => const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 32,
        letterSpacing: -0.5,
        color: AppColors.textPrimary,
        height: 1.1,
      );

  // ── Headline ────────────────────────────────────────────────────────────
  static TextStyle get headline => const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 24,
        letterSpacing: -0.2,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  // ── Title ───────────────────────────────────────────────────────────────
  static TextStyle get title => const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 18,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  // ── Body ────────────────────────────────────────────────────────────────
  static TextStyle get body => const TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 14,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodyMedium => const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 14,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  // ── Label ───────────────────────────────────────────────────────────────
  static TextStyle get label => const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 12,
        color: AppColors.textPrimary,
        height: 1.4,
        letterSpacing: 0.1,
      );

  // ── Caption ─────────────────────────────────────────────────────────────
  static TextStyle get caption => const TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 11,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  // ── Badge ───────────────────────────────────────────────────────────────
  static TextStyle get badge => const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 10,
        letterSpacing: 0.5,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  // ── Mono large ──────────────────────────────────────────────────────────
  static TextStyle get monoLarge => const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 20,
        color: AppColors.textPrimary,
        letterSpacing: 0.5,
      );

  static TextStyle get monoSmall => const TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 11,
        color: AppColors.textSecondary,
        letterSpacing: 0.1,
      );

  // ── App name / brand ─────────────────────────────────────────────────────
  static TextStyle get appName => const TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 28,
        letterSpacing: -1.0,
        color: AppColors.textPrimary,
        height: 1.1,
      );

  static TextStyle get tagline => const TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 13,
        letterSpacing: 0.5,
        color: AppColors.primary,
        height: 1.4,
      );

  // ── Muted variants ───────────────────────────────────────────────────────
  static TextStyle get bodyMuted =>
      body.copyWith(color: AppColors.textSecondary);
  static TextStyle get captionPrimary =>
      caption.copyWith(color: AppColors.primary);
  static TextStyle get labelMuted =>
      label.copyWith(color: AppColors.textSecondary);
}
