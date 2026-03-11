import 'package:intl/intl.dart';

import '../../../home/domain/models/category.dart';
import '../../../home/domain/models/transaction.dart';
import '../../../goals/domain/models/goal.dart';
import '../../../budget/domain/models/budget.dart';
import '../models/analysis_models.dart';

class AnalysisAggregator {
  AnalysisAggregator._();

  static List<Transaction> filterByType(
    List<Transaction> transactions,
    TransactionType type,
  ) {
    return transactions.where((tx) => tx.type == type).toList();
  }

  static List<Transaction> sortLatest(List<Transaction> transactions) {
    final sorted = [...transactions]
      ..sort((a, b) {
        final byDate = b.transactionDate.compareTo(a.transactionDate);
        if (byDate != 0) return byDate;
        return b.createdAt.compareTo(a.createdAt);
      });
    return sorted;
  }

  static double totalAmount(List<Transaction> transactions) {
    return transactions.fold<double>(0, (sum, tx) => sum + tx.amount);
  }

  static List<MonthlyAmountPoint> monthlySeries(
    List<Transaction> transactions, {
    int months = 7,
  }) {
    if (transactions.isEmpty) return const [];

    final grouped = <String, double>{};
    final keyFormat = DateFormat('yyyy-MM');
    final labelFormat = DateFormat('MMM');

    for (final tx in transactions) {
      final key = keyFormat.format(tx.transactionDate);
      grouped[key] = (grouped[key] ?? 0) + tx.amount;
    }

    final keys = grouped.keys.toList()..sort();
    final recentKeys = keys.length > months ? keys.sublist(keys.length - months) : keys;

    return recentKeys
        .map(
          (key) => MonthlyAmountPoint(
            label: labelFormat.format(DateTime.parse('$key-01')),
            amount: grouped[key] ?? 0,
          ),
        )
        .toList();
  }

  static List<CategoryBreakdownItem> expenseByCategory(
    List<Transaction> expenses,
    List<Category> categories,
  ) {
    final categoryNames = {
      for (final c in categories) c.id: c.name,
    };

    final grouped = <String, double>{};
    for (final tx in expenses) {
      final key = tx.categoryId == null || tx.categoryId!.isEmpty
          ? 'Uncategorized'
          : (categoryNames[tx.categoryId!] ?? 'Uncategorized');
      grouped[key] = (grouped[key] ?? 0) + tx.amount;
    }

    final items = grouped.entries
        .map((e) => CategoryBreakdownItem(categoryName: e.key, amount: e.value))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    return items;
  }

  static AnalysisSavingSummary savingSummary(
    List<Goal> goals,
  ) {
    final totalSaved = goals.fold<double>(0, (sum, g) => sum + g.currentAmount);
    final completedCount = goals
        .where((g) => g.targetAmount > 0 && g.currentAmount >= g.targetAmount)
        .length;
    final completedPercent =
        goals.isEmpty ? 0.0 : (completedCount / goals.length).clamp(0.0, 1.0);

    return AnalysisSavingSummary(
      totalSavedAmount: totalSaved,
      completedGoalsCount: completedCount,
      completedGoalsPercent: completedPercent,
    );
  }

  static List<Goal> goalPreview(List<Goal> goals, {int maxItems = 3}) {
    final sorted = [...goals]
      ..sort((a, b) {
        final aComplete = a.targetAmount > 0 && a.currentAmount >= a.targetAmount;
        final bComplete = b.targetAmount > 0 && b.currentAmount >= b.targetAmount;
        if (aComplete != bComplete) return aComplete ? 1 : -1;
        final byProgress = b.progress.compareTo(a.progress);
        if (byProgress != 0) return byProgress;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    return sorted.take(maxItems).toList();
  }

  static List<Budget> budgetPreview(List<Budget> budgets, {int maxItems = 3}) {
    final sorted = [...budgets]
      ..sort((a, b) {
        final byProgress = b.progress.compareTo(a.progress);
        if (byProgress != 0) return byProgress;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    return sorted.take(maxItems).toList();
  }
}
