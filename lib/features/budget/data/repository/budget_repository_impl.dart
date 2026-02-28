import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../services/local/local_database.dart';
import '../../domain/models/budget.dart';
import '../../domain/repository/budget_repository.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  BudgetRepositoryImpl(this._localDb, this._client);

  final LocalDatabase _localDb;
  final SupabaseClient _client;
  static const _uuid = Uuid();

  @override
  Future<List<Budget>> getBudgets() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];
    final rows = _localDb.getBudgets(user.id);
    return rows.map((row) {
      final spent = _localDb.computeBudgetSpent(row['id'] as String, user.id);
      final normalized = Map<String, dynamic>.from(row)..['spent'] = spent;
      return Budget.fromJson(normalized).copyWith(spent: spent);
    }).toList();
  }

  @override
  Future<void> addBudget(Budget budget) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final now = DateTime.now().toIso8601String();
    final row = {
      'id': budget.id.isEmpty ? _uuid.v4() : budget.id,
      'user_id': user.id,
      'name': budget.name,
      'amount': budget.amount,
      'category_id': budget.categoryId,
      'wallet_id': budget.walletId,
      'recurrence': budget.recurrence,
      'start_date': budget.startDate.toIso8601String(),
      'end_date': budget.endDate?.toIso8601String(),
      'currency': budget.currency,
      'created_at': now,
      'updated_at': now,
    };

    _localDb.putBudget(row);
    await _localDb.enqueueChange(
      userId: user.id,
      entity: 'budgets',
      entityId: row['id'] as String,
      operation: 'create',
      payload: row,
    );
  }
}
