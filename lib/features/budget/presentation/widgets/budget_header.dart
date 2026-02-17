import 'package:flutter/material.dart';
import 'package:finwise/core/theme/app_text_styles.dart';

class BudgetHeader extends StatelessWidget {
  const BudgetHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return  Text(
      'Budget',
      style: AppTextStyles.headingLarge,
    );
  }
}
