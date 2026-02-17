import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/global_providers.dart';
import '../../../../core/theme/app_spacing.dart';

import '../providers/transaction_provider.dart';
import '../providers/wallet_provider.dart';

import '../../domain/models/category.dart';
import '../../domain/models/portfolio_summary.dart';

import '../widgets/home_header.dart';
import '../widgets/balance_section.dart';
import '../widgets/portfolio_card.dart';
import '../widgets/categories_section.dart';
import '../widgets/transaction_section.dart';
import 'add_transaction_screen.dart';

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

    const categories = [
      Category(label: 'Investments', icon: Icons.trending_up, isPrimary: true),
      Category(label: 'Markets', icon: Icons.show_chart),
      Category(label: 'Savings', icon: Icons.savings),
      Category(label: 'Goals', icon: Icons.flag),
    ];

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

              final portfolioSummary = PortfolioSummary(
                totalValue: totalBalance,
                chartSpots: const [],
              );

              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    children: [
                      HomeHeader(userName: userName),

                      const SizedBox(height: AppSpacing.lg),
                      BalanceSection(amount: totalBalance),

                      const SizedBox(height: AppSpacing.lg),
                      PortfolioCard(summary: portfolioSummary),

                      const SizedBox(height: AppSpacing.lg),
                      const CategoriesSection(categories: categories),

                      const SizedBox(height: AppSpacing.lg),

                      TransactionSection(
                        transactions: transactions,
                        onSeeMore: () {},
                      ),
                    ],
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
