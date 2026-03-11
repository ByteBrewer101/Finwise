import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _featureSlides = <_FeatureSlideData>[
    _FeatureSlideData(
      title: 'Easy',
      description: 'Simplified features to easily track income, expenses, and budget',
      image: 'assets/images/onboarding1.png',
    ),
    _FeatureSlideData(
      title: 'Flexible',
      description: 'We help our users to make the right financial decisions',
      image: 'assets/images/onboarding2.png',
    ),
    _FeatureSlideData(
      title: 'Goals',
      description: 'You can track your progress and achievements in a special section',
      image: 'assets/images/onboarding3.png',
    ),
  ];

  bool _expanded = false;
  int _currentIndex = 0;

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_launch', false);
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  Future<void> _goToRegister() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_launch', false);
    if (!mounted) return;
    context.go(AppRoutes.register);
  }

  Future<void> _onPrimaryTap() async {
    if (!_expanded) {
      setState(() => _expanded = true);
      return;
    }

    if (_currentIndex >= _featureSlides.length - 1) {
      await _completeOnboarding();
      return;
    }

    setState(() => _currentIndex++);
  }

  @override
  Widget build(BuildContext context) {
    final activeSlide = _featureSlides[_currentIndex];
    final isLast = _currentIndex == _featureSlides.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
                  const SizedBox(height: 44),
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'welcome to',
                            style: AppTextStyles.headingSmall.copyWith(
                              color: const Color(0xFF374151),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'FinWise',
                            style: AppTextStyles.headingLarge.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: 164,
                            child: Text(
                              'App that will help you to properly manage your finances',
                              textAlign: TextAlign.right,
                              style: AppTextStyles.body.copyWith(
                                color: const Color(0xFF9CA3AF),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 26),
                      child: Image.asset(
                        'assets/images/onboarding1.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) {
                          return const Icon(
                            Icons.cloud,
                            size: 180,
                            color: Color(0xFFD1D5DB),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 360),
              curve: Curves.easeInOut,
              left: 0,
              right: 0,
              bottom: 0,
              top: _expanded ? 70 : null,
              height: _expanded ? null : 188,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: Color(0xFF04261E),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  child: _expanded
                      ? _ExpandedPanel(
                          key: const ValueKey('expanded'),
                          slide: activeSlide,
                          index: _currentIndex,
                          totalDots: _featureSlides.length,
                          isLast: isLast,
                          onSkip: _completeOnboarding,
                          onPrimaryTap: _onPrimaryTap,
                          onRegisterTap: _goToRegister,
                        )
                      : _CollapsedPanel(
                          key: const ValueKey('collapsed'),
                          onPrimaryTap: _onPrimaryTap,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollapsedPanel extends StatelessWidget {
  const _CollapsedPanel({super.key, required this.onPrimaryTap});

  final VoidCallback onPrimaryTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ElevatedButton(
          onPressed: onPrimaryTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(
            'Get Started',
            style: AppTextStyles.headingSmall.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _ExpandedPanel extends StatelessWidget {
  const _ExpandedPanel({
    super.key,
    required this.slide,
    required this.index,
    required this.totalDots,
    required this.isLast,
    required this.onSkip,
    required this.onPrimaryTap,
    required this.onRegisterTap,
  });

  final _FeatureSlideData slide;
  final int index;
  final int totalDots;
  final bool isLast;
  final VoidCallback onSkip;
  final VoidCallback onPrimaryTap;
  final VoidCallback onRegisterTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 14, 0),
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: onSkip,
                child: Text(
                  'Skip',
                  style: AppTextStyles.headingSmall.copyWith(
                    color: AppColors.primaryLight,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 36),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 360),
            switchInCurve: Curves.easeInOutCubic,
            switchOutCurve: Curves.easeInOutCubic,
            transitionBuilder: (child, animation) {
              final offsetAnimation = Tween<Offset>(
                begin: const Offset(0.06, 0),
                end: Offset.zero,
              ).animate(animation);
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: offsetAnimation, child: child),
              );
            },
            child: Padding(
              key: ValueKey('img-$index'),
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Image.asset(
                slide.image,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) {
                  return const Icon(Icons.cloud, size: 180, color: Color(0xFF6B7280));
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            totalDots,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: i == index ? 14 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: i == index ? AppColors.primaryLight : Colors.white70,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 340),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Column(
            key: ValueKey('txt-$index'),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  slide.title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headingLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 34),
                child: Text(
                  slide.description,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    color: const Color(0xFFD1D5DB),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 34),
          child: ElevatedButton(
            onPressed: onPrimaryTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              isLast ? 'Login' : 'Next',
              style: AppTextStyles.headingSmall.copyWith(color: Colors.white),
            ),
          ),
        ),
        if (isLast) ...[
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 4,
            children: [
              Text(
                'Have an account already?',
                style: AppTextStyles.body.copyWith(color: Colors.white),
              ),
              GestureDetector(
                onTap: onRegisterTap,
                child: Text(
                  'Register',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

class _FeatureSlideData {
  const _FeatureSlideData({
    required this.title,
    required this.description,
    required this.image,
  });

  final String title;
  final String description;
  final String image;
}
