import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repository/goal_repository_impl.dart';
import '../../domain/models/goal.dart';

final singleGoalProvider = FutureProvider.family<Goal?, String>((
  ref,
  goalId,
) async {
  final repo = ref.read(goalRepositoryProvider);
  final goals = await repo.fetchGoals();

  try {
    return goals.firstWhere((g) => g.id == goalId);
  } catch (_) {
    return null;
  }
});
