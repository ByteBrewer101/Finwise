import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../services/local/local_database.dart';
import '../../domain/models/transaction.dart';
import '../../domain/repository/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl(this.localDb, this.client);

  final LocalDatabase localDb;
  final SupabaseClient client;
  static const _uuid = Uuid();

  @override
  Future<List<Transaction>> fetchTransactions() async {
    final user = client.auth.currentUser;
    if (user == null) return [];
    final rows = localDb.getTransactions(user.id);
    return rows.map(Transaction.fromMap).toList();
  }

  @override
  Future<void> addTransaction(Transaction transaction) async {
    final user = client.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final now = DateTime.now().toIso8601String();
    final row = {
      'id': transaction.id.isEmpty ? _uuid.v4() : transaction.id,
      'user_id': user.id,
      'wallet_id': transaction.walletId,
      'target_wallet_id': transaction.targetWalletId,
      'category_id': transaction.categoryId,
      'budget_id': transaction.budgetId,
      'type': transaction.type.name,
      'amount': transaction.amount,
      'description': transaction.description,
      'transaction_date': transaction.transactionDate.toIso8601String(),
      'created_at': now,
      'updated_at': now,
    };

    final walletId = row['wallet_id'] as String?;
    final txType = row['type'] as String?;
    final amount = (row['amount'] as num).toDouble();
    if (walletId != null && (txType == 'expense' || txType == 'transfer')) {
      final wallet = localDb.getWalletById(walletId);
      final balance = (wallet?['balance'] as num?)?.toDouble() ?? 0;
      if (balance < amount) {
        throw Exception('Insufficient wallet balance');
      }
    }

    final budgetId = row['budget_id'] as String?;
    if (txType == 'expense' && budgetId != null) {
      final budget = localDb.getBudgetById(budgetId);
      if (budget == null) {
        throw Exception('Budget not found');
      }
      final spent = localDb.computeBudgetSpent(budgetId, user.id);
      final target = (budget['amount'] as num?)?.toDouble() ?? 0;
      final remaining = (target - spent).clamp(0, target);
      if (amount > remaining) {
        throw Exception('Amount exceeds remaining budget');
      }
    }

    localDb.putTransaction(row);
    localDb.applyWalletImpactForTransaction(row, isInsert: true);
    await localDb.enqueueChange(
      userId: user.id,
      entity: 'transactions',
      entityId: row['id'] as String,
      operation: 'create',
      payload: row,
    );
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final row = localDb.getTransactionById(id);
    if (row == null) return;
    localDb.applyWalletImpactForTransaction(row, isInsert: false);
    localDb.deleteTransaction(id);

    await localDb.enqueueChange(
      userId: row['user_id'] as String,
      entity: 'transactions',
      entityId: id,
      operation: 'delete',
    );
  }
}
