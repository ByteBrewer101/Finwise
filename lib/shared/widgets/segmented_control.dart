import 'package:flutter/material.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_colors.dart';

class SegmentedControl extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const SegmentedControl({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: List.generate(
          options.length,
          (index) {
            final selected = index == selectedIndex;

            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color:
                        selected ? AppColors.primary : Colors.transparent,
                    borderRadius:
                        BorderRadius.circular(AppRadius.md),
                  ),
                  child: Center(
                    child: Text(
                      options[index],
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
