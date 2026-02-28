import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/global_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/goals_provider.dart';
import '../../domain/models/goal.dart';
import 'goal_preview_screen.dart';
import 'set_goal_bottom_sheet.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);
    final user = ref.watch(currentUserProvider);

    final userName =
        user?.userMetadata?['full_name'] ?? user?.email?.split('@').first ?? 'User';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: goalsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text("Failed to load goals")),
          data: (goals) {
            final totalTarget = goals.fold<double>(0, (sum, g) => sum + g.targetAmount);
            final totalCurrent = goals.fold<double>(0, (sum, g) => sum + g.currentAmount);
            final delta = totalCurrent - totalTarget;
            final currencyCode = goals.isNotEmpty ? goals.first.currency : 'INR';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
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
                            Text(userName, style: AppTextStyles.headingSmall),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const SetGoalBottomSheet(),
                          );
                        },
                        icon: const Icon(Icons.add_box_outlined),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications_none),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Center(
                  child: Column(
                    children: [
                      Text('Total Goals Value', style: AppTextStyles.bodySmall),
                      const SizedBox(height: 6),
                      Text(
                        CurrencyFormatter.format(
                          amount: totalCurrent,
                          currency: currencyCode,
                        ),
                        style: AppTextStyles.amount,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        delta >= 0
                            ? '+${CurrencyFormatter.format(amount: delta.abs(), currency: currencyCode)} saved since you began'
                            : '${CurrencyFormatter.format(amount: delta.abs(), currency: currencyCode)} remaining to reach target',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Goals', style: AppTextStyles.headingLarge),
                      Text(
                        'See More',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: goals.isEmpty
                      ? const Center(child: Text('No goals yet'))
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          itemCount: goals.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, index) {
                            final goal = goals[index];
                            return _GoalListTile(
                              goal: goal,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => GoalPreviewScreen(goalId: goal.id),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GoalListTile extends StatelessWidget {
  final Goal goal;
  final VoidCallback onTap;

  const _GoalListTile({
    required this.goal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progressValue = goal.progress.clamp(0.0, 1.0);
    final percent = (progressValue * 100).clamp(0, 100).toStringAsFixed(0);
    final isCompleted = goal.currentAmount >= goal.targetAmount;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(Icons.landscape_outlined, size: 18),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    goal.name,
                    style: AppTextStyles.headingSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  CurrencyFormatter.format(
                    amount: goal.currentAmount,
                    currency: goal.currency,
                  ),
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  isCompleted ? 'Completed' : '$percent%',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isCompleted ? AppColors.primaryDark : AppColors.accentYellow,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  'out of ${CurrencyFormatter.format(amount: goal.targetAmount, currency: goal.currency)}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progressValue,
                minHeight: 4,
                color: AppColors.accentYellow,
                backgroundColor: AppColors.divider,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
