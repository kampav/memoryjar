import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/color_schemes.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      emoji: '📸',
      title: 'Capture Life\'s Moments',
      description: 'Record precious memories with photos, voice notes, and text. '
          'Every moment matters, from daily joys to milestone celebrations.',
      gradient: AppColors.onboardingGradient1,
      decorativeEmojis: ['✨', '💫', '🌟', '⭐'],
      features: [
        'Photos & Videos',
        'Voice Notes',
        'Written Memories',
        'Mood Tracking',
      ],
    ),
    OnboardingPageData(
      emoji: '👨‍👩‍👧‍👦',
      title: 'Share with Those You Love',
      description: 'Create separate jars for family, friends, or just yourself. '
          'Build a collective memory treasury that grows over time.',
      gradient: AppColors.onboardingGradient2,
      decorativeEmojis: ['💕', '🏠', '👥', '🎉'],
      features: [
        'Family Jars',
        'Friend Groups',
        'Personal Space',
        'Easy Sharing',
      ],
    ),
    OnboardingPageData(
      emoji: '🤖',
      title: 'AI-Powered Reflections',
      description: 'Our AI transforms your memories into beautiful narratives. '
          'Get weekly, monthly, and yearly reflections that tell your story.',
      gradient: AppColors.onboardingGradient3,
      decorativeEmojis: ['📖', '🎭', '💭', '🔮'],
      features: [
        'Weekly Summaries',
        'Monthly Highlights',
        'Yearly Stories',
        'Theme Discovery',
      ],
    ),
    OnboardingPageData(
      emoji: '🔒',
      title: 'Your Privacy Matters',
      description: 'Your memories are encrypted and secure. You control who sees what, '
          'with full GDPR compliance and data portability.',
      gradient: AppColors.onboardingGradient4,
      decorativeEmojis: ['🛡️', '🔐', '✅', '🇬🇧'],
      features: [
        'End-to-End Encryption',
        'GDPR Compliant',
        'Export Anytime',
        'You Own Your Data',
      ],
    ),
    OnboardingPageData(
      emoji: '🚀',
      title: 'Ready to Start?',
      description: 'Begin your memory journey today. Create your first jar '
          'and start capturing the moments that make life beautiful.',
      gradient: AppColors.onboardingGradient5,
      decorativeEmojis: ['🎊', '🌈', '💖', '🫙'],
      features: [
        'Free to Start',
        'Quick Setup',
        'Invite Family',
        'Start Capturing',
      ],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/terms');
    }
  }

  void _skip() {
    context.go('/terms');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page View
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              return _OnboardingPage(data: _pages[index]);
            },
          ),

          // Skip Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: TextButton(
              onPressed: _skip,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.white.withOpacity(0.2),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Skip',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),

          // Bottom Navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.of(context).padding.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(isActive ? 1 : 0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == _pages.length - 1 
                                ? 'Get Started' 
                                : 'Continue',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _currentPage == _pages.length - 1 
                                ? Icons.check_circle_outline
                                : Icons.arrow_forward,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPageData {
  final String emoji;
  final String title;
  final String description;
  final LinearGradient gradient;
  final List<String> decorativeEmojis;
  final List<String> features;

  OnboardingPageData({
    required this.emoji,
    required this.title,
    required this.description,
    required this.gradient,
    required this.decorativeEmojis,
    required this.features,
  });
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingPageData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: data.gradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 80, 24, 180),
          child: Column(
            children: [
              // Floating Decorative Emojis
              SizedBox(
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    for (int i = 0; i < data.decorativeEmojis.length; i++)
                      Positioned(
                        left: i == 0 ? 20 : (i == 2 ? 40 : null),
                        right: i == 1 ? 20 : (i == 3 ? 40 : null),
                        top: i % 2 == 0 ? 0 : 40,
                        child: Text(
                          data.decorativeEmojis[i],
                          style: const TextStyle(fontSize: 32),
                        )
                            .animate(delay: Duration(milliseconds: 200 + (i * 100)))
                            .fadeIn(duration: 600.ms)
                            .scale(begin: const Offset(0, 0))
                            .then()
                            .shimmer(duration: 2000.ms, delay: 1000.ms),
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Main Emoji
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    data.emoji,
                    style: const TextStyle(fontSize: 64),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(begin: const Offset(0.5, 0.5), curve: Curves.easeOutBack),
              
              const SizedBox(height: 40),
              
              // Title
              Text(
                data.title,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              )
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.2, end: 0),
              
              const SizedBox(height: 16),
              
              // Description
              Text(
                data.description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              )
                  .animate(delay: 400.ms)
                  .fadeIn(duration: 600.ms),
              
              const SizedBox(height: 32),
              
              // Features Grid
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: data.features.asMap().entries.map((entry) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                      .animate(delay: Duration(milliseconds: 500 + (entry.key * 100)))
                      .fadeIn(duration: 400.ms)
                      .slideX(begin: 0.2, end: 0);
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
