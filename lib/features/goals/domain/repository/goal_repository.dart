import '../models/goal.dart';
import '../models/goal_contribution.dart';

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

  Future<void> addContribution({
    required String goalId,
    required String walletId,
    required double amount,
  });

  Future<void> updateGoal({
    required String goalId,
    required String name,
    required String targetFor,
    required double targetAmount,
    required String currency,
    DateTime? startDate,
    DateTime? endDate,
  });

  // ✅ ADDED (Only this)
  Future<void> deleteGoal(String goalId);

  Future<List<GoalContribution>> fetchContributions(String goalId);
}
