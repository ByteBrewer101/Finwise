enum GoalPriceSegment {
  under50k,
  from50kTo100k,
  from100kTo500k,
  from500kTo1m,
  above1m,
}

class InvestmentAllocation {
  final String label;
  final double percentage;

  const InvestmentAllocation({
    required this.label,
    required this.percentage,
  });
}

class InvestmentRecommendation {
  final String title;
  final List<InvestmentAllocation> allocations;

  const InvestmentRecommendation({
    required this.title,
    required this.allocations,
  });

  double get totalPercentage =>
      allocations.fold<double>(0, (sum, item) => sum + item.percentage);
}
