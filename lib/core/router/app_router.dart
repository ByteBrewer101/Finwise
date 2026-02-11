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

import 'auth_notifier.dart';
import 'app_routes.dart';
import 'main_layout.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = AuthNotifier();

  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;

      final isLoggedIn = session != null;

      final isGoingToAuth =
          state.uri.path == AppRoutes.login ||
          state.uri.path == AppRoutes.register;

      if (!isLoggedIn && !isGoingToAuth) {
        return AppRoutes.login;
      }

      if (isLoggedIn && isGoingToAuth) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
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
