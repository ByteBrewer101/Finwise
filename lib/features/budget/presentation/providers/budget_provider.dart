import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/datasource/budget_remote_datasource.dart';
import '../../data/repository/budget_repository_impl.dart';
import '../../domain/models/budget.dart';
import '../../domain/repository/budget_repository.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final client = Supabase.instance.client;
  return BudgetRepositoryImpl(
    BudgetRemoteDataSource(client),
  );
});

final budgetListProvider = FutureProvider<List<Budget>>((ref) async {
  final repo = ref.watch(budgetRepositoryProvider);
  return repo.getBudgets();
});
