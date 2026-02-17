import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/goal.dart';
import '../../domain/repository/goal_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/data/supabase_client_provider.dart';

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

    return (response as List)
        .map((e) => Goal.fromMap(e))
        .toList();
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
}
