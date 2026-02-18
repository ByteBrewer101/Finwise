import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/budget.dart';

class BudgetRemoteDataSource {
  final SupabaseClient _client;

  BudgetRemoteDataSource(this._client);

  Future<List<Budget>> fetchBudgets() async {
    final response = await _client
        .from('budgets')
        .select('''
          id,
          name,
          amount,
          recurrence,
          start_date,
          end_date,
          category_id,
          wallet_id
        ''')
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => Budget.fromJson(e))
        .toList();
  }

  Future<void> createBudget(Budget budget) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    await _client.from('budgets').insert(
      budget.toJson(user.id),
    );
  }
}
