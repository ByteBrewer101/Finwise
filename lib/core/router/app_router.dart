import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';

import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/budget/presentation/screens/budget_screen.dart';
import '../../features/analysis/presentation/screens/analysis_screen.dart';
import '../../features/goals/presentation/screens/goals_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../providers/shared_prefs_provider.dart';

import 'auth_notifier.dart';
import 'app_routes.dart';
import 'main_layout.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = AuthNotifier();

  return GoRouter(
    initialLocation: AppRoutes.onboarding,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;

      final prefs = ref.read(sharedPreferencesProvider);
      final isFirstLaunch = prefs.getBool('first_launch') ?? true;

      final goingToOnboarding = state.uri.path == AppRoutes.onboarding;
      final goingToLogin = state.uri.path == AppRoutes.login;
      final goingToRegister = state.uri.path == AppRoutes.register;

      // 1️⃣ FIRST LAUNCH → show onboarding only once
      if (isFirstLaunch) {
        if (!goingToOnboarding) {
          return AppRoutes.onboarding;
        }
        return null;
      }

      // 2️⃣ Not logged in → go to login
      if (!isLoggedIn) {
        if (!goingToLogin && !goingToRegister) {
          return AppRoutes.login;
        }
        return null;
      }

      // 3️⃣ Logged in → prevent going back to auth/onboarding
      if (isLoggedIn &&
          (goingToLogin || goingToRegister || goingToOnboarding)) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      /// ONBOARDING
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      /// AUTH ROUTES
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),

      /// MAIN APP SHELL
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.budget,
            builder: (context, state) => const BudgetScreen(),
          ),
          GoRoute(
            path: AppRoutes.analysis,
            builder: (context, state) => const AnalysisScreen(),
          ),
          GoRoute(
            path: AppRoutes.goals,
            builder: (context, state) => const GoalsScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});
