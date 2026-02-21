import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

import '../../domain/models/budget.dart';
import '../providers/budget_transactions_provider.dart';
import '../../../home/presentation/screens/add_transaction_screen.dart';

class BudgetDetailScreen extends ConsumerWidget {
  final Budget budget;

  const BudgetDetailScreen({super.key, required this.budget});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync =
        ref.watch(budgetTransactionsProvider(budget.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(budget.name, style: AppTextStyles.headingMedium),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Budget Summary Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    CurrencyFormatter.format(
                      amount: budget.amount,
                      currency: budget.currency,
                    ),
                    style: AppTextStyles.headingLarge
                        .copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Spent: ${CurrencyFormatter.format(amount: budget.spent, currency: budget.currency)}',
                    style: AppTextStyles.body
                        .copyWith(color: Colors.white70),
                  ),
                  Text(
                    'Remaining: ${CurrencyFormatter.format(amount: budget.remaining, currency: budget.currency)}',
                    style: AppTextStyles.body
                        .copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: budget.progress,
                    backgroundColor: Colors.white24,
                    valueColor:
                        const AlwaysStoppedAnimation(Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            /// Add More Button
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddTransactionScreen(
                        preselectedBudgetId: budget.id,
                      ),
                    ),
                  );
                },
                child: const Text('Add More'),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            const Text(
              'Expenditure',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: AppSpacing.md),

            /// Transactions List
            Expanded(
              child: transactionsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(e.toString())),
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return const Center(
                      child: Text('No transactions yet'),
                    );
                  }

                  return ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final tx = transactions[index];

                      return ListTile(
                        title: Text(tx.description ?? 'Expense'),
                        trailing: Text(
                          CurrencyFormatter.format(
                            amount: tx.amount,
                            currency: budget.currency,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}