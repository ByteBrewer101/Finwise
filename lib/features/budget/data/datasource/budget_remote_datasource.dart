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
        currency,
        category_id,
        wallet_id,
        categories(name),
        wallets(name)
      ''')
        .order('created_at', ascending: false);

    final rawBudgets = (response as List)
        .map((e) => Budget.fromJson(e))
        .toList();

    final List<Budget> finalBudgets = [];

    for (final budget in rawBudgets) {
      final spending = await _client.rpc(
        'get_budget_spending',
        params: {'p_budget_id': budget.id},
      );

      finalBudgets.add(budget.copyWith(spent: (spending as num).toDouble()));
    }

    return finalBudgets;
  }

  Future<void> createBudget(Budget budget) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    await _client.from('budgets').insert(budget.toJson(user.id));
  }
}
