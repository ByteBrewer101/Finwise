import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/validators.dart';
import '../../../../services/data/supabase_client_provider.dart';
import '../../../../services/local/local_database.dart';
import '../../../../services/sync/sync_service.dart';
import '../../domain/models/goal.dart';
import '../../domain/models/goal_contribution.dart';
import '../../domain/repository/goal_repository.dart';

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  final supabase = ref.read(supabaseClientProvider);
  final localDb = ref.read(localDatabaseProvider);
  return GoalRepositoryImpl(supabase, localDb);
});

class GoalRepositoryImpl implements GoalRepository {
  GoalRepositoryImpl(this.supabase, this.localDb);

  final SupabaseClient supabase;
  final LocalDatabase localDb;
  static const _uuid = Uuid();

  @override
  Future<List<Goal>> fetchGoals() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];
    final rows = localDb.getGoals(user.id);
    return rows.map(Goal.fromMap).toList();
  }

  @override
  Future<void> createGoal({
    required String name,
    required String targetFor,
    required double targetAmount,
    required double contribution,
    required String currency,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final now = DateTime.now().toIso8601String();
    final goalId = _uuid.v4();
    AppValidators.ensurePositiveAmount(
      targetAmount,
      message: 'Enter a valid target fund amount',
    );
    final row = {
      'id': goalId,
      'user_id': user.id,
      'name': name,
      'target_for': targetFor,
      'target_amount': targetAmount,
      'current_amount': 0,
      'contribution': contribution,
      'currency': currency,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'created_at': now,
      'updated_at': now,
    };

    localDb.putGoal(row);
    await localDb.enqueueChange(
      userId: user.id,
      entity: 'goals',
      entityId: goalId,
      operation: 'create',
      payload: row,
    );
  }

  @override
  Future<void> addContribution({
    required String goalId,
    required String walletId,
    required double amount,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    AppValidators.ensurePositiveAmount(
      amount,
      message: 'Enter a valid contribution amount',
    );

    final goal = localDb.getGoalById(goalId);
    if (goal == null) {
      throw Exception('Goal not found');
    }
    final target = (goal['target_amount'] as num?)?.toDouble() ?? 0;
    final current = (goal['current_amount'] as num?)?.toDouble() ?? 0;
    final remainingGoal = (target - current).clamp(0, target);
    AppValidators.ensureAmountNotExceeding(
      amount: amount,
      maxAllowed: remainingGoal.toDouble(),
      message: 'Amount exceeds remaining goal (${remainingGoal.toStringAsFixed(2)})',
    );

    final wallet = localDb.getWalletById(walletId);
    final balance = (wallet?['balance'] as num?)?.toDouble() ?? 0;
    AppValidators.ensureAmountNotExceeding(
      amount: amount,
      maxAllowed: balance,
      message: 'Insufficient wallet balance',
    );

    final now = DateTime.now();
    final nowIso = now.toIso8601String();
    final transactionId = _uuid.v4();
    final contributionId = _uuid.v4();

    final transactionRow = {
      'id': transactionId,
      'user_id': user.id,
      'wallet_id': walletId,
      'type': 'expense',
      'amount': amount,
      'description': 'Goal Contribution',
      'transaction_date': nowIso,
      'created_at': nowIso,
      'updated_at': nowIso,
    };

    localDb.putTransaction(transactionRow);
    localDb.applyWalletImpactForTransaction(transactionRow, isInsert: true);
    await localDb.enqueueChange(
      userId: user.id,
      entity: 'transactions',
      entityId: transactionId,
      operation: 'create',
      payload: transactionRow,
    );

    final contributionRow = {
      'id': contributionId,
      'goal_id': goalId,
      'user_id': user.id,
      'amount': amount,
      'contributed_at': nowIso,
      'created_at': nowIso,
      'transaction_id': transactionId,
    };

    localDb.putGoalContribution(contributionRow);
    localDb.applyLocalGoalContribution(goalId: goalId, amount: amount);
    await localDb.enqueueChange(
      userId: user.id,
      entity: 'goal_contributions',
      entityId: contributionId,
      operation: 'create',
      payload: contributionRow,
    );
  }

  @override
  Future<List<GoalContribution>> fetchContributions(String goalId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];
    final rows = localDb.getGoalContributions(userId: user.id, goalId: goalId);
    return rows.map(GoalContribution.fromMap).toList();
  }

  @override
  Future<void> updateGoal({
    required String goalId,
    required String name,
    required String targetFor,
    required double targetAmount,
    required String currency,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final existing = localDb.getGoalById(goalId);
    if (existing == null) {
      throw Exception('Goal not found');
    }
    AppValidators.ensurePositiveAmount(
      targetAmount,
      message: 'Enter a valid target amount',
    );
    final currentAmount = (existing['current_amount'] as num?)?.toDouble() ?? 0;
    AppValidators.ensureAmountNotExceeding(
      amount: currentAmount,
      maxAllowed: targetAmount,
      message: 'New target cannot be less than already invested amount.',
    );

    final updated = Map<String, dynamic>.from(existing);
    updated['name'] = name;
    updated['target_for'] = targetFor;
    updated['target_amount'] = targetAmount;
    updated['currency'] = currency;
    updated['start_date'] = startDate?.toIso8601String();
    updated['end_date'] = endDate?.toIso8601String();
    updated['updated_at'] = DateTime.now().toIso8601String();
    localDb.putGoal(updated);

    await localDb.enqueueChange(
      userId: user.id,
      entity: 'goals',
      entityId: goalId,
      operation: 'update',
      payload: updated,
    );
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final contributions = localDb.getGoalContributionsByGoal(goalId);
    for (final contribution in contributions) {
      final transactionId = contribution['transaction_id'] as String?;
      final amount = (contribution['amount'] as num?)?.toDouble() ?? 0;
      if (amount > 0) {
        localDb.rollbackLocalGoalContribution(goalId: goalId, amount: amount);
      }
      if (transactionId != null) {
        final tx = localDb.getTransactionById(transactionId);
        if (tx != null) {
          localDb.applyWalletImpactForTransaction(tx, isInsert: false);
          localDb.deleteTransaction(transactionId);
        }
      }
      localDb.deleteGoalContribution(contribution['id'] as String);
    }

    localDb.deleteGoal(goalId);
    await localDb.enqueueChange(
      userId: user.id,
      entity: 'goals',
      entityId: goalId,
      operation: 'delete',
    );
  }
}
