import 'package:flutter/material.dart';
import 'package:finwise/core/theme/app_spacing.dart';
import 'package:finwise/core/theme/app_text_styles.dart';
import 'package:finwise/core/theme/app_colors.dart';
import 'package:finwise/core/theme/app_radius.dart';

import '../../domain/models/budget.dart';

class BudgetGridSection extends StatelessWidget {
  final List<Budget> budgets;
  final VoidCallback? onPrimaryTap;
  final Function(Budget)? onBudgetTap;

  const BudgetGridSection({
    super.key,
    required this.budgets,
    this.onPrimaryTap,
    this.onBudgetTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: budgets.length + 1, // +1 for Set Budget
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        // Primary card
        if (index == 0) {
          return GestureDetector(
            onTap: onPrimaryTap,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: const _PrimaryBudgetCard(),
            ),
          );
        }

        final budget = budgets[index - 1];

        return GestureDetector(
          onTap: () => onBudgetTap?.call(budget),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: _BudgetProgressCard(budget: budget),
          ),
        );
      },
    );
  }
}

class _PrimaryBudgetCard extends StatelessWidget {
  const _PrimaryBudgetCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.add, color: Colors.white, size: 32),
        SizedBox(height: AppSpacing.sm),
        Text('Set Budget', style: TextStyle(color: Colors.white)),
      ],
    );
  }
}

class _BudgetProgressCard extends StatelessWidget {
  final Budget budget;

  const _BudgetProgressCard({required this.budget});

  @override
  Widget build(BuildContext context) {
    final progress = budget.progress;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 8,
                backgroundColor: AppColors.divider,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          budget.name, // 🔥 Real budget identity
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
