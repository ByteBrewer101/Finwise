import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:finwise/core/theme/app_spacing.dart';
import 'package:finwise/core/theme/app_text_styles.dart';
import 'package:finwise/core/theme/app_colors.dart';
import 'package:finwise/features/home/domain/models/portfolio_summary.dart';

class PortfolioCard extends StatelessWidget {
  final PortfolioSummary summary;
  final String currencySymbol;

  const PortfolioCard({
    super.key,
    required this.summary,
    this.currencySymbol = '₹',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header Row
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _PortfolioTitle(),
                Row(
                  children: [
                    _ToggleChip(label: 'Chart', selected: true),
                    SizedBox(width: 8),
                    _ToggleChip(label: 'Table', selected: false),
                  ],
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            /// Portfolio Value (Dynamic)
            Text(
              '$currencySymbol${summary.totalValue.toStringAsFixed(0)}',
              style: AppTextStyles.headingLarge.copyWith(
                color: Colors.white,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            /// Chart (Dynamic)
            SizedBox(
              height: 170,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  minY: 0,
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      curveSmoothness: 0.35,
                      color: Colors.white,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0x1FFFFFFF),
                      ),
                      spots: summary.chartSpots,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PortfolioTitle extends StatelessWidget {
  const _PortfolioTitle();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Portfolio',
      style: AppTextStyles.headingMedium.copyWith(
        color: Colors.white,
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;

  const _ToggleChip({
    required this.label,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: selected
            ? Colors.white.withValues(alpha: 0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.body.copyWith(
          color: Colors.white,
          fontWeight: selected
              ? FontWeight.w600
              : FontWeight.w400,
        ),
      ),
    );
  }
}
