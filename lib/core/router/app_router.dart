import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/terms_screen.dart';
import '../../features/onboarding/presentation/screens/profile_setup_screen.dart';
import '../../features/onboarding/presentation/screens/jar_setup_screen.dart';
import '../../features/onboarding/presentation/screens/family_setup_screen.dart';
import '../../features/home/presentation/screens/main_shell.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/family/presentation/screens/family_screen.dart';
import '../../features/reflections/presentation/screens/reflections_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/memories/presentation/screens/create_memory_screen.dart';
import '../../features/memories/presentation/screens/memory_detail_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Welcome Screen
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      
      // Login Screen
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      
      // Onboarding Flow
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/terms',
        name: 'terms',
        builder: (context, state) => const TermsScreen(),
      ),
      GoRoute(
        path: '/onboarding/profile',
        name: 'profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/onboarding/jar-setup',
        name: 'jar-setup',
        builder: (context, state) => const JarSetupScreen(),
      ),
      GoRoute(
        path: '/onboarding/family',
        name: 'family-setup',
        builder: (context, state) => const FamilySetupScreen(),
      ),
      
      // Settings
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      
      // Main App Shell with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/family',
            name: 'family',
            builder: (context, state) => const FamilyScreen(),
          ),
          GoRoute(
            path: '/reflections',
            name: 'reflections',
            builder: (context, state) => const ReflectionsScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      
      // Create Memory (Modal)
      GoRoute(
        path: '/create-memory',
        name: 'create-memory',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CreateMemoryScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        ),
      ),
      
      // Memory Detail
      GoRoute(
        path: '/memory/:id',
        name: 'memory-detail',
        builder: (context, state) {
          final memoryId = state.pathParameters['id']!;
          return MemoryDetailScreen(memoryId: memoryId);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(state.matchedLocation),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
