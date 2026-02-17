import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class AppEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const AppEmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }
}
