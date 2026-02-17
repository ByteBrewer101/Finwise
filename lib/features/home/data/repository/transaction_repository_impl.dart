import '../../domain/models/transaction.dart';
import '../../domain/repository/transaction_repository.dart';
import '../datasource/transaction_remote_datasource.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDatasource remoteDatasource;

  TransactionRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<Transaction>> fetchTransactions() {
    return remoteDatasource.fetchTransactions();
  }

  @override
  Future<void> addTransaction(Transaction transaction) {
    return remoteDatasource.addTransaction(transaction);
  }

  @override
  Future<void> deleteTransaction(String id) {
    return remoteDatasource.deleteTransaction(id);
  }
}
