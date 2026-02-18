import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repository/goal_repository_impl.dart';
import '../../domain/models/goal_contribution.dart';

final goalContributionsProvider =
    FutureProvider.family<List<GoalContribution>, String>((ref, goalId) async {
  final repository = ref.read(goalRepositoryProvider);
  return repository.fetchContributions(goalId);
});
