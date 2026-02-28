import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../home/presentation/screens/add_transaction_screen.dart';
import '../../domain/models/budget.dart';
import '../providers/budget_provider.dart';
import '../providers/budget_transactions_provider.dart';

class BudgetDetailScreen extends ConsumerWidget {
  final Budget budget;

  const BudgetDetailScreen({super.key, required this.budget});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveBudgetAsync = ref.watch(budgetListProvider);
    final liveBudget = liveBudgetAsync.maybeWhen(
      data: (budgets) {
        for (final b in budgets) {
          if (b.id == budget.id) return b;
        }
        return budget;
      },
      orElse: () => budget,
    );

    final transactionsAsync = ref.watch(budgetTransactionsProvider(liveBudget.id));
    final isCompleted = liveBudget.spent >= liveBudget.amount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          budget.name,
          style: AppTextStyles.headingMedium,
        ),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _BudgetHeroCard(budget: liveBudget),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              if (!isCompleted)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddTransactionScreen(
                            preselectedBudgetId: liveBudget.id,
                          ),
                        ),
                      );
                      ref.invalidate(budgetListProvider);
                      ref.invalidate(budgetTransactionsProvider(liveBudget.id));
                    },
                    child: const Text('Add more'),
                  ),
                )
              else
                Expanded(
                  child: Container(
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Completed',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.call_outlined),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Expenditure', style: AppTextStyles.headingLarge),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _dateRangeLabel(liveBudget.startDate, liveBudget.endDate),
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          transactionsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(e.toString(), style: AppTextStyles.body),
            ),
            data: (transactions) {
              if (transactions.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: Center(child: Text('No transactions yet')),
                );
              }

              final sortedTransactions = [...transactions]
                ..sort((a, b) {
                  final byDate = b.transactionDate.compareTo(a.transactionDate);
                  if (byDate != 0) return byDate;
                  return b.createdAt.compareTo(a.createdAt);
                });

              final budgetProgress = liveBudget.progress.clamp(0.0, 1.0);
              final budgetPercent = (budgetProgress * 100).toStringAsFixed(0);
              final remainingLabel =
                  CurrencyFormatter.format(
                    amount: liveBudget.remaining,
                    currency: liveBudget.currency,
                  );

              return Column(
                children: sortedTransactions.map((tx) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMuted,
                                borderRadius: BorderRadius.circular(17),
                              ),
                              child: const Icon(
                                Icons.fastfood_rounded,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tx.description?.isNotEmpty == true
                                        ? tx.description!
                                        : 'Expense',
                                    style: AppTextStyles.headingSmall,
                                  ),
                                  Text(
                                    '${liveBudget.spent >= liveBudget.amount ? 'Completed' : '$budgetPercent%'}',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: liveBudget.spent >= liveBudget.amount
                                          ? AppColors.primaryDark
                                          : AppColors.accentYellow,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  CurrencyFormatter.format(
                                    amount: tx.amount,
                                    currency: liveBudget.currency,
                                  ),
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Left $remainingLabel',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        LinearProgressIndicator(
                          value: budgetProgress,
                          minHeight: 5,
                          color: AppColors.accentYellow,
                          backgroundColor: AppColors.divider,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  String _dateRangeLabel(DateTime start, DateTime? end) {
    final f = DateFormat('d MMM yyyy');
    final endDate = end ?? DateTime.now();
    return '${f.format(start)} - ${f.format(endDate)}';
  }
}

class _BudgetHeroCard extends StatelessWidget {
  final Budget budget;

  const _BudgetHeroCard({required this.budget});

  @override
  Widget build(BuildContext context) {
    final clampedProgress = budget.progress.clamp(0.0, 1.0);
    final spentForDisplay = math.min(budget.spent, budget.amount);
    final isCompleted = budget.spent >= budget.amount;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF072821), Color(0xFF0B3930)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  CurrencyFormatter.format(amount: budget.amount, currency: budget.currency),
                  style: AppTextStyles.amount.copyWith(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _capitalize(budget.recurrence),
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          Text('Budget', style: AppTextStyles.body.copyWith(color: Colors.white70)),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 152,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final activeIndex = ((clampedProgress * 6).clamp(0, 6)).round();
                final isActive = i == activeIndex;
                final barHeight = isActive ? 82.0 : 36.0 + ((i % 4) * 11);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isActive && !isCompleted)
                      Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accentYellow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          CurrencyFormatter.symbol(budget.currency) +
                              spentForDisplay.toStringAsFixed(0),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.black87,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    Container(
                      width: 6,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.accentYellow
                            : AppColors.primary.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      const ['S', 'M', 'T', 'W', 'T', 'F', 'S'][i],
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                    ),
                  ],
                );
              }),
            ),
          ),
          if (isCompleted) ...[
            const SizedBox(height: 4),
            Text(
              'Completed',
              style: AppTextStyles.body.copyWith(
                color: AppColors.primaryLight,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}
