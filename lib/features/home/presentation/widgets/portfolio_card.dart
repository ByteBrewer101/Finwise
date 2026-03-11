import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:finwise/core/theme/app_colors.dart';
import 'package:finwise/core/theme/app_spacing.dart';
import 'package:finwise/core/theme/app_text_styles.dart';
import 'package:finwise/features/home/domain/models/portfolio_summary.dart';
import 'package:finwise/features/home/domain/models/transaction.dart';

enum _PortfolioView { chart, table }

class PortfolioCard extends StatefulWidget {
  final PortfolioSummary summary;
  final List<Transaction> transactions;
  final String currencySymbol;

  const PortfolioCard({
    super.key,
    required this.summary,
    required this.transactions,
    this.currencySymbol = '\u20B9',
  });

  @override
  State<PortfolioCard> createState() => _PortfolioCardState();
}

class _PortfolioCardState extends State<PortfolioCard> {
  _PortfolioView _view = _PortfolioView.chart;

  @override
  Widget build(BuildContext context) {
    final chartSpots = _buildChartSpots();

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _PortfolioTitle(),
                Row(
                  children: [
                    _ToggleChip(
                      label: 'Chart',
                      selected: _view == _PortfolioView.chart,
                      onTap: () => setState(() => _view = _PortfolioView.chart),
                    ),
                    const SizedBox(width: 8),
                    _ToggleChip(
                      label: 'Table',
                      selected: _view == _PortfolioView.table,
                      onTap: () => setState(() => _view = _PortfolioView.table),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '${widget.currencySymbol}${widget.summary.totalValue.toStringAsFixed(0)}',
              style: AppTextStyles.headingLarge.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: _view == _PortfolioView.chart
                  ? _PortfolioChart(spots: chartSpots)
                  : _PortfolioTable(
                      transactions: widget.transactions,
                      currencySymbol: widget.currencySymbol,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _buildChartSpots() {
    if (widget.summary.chartSpots.isNotEmpty) {
      return widget.summary.chartSpots;
    }

    if (widget.transactions.isEmpty) {
      return const [FlSpot(0, 0), FlSpot(1, 0)];
    }

    final sorted = [...widget.transactions]
      ..sort((a, b) => a.transactionDate.compareTo(b.transactionDate));

    final points = <FlSpot>[];
    var running = 0.0;

    for (final tx in sorted) {
      switch (tx.type) {
        case TransactionType.income:
          running += tx.amount;
          break;
        case TransactionType.expense:
          running -= tx.amount;
          break;
        case TransactionType.transfer:
          // Overall portfolio value does not change for self transfer.
          break;
      }
      points.add(FlSpot(points.length.toDouble(), running));
    }

    const window = 12;
    if (points.length > window) {
      final sliced = points.sublist(points.length - window);
      return [
        for (var i = 0; i < sliced.length; i++) FlSpot(i.toDouble(), sliced[i].y),
      ];
    }
    return points;
  }
}

class _PortfolioChart extends StatelessWidget {
  final List<FlSpot> spots;

  const _PortfolioChart({required this.spots});

  @override
  Widget build(BuildContext context) {
    final minY = spots.map((e) => e.y).reduce(min);
    final maxY = spots.map((e) => e.y).reduce(max);
    final padding = ((maxY - minY).abs() * 0.2).clamp(100, 10000).toDouble();

    return SizedBox(
      key: const ValueKey('chart'),
      height: 170,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(show: false),
          minY: minY - padding,
          maxY: maxY + padding,
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
              spots: spots,
            ),
          ],
        ),
      ),
    );
  }
}

class _PortfolioTable extends StatelessWidget {
  final List<Transaction> transactions;
  final String currencySymbol;

  const _PortfolioTable({
    required this.transactions,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final recent = [...transactions]
      ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    final visible = recent.take(5).toList();
    final dateFormat = DateFormat('dd MMM');

    if (visible.isEmpty) {
      return SizedBox(
        key: const ValueKey('table-empty'),
        height: 170,
        child: Center(
          child: Text(
            'No transactions yet',
            style: AppTextStyles.body.copyWith(color: Colors.white70),
          ),
        ),
      );
    }

    return SizedBox(
      key: const ValueKey('table'),
      height: 170,
      child: ListView.separated(
        itemCount: visible.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: Colors.white.withValues(alpha: 0.25),
        ),
        itemBuilder: (context, index) {
          final tx = visible[index];
          final isIncome = tx.type == TransactionType.income;
          final sign = isIncome ? '+' : '-';
          final typeLabel = tx.type.name;
          final date = dateFormat.format(tx.transactionDate);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    tx.description?.isNotEmpty == true ? tx.description! : typeLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  date,
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                ),
                const SizedBox(width: 10),
                Text(
                  '$sign$currencySymbol${tx.amount.toStringAsFixed(0)}',
                  style: AppTextStyles.body.copyWith(
                    color: isIncome ? Colors.white : const Color(0xFFFFD1D1),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
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
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.white.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: Colors.white,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
