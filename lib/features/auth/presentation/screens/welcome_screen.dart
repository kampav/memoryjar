import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../../../../core/theme/color_schemes.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  bool _isLoading = false;
  String? _loadingMethod;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _loadingMethod = 'google';
    });

    try {
      final authService = ref.read(authServiceProvider);
      final result = await authService.signInWithGoogle();
      
      if (result != null && mounted) {
        final needsOnboarding = await authService
            .needsOnboarding(result.user!.uid);
        
        if (!mounted) return;
        
        if (needsOnboarding) {
          context.go('/onboarding/profile');
        } else {
          context.go('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingMethod = null;
        });
      }
    }
  }

  Future<void> _signInAnonymously() async {
    setState(() {
      _isLoading = true;
      _loadingMethod = 'anonymous';
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInAnonymously();
      
      if (mounted) {
        context.go('/onboarding/profile');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingMethod = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundLight,
              Color(0xFFFFF5EB),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 2),
                
                // Hero Section
                Column(
                  children: [
                    // Jar Icon with animation
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryLight,
                            AppColors.primary,
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '🫙',
                          style: TextStyle(fontSize: 72),
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .scale(begin: const Offset(0.8, 0.8)),
                    
                    const SizedBox(height: 32),
                    
                    // Welcome Text
                    const Text(
                      'Welcome to\nMemory Jar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryLight,
                        height: 1.2,
                      ),
                    )
                        .animate(delay: 200.ms)
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 0.2, end: 0),
                    
                    const SizedBox(height: 16),
                    
                    // Subtitle
                    Text(
                      'Capture life\'s precious moments\nand cherish them forever',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondaryLight,
                        height: 1.5,
                      ),
                    )
                        .animate(delay: 400.ms)
                        .fadeIn(duration: 600.ms),
                  ],
                ),
                
                const Spacer(flex: 2),
                
                // Sign In Buttons
                Column(
                  children: [
                    // Google Sign In
                    _SignInButton(
                      text: 'Continue with Google',
                      icon: Icons.g_mobiledata,
                      isLoading: _loadingMethod == 'google',
                      enabled: !_isLoading,
                      onPressed: _signInWithGoogle,
                      isPrimary: true,
                    )
                        .animate(delay: 500.ms)
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.2, end: 0),
                    
                    const SizedBox(height: 12),
                    
                    // Email Sign In
                    _SignInButton(
                      text: 'Continue with Email',
                      icon: Icons.email_outlined,
                      isLoading: false,
                      enabled: !_isLoading,
                      onPressed: () => context.push('/login'),
                    )
                        .animate(delay: 600.ms)
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.2, end: 0),
                    
                    const SizedBox(height: 24),
                    
                    // Anonymous / Try it out
                    TextButton(
                      onPressed: _isLoading ? null : _signInAnonymously,
                      child: _loadingMethod == 'anonymous'
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Try it out first →',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    )
                        .animate(delay: 700.ms)
                        .fadeIn(duration: 400.ms),
                  ],
                ),
                
                const Spacer(),
                
                // Terms
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'By continuing, you agree to our\nTerms of Service and Privacy Policy',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryLight.withOpacity(0.7),
                    ),
                  ),
                )
                    .animate(delay: 800.ms)
                    .fadeIn(duration: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SignInButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isLoading;
  final bool enabled;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _SignInButton({
    required this.text,
    required this.icon,
    required this.isLoading,
    required this.enabled,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 24),
                    const SizedBox(width: 12),
                    Text(text, style: const TextStyle(fontSize: 16)),
                  ],
                ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: enabled ? onPressed : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(text, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
