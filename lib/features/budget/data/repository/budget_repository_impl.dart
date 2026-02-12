import '../../domain/models/budget.dart';
import '../../domain/repository/budget_repository.dart';
import '../datasource/budget_remote_datasource.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetRemoteDataSource _remote;

  BudgetRepositoryImpl(this._remote);

  @override
  Future<List<Budget>> getBudgets() {
    return _remote.fetchBudgets();
  }

  @override
  Future<void> addBudget(Budget budget) {
    return _remote.createBudget(budget);
  }
}
