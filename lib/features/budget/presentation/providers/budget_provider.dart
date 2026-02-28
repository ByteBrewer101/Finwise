import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../services/sync/sync_service.dart';
import '../../data/repository/budget_repository_impl.dart';
import '../../domain/models/budget.dart';
import '../../domain/repository/budget_repository.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final client = Supabase.instance.client;
  final localDb = ref.read(localDatabaseProvider);
  return BudgetRepositoryImpl(localDb, client);
});

final budgetListProvider = FutureProvider<List<Budget>>((ref) async {
  final repo = ref.watch(budgetRepositoryProvider);
  var budgets = await repo.getBudgets();
  if (budgets.isEmpty && Supabase.instance.client.auth.currentUser != null) {
    await ref.read(syncServiceProvider).syncNow();
    budgets = await repo.getBudgets();
  }
  return budgets;
});
