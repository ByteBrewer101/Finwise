import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../services/sync/sync_service.dart';
import '../../../home/domain/models/transaction.dart';

final budgetTransactionsProvider =
    FutureProvider.family<List<Transaction>, String>((ref, budgetId) async {
  final user = Supabase.instance.client.auth.currentUser;

  if (user == null) return [];

  final localDb = ref.read(localDatabaseProvider);
  final rows = localDb.getTransactionsForBudget(userId: user.id, budgetId: budgetId);
  return rows.map(Transaction.fromMap).toList();
});
