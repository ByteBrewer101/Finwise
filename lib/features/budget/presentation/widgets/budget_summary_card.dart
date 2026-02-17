import 'package:flutter/material.dart';
import 'package:finwise/core/theme/app_spacing.dart';
import 'package:finwise/core/theme/app_text_styles.dart';
import 'package:finwise/core/theme/app_colors.dart';
import 'package:finwise/core/theme/app_radius.dart';
import 'package:intl/intl.dart';

import '../../domain/models/budget_summary.dart';

class BudgetSummaryCard extends StatelessWidget {
  final BudgetSummary summary;
  final String currencySymbol;
  final VoidCallback? onAddMore;
  final VoidCallback? onRebalance;

  const BudgetSummaryCard({
    super.key,
    required this.summary,
    required this.currencySymbol,
    this.onAddMore,
    this.onRebalance,
  });
  String _formatCurrency(double amount) {
    final format = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '',
      decimalDigits: 0,
    );
    return format.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title
           Text('Total Balance', style: AppTextStyles.body),

          const SizedBox(height: AppSpacing.sm),

          /// Amount + Growth Chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹ ${_formatCurrency(summary.totalBalance)}',
                style: AppTextStyles.headingLarge,
              ),

              _GrowthChip(
                percentage: summary.growthPercentage,
                isPositive: summary.isGrowthPositive,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          /// Cash split
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cashless: ₹ ${_formatCurrency(summary.cashless)}',
                style: AppTextStyles.body,
              ),
              Text(
                'Cash: ₹ ${_formatCurrency(summary.cash)}',
                style: AppTextStyles.body,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          /// Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onAddMore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),

                  child: const Text(
                    'Add More',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton(
                  onPressed: onRebalance,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: const Text('Re-Balancing'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GrowthChip extends StatelessWidget {
  final double percentage;
  final bool isPositive;

  const _GrowthChip({required this.percentage, required this.isPositive});

  @override
  Widget build(BuildContext context) {
    final color = isPositive ? AppColors.success : AppColors.danger;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          Icon(
            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: AppTextStyles.body.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
