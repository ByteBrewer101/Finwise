import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repository/goal_repository_impl.dart';
import '../../domain/repository/goal_repository.dart';
import 'goals_provider.dart';
import 'goal_contributions_provider.dart';

final goalsNotifierProvider =
    StateNotifierProvider<GoalsNotifier, AsyncValue<void>>((ref) {
      final repository = ref.read(goalRepositoryProvider);
      return GoalsNotifier(repository, ref);
    });

class GoalsNotifier extends StateNotifier<AsyncValue<void>> {
  final GoalRepository repository;
  final Ref ref;

  GoalsNotifier(this.repository, this.ref) : super(const AsyncData(null));

  Future<void> createGoal({
    required String name,
    required String targetFor,
    required double targetAmount,
    required double contribution,
    required String currency,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = const AsyncLoading();

    try {
      await repository.createGoal(
        name: name,
        targetFor: targetFor,
        targetAmount: targetAmount,
        contribution: contribution,
        currency: currency,
        startDate: startDate,
        endDate: endDate,
      );

      ref.invalidate(goalsProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> addContribution({
    required String goalId,
    required String walletId,
    required double amount,
  }) async {
    state = const AsyncLoading();

    try {
      await repository.addContribution(
        goalId: goalId,
        walletId: walletId,
        amount: amount,
      );

      // 🔥 Critical invalidations
      ref.invalidate(goalsProvider);
      ref.invalidate(singleGoalProvider(goalId));
      ref.invalidate(goalContributionsProvider(goalId));

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> updateGoal({
    required String goalId,
    required String name,
    required String targetFor,
    required double targetAmount,
    required String currency,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = const AsyncLoading();

    try {
      await repository.updateGoal(
        goalId: goalId,
        name: name,
        targetFor: targetFor,
        targetAmount: targetAmount,
        currency: currency,
        startDate: startDate,
        endDate: endDate,
      );

      ref.invalidate(goalsProvider);
      ref.invalidate(singleGoalProvider(goalId));

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
