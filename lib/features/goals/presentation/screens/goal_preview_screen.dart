import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/secondary_button.dart';
import '../../domain/models/goal.dart';

class GoalPreviewScreen extends StatelessWidget {
  final Goal goal;

  const GoalPreviewScreen({
    super.key,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (goal.progress * 100).clamp(0, 100);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
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
                    onPressed: () {},
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              /// GOAL TITLE
              Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.flag,
                      size: 48,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      goal.name,
                      style: AppTextStyles.headingLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Rp ${goal.currentAmount.toStringAsFixed(0)}",
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
                  value: goal.progress,
                  backgroundColor: AppColors.surfaceMuted,
                  color: AppColors.primary,
                  minHeight: 8,
                ),
              ),

              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "${percent.toStringAsFixed(0)}%",
                  style: AppTextStyles.headingSmall,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              /// ACTION BUTTONS
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      label: "Add more",
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: SecondaryButton(
                      label: "Contact Us",
                      onPressed: () {},
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              /// SUMMARY SECTION
              Text(
                "Details",
                style: AppTextStyles.headingMedium,
              ),

              const SizedBox(height: AppSpacing.md),

              _DetailRow(
                title: "Target Amount",
                value:
                    "Rp ${goal.targetAmount.toStringAsFixed(0)}",
              ),

              const SizedBox(height: 8),

              _DetailRow(
                title: "Start Date",
                value: goal.startDate?.toString().split(" ").first ??
                    "-",
              ),

              const SizedBox(height: 8),

              _DetailRow(
                title: "End Date",
                value: goal.endDate?.toString().split(" ").first ??
                    "-",
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

  const _DetailRow({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.body,
        ),
        Text(
          value,
          style: AppTextStyles.headingSmall,
        ),
      ],
    );
  }
}
