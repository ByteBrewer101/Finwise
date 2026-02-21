import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/goal_detail_providers.dart';
import 'edit_goal_screen.dart';
import 'add_contribution_bottom_sheet.dart';

class GoalPreviewScreen extends ConsumerWidget {
  final String goalId;

  const GoalPreviewScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalAsync = ref.watch(singleGoalProvider(goalId));
    final contributionsAsync = ref.watch(goalContributionsProvider(goalId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: goalAsync == null
            ? const Center(child: Text("Goal not found"))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditGoalScreen(goal: goalAsync),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    /// CENTER
                    Center(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.flag,
                            size: 48,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            goalAsync.name,
                            style: AppTextStyles.headingLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            CurrencyFormatter.format(
                              amount: goalAsync.currentAmount,
                              currency: goalAsync.currency,
                            ),
                            style: AppTextStyles.amount.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    /// PROGRESS BAR
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: goalAsync.progress,
                        minHeight: 8,
                        backgroundColor: AppColors.surfaceMuted,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "${(goalAsync.progress * 100).clamp(0, 100).toStringAsFixed(0)}%",
                        style: AppTextStyles.headingSmall,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    /// ACTION BUTTONS
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) =>
                                    AddContributionBottomSheet(goal: goalAsync),
                              );
                            },
                            child: const Text("Add more"),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            child: const Text("Contact Us"),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    /// CONTRIBUTIONS (keep async)
                    Text("Contributions", style: AppTextStyles.headingMedium),

                    const SizedBox(height: AppSpacing.md),

                    contributionsAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text(e.toString())),
                      data: (contributions) {
                        if (contributions.isEmpty) {
                          return const Text("No contributions yet");
                        }

                        return Column(
                          children: contributions.map((c) {
                            return Container(
                              margin: const EdgeInsets.only(
                                bottom: AppSpacing.md,
                              ),
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "+ ₹${c.amount.toStringAsFixed(0)}",
                                    style: AppTextStyles.headingSmall,
                                  ),
                                  Text(
                                    "${c.contributedAt.year}-${c.contributedAt.month.toString().padLeft(2, '0')}-${c.contributedAt.day.toString().padLeft(2, '0')}",
                                    style: AppTextStyles.bodyMuted,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    /// DETAILS
                    Text("Details", style: AppTextStyles.headingMedium),

                    const SizedBox(height: AppSpacing.md),

                    _DetailRow(
                      title: "Target Amount",
                      value: "₹ ${goalAsync.targetAmount.toStringAsFixed(0)}",
                    ),

                    const SizedBox(height: 8),

                    _DetailRow(
                      title: "Start Date",
                      value:
                          goalAsync.startDate?.toString().split(" ").first ??
                          "-",
                    ),

                    const SizedBox(height: 8),

                    _DetailRow(
                      title: "End Date",
                      value:
                          goalAsync.endDate?.toString().split(" ").first ?? "-",
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String title;
  final String value;

  const _DetailRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.body),
        Text(value, style: AppTextStyles.headingSmall),
      ],
    );
  }
}
