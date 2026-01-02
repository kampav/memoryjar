import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'color_schemes.dart';

/// App theme configuration with full dark mode support
class AppTheme {
  AppTheme._();

  // ============================================
  // TYPOGRAPHY
  // ============================================
  static const String fontFamily = 'SF Pro Display';

  static const TextTheme _textTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400, letterSpacing: -0.25),
    displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400),
    displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w400),
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.15),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
    labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5),
  );

  // ============================================
  // GLASS EFFECT CONSTANTS
  // ============================================
  static const double glassBlur = 12.0;
  static const double glassBorderRadius = 24.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;

  // ============================================
  // LIGHT THEME
  // ============================================
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Colors
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryContainer,
        onPrimary: AppColors.onPrimary,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondary: AppColors.onSecondary,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textPrimaryLight,
        error: AppColors.error,
        onError: Colors.white,
      ),
      
      scaffoldBackgroundColor: AppColors.backgroundLight,
      
      // App Bar
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimaryLight,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryLight,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Text Theme
      textTheme: _textTheme.apply(
        bodyColor: AppColors.textPrimaryLight,
        displayColor: AppColors.textPrimaryLight,
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonBorderRadius),
          borderSide: BorderSide(color: AppColors.textTertiaryLight.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonBorderRadius),
          borderSide: BorderSide(color: AppColors.textTertiaryLight.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonBorderRadius),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonBorderRadius),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondaryLight),
        hintStyle: TextStyle(color: AppColors.textTertiaryLight),
      ),
      
      // Card Theme
      cardTheme: const CardThemeData(
        color: AppColors.cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        margin: EdgeInsets.zero,
      ),
      
      // Dialog Theme
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.surfaceLight,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
      
      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceLight,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      
      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimaryLight,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonBorderRadius),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.textTertiaryLight;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryLight.withOpacity(0.5);
          }
          return AppColors.textDisabledLight;
        }),
      ),
      
      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      
      // List Tile Theme
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        iconColor: AppColors.textSecondaryLight,
      ),
      
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: AppColors.textDisabledLight.withOpacity(0.5),
        thickness: 1,
        space: 1,
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.textSecondaryLight,
        size: 24,
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
      
      // Page Transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // ============================================
  // DARK THEME
  // ============================================
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Colors
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        primaryContainer: AppColors.primaryDark,
        onPrimary: Colors.white,
        onPrimaryContainer: AppColors.primaryLight,
        secondary: AppColors.secondaryLight,
        secondaryContainer: AppColors.secondaryDark,
        onSecondary: Colors.white,
        onSecondaryContainer: AppColors.secondaryLight,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
        error: AppColors.error,
        onError: Colors.white,
      ),
      
      scaffoldBackgroundColor: AppColors.backgroundDark,
      
      // App Bar
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimaryDark,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Text Theme
      textTheme: _textTheme.apply(
        bodyColor: AppColors.textPrimaryDark,
        displayColor: AppColors.textPrimaryDark,
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: const BorderSide(color: AppColors.primaryLight, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonBorderRadius),
          borderSide: BorderSide(color: AppColors.textTertiaryDark.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonBorderRadius),
          borderSide: BorderSide(color: AppColors.textTertiaryDark.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonBorderRadius),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonBorderRadius),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondaryDark),
        hintStyle: TextStyle(color: AppColors.textTertiaryDark),
      ),
      
      // Card Theme
      cardTheme: const CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        margin: EdgeInsets.zero,
      ),
      
      // Dialog Theme
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.surfaceDark,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
      
      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceDark,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      
      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        contentTextStyle: const TextStyle(color: AppColors.textPrimaryDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonBorderRadius),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryLight;
          }
          return AppColors.textTertiaryDark;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withOpacity(0.5);
          }
          return AppColors.textDisabledDark;
        }),
      ),
      
      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryLight;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: AppColors.textSecondaryDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      
      // List Tile Theme
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        iconColor: AppColors.textSecondaryDark,
      ),
      
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: AppColors.textDisabledDark.withOpacity(0.3),
        thickness: 1,
        space: 1,
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.textSecondaryDark,
        size: 24,
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
      
      // Page Transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
