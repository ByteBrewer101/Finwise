class MonthlyAmountPoint {
  const MonthlyAmountPoint({
    required this.label,
    required this.amount,
  });

  final String label;
  final double amount;
}

class CategoryBreakdownItem {
  const CategoryBreakdownItem({
    required this.categoryName,
    required this.amount,
  });

  final String categoryName;
  final double amount;
}

class AnalysisSavingSummary {
  const AnalysisSavingSummary({
    required this.totalSavedAmount,
    required this.completedGoalsCount,
    required this.completedGoalsPercent,
  });

  final double totalSavedAmount;
  final int completedGoalsCount;
  final double completedGoalsPercent;
}
