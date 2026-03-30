import 'dart:math';

import '../data/goal_investment_recommendations.dart';
import '../models/investment_recommendation.dart';

class GoalInvestmentRecommendationEngine {
  GoalInvestmentRecommendationEngine._();

  static GoalPriceSegment segmentForAmount(double targetAmount) {
    if (targetAmount < 50000) {
      return GoalPriceSegment.under50k;
    }
    if (targetAmount < 100000) {
      return GoalPriceSegment.from50kTo100k;
    }
    if (targetAmount < 500000) {
      return GoalPriceSegment.from100kTo500k;
    }
    if (targetAmount < 1000000) {
      return GoalPriceSegment.from500kTo1m;
    }
    return GoalPriceSegment.above1m;
  }

  static InvestmentRecommendation pickForGoalAmount(
    double targetAmount, {
    Random? random,
  }) {
    final segment = segmentForAmount(targetAmount);
    final recommendations = goalInvestmentRecommendations[segment] ?? const [];

    if (recommendations.isEmpty) {
      return const InvestmentRecommendation(title: 'Balanced Mix', allocations: []);
    }

    final picker = random ?? Random();
    return recommendations[picker.nextInt(recommendations.length)];
  }
}
