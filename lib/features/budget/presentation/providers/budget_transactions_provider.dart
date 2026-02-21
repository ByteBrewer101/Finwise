import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../home/domain/models/transaction.dart';

final budgetTransactionsProvider =
    FutureProvider.family<List<Transaction>, String>((ref, budgetId) async {
  final client = Supabase.instance.client;
  final user = client.auth.currentUser;

  if (user == null) return [];

  final response = await client
      .from('transactions')
      .select()
      .eq('user_id', user.id)
      .eq('budget_id', budgetId)
      .order('transaction_date', ascending: false);

  return (response as List)
      .map((e) => Transaction.fromMap(e))
      .toList();
});