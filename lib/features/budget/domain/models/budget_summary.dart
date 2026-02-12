class BudgetSummary {
  final double totalBalance;
  final double cashless;
  final double cash;
  final double growthPercentage;
  final bool isGrowthPositive;

  const BudgetSummary({
    required this.totalBalance,
    required this.cashless,
    required this.cash,
    required this.growthPercentage,
    this.isGrowthPositive = true,
  });
}
