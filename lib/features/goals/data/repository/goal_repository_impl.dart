import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/goal.dart';
import '../../domain/repository/goal_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/data/supabase_client_provider.dart';
import '../../domain/models/goal_contribution.dart';

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  final supabase = ref.read(supabaseClientProvider);
  return GoalRepositoryImpl(supabase);
});

class GoalRepositoryImpl implements GoalRepository {
  final SupabaseClient supabase;

  GoalRepositoryImpl(this.supabase);

  @override
  Future<List<Goal>> fetchGoals() async {
    final response = await supabase
        .from('goals')
        .select()
        .order('created_at', ascending: false);

    return (response as List).map((e) => Goal.fromMap(e)).toList();
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
      throw Exception("User not authenticated");
    }

    await supabase.from('goals').insert({
      'user_id': user.id,
      'name': name,
      'target_for': targetFor,
      'target_amount': targetAmount,
      'contribution': contribution,
      'currency': currency,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
    });
  }

  @override
  Future<void> addContribution({
    required String goalId,
    required String walletId,
    required double amount,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception("User not authenticated");
    }

    final transaction = await supabase
        .from('transactions')
        .insert({
          'user_id': user.id,
          'wallet_id': walletId,
          'type': 'expense',
          'amount': amount,
          'description': 'Goal Contribution',
          'transaction_date': DateTime.now().toIso8601String(),
        })
        .select()
        .single();

    final transactionId = transaction['id'];

    await supabase.from('goal_contributions').insert({
      'goal_id': goalId,
      'user_id': user.id,
      'amount': amount,
      'contributed_at': DateTime.now().toIso8601String(),
      'transaction_id': transactionId,
    });
  }

  @override
  Future<List<GoalContribution>> fetchContributions(String goalId) async {
    final response = await supabase
        .from('goal_contributions')
        .select()
        .eq('goal_id', goalId)
        .order('contributed_at', ascending: false);

    return (response as List)
        .map((e) => GoalContribution.fromMap(e))
        .toList();
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
    await supabase
        .from('goals')
        .update({
          'name': name,
          'target_for': targetFor,
          'target_amount': targetAmount,
          'currency': currency,
          'start_date': startDate?.toIso8601String(),
          'end_date': endDate?.toIso8601String(),
        })
        .eq('id', goalId);
  }

  // =====================================================
  // DELETE GOAL (Only Added This)
  // =====================================================

  @override
  Future<void> deleteGoal(String goalId) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception("User not authenticated");
    }

    await supabase
        .from('goals')
        .delete()
        .eq('id', goalId)
        .eq('user_id', user.id);
  }
}
