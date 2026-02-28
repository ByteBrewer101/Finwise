import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/global_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../home/presentation/providers/wallet_provider.dart';
import '../../domain/models/budget.dart';
import '../providers/budget_provider.dart';
import 'budget_detail_screen.dart';
import 'set_budget_screen.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.watch(budgetListProvider);
    final walletsAsync = ref.watch(walletProvider);
    final user = ref.watch(currentUserProvider);

    final userName =
        user?.userMetadata?['full_name'] ?? user?.email?.split('@').first ?? 'User';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: budgetAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (budgets) {
            return walletsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (wallets) {
                final totalWalletBalance = wallets.fold<double>(
                  0,
                  (sum, w) => sum + w.balance,
                );

                final cashBalance = wallets
                    .where((w) => w.type.toLowerCase() == 'cash')
                    .fold<double>(0, (sum, w) => sum + w.balance);

                final cashlessBalance = (totalWalletBalance - cashBalance).clamp(
                  0,
                  double.infinity,
                ).toDouble();

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _BudgetTopHeader(userName: userName),
                      const SizedBox(height: AppSpacing.md),
                      _BudgetTotalCard(
                        totalBalance: totalWalletBalance,
                        cashBalance: cashBalance,
                        cashlessBalance: cashlessBalance,
                        onAddMore: () => _openSetBudget(context),
                        onRebalance: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Re-balancing coming soon')),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text('Budgeting', style: AppTextStyles.headingLarge),
                      const SizedBox(height: AppSpacing.md),
                      _BudgetGrid(
                        budgets: budgets,
                        onSetBudgetTap: () => _openSetBudget(context),
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
            );
          },
        ),
      ),
    );
  }

  void _openSetBudget(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SetBudgetScreen()),
    );
  }
}

class _BudgetTopHeader extends StatelessWidget {
  final String userName;

  const _BudgetTopHeader({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.surfaceMuted,
          child: Icon(Icons.person, size: 18, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome', style: AppTextStyles.bodySmall),
              Text(
                userName,
                style: AppTextStyles.headingSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none),
        ),
      ],
    );
  }
}

class _BudgetTotalCard extends StatelessWidget {
  final double totalBalance;
  final double cashlessBalance;
  final double cashBalance;
  final VoidCallback onAddMore;
  final VoidCallback onRebalance;

  const _BudgetTotalCard({
    required this.totalBalance,
    required this.cashlessBalance,
    required this.cashBalance,
    required this.onAddMore,
    required this.onRebalance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Balance', style: AppTextStyles.headingMedium),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Text(
                CurrencyFormatter.format(amount: totalBalance, currency: 'INR'),
                style: AppTextStyles.amount.copyWith(color: AppColors.primaryDark),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '+${_growthPercent(totalBalance).toStringAsFixed(1)}%',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _MoneySplit(
                  label: 'Cashless',
                  amount: cashlessBalance,
                ),
              ),
              Container(
                height: 26,
                width: 1,
                color: AppColors.divider,
              ),
              Expanded(
                child: _MoneySplit(
                  label: 'Cash',
                  amount: cashBalance,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onAddMore,
                  child: const Text('Add more'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ElevatedButton(
                  onPressed: onRebalance,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF23C9D9)),
                  child: const Text(
                    'Re-Balancing',
                    style: TextStyle(color: Colors.white),
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
        ],
      ),
    );
  }

  double _growthPercent(double totalBalance) {
    if (totalBalance <= 0) return 0;
    return (totalBalance / 100000).clamp(0, 99);
  }
}

class _MoneySplit extends StatelessWidget {
  final String label;
  final double amount;

  const _MoneySplit({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.format(amount: amount, currency: 'INR'),
            style: AppTextStyles.headingSmall,
          ),
        ],
      ),
    );
  }
}

class _BudgetGrid extends StatelessWidget {
  final List<Budget> budgets;
  final VoidCallback onSetBudgetTap;
  final ValueChanged<Budget> onBudgetTap;

  const _BudgetGrid({
    required this.budgets,
    required this.onSetBudgetTap,
    required this.onBudgetTap,
  });

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      _SetBudgetCard(onTap: onSetBudgetTap),
      ...budgets.map(
        (budget) => _BudgetCard(
          budget: budget,
          onTap: () => onBudgetTap(budget),
        ),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, index) => cards[index],
    );
  }
}

class _SetBudgetCard extends StatelessWidget {
  final VoidCallback onTap;

  const _SetBudgetCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF09241F), Color(0xFF0A2E26)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 3),
              ),
              child: const Icon(Icons.add, color: AppColors.primary, size: 30),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Set Budget',
              style: AppTextStyles.headingSmall.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final Budget budget;
  final VoidCallback onTap;

  const _BudgetCard({
    required this.budget,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 68,
              height: 68,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: budget.progress,
                    strokeWidth: 6,
                    backgroundColor: AppColors.divider,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF56C7D8)),
                  ),
                  Text(
                    '${(budget.progress * 100).toStringAsFixed(0)}%',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              budget.name,
              style: AppTextStyles.headingSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              CurrencyFormatter.format(amount: budget.amount, currency: budget.currency),
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
