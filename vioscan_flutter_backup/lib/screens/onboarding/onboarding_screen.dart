// lib/screens/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class OnboardingPage {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;

  const OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = const [
    OnboardingPage(
      title: 'UV Fluorescence\nImaging',
      subtitle:
          'VioScan uses advanced UV fluorescence technology to detect early signs of Basal Cell Carcinoma invisible to the naked eye.',
      icon: Icons.light_mode_rounded,
      gradientColors: [Color(0xFF6C3CE1), Color(0xFF3B82F6)],
    ),
    OnboardingPage(
      title: 'AI-Powered\nAnalysis',
      subtitle:
          'Our deep learning model analyzes UV scan patterns with over 94% accuracy, providing instant risk assessment and detailed reports.',
      icon: Icons.psychology_rounded,
      gradientColors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
    ),
    OnboardingPage(
      title: 'Track & Monitor\nOver Time',
      subtitle:
          'Monitor skin changes over time with detailed history, progress charts, and alerts when anomalies need attention.',
      icon: Icons.trending_up_rounded,
      gradientColors: [Color(0xFF06B6D4), Color(0xFF22C55E)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              final page = _pages[index];
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      page.gradientColors[0].withValues(alpha:0.08),
                      Colors.white,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon container
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: page.gradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              BoxShadow(
                                color: page.gradientColors[0].withValues(alpha:0.4),
                                blurRadius: 40,
                                spreadRadius: 4,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          child: Icon(page.icon, size: 64, color: Colors.white),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          page.subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(32, 24, 32, 48),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? AppColors.primary
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // CTA Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          context.go('/login');
                        }
                      },
                      child: Text(
                        _currentPage < _pages.length - 1
                            ? 'Continue'
                            : 'Get Started',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text(
                      'Skip',
                      style: TextStyle(color: AppColors.textSecondary),
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
