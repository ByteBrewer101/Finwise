import '../models/goal.dart';

abstract class GoalRepository {
  Future<List<Goal>> fetchGoals();

  Future<void> createGoal({
    required String name,
    required String targetFor,
    required double targetAmount,
    required double contribution,
    required String currency,
    DateTime? startDate,
    DateTime? endDate,
  });
}
