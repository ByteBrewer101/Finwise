import 'package:fl_chart/fl_chart.dart';

class PortfolioSummary {
  final double totalValue;
  final List<FlSpot> chartSpots;

  const PortfolioSummary({
    required this.totalValue,
    required this.chartSpots,
  });
}
