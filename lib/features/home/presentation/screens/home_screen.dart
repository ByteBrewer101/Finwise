import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/global_providers.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../services/sync/sync_service.dart';
import '../../../budget/presentation/providers/budget_provider.dart';
import '../../../goals/presentation/providers/goals_provider.dart';

import '../providers/transaction_provider.dart';
import '../providers/wallet_provider.dart';

import '../../domain/models/portfolio_summary.dart';

import '../widgets/home_header.dart';
import '../widgets/balance_section.dart';
import '../widgets/portfolio_card.dart';
import '../widgets/transaction_section.dart';
import 'add_transaction_screen.dart';
import 'all_transactions_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final transactionsAsync = ref.watch(transactionProvider);
    final walletsAsync = ref.watch(walletProvider);

    final userName =
        user?.userMetadata?['full_name'] ??
        user?.email?.split('@').first ??
        'User';

    void showComingSoon() {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feature coming soon')),
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (transactions) {
          return walletsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(e.toString())),
            data: (wallets) {
              final totalBalance = wallets.fold<double>(
                0,
                (sum, wallet) => sum + wallet.balance,
              );
              final isEmptyState = transactions.isEmpty && totalBalance <= 0;

              final portfolioSummary = PortfolioSummary(
                totalValue: totalBalance,
                chartSpots: const [],
              );

              return SafeArea(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(syncServiceProvider).syncNow();
                    await ref.read(walletProvider.notifier).loadWallets();
                    await ref.read(transactionProvider.notifier).loadTransactions();
                    ref.invalidate(budgetListProvider);
                    ref.invalidate(goalsProvider);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Column(
                      children: [
                        HomeHeader(
                          userName: userName,
                          onSearchTap: showComingSoon,
                          onNotificationTap: showComingSoon,
                        ),

                        const SizedBox(height: AppSpacing.lg),
                        if (isEmptyState) ...[
                          const SizedBox(height: 90),
                          Text(
                            'Your FinWise is empty',
                            style: AppTextStyles.headingMedium,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                            child: Text(
                              'First, connect your bank account or start tracking your expenses manually',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => context.go(AppRoutes.goals),
                                child: const Text('Add Goals and Markets'),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                            child: SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AddTransactionScreen(),
                                    ),
                                  );
                                },
                                child: const Text('Add Investments Manually'),
                              ),
                            ),
                          ),
                        ] else ...[
                          BalanceSection(
                            amount: totalBalance,
                            title: 'Total Pocket Balance',
                            onDetailTap: showComingSoon,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          PortfolioCard(
                            summary: portfolioSummary,
                            transactions: transactions,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _HomeCategories(
                            onInvestmentsTap: () => context.go(AppRoutes.budget),
                            onMarketsTap: showComingSoon,
                            onSavingsTap: () => context.go(AppRoutes.analysis),
                            onGoalsTap: () => context.go(AppRoutes.goals),
                            onSeeMoreTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AllTransactionsScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TransactionSection(
                            transactions: transactions,
                            showHeader: false,
                            onSeeMore: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AllTransactionsScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _HomeCategories extends StatelessWidget {
  final VoidCallback onInvestmentsTap;
  final VoidCallback onMarketsTap;
  final VoidCallback onSavingsTap;
  final VoidCallback onGoalsTap;
  final VoidCallback onSeeMoreTap;

  const _HomeCategories({
    required this.onInvestmentsTap,
    required this.onMarketsTap,
    required this.onSavingsTap,
    required this.onGoalsTap,
    required this.onSeeMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget tile({
      required String label,
      required IconData icon,
      required VoidCallback onTap,
      bool highlighted = false,
    }) {
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            height: 84,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: highlighted ? const Color(0xFF09241F) : AppColors.card,
              borderRadius: BorderRadius.circular(14),
              boxShadow: highlighted
                  ? null
                  : const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: highlighted ? Colors.white : AppColors.primary,
                  size: 20,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: highlighted ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Categories', style: AppTextStyles.headingLarge),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              tile(
                label: 'Investments',
                icon: Icons.savings_outlined,
                onTap: onInvestmentsTap,
                highlighted: true,
              ),
              tile(
                label: 'Markets',
                icon: Icons.credit_card,
                onTap: onMarketsTap,
              ),
              tile(
                label: 'Savings',
                icon: Icons.account_balance,
                onTap: onSavingsTap,
              ),
              tile(
                label: 'Goals',
                icon: Icons.show_chart,
                onTap: onGoalsTap,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Investment History', style: AppTextStyles.headingLarge),
                  Text('This month', style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
                ],
              ),
              GestureDetector(
                onTap: onSeeMoreTap,
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
        ],
      ),
    );
  }
}
