import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../home/domain/models/transaction.dart';
import '../../../home/presentation/providers/transaction_provider.dart';
import '../../domain/usecases/analysis_aggregator.dart';

class AnalysisHistoryScreen extends ConsumerWidget {
  const AnalysisHistoryScreen({
    super.key,
    required this.type,
  });

  final TransactionType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionProvider);
    final title = type == TransactionType.income ? 'Income History' : 'Expense History';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title, style: AppTextStyles.headingMedium),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feature coming soon')),
              );
            },
            icon: const Icon(Icons.calendar_today_outlined),
          ),
        ],
      ),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (allTransactions) {
          final filtered = AnalysisAggregator.sortLatest(
            AnalysisAggregator.filterByType(allTransactions, type),
          );
          final total = AnalysisAggregator.totalAmount(filtered);

          if (filtered.isEmpty) {
            return Center(
              child: Text(
                'No ${type.name} transactions yet',
                style: AppTextStyles.body,
              ),
            );
          }

          final grouped = _groupByMonth(filtered);
          final monthKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
          final monthHeader = DateFormat('MMMM yyyy');
          final dateTimeFormat = DateFormat('MMM dd, HH:mm');

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Center(
                child: Column(
                  children: [
                    Text(
                      type == TransactionType.income ? 'Total Income' : 'Total Expense',
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      CurrencyFormatter.format(amount: total, currency: 'INR'),
                      style: AppTextStyles.amount.copyWith(
                        color: type == TransactionType.income
                            ? AppColors.primaryDark
                            : AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              for (final monthKey in monthKeys) ...[
                Text(monthHeader.format(DateTime.parse('$monthKey-01')), style: AppTextStyles.headingMedium),
                const SizedBox(height: AppSpacing.md),
                ...grouped[monthKey]!.map((tx) {
                  final isIncome = tx.type == TransactionType.income;
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isIncome ? Icons.attach_money : Icons.money_off_csred_rounded,
                            color: AppColors.primaryDark,
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
                                    : (isIncome ? 'Income' : 'Expense'),
                                style: AppTextStyles.headingSmall,
                              ),
                              Text(
                                dateTimeFormat.format(tx.transactionDate),
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${isIncome ? '+' : '-'}${CurrencyFormatter.format(amount: tx.amount, currency: 'INR')}',
                          style: AppTextStyles.body.copyWith(
                            color: isIncome ? AppColors.primaryDark : AppColors.danger,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: AppSpacing.md),
              ],
            ],
          );
        },
      ),
    );
  }

  Map<String, List<Transaction>> _groupByMonth(List<Transaction> transactions) {
    final grouped = <String, List<Transaction>>{};
    final keyFormat = DateFormat('yyyy-MM');

    for (final tx in transactions) {
      final key = keyFormat.format(tx.transactionDate);
      grouped.putIfAbsent(key, () => <Transaction>[]).add(tx);
    }
    return grouped;
  }
}
