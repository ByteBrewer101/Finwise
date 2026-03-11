import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../budget/domain/models/budget.dart';
import '../../../budget/presentation/providers/budget_provider.dart';
import '../../../goals/domain/models/goal.dart';
import '../../../goals/presentation/providers/goals_provider.dart';
import '../../../home/domain/models/category.dart';
import '../../../home/domain/models/transaction.dart';
import '../../../home/presentation/providers/category_provider.dart';
import '../../../home/presentation/providers/transaction_provider.dart';
import '../../domain/models/analysis_models.dart';
import '../../domain/usecases/analysis_aggregator.dart';

final analysisTransactionsByTypeProvider =
    Provider.family<List<Transaction>, TransactionType>((ref, type) {
  final allTransactions = ref.watch(transactionProvider).valueOrNull ?? const <Transaction>[];
  final filtered = AnalysisAggregator.filterByType(allTransactions, type);
  return AnalysisAggregator.sortLatest(filtered);
});

final analysisMonthlySeriesProvider =
    Provider.family<List<MonthlyAmountPoint>, TransactionType>((ref, type) {
  final txs = ref.watch(analysisTransactionsByTypeProvider(type));
  return AnalysisAggregator.monthlySeries(txs, months: 7);
});

final analysisTotalByTypeProvider = Provider.family<double, TransactionType>((ref, type) {
  final txs = ref.watch(analysisTransactionsByTypeProvider(type));
  return AnalysisAggregator.totalAmount(txs);
});

final expenseCategoryBreakdownProvider = Provider<List<CategoryBreakdownItem>>((ref) {
  final expenses = ref.watch(analysisTransactionsByTypeProvider(TransactionType.expense));
  final categories = ref.watch(categoryProvider).valueOrNull ?? const <Category>[];
  return AnalysisAggregator.expenseByCategory(expenses, categories);
});

final analysisGoalsProvider = Provider<List<Goal>>((ref) {
  return ref.watch(goalsProvider).valueOrNull ?? const <Goal>[];
});

final analysisBudgetsProvider = Provider<List<Budget>>((ref) {
  return ref.watch(budgetListProvider).valueOrNull ?? const <Budget>[];
});

final analysisSavingSummaryProvider = Provider<AnalysisSavingSummary>((ref) {
  final goals = ref.watch(analysisGoalsProvider);
  return AnalysisAggregator.savingSummary(goals);
});

final goalsPreviewProvider = Provider<List<Goal>>((ref) {
  final goals = ref.watch(analysisGoalsProvider);
  return AnalysisAggregator.goalPreview(goals, maxItems: 3);
});

final budgetsPreviewProvider = Provider<List<Budget>>((ref) {
  final budgets = ref.watch(analysisBudgetsProvider);
  return AnalysisAggregator.budgetPreview(budgets, maxItems: 3);
});

final hasMoreGoalsProvider = Provider<bool>((ref) {
  final goals = ref.watch(analysisGoalsProvider);
  return goals.length > 3;
});

final hasMoreBudgetsProvider = Provider<bool>((ref) {
  final budgets = ref.watch(analysisBudgetsProvider);
  return budgets.length > 3;
});
