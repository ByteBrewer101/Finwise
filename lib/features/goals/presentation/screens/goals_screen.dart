import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_card_container.dart';

import '../providers/goals_provider.dart';
import '../../domain/models/goal.dart';
import 'goal_preview_screen.dart';
import 'set_goal_bottom_sheet.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: goalsAsync.when(
          data: (goals) {
            final totalValue = goals.fold<double>(
              0,
              (sum, g) => sum + g.targetAmount,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Goals", style: AppTextStyles.headingLarge),
                      IconButton(
                        icon: const Icon(Icons.add),
                        color: AppColors.primary,
                        onPressed: () async {
                          await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const SetGoalBottomSheet(),
                          );

                          if (!context.mounted) return;

                          // Show success AFTER bottom sheet closes
                          showDialog(
                            context: context,
                            builder: (_) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child:const Padding(
                                  padding:  EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children:  [
                                      Icon(
                                        Icons.check_circle,
                                        size: 60,
                                        color: AppColors.primary,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        "Success Goals Created",
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),

                /// TOTAL GOALS VALUE
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Total Goals Value", style: AppTextStyles.body),
                      const SizedBox(height: 6),
                      Text(
                        "Rp ${totalValue.toStringAsFixed(0)}",
                        style: AppTextStyles.amount,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                /// GOALS LIST
                Expanded(
                  child: goals.isEmpty
                      ? const Center(child: Text("No goals yet"))
                      : ListView.separated(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          itemCount: goals.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, index) {
                            final goal = goals[index];
                            return _GoalCard(goal: goal);
                          },
                        ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text("Failed to load goals")),
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final Goal goal;

  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final percent = (goal.progress * 100).clamp(0, 100);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => GoalPreviewScreen(goal: goal)),
        );
      },
      child: AppCardContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// GOAL NAME
            Text(goal.name, style: AppTextStyles.headingSmall),

            const SizedBox(height: 6),

            /// CURRENT AMOUNT
            Text(
              "Rp ${goal.currentAmount.toStringAsFixed(0)}",
              style: AppTextStyles.body.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            /// PROGRESS BAR
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: goal.progress,
                backgroundColor: AppColors.surfaceMuted,
                color: AppColors.primary,
                minHeight: 6,
              ),
            ),

            const SizedBox(height: 6),

            /// PERCENT TEXT
            Text(
              "${percent.toStringAsFixed(0)}% • out of Rp ${goal.targetAmount.toStringAsFixed(0)}",
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
