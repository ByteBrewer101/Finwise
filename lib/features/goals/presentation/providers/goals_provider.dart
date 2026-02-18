import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repository/goal_repository_impl.dart';
import '../../domain/models/goal.dart';

final goalsProvider = FutureProvider<List<Goal>>((ref) async {
  final repository = ref.read(goalRepositoryProvider);
  return repository.fetchGoals();
});

final singleGoalProvider =
    FutureProvider.family<Goal, String>((ref, goalId) async {
  final repository = ref.read(goalRepositoryProvider);
  final goals = await repository.fetchGoals();
  return goals.firstWhere((g) => g.id == goalId);
});
