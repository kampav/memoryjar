import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/color_schemes.dart';
import '../../../../shared/widgets/glass_container.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1a1a2e), const Color(0xFF16213e)]
                : [AppColors.background, AppColors.backgroundSecondary],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Animated Background Elements
              Expanded(
                flex: 3,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Floating decorative elements
                    Positioned(
                      top: size.height * 0.05,
                      left: size.width * 0.1,
                      child: _buildFloatingEmoji('✨', 40)
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .moveY(begin: 0, end: -15, duration: 2000.ms)
                          .fadeIn(duration: 600.ms, delay: 200.ms),
                    ),
                    Positioned(
                      top: size.height * 0.08,
                      right: size.width * 0.15,
                      child: _buildFloatingEmoji('💫', 32)
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .moveY(begin: 0, end: 12, duration: 1800.ms)
                          .fadeIn(duration: 600.ms, delay: 400.ms),
                    ),
                    Positioned(
                      top: size.height * 0.2,
                      left: size.width * 0.05,
                      child: _buildFloatingEmoji('🌟', 28)
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .moveY(begin: 0, end: 10, duration: 2200.ms)
                          .fadeIn(duration: 600.ms, delay: 600.ms),
                    ),
                    Positioned(
                      top: size.height * 0.15,
                      right: size.width * 0.08,
                      child: _buildFloatingEmoji('💝', 36)
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .moveY(begin: 0, end: -12, duration: 1600.ms)
                          .fadeIn(duration: 600.ms, delay: 300.ms),
                    ),

                    // Main Jar Icon
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 40,
                                offset: const Offset(0, 20),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              '🫙',
                              style: TextStyle(fontSize: 80),
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 800.ms)
                            .scale(begin: const Offset(0.8, 0.8), duration: 800.ms, curve: Curves.easeOutBack),

                        const SizedBox(height: 32),

                        // App Name
                        GradientText(
                          text: 'Memory Jar',
                          gradient: AppColors.primaryGradient,
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1,
                          ),
                        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),

                        const SizedBox(height: 12),

                        // Tagline
                        Text(
                          'Capture life\'s precious moments',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: isDark ? Colors.white70 : AppColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ).animate().fadeIn(delay: 600.ms),
                      ],
                    ),
                  ],
                ),
              ),

              // Bottom Section
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Features List
                      _buildFeatureItem(
                        '📸',
                        'Capture memories with photos, text & voice',
                        isDark,
                      ).animate().fadeIn(delay: 700.ms).slideX(begin: -0.2),

                      const SizedBox(height: 12),

                      _buildFeatureItem(
                        '👨‍👩‍👧‍👦',
                        'Share special moments with family & friends',
                        isDark,
                      ).animate().fadeIn(delay: 800.ms).slideX(begin: -0.2),

                      const SizedBox(height: 12),

                      _buildFeatureItem(
                        '✨',
                        'AI-powered reflections on your journey',
                        isDark,
                      ).animate().fadeIn(delay: 900.ms).slideX(begin: -0.2),

                      const SizedBox(height: 40),

                      // Get Started Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => context.go('/login'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            shadowColor: AppColors.primary.withOpacity(0.4),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Get Started',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 1000.ms).scale(delay: 1000.ms),

                      const SizedBox(height: 16),

                      // Terms Notice
                      Text(
                        'By continuing, you agree to our Terms of Service\nand Privacy Policy',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white38 : AppColors.textTertiary,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 1100.ms),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingEmoji(String emoji, double size) {
    return Text(
      emoji,
      style: TextStyle(fontSize: size),
    );
  }

  Widget _buildFeatureItem(String emoji, String text, bool isDark) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
