import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import 'app_routes.dart';

class SplashGate extends ConsumerWidget {
  const SplashGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      authState.when(
        authenticated: () => context.go(AppRoutes.dashboard),
        unauthenticated: () => context.go(AppRoutes.login),
        loading: () {},
        error: (_) => context.go(AppRoutes.login),
      );
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
