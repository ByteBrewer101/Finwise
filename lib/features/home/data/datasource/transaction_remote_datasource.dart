import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/transaction.dart';

class TransactionRemoteDatasource {
  final SupabaseClient client;

  TransactionRemoteDatasource(this.client);

  Future<List<Transaction>> fetchTransactions() async {
    final user = client.auth.currentUser;
    if (user == null) return [];

    final response = await client
        .from('transactions')
        .select()
        .eq('user_id', user.id)
        .order('transaction_date', ascending: false);

    return (response as List)
        .map((e) => Transaction.fromMap(e))
        .toList();
  }

  Future<void> addTransaction(Transaction transaction) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await client.from('transactions').insert({
      ...transaction.toMap(),
      'user_id': user.id,
    });
  }

  Future<void> deleteTransaction(String id) async {
    await client
        .from('transactions')
        .delete()
        .eq('id', id);
  }
}
