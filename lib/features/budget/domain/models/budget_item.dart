class BudgetItem {
  final String title;
  final double percentage;
  final bool isPrimary;

  const BudgetItem({
    required this.title,
    required this.percentage,
    this.isPrimary = false,
  });
}
