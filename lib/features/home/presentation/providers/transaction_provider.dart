import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/datasource/transaction_remote_datasource.dart';
import '../../data/repository/transaction_repository_impl.dart';
import '../../domain/models/transaction.dart';
import '../../domain/repository/transaction_repository.dart';
import 'wallet_provider.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final client = Supabase.instance.client;
  return TransactionRepositoryImpl(TransactionRemoteDatasource(client));
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

  /// ===============================
  /// LOAD TRANSACTIONS
  /// ===============================

  Future<void> loadTransactions() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        state = const AsyncData([]);
        return;
      }

      final repo = ref.read(transactionRepositoryProvider);
      final transactions = await repo.fetchTransactions();

      state = AsyncData(transactions);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// ===============================
  /// ADD TRANSACTION
  /// ===============================

  Future<void> addTransaction(Transaction transaction) async {
    try {
      final repo = ref.read(transactionRepositoryProvider);

      await repo.addTransaction(transaction);

      // Reload transactions
      await loadTransactions();

      // 🔥 CRITICAL: Reload wallets after trigger updates balance
      await ref.read(walletProvider.notifier).loadWallets();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// ===============================
  /// DELETE TRANSACTION (Future Safe)
  /// ===============================

  Future<void> deleteTransaction(String id) async {
    try {
      final repo = ref.read(transactionRepositoryProvider);

      await repo.deleteTransaction(id);

      await loadTransactions();

      ref.read(walletProvider.notifier).loadWallets();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
