import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class HomeHeader extends StatelessWidget {
  final String userName;

  const HomeHeader({
    super.key,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          // Profile Avatar (placeholder)
          const CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary,
            child: Icon(
              Icons.person,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // Welcome Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back,',
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  userName,
                  style: AppTextStyles.headingMedium,
                ),
              ],
            ),
          ),

          // Search Icon
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search,
              color: AppColors.textPrimary,
            ),
          ),

          // Notification Icon
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
