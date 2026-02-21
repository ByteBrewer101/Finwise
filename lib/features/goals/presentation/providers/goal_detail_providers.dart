import 'package:finwise/features/goals/presentation/providers/goals_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repository/goal_repository_impl.dart';
import '../../domain/models/goal.dart';
import '../../domain/models/goal_contribution.dart';

/// =====================================================
/// SINGLE GOAL
/// =====================================================

final singleGoalProvider =
    Provider.family<Goal?, String>((ref, goalId) {
  final goalsAsync = ref.watch(goalsProvider);

  return goalsAsync.when(
    data: (goals) {
      try {
        return goals.firstWhere((g) => g.id == goalId);
      } catch (_) {
        return null;
      }
    },
    loading: () => null,
    error: (_, __) => null,
  );
});
/// =====================================================
/// GOAL CONTRIBUTIONS
/// =====================================================

final goalContributionsProvider =
    FutureProvider.family<List<GoalContribution>, String>((ref, goalId) async {
      final repo = ref.read(goalRepositoryProvider);
      return repo.fetchContributions(goalId);
    });
