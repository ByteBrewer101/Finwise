import 'package:flutter/material.dart';
import 'package:finwise/core/theme/app_colors.dart';
import 'package:finwise/core/theme/app_spacing.dart';
import 'package:finwise/core/theme/app_text_styles.dart';
import 'package:finwise/features/home/domain/models/category.dart';

class CategoriesSection extends StatelessWidget {
  final List<Category> categories;

  const CategoriesSection({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text('Categories', style: AppTextStyles.headingMedium),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 110,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              return _CategoryCard(category: categories[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: category.isPrimary ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!category.isPrimary)
            const BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
        ],
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            category.icon,
            size: 24,
            color: category.isPrimary ? Colors.white : AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            category.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body.copyWith(
              color: category.isPrimary ? Colors.white : AppColors.textPrimary,

              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
