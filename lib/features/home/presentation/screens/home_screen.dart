import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:finwise/core/theme/app_spacing.dart';

import 'package:finwise/features/home/presentation/widgets/home_header.dart';
import 'package:finwise/features/home/presentation/widgets/balance_section.dart';
import 'package:finwise/features/home/presentation/widgets/portfolio_card.dart';
import 'package:finwise/features/home/presentation/widgets/categories_section.dart';
import 'package:finwise/features/home/presentation/widgets/transaction_section.dart';

import 'package:finwise/features/home/domain/models/transaction.dart';
import 'package:finwise/features/home/domain/models/category.dart';
import 'package:finwise/features/home/domain/models/portfolio_summary.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = Supabase.instance.client.auth.currentUser;

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

    const portfolioSummary = PortfolioSummary(
      totalValue: 24580,
      chartSpots: [
        FlSpot(0, 3),
        FlSpot(1, 2),
        FlSpot(2, 5),
        FlSpot(3, 3.5),
        FlSpot(4, 6),
        FlSpot(5, 4),
      ],
    );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              HomeHeader(userName: userName),

              const SizedBox(height: AppSpacing.lg),
              const BalanceSection(amount: 24580.00),

              const SizedBox(height: AppSpacing.lg),
              const PortfolioCard(summary: portfolioSummary),

              const SizedBox(height: AppSpacing.lg),
              const CategoriesSection(categories: categories),

              const SizedBox(height: AppSpacing.lg),

              TransactionSection(
                transactions: [
                  Transaction(
                    title: "Salary",
                    subtitle: "Company Inc.",
                    amount: 50000,
                    type: TransactionType.income,
                    date: DateTime.now(),
                  ),
                  Transaction(
                    title: "Groceries",
                    subtitle: "Supermarket",
                    amount: 2400,
                    type: TransactionType.expense,
                    date: DateTime.now(),
                  ),
                ],
                onSeeMore: () {
                  // TODO: Navigate to full transaction page
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
