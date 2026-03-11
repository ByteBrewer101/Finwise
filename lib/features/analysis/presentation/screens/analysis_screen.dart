import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../budget/presentation/providers/budget_provider.dart';
import '../../../goals/presentation/providers/goals_provider.dart';
import '../../../home/domain/models/transaction.dart';
import '../../../home/presentation/providers/transaction_provider.dart';
import '../../domain/models/analysis_models.dart';
import '../providers/analysis_provider.dart';
import 'analysis_history_screen.dart';

class AnalysisScreen extends ConsumerStatefulWidget {
  const AnalysisScreen({super.key});

  @override
  ConsumerState<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends ConsumerState<AnalysisScreen> {
  int _selectedTab = 0;
  bool _showSavingTable = false;

  Future<void> _openHistory(TransactionType type) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnalysisHistoryScreen(type: type),
      ),
    );
    if (!mounted) return;
    ref.invalidate(transactionProvider);
    ref.invalidate(goalsProvider);
    ref.invalidate(budgetListProvider);
  }

  @override
  Widget build(BuildContext context) {
    final tabs = ['Income', 'Expenses', 'Saving'];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Financial Analysis', style: AppTextStyles.headingMedium),
                  ),
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Feature coming soon')),
                      );
                    },
                    icon: const Icon(Icons.notifications_none),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  children: List.generate(tabs.length, (index) {
                    final selected = _selectedTab == index;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeInOut,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                          ),
                          child: Text(
                            tabs[index],
                            style: AppTextStyles.body.copyWith(
                              color: selected ? Colors.white : AppColors.textMuted,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: IndexedStack(
                index: _selectedTab,
                children: [
                  _IncomeTab(onSeeMore: () => _openHistory(TransactionType.income)),
                  _ExpenseTab(onSeeMore: () => _openHistory(TransactionType.expense)),
                  _SavingTab(
                    showTable: _showSavingTable,
                    onToggle: (showTable) => setState(() => _showSavingTable = showTable),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IncomeTab extends ConsumerWidget {
  const _IncomeTab({required this.onSeeMore});

  final VoidCallback onSeeMore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionProvider);
    final incomes = ref.watch(analysisTransactionsByTypeProvider(TransactionType.income));
    final totalIncome = ref.watch(analysisTotalByTypeProvider(TransactionType.income));
    final monthly = ref.watch(analysisMonthlySeriesProvider(TransactionType.income));

    return transactionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (_) {
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          children: [
            Text('Total Income', style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 4),
            Text(
              CurrencyFormatter.format(amount: totalIncome, currency: 'INR'),
              style: AppTextStyles.amount.copyWith(color: AppColors.primaryDark),
            ),
            const SizedBox(height: AppSpacing.md),
            _AnalysisBarChart(points: monthly),
            const SizedBox(height: AppSpacing.md),
            _HistorySection(
              heading: 'Transaction History',
              transactions: incomes.take(5).toList(),
              onSeeMore: onSeeMore,
            ),
            const SizedBox(height: 90),
          ],
        );
      },
    );
  }
}

class _ExpenseTab extends ConsumerWidget {
  const _ExpenseTab({required this.onSeeMore});

  final VoidCallback onSeeMore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionProvider);
    final expenses = ref.watch(analysisTransactionsByTypeProvider(TransactionType.expense));
    final incomesTotal = ref.watch(analysisTotalByTypeProvider(TransactionType.income));
    final expenseTotal = ref.watch(analysisTotalByTypeProvider(TransactionType.expense));
    final monthly = ref.watch(analysisMonthlySeriesProvider(TransactionType.expense));
    final categoryBreakdown = ref.watch(expenseCategoryBreakdownProvider);
    final net = incomesTotal - expenseTotal;

    return transactionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (_) {
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Expenses',
                        style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.format(amount: expenseTotal, currency: 'INR'),
                        style: AppTextStyles.amount.copyWith(color: AppColors.primaryDark),
                      ),
                    ],
                  ),
                ),
                if (net < 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEC4899),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '-${CurrencyFormatter.format(amount: net.abs(), currency: 'INR')}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _AnalysisBarChart(points: monthly),
            if (categoryBreakdown.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Category Breakdown', style: AppTextStyles.headingSmall),
                    const SizedBox(height: AppSpacing.sm),
                    ...categoryBreakdown.take(4).map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(item.categoryName, style: AppTextStyles.body),
                            ),
                            Text(
                              CurrencyFormatter.format(amount: item.amount, currency: 'INR'),
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.danger,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            _HistorySection(
              heading: 'Transaction History',
              transactions: expenses.take(5).toList(),
              onSeeMore: onSeeMore,
            ),
            const SizedBox(height: 90),
          ],
        );
      },
    );
  }
}

