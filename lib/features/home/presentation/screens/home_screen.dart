import 'package:finwise/shared/widgets/home/portfolio_card.dart';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/home/home_header.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/home/balance_section.dart';
import '../../../../shared/widgets/home/categories_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              HomeHeader(userName: 'Aman'),
              SizedBox(height: AppSpacing.lg),
              BalanceSection(amount: 24580.00),
              SizedBox(height: AppSpacing.lg),
              PortfolioCard(),
              SizedBox(height: AppSpacing.lg),
              CategoriesSection(),
            ],
          ),
        ),
      ),
    );
  }
}
