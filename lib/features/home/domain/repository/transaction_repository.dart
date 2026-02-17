import '../models/transaction.dart';

abstract class TransactionRepository {
  Future<List<Transaction>> fetchTransactions();

  Future<void> addTransaction(Transaction transaction);

  Future<void> deleteTransaction(String id);
}
