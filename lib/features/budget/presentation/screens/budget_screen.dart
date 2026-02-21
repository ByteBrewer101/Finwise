import 'package:finwise/features/budget/presentation/screens/budget_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:finwise/core/theme/app_spacing.dart';

import '../../domain/models/budget.dart';
import '../../domain/models/budget_summary.dart';

import '../providers/budget_provider.dart';

import '../widgets/budget_header.dart';
import '../widgets/budget_summary_card.dart';
import '../widgets/budget_grid_section.dart';
import 'set_budget_screen.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.watch(budgetListProvider);

    return Scaffold(
      body: SafeArea(
        child: budgetAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (budgets) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BudgetHeader(),

                  const SizedBox(height: AppSpacing.lg),

                  BudgetSummaryCard(
                    summary: _buildSummaryFromBudgets(budgets),
                    currencySymbol: '₹',
                    onAddMore: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SetBudgetScreen(),
                        ),
                      );
                    },
                    onRebalance: () {},
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  BudgetGridSection(
                    budgets: budgets,
                    onPrimaryTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SetBudgetScreen(),
                        ),
                      );
                    },
                    onBudgetTap: (budget) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BudgetDetailScreen(budget: budget),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Build summary dynamically
  static BudgetSummary _buildSummaryFromBudgets(List<Budget> budgets) {
    double total = 0;
    double cash = 0;
    double cashless = 0;

    for (final b in budgets) {
      total += b.amount;

      if (b.walletName?.toLowerCase() == 'cash') {
        cash += b.amount;
      } else {
        cashless += b.amount;
      }
    }

    return BudgetSummary(
      totalBalance: total,
      cashless: cashless,
      cash: cash,
      growthPercentage: 0,
      isGrowthPositive: true,
    );
  }
}
