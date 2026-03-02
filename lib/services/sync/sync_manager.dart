import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/budget/presentation/providers/budget_provider.dart';
import '../../features/budget/presentation/providers/budget_transactions_provider.dart';
import '../../features/goals/presentation/providers/goal_detail_providers.dart';
import '../../features/goals/presentation/providers/goals_provider.dart';
import '../../features/home/presentation/providers/category_provider.dart';
import '../../features/home/presentation/providers/transaction_provider.dart';
import '../../features/home/presentation/providers/wallet_provider.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';
import 'sync_service.dart';

enum InitialSyncState {
  syncing,
  ready,
}

final initialSyncStateProvider = StateProvider<InitialSyncState>((ref) {
  return InitialSyncState.syncing;
});

final syncBootstrapProvider = Provider<void>((ref) {
  final manager = SyncManager(ref);
  Future<void>.microtask(manager.start);
  ref.onDispose(manager.dispose);
});

class SyncManager {
  SyncManager(this._ref);

  final Ref _ref;
  Timer? _timer;
  Timer? _sessionBootstrapTimer;
  AppLifecycleListener? _lifecycleListener;
  StreamSubscription<AuthState>? _authSubscription;

  void start() {
    _timer ??= Timer.periodic(const Duration(minutes: 2), (_) async {
      await _runSyncAndRefresh();
    });

    _lifecycleListener ??= AppLifecycleListener(
      onInactive: () async => _runSyncAndRefresh(),
      onPause: () async => _runSyncAndRefresh(),
      onDetach: () async => _runSyncAndRefresh(),
      onResume: () async => _runSyncAndRefresh(),
    );

    _authSubscription ??= Supabase.instance.client.auth.onAuthStateChange.listen((
      event,
    ) async {
      final authEvent = event.event;
      if (authEvent == AuthChangeEvent.signedIn ||
          authEvent == AuthChangeEvent.tokenRefreshed ||
          authEvent == AuthChangeEvent.userUpdated) {
        await _runInitialSyncAndRefresh();
      } else if (authEvent == AuthChangeEvent.signedOut) {
        _ref.read(syncServiceProvider).resetSession();
        _ref.read(initialSyncStateProvider.notifier).state = InitialSyncState.ready;
        _ref.invalidate(walletProvider);
        _ref.invalidate(transactionProvider);
        _ref.invalidate(categoryProvider);
        _ref.invalidate(budgetListProvider);
        _ref.invalidate(goalsProvider);
        _ref.invalidate(profileProvider);
      }
    });

    _sessionBootstrapTimer ??= Timer.periodic(const Duration(seconds: 2), (_) async {
      if (Supabase.instance.client.auth.currentUser != null) {
        await _runInitialSyncAndRefresh();
        _sessionBootstrapTimer?.cancel();
        _sessionBootstrapTimer = null;
      }
    });

    unawaited(_runInitialSyncAndRefresh());
  }

  Future<void> _runInitialSyncAndRefresh() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      _ref.read(initialSyncStateProvider.notifier).state = InitialSyncState.ready;
      return;
    }

    _ref.read(initialSyncStateProvider.notifier).state = InitialSyncState.syncing;
    try {
      await _ref.read(syncServiceProvider).initializeForCurrentUser();
      await _refreshDataProviders();
    } finally {
      _ref.read(initialSyncStateProvider.notifier).state = InitialSyncState.ready;
    }
  }

  Future<void> _runSyncAndRefresh() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    await _ref.read(syncServiceProvider).syncNow();
    await _refreshDataProviders();
  }

  Future<void> _refreshDataProviders() async {
    final walletNotifier = _ref.read(walletProvider.notifier);
    final transactionNotifier = _ref.read(transactionProvider.notifier);
    final profileNotifier = _ref.read(profileProvider.notifier);

    await Future.wait([
      walletNotifier.loadWallets(),
      transactionNotifier.loadTransactions(),
      profileNotifier.loadProfile(),
    ]);

    _ref.invalidate(categoryProvider);
    _ref.invalidate(budgetListProvider);
    _ref.invalidate(budgetTransactionsProvider);
    _ref.invalidate(goalsProvider);
    _ref.invalidate(goalContributionsProvider);
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    _sessionBootstrapTimer?.cancel();
    _sessionBootstrapTimer = null;
    _lifecycleListener?.dispose();
    _lifecycleListener = null;
    _authSubscription?.cancel();
    _authSubscription = null;
  }
}
