import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../../../../core/theme/color_schemes.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> 
    with SingleTickerProviderStateMixin {
  bool _hasNavigated = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _initializeAndNavigate();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _initializeAndNavigate() async {
    // Minimum splash display time for branding
    await Future.delayed(const Duration(milliseconds: 2000));
    
    if (!mounted || _hasNavigated) return;

    final authService = ref.read(authServiceProvider);
    
    // CRITICAL FIX: Properly wait for Firebase Auth to restore session
    // This is the key fix for the login persistence issue
    final user = await authService.waitForAuthReady(
      timeout: const Duration(seconds: 3),
    );
    
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;

    if (user != null) {
      // User is authenticated - check onboarding status
      try {
        final needsOnboarding = await authService.needsOnboarding(user.uid);
        
        if (!mounted) return;
        
        if (needsOnboarding) {
          // Check if they need terms first
          final needsTerms = await authService.needsTermsAcceptance(user.uid);
          if (needsTerms) {
            context.go('/onboarding');
          } else {
            context.go('/onboarding/profile');
          }
        } else {
          context.go('/home');
        }
      } catch (e) {
        debugPrint('Splash navigation error: $e');
        if (mounted) {
          context.go('/welcome');
        }
      }
    } else {
      // No user - go to welcome screen
      if (mounted) {
        context.go('/welcome');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Jar Icon with Glow
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(
                              0.1 + (_pulseController.value * 0.15),
                            ),
                            blurRadius: 30 + (_pulseController.value * 20),
                            spreadRadius: 5 + (_pulseController.value * 10),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '🫙',
                          style: TextStyle(fontSize: 72),
                        ),
                      ),
                    );
                  },
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1, 1),
                      curve: Curves.easeOutBack,
                    ),
                
                const SizedBox(height: 32),
                
                // App Name with Gradient Text Effect
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.white, Color(0xFFE0E7FF)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(bounds),
                  child: const Text(
                    'Memory Jar',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                )
                    .animate(delay: 300.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),
                
                const SizedBox(height: 12),
                
                // Tagline
                Text(
                  'Capture moments, cherish memories',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 0.5,
                  ),
                )
                    .animate(delay: 500.ms)
                    .fadeIn(duration: 600.ms),
                
                const SizedBox(height: 60),
                
                // Animated Loading Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: _LoadingDot(
                        delay: Duration(milliseconds: index * 200),
                      ),
                    );
                  }),
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

class _LoadingDot extends StatefulWidget {
  final Duration delay;

  const _LoadingDot({required this.delay});

  @override
  State<_LoadingDot> createState() => _LoadingDotState();
}

class _LoadingDotState extends State<_LoadingDot> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(_animation.value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
