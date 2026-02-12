import 'package:flutter/material.dart';
import 'package:finwise/core/theme/app_spacing.dart';
import 'package:finwise/core/theme/app_text_styles.dart';
import 'package:finwise/core/theme/app_colors.dart';
import 'package:finwise/core/theme/app_radius.dart';

import '../../domain/models/budget_category.dart';

class BudgetGridSection extends StatelessWidget {
  final List<BudgetCategory> categories;
  final Function(BudgetCategory)? onCategoryTap;

  const BudgetGridSection({
    super.key,
    required this.categories,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final category = categories[index];

        return GestureDetector(
          onTap: () => onCategoryTap?.call(category),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: category.isPrimary ? Colors.black : AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: category.isPrimary
                  ? null
                  : const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
            ),
            child: category.isPrimary
                ? const _PrimaryBudgetCard()
                : _BudgetProgressCard(category: category),
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
        Text('Set Budget', style: AppTextStyles.body),
      ],
    );
  }
}

class _BudgetProgressCard extends StatelessWidget {
  final BudgetCategory category;

  const _BudgetProgressCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final progress = category.percentage / 100;

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
                '${category.percentage.toStringAsFixed(0)}%',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          category.title,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
