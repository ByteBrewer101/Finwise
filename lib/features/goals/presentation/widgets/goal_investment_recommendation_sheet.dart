import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/models/goal.dart';
import '../models/investment_recommendation.dart';

class GoalInvestmentRecommendationSheet extends StatelessWidget {
  const GoalInvestmentRecommendationSheet({
    super.key,
    required this.goal,
    required this.recommendation,
  });

  final Goal goal;
  final InvestmentRecommendation recommendation;

  static const Map<String, Color> _segmentColors = {
    'SIP': AppColors.primary,
    'Mutual Funds': AppColors.primaryDark,
    'Gold': AppColors.accentYellow,
    'Silver': Color(0xFF94A3B8),
    'Stocks': Color(0xFF6C63FF),
  };

  @override
  Widget build(BuildContext context) {
    final allocations = recommendation.allocations;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.lg,
        ),
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Investment Recommendation',
                style: AppTextStyles.headingMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                goal.name,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation.title,
                      style: AppTextStyles.headingSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Target: ${CurrencyFormatter.format(amount: goal.targetAmount, currency: goal.currency)}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                height: 220,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 46,
                    borderData: FlBorderData(show: false),
                    sections: [
                      for (final allocation in allocations)
                        PieChartSectionData(
                          color: _segmentColors[allocation.label] ?? AppColors.primary,
                          value: allocation.percentage,
                          radius: 56,
                          title: '${allocation.percentage.toStringAsFixed(0)}%',
                          titleStyle: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Recommended Allocation',
                style: AppTextStyles.headingSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              ...allocations.map(
                (allocation) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _segmentColors[allocation.label] ?? AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          allocation.label,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${allocation.percentage.toStringAsFixed(0)}%',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
