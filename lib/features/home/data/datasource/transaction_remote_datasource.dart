import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/transaction.dart';

class TransactionRemoteDatasource {
  final SupabaseClient client;

  TransactionRemoteDatasource(this.client);

  // ===============================
  // FETCH TRANSACTIONS
  // ===============================

  Future<List<Transaction>> fetchTransactions() async {
    final user = client.auth.currentUser;
    if (user == null) return [];

    final response = await client
        .from('transactions')
        .select() // includes budget_id automatically
        .eq('user_id', user.id)
        .order('transaction_date', ascending: false);

    return (response as List).map((e) => Transaction.fromMap(e)).toList();
  }

  // ===============================
  // ADD TRANSACTION
  // ===============================

  Future<void> addTransaction(Transaction transaction) async {
    final user = client.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    await client.from('transactions').insert({
      ...transaction.toMap(), // includes budget_id safely
      'user_id': user.id,
    });
  }

  // ===============================
  // DELETE TRANSACTION
  // ===============================

  Future<void> deleteTransaction(String id) async {
    await client.from('transactions').delete().eq('id', id);
  }
}
