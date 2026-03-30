import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/goal_detail_providers.dart';
import '../utils/goal_investment_recommendation_engine.dart';
import '../widgets/goal_investment_recommendation_sheet.dart';
import 'add_contribution_bottom_sheet.dart';
import 'edit_goal_screen.dart';

class GoalPreviewScreen extends ConsumerWidget {
  final String goalId;

  const GoalPreviewScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = ref.watch(singleGoalProvider(goalId));
    final contributionsAsync = ref.watch(goalContributionsProvider(goalId));

    if (goal == null) {
      return const Scaffold(
        body: Center(child: Text('Goal not found')),
      );
    }

    final progressValue = goal.progress.clamp(0.0, 1.0);
    final percent = (progressValue * 100).toStringAsFixed(0);
    final isCompleted = goal.currentAmount >= goal.targetAmount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Preview Goals'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              final recommendation =
                  GoalInvestmentRecommendationEngine.pickForGoalAmount(
                goal.targetAmount,
              );

              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => GoalInvestmentRecommendationSheet(
                  goal: goal,
                  recommendation: recommendation,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditGoalScreen(goal: goal)),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.landscape_outlined, color: AppColors.primary, size: 30),
                const SizedBox(height: AppSpacing.sm),
                Text(goal.name, style: AppTextStyles.headingMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      CurrencyFormatter.format(amount: goal.currentAmount, currency: goal.currency),
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$percent%',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.accentYellow,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progressValue,
                    minHeight: 6,
                    color: AppColors.accentYellow,
                    backgroundColor: AppColors.divider,
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'out of ${CurrencyFormatter.format(amount: goal.targetAmount, currency: goal.currency)}',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: isCompleted
                    ? Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Completed',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : OutlinedButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => AddContributionBottomSheet(goal: goal),
                          );
                        },
                        child: const Text('Add more'),
                      ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    textStyle: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Contact Us'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _InfoRow(
            title: 'Contributions',
            value: CurrencyFormatter.format(
              amount: goal.currentAmount,
              currency: goal.currency,
            ),
          ),
          _InfoRow(
            title: 'Durations',
            value: _durationText(goal.startDate, goal.endDate),
          ),
          _InfoRow(
            title: 'Target Date',
            value: goal.endDate == null
                ? '-'
                : DateFormat('d MMMM yyyy').format(goal.endDate!),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Transaction', style: AppTextStyles.headingLarge),
              if (goal.endDate != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    DateFormat('yyyy').format(goal.endDate!),
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryDark),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          contributionsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text(e.toString()),
            data: (contributions) {
              if (contributions.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: Center(child: Text('No contributions yet')),
                );
              }

              return Column(
                children: contributions.map((c) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primaryDark,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.arrow_upward, size: 16, color: Colors.white),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Installment', style: AppTextStyles.headingSmall),
                              Text('Transfer', style: AppTextStyles.bodySmall),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '+ ${CurrencyFormatter.format(amount: c.amount, currency: goal.currency)}',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              DateFormat('d MMM yyyy').format(c.contributedAt),
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  String _durationText(DateTime? start, DateTime? end) {
    if (start == null || end == null) return '-';
    final months = ((end.year - start.year) * 12 + (end.month - start.month)).abs();
    return '$months Month';
  }
}

class _InfoRow extends StatelessWidget {
  final String title;
  final String value;

  const _InfoRow({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.body),
          Text(value, style: AppTextStyles.headingSmall),
        ],
      ),
    );
  }
}
