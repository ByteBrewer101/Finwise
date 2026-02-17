import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class AppChipToggle extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const AppChipToggle({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Text(
          label,
          style: AppTextStyles.body.copyWith(
            fontWeight: selected
                ? FontWeight.w600
                : FontWeight.w400,
            color: selected
                ? AppColors.primary
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
