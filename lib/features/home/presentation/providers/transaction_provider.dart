import 'package:finwise/features/budget/presentation/providers/budget_provider.dart';
import 'package:finwise/features/budget/presentation/providers/budget_transactions_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../services/sync/sync_service.dart';
import '../../data/repository/transaction_repository_impl.dart';
import '../../domain/models/transaction.dart';
import '../../domain/repository/transaction_repository.dart';
import 'wallet_provider.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final client = Supabase.instance.client;
  final localDb = ref.read(localDatabaseProvider);
  return TransactionRepositoryImpl(localDb, client);
});

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, AsyncValue<List<Transaction>>>(
      (ref) => TransactionNotifier(ref),
    );

class TransactionNotifier extends StateNotifier<AsyncValue<List<Transaction>>> {
  final Ref ref;

  TransactionNotifier(this.ref) : super(const AsyncLoading()) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        if (!mounted) return;
        state = const AsyncData([]);
        return;
      }

      final repo = ref.read(transactionRepositoryProvider);
      var transactions = await repo.fetchTransactions();
      if (transactions.isEmpty) {
        await ref.read(syncServiceProvider).syncNow();
        transactions = await repo.fetchTransactions();
      }

      if (!mounted) return;
      state = AsyncData(transactions);
    } catch (e, st) {
      if (!mounted) return;
      state = AsyncError(e, st);
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      final repo = ref.read(transactionRepositoryProvider);

      await repo.addTransaction(transaction);

      await loadTransactions();
      if (!mounted) return;

      // Reload wallets after trigger updates balances.
      await ref.read(walletProvider.notifier).loadWallets();
      ref.invalidate(budgetListProvider);
      ref.invalidate(budgetTransactionsProvider);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      final repo = ref.read(transactionRepositoryProvider);

      await repo.deleteTransaction(id);

      await loadTransactions();
      if (!mounted) return;
      ref.read(walletProvider.notifier).loadWallets();
    } catch (e, st) {
      if (!mounted) return;
      state = AsyncError(e, st);
    }
  }
}
