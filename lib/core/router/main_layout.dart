import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';
import '../../services/sync/sync_manager.dart';

class MainLayout extends ConsumerWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith(AppRoutes.budget)) return 1;
    if (location.startsWith(AppRoutes.analysis)) return 2;
    if (location.startsWith(AppRoutes.goals)) return 3;
    if (location.startsWith(AppRoutes.profile)) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.budget);
        break;
      case 2:
        context.go(AppRoutes.analysis);
        break;
      case 3:
        context.go(AppRoutes.goals);
        break;
      case 4:
        context.go(AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = _locationToIndex(location);
    final syncState = ref.watch(initialSyncStateProvider);
    final shouldGate = currentIndex == 0 || currentIndex == 1 || currentIndex == 3;

    final gatedChild = shouldGate && syncState == InitialSyncState.syncing
        ? const Center(child: CircularProgressIndicator())
        : child;

    return Scaffold(
      body: gatedChild,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onTap(context, index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'Budget'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Analysis'),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Goals'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