class _SavingTab extends ConsumerWidget {
  const _SavingTab({
    required this.showTable,
    required this.onToggle,
  });

  final bool showTable;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);
    final budgetsAsync = ref.watch(budgetListProvider);
    final incomeMonthly = ref.watch(analysisMonthlySeriesProvider(TransactionType.income));
    final savingSummary = ref.watch(analysisSavingSummaryProvider);
    final goalsPreview = ref.watch(goalsPreviewProvider);
    final budgetsPreview = ref.watch(budgetsPreviewProvider);
    final hasMoreGoals = ref.watch(hasMoreGoalsProvider);
    final hasMoreBudgets = ref.watch(hasMoreBudgetsProvider);

    return goalsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (goals) {
        return budgetsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(e.toString())),
          data: (budgets) {
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Saved Balance',
                              style: AppTextStyles.headingSmall.copyWith(color: Colors.white),
                            ),
                          ),
                          _MiniToggleChip(
                            label: 'Chart',
                            selected: !showTable,
                            onTap: () => onToggle(false),
                          ),
                          const SizedBox(width: 6),
                          _MiniToggleChip(
                            label: 'Table',
                            selected: showTable,
                            onTap: () => onToggle(true),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.format(
                          amount: savingSummary.totalSavedAmount,
                          currency: 'INR',
                        ),
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 240),
                        child: showTable
                            ? _SavingGoalsTable(
                                goalsCount: goals.length,
                                totalSaved: savingSummary.totalSavedAmount,
                              )
                            : _SavingMiniChart(points: incomeMonthly),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF072821), Color(0xFF0B3930)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Target completed',
                              style: AppTextStyles.headingSmall.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: () => context.go(AppRoutes.goals),
                              child: Text(
                                'View',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.primaryLight,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () => context.go(AppRoutes.goals),
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: savingSummary.completedGoalsPercent,
                                strokeWidth: 5,
                                backgroundColor: Colors.white24,
                                valueColor:
                                    const AlwaysStoppedAnimation(Color(0xFF56C7D8)),
                              ),
                              Text(
                                '${(savingSummary.completedGoalsPercent * 100).toStringAsFixed(0)}%',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _SavingsGoalsSection(
                  goalsCount: goals.length,
                  completedGoalsCount: savingSummary.completedGoalsCount,
                  hasMoreGoals: hasMoreGoals,
                  onSeeMore: () => context.go(AppRoutes.goals),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...goalsPreview.map((goal) {
                  final progress = goal.progress.clamp(0.0, 1.0);
                  final isComplete = progress >= 1;
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                goal.name,
                                style: AppTextStyles.headingSmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              CurrencyFormatter.format(
                                amount: goal.currentAmount,
                                currency: goal.currency,
                              ),
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              '${(progress * 100).toStringAsFixed(0)}%',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isComplete ? AppColors.primaryDark : AppColors.accentYellow,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (isComplete) ...[
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                'Completed',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                            const Spacer(),
                            Text(
                              'of ${CurrencyFormatter.format(amount: goal.targetAmount, currency: goal.currency)}',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: progress,
                          minHeight: 4,
                          backgroundColor: AppColors.divider,
                          color: AppColors.accentYellow,
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: AppSpacing.md),
                _SavingsBudgetSection(
                  budgetsCount: budgets.length,
                  hasMoreBudgets: hasMoreBudgets,
                  onSeeMore: () => context.go(AppRoutes.budget),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...budgetsPreview.map((budget) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(budget.name, style: AppTextStyles.headingSmall),
                              const SizedBox(height: 4),
                              Text(
                                '${(budget.progress * 100).toStringAsFixed(0)}% used',
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              CurrencyFormatter.format(amount: budget.spent, currency: budget.currency),
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.danger,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'of ${CurrencyFormatter.format(amount: budget.amount, currency: budget.currency)}',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 90),
              ],
            );
          },
        );
      },
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection({
    required this.heading,
    required this.transactions,
    required this.onSeeMore,
  });

  final String heading;
  final List<Transaction> transactions;
  final VoidCallback onSeeMore;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(heading, style: AppTextStyles.headingLarge)),
            GestureDetector(
              onTap: onSeeMore,
              child: Text(
                'See More',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (transactions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Text('No transactions yet', style: AppTextStyles.body),
          )
        else
          ...transactions.map((tx) {
            final isIncome = tx.type == TransactionType.income;
            return Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: (isIncome ? AppColors.primary : AppColors.danger)
                        .withValues(alpha: 0.12),
                    child: Icon(
                      isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                      color: isIncome ? AppColors.primaryDark : AppColors.danger,
                    ),
                  ),
                  title: Text(
                    tx.description?.isNotEmpty == true
                        ? tx.description!
                        : (isIncome ? 'Income' : 'Expense'),
                    style: AppTextStyles.headingSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${tx.transactionDate.day}/${tx.transactionDate.month}/${tx.transactionDate.year}',
                    style: AppTextStyles.bodySmall,
                  ),
                  trailing: Text(
                    '${isIncome ? '+' : '-'}${CurrencyFormatter.format(amount: tx.amount, currency: 'INR')}',
                    style: AppTextStyles.body.copyWith(
                      color: isIncome ? AppColors.primaryDark : AppColors.danger,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Divider(height: 8),
              ],
            );
          }),
      ],
    );
  }
}

