import 'package:flutter/material.dart';

class AppColors {
  // Primary Warm Palette
  static const Color primary = Color(0xFFE67E22);      // Warm Amber
  static const Color primaryLight = Color(0xFFF39C12); // Light Amber
  static const Color primaryDark = Color(0xFFD35400);  // Deep Amber
  
  // Accent Colors
  static const Color accent = Color(0xFF9B59B6);       // Soft Purple
  static const Color secondary = Color(0xFF3498DB);    // Sky Blue
  static const Color accentPurple = Color(0xFF9B59B6);
  static const Color accentBlue = Color(0xFF3498DB);
  static const Color accentGreen = Color(0xFF27AE60);
  static const Color accentOrange = Color(0xFFFF6B35);
  
  // Background Colors (Light Mode)
  static const Color backgroundLight = Color(0xFFFDF6F0);     // Warm Cream
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFBF7);
  
  // Background Colors (Dark Mode)
  static const Color backgroundDark = Color(0xFF1A1A2E);
  static const Color surfaceDark = Color(0xFF16213E);
  static const Color cardDark = Color(0xFF0F3460);
  
  // Text Colors
  static const Color textPrimaryLight = Color(0xFF2C3E50);
  static const Color textSecondaryLight = Color(0xFF7F8C8D);
  static const Color textPrimaryDark = Color(0xFFF5F5F5);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  
  // Mood Colors
  static const Map<String, Color> moodColors = {
    '😊': Color(0xFFFFE66D),  // Happy - Yellow
    '🥰': Color(0xFFFF6B9D),  // Loving - Pink
    '😌': Color(0xFF4ECDC4),  // Peaceful - Teal
    '🎉': Color(0xFFFF6B35),  // Excited - Orange
    '🙏': Color(0xFFA8E6CF),  // Grateful - Mint
    '😢': Color(0xFF74B9FF),  // Sad - Light Blue
    '😤': Color(0xFFFF7675),  // Frustrated - Coral
    '🤔': Color(0xFFDFE6E9),  // Thoughtful - Gray
    '😴': Color(0xFFB8B5FF),  // Tired - Lavender
    '🌟': Color(0xFFFFD93D),  // Proud - Gold
  };
  
  // Glass Effect Colors
  static const Color glassLight = Color(0x40FFFFFF);
  static const Color glassDark = Color(0x20FFFFFF);
  static const Color glassBorder = Color(0x30FFFFFF);
  
  // Status Colors
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);
}

class GlassConstants {
  static const double blurSigma = 10.0;
  static const double borderRadius = 20.0;
  static const double borderWidth = 1.5;
  
  static final LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withOpacity(0.25),
      Colors.white.withOpacity(0.10),
    ],
  );
  
  static final LinearGradient darkGlassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withOpacity(0.15),
      Colors.white.withOpacity(0.05),
    ],
  );
}
