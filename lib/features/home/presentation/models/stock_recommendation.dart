class StockRecommendation {
  const StockRecommendation({
    required this.name,
    required this.sector,
    required this.performance,
    required this.source,
  });

  final String name;
  final String sector;
  final String performance;
  final String source;
}
