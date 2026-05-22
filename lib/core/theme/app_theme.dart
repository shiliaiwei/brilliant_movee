import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_spacing.dart';

/// Builds the Material 3 dark theme for Brilliant Movee.
/// All values are derived from design tokens — no raw values here.
abstract final class AppTheme {
  static ThemeData get darkTheme {
    final colorScheme = AppColors.m3DarkScheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,

      // ── Scaffold ──────────────────────────────────────────────────────────
      scaffoldBackgroundColor: AppColors.backgroundDeep,

      // ── AppBar ────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundDeep,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.headline,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppColors.backgroundDeep,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 24),
      ),

      // ── Bottom Navigation ─────────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.backgroundSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
          fontSize: 11,
        ),
      ),

      // ── Card ──────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.backgroundSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: AppColors.primaryBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Elevated Button ───────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.backgroundDeep,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          textStyle: AppTextStyles.bodyMedium.copyWith(
            fontFamily: 'SpaceGrotesk',
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
          elevation: 0,
        ),
      ),

      // ── Text Button ───────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(48, 48),
          textStyle: AppTextStyles.bodyMedium,
        ),
      ),

      // ── Input Decoration ──────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundElevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primaryBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primaryBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        labelStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
      ),

      // ── Chip ──────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.backgroundElevated,
        selectedColor: AppColors.primaryGlow,
        labelStyle: AppTextStyles.label,
        side: const BorderSide(color: AppColors.primaryBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // ── Bottom Sheet ──────────────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.backgroundSurface,
        modalBackgroundColor: AppColors.backgroundSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.sheet),
          ),
        ),
        dragHandleColor: AppColors.textSecondary,
        dragHandleSize: Size(40, 4),
        showDragHandle: true,
      ),

      // ── Snack Bar ─────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.backgroundElevated,
        contentTextStyle: AppTextStyles.body,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ── Slider ────────────────────────────────────────────────────────────
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.backgroundElevated,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primaryGlow,
        valueIndicatorColor: AppColors.backgroundElevated,
        valueIndicatorTextStyle: TextStyle(
          fontFamily: 'JetBrainsMono',
          color: AppColors.textPrimary,
          fontSize: 12,
        ),
      ),

      // ── Switch ────────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryGlow;
          }
          return AppColors.backgroundElevated;
        }),
      ),

      // ── Text Theme ────────────────────────────────────────────────────────
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),

      // ── Icon ──────────────────────────────────────────────────────────────
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: 24,
      ),
    );
  }
}
