import 'package:flutter/material.dart';

/// Modern vibrant color scheme for Memory Jar
/// Replacing warm amber tones with a fresh, modern palette
class AppColors {
  AppColors._();

  // ============================================
  // PRIMARY COLORS - Modern Indigo
  // ============================================
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryContainer = Color(0xFFE0E7FF);
  static const Color onPrimary = Colors.white;
  static const Color onPrimaryContainer = Color(0xFF3730A3);

  // ============================================
  // SECONDARY COLORS - Vibrant Teal
  // ============================================
  static const Color secondary = Color(0xFF14B8A6);
  static const Color secondaryLight = Color(0xFF2DD4BF);
  static const Color secondaryDark = Color(0xFF0D9488);
  static const Color secondaryContainer = Color(0xFFCCFBF1);
  static const Color onSecondary = Colors.white;
  static const Color onSecondaryContainer = Color(0xFF115E59);

  // ============================================
  // ACCENT COLORS
  // ============================================
  static const Color accentPink = Color(0xFFF472B6);
  static const Color accentPurple = Color(0xFFA78BFA);
  static const Color accentBlue = Color(0xFF60A5FA);
  static const Color accentGreen = Color(0xFF34D399);
  static const Color accentOrange = Color(0xFFFB923C);
  static const Color accentYellow = Color(0xFFFBBF24);
  static const Color accentCyan = Color(0xFF22D3EE);
  static const Color accentRose = Color(0xFFFB7185);

  // ============================================
  // JAR TYPE COLORS
  // ============================================
  static const Color jarPersonal = Color(0xFF8B5CF6);      // Violet
  static const Color jarFamily = Color(0xFFF472B6);         // Pink
  static const Color jarFriends = Color(0xFF06B6D4);        // Cyan
  static const Color jarWork = Color(0xFF3B82F6);           // Blue
  static const Color jarCustom = Color(0xFF6366F1);         // Primary

  // ============================================
  // BACKGROUND COLORS - Light Mode
  // ============================================
  static const Color backgroundLight = Color(0xFFFAFAFC);
  static const Color surfaceLight = Colors.white;
  static const Color cardLight = Colors.white;
  
  // Aliases for backward compatibility
  static const Color background = backgroundLight;
  static const Color backgroundSecondary = Color(0xFFF1F5F9);
  static const Color surface = surfaceLight;
  static const Color card = cardLight;
  
  // Text color aliases
  static const Color textPrimary = textPrimaryLight;
  static const Color textSecondary = textSecondaryLight;
  static const Color textTertiary = textTertiaryLight;

  // ============================================
  // BACKGROUND COLORS - Dark Mode
  // ============================================
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF334155);

  // ============================================
  // TEXT COLORS - Light Mode
  // ============================================
  static const Color textPrimaryLight = Color(0xFF1E293B);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textTertiaryLight = Color(0xFF94A3B8);
  static const Color textDisabledLight = Color(0xFFCBD5E1);

  // ============================================
  // TEXT COLORS - Dark Mode
  // ============================================
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textTertiaryDark = Color(0xFF64748B);
  static const Color textDisabledDark = Color(0xFF475569);

  // ============================================
  // STATUS COLORS
  // ============================================
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // ============================================
  // MOOD COLORS
  // ============================================
  static const Color moodJoyful = Color(0xFFFBBF24);
  static const Color moodPeaceful = Color(0xFF14B8A6);
  static const Color moodGrateful = Color(0xFFF472B6);
  static const Color moodNostalgic = Color(0xFFA78BFA);
  static const Color moodExcited = Color(0xFFFB923C);
  static const Color moodReflective = Color(0xFF60A5FA);

  // ============================================
  // GRADIENT PRESETS
  // ============================================
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary, primaryDark],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryLight, secondary, secondaryDark],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentPink, accentPurple],
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentOrange, accentPink, accentPurple],
  );

  static const LinearGradient oceanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentCyan, accentBlue, primary],
  );

  static const LinearGradient forestGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentGreen, secondary, secondaryDark],
  );

  static const LinearGradient backgroundGradientLight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundLight, Color(0xFFF1F5F9)],
  );

  static const LinearGradient backgroundGradientDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundDark, Color(0xFF1E293B)],
  );

  // ============================================
  // ONBOARDING PAGE GRADIENTS
  // ============================================
  static const LinearGradient onboardingGradient1 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
  );

  static const LinearGradient onboardingGradient2 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF472B6), Color(0xFFFB7185)],
  );

  static const LinearGradient onboardingGradient3 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF14B8A6), Color(0xFF06B6D4)],
  );

  static const LinearGradient onboardingGradient4 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
  );

  static const LinearGradient onboardingGradient5 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFA78BFA), Color(0xFFC4B5FD)],
  );

  // ============================================
  // GLASS EFFECT COLORS
  // ============================================
  static Color glassWhite = Colors.white.withOpacity(0.15);
  static Color glassWhiteBorder = Colors.white.withOpacity(0.25);
  static Color glassDark = Colors.black.withOpacity(0.15);
  static Color glassDarkBorder = Colors.white.withOpacity(0.1);

  // ============================================
  // HELPER METHODS
  // ============================================
  static Color getJarColor(String jarType) {
    switch (jarType.toLowerCase()) {
      case 'personal':
        return jarPersonal;
      case 'family':
        return jarFamily;
      case 'friends':
        return jarFriends;
      case 'work':
        return jarWork;
      default:
        return jarCustom;
    }
  }

  static Color getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'joyful':
        return moodJoyful;
      case 'peaceful':
        return moodPeaceful;
      case 'grateful':
        return moodGrateful;
      case 'nostalgic':
        return moodNostalgic;
      case 'excited':
        return moodExcited;
      case 'reflective':
        return moodReflective;
      default:
        return primary;
    }
  }
}

/// Color scheme extension for dark mode support
class AppColorScheme {
  final bool isDark;

  AppColorScheme({this.isDark = false});

  Color get primary => AppColors.primary;
  Color get primaryLight => AppColors.primaryLight;
  Color get primaryDark => AppColors.primaryDark;
  Color get secondary => AppColors.secondary;
  
  Color get background => isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
  Color get surface => isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
  Color get card => isDark ? AppColors.cardDark : AppColors.cardLight;
  
  Color get textPrimary => isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
  Color get textSecondary => isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
  Color get textTertiary => isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;
  Color get textDisabled => isDark ? AppColors.textDisabledDark : AppColors.textDisabledLight;

  LinearGradient get backgroundGradient => 
    isDark ? AppColors.backgroundGradientDark : AppColors.backgroundGradientLight;

  Color get glassColor => isDark ? AppColors.glassDark : AppColors.glassWhite;
  Color get glassBorder => isDark ? AppColors.glassDarkBorder : AppColors.glassWhiteBorder;
}
