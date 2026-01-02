import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/color_schemes.dart';
import '../providers/auth_provider.dart';
import '../../../../shared/widgets/glass_container.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.signInWithGoogle();
      
      if (user != null && mounted) {
        // Check if user needs onboarding
        final needsOnboarding = await authService.needsOnboarding();
        if (needsOnboarding) {
          context.go('/onboarding');
        } else {
          context.go('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Sign in failed. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithApple() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.signInWithApple();
      
      if (user != null && mounted) {
        final needsOnboarding = await authService.needsOnboarding();
        if (needsOnboarding) {
          context.go('/onboarding');
        } else {
          context.go('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Sign in failed. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                SizedBox(height: size.height * 0.08),

                // Header with Jar Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '🫙',
                      style: TextStyle(fontSize: 50),
                    ),
                  ),
                ).animate().fadeIn(duration: 600.ms).scale(delay: 200.ms),

                const SizedBox(height: 32),

                // Welcome Text
                Text(
                  'Welcome Back',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),

                const SizedBox(height: 8),

                Text(
                  'Sign in to continue your memory journey',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 400.ms),

                SizedBox(height: size.height * 0.08),

                // Error Message
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade400),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().shake(),
                  const SizedBox(height: 24),
                ],

                // Google Sign In Button
                _SignInButton(
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  icon: 'assets/icons/google.png',
                  fallbackIcon: Icons.g_mobiledata_rounded,
                  label: 'Continue with Google',
                  backgroundColor: isDark ? const Color(0xFF2d2d3a) : Colors.white,
                  textColor: isDark ? Colors.white : AppColors.textPrimary,
                  isLoading: _isLoading,
                  isDark: isDark,
                ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.2),

                const SizedBox(height: 16),

                // Apple Sign In Button (iOS only or web)
                if (Platform.isIOS || Platform.isMacOS) ...[
                  _SignInButton(
                    onPressed: _isLoading ? null : _signInWithApple,
                    icon: 'assets/icons/apple.png',
                    fallbackIcon: Icons.apple_rounded,
                    label: 'Continue with Apple',
                    backgroundColor: isDark ? Colors.white : Colors.black,
                    textColor: isDark ? Colors.black : Colors.white,
                    isLoading: _isLoading,
                    isDark: isDark,
                  ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.2),
                  const SizedBox(height: 24),
                ] else ...[
                  const SizedBox(height: 8),
                ],

                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: isDark ? Colors.white12 : Colors.grey.shade300,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or',
                        style: TextStyle(
                          color: isDark ? Colors.white38 : AppColors.textTertiary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: isDark ? Colors.white12 : Colors.grey.shade300,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 700.ms),

                const SizedBox(height: 24),

                // Email Sign In (Future)
                GlassCard(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Email sign-in coming soon!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.email_outlined,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Continue with Email',
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 800.ms),

                SizedBox(height: size.height * 0.08),

                // Back Button
                TextButton.icon(
                  onPressed: () => context.go('/welcome'),
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    size: 18,
                    color: isDark ? Colors.white54 : AppColors.textSecondary,
                  ),
                  label: Text(
                    'Back to Welcome',
                    style: TextStyle(
                      color: isDark ? Colors.white54 : AppColors.textSecondary,
                    ),
                  ),
                ).animate().fadeIn(delay: 900.ms),

                const SizedBox(height: 24),

                // Terms
                Text(
                  'By signing in, you agree to our Terms of Service\nand acknowledge our Privacy Policy',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white30 : AppColors.textTertiary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 1000.ms),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SignInButton extends StatelessWidget {
  const _SignInButton({
    required this.onPressed,
    required this.icon,
    required this.fallbackIcon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.isLoading,
    required this.isDark,
  });

  final VoidCallback? onPressed;
  final String icon;
  final IconData fallbackIcon;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final bool isLoading;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDark ? Colors.white12 : Colors.grey.shade300,
            ),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Try to load image, fallback to icon
                  Icon(fallbackIcon, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