class _AnalysisBarChart extends StatelessWidget {
  const _AnalysisBarChart({required this.points});

  final List<MonthlyAmountPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text('No data available', style: AppTextStyles.body),
      );
    }

    final maxAmount = points
        .map((p) => p.amount)
        .reduce((a, b) => a > b ? a : b)
        .clamp(1, double.infinity);
    final peakIndex = points.indexWhere((p) => p.amount == maxAmount);

    return Container(
      height: 250,
      padding: const EdgeInsets.fromLTRB(10, 16, 10, 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RotatedBox(
                  quarterTurns: 3,
                  child: Text('Yearly', style: AppTextStyles.bodySmall),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Text(
                      'Monthly',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                RotatedBox(
                  quarterTurns: 3,
                  child: Text('Weekly', style: AppTextStyles.bodySmall),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(points.length, (index) {
                      final p = points[index];
                      final isPeak = index == peakIndex;
                      final ratio = (p.amount / maxAmount).clamp(0.0, 1.0);
                      final barHeight = 40 + (ratio * 120);

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (isPeak)
                            Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.accentYellow,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                CurrencyFormatter.symbol('INR') + p.amount.toStringAsFixed(0),
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          Container(
                            width: 6,
                            height: barHeight,
                            decoration: BoxDecoration(
                              color: isPeak ? AppColors.accentYellow : AppColors.divider,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: points.map((p) => Text(p.label, style: AppTextStyles.bodySmall)).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniToggleChip extends StatelessWidget {
  const _MiniToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? Colors.white.withValues(alpha: 0.22) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.white,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _SavingMiniChart extends StatelessWidget {
  const _SavingMiniChart({required this.points});

  final List<MonthlyAmountPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return SizedBox(
        key: const ValueKey('saving-chart-empty'),
        height: 120,
        child: Center(
          child: Text(
            'No chart data',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
          ),
        ),
      );
    }

    final spots = <FlSpot>[
      for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].amount),
    ];
    final minY = spots.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    final pad = ((maxY - minY).abs() * 0.2).clamp(100, 10000).toDouble();

    return SizedBox(
      key: const ValueKey('saving-chart'),
      height: 120,
      child: LineChart(
        LineChartData(
          minY: minY - pad,
          maxY: maxY + pad,
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.white,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0x1FFFFFFF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavingGoalsTable extends StatelessWidget {
  const _SavingGoalsTable({
    required this.goalsCount,
    required this.totalSaved,
  });

  final int goalsCount;
  final double totalSaved;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('saving-table'),
      height: 120,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Active goals: $goalsCount',
            style: AppTextStyles.body.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Total saved: ${CurrencyFormatter.format(amount: totalSaved, currency: 'INR')}',
            style: AppTextStyles.body.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SavingsGoalsSection extends StatelessWidget {
  const _SavingsGoalsSection({
    required this.goalsCount,
    required this.completedGoalsCount,
    required this.hasMoreGoals,
    required this.onSeeMore,
  });

  final int goalsCount;
  final int completedGoalsCount;
  final bool hasMoreGoals;
  final VoidCallback onSeeMore;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text('Goals Progress', style: AppTextStyles.headingLarge)),
        Text(
          '$completedGoalsCount/$goalsCount',
          style: AppTextStyles.body.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (hasMoreGoals) ...[
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: onSeeMore,
            child: Text(
              'See More',
              style: AppTextStyles.body.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SavingsBudgetSection extends StatelessWidget {
  const _SavingsBudgetSection({
    required this.budgetsCount,
    required this.hasMoreBudgets,
    required this.onSeeMore,
  });

  final int budgetsCount;
  final bool hasMoreBudgets;
  final VoidCallback onSeeMore;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text('Budget Control', style: AppTextStyles.headingLarge)),
        Text(
          '$budgetsCount',
          style: AppTextStyles.body.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (hasMoreBudgets) ...[
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: onSeeMore,
            child: Text(
              'See More',
              style: AppTextStyles.body.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
