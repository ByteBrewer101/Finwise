class BudgetCategory {
  final String title;
  final double percentage;
  final bool isPrimary;

  const BudgetCategory({
    required this.title,
    required this.percentage,
    this.isPrimary = false,
  });
}
