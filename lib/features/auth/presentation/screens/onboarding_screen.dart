import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() =>
      _OnboardingScreenState();
}

class _OnboardingScreenState
    extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {

  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _showPanel = false;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      title: "Easy",
      description:
          "Simplified features to easily track income, expenses, and budget",
      image: "assets/images/onboarding1.png",
    ),
    _OnboardingData(
      title: "Flexible",
      description:
          "We help our users to make the right financial decisions",
      image: "assets/images/onboarding2.png",
    ),
    _OnboardingData(
      title: "Goals",
      description:
          "You can track your progress and achievements in a special section",
      image: "assets/images/onboarding3.png",
    ),
  ];

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          _showPanel = true;
        });
      }
    });
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_launch', false);

    if (mounted) {
      context.go(AppRoutes.login);
    }
  }

  void _next() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [

          /// 🔹 TOP ILLUSTRATION AREA
          Positioned.fill(
            child: Column(
              children: [

                const SizedBox(height: 70),

                /// Skip
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: GestureDetector(
                      onTap: _completeOnboarding,
                      child: Text(
                        "Skip",
                        style: TextStyle(
                          color: AppColors.primaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// Placeholder image (replace later)
                Expanded(
                  child: Image.asset(
                    _pages[_currentIndex].image,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.cloud,
                      size: 180,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// 🔹 SLIDING PANEL
          AnimatedAlign(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            alignment: _showPanel
                ? Alignment.bottomCenter
                : const Alignment(0, 1.2),
            child: Container(
              height: screenHeight * 0.55,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [

                  /// Drag indicator
                  Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  /// PageView
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _pages.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      itemBuilder: (_, index) {
                        final page = _pages[index];
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              page.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              page.description,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  /// Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin:
                            const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentIndex == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == index
                              ? AppColors.primary
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  PrimaryButton(
                    label: _currentIndex == _pages.length - 1
                        ? "Login"
                        : "Next",
                    onPressed: _next,
                  ),

                  if (_currentIndex == _pages.length - 1) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Have an account already? "),
                        GestureDetector(
                          onTap: () {
                            context.go(AppRoutes.register);
                          },
                          child: Text(
                            "Register",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final String title;
  final String description;
  final String image;

  const _OnboardingData({
    required this.title,
    required this.description,
    required this.image,
  });
}
