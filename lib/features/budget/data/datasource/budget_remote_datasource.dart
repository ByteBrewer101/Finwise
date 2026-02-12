import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/budget.dart';

class BudgetRemoteDataSource {
  final SupabaseClient _client;

  BudgetRemoteDataSource(this._client);

  Future<List<Budget>> fetchBudgets() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await _client
        .from('budgets')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Budget.fromJson(json))
        .toList();
  }

  Future<void> createBudget(Budget budget) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _client.from('budgets').insert({
      ...budget.toJson(),
      'user_id': user.id,
    });
  }
}
