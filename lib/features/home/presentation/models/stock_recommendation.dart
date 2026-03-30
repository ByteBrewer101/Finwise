import 'package:flutter/material.dart';

class StockRecommendation {
  const StockRecommendation({
    required this.name,
    required this.sector,
    required this.performance,
    required this.source,
    required this.logoText,
    required this.logoBackgroundColor,
    this.logoForegroundColor = Colors.white,
  });

  final String name;
  final String sector;
  final String performance;
  final String source;
  final String logoText;
  final Color logoBackgroundColor;
  final Color logoForegroundColor;
}
