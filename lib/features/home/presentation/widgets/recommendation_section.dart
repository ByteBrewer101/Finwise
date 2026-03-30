import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/stock_recommendation.dart';

const List<StockRecommendation> kStockRecommendations = [
  StockRecommendation(
    name: 'Bajaj Finance',
    sector: 'NBFC',
    performance: '~3400% in 10 years',
    source: 'Ventura Securities',
  ),
  StockRecommendation(
    name: 'Titan Company',
    sector: 'Consumer / Jewellery',
    performance: '~1500% in 10 years',
    source: 'Ventura',
  ),
  StockRecommendation(
    name: 'Reliance Industries',
    sector: 'Conglomerate',
    performance: '~515% in 10 years',
    source: 'Ventura',
  ),
  StockRecommendation(
    name: 'TCS',
    sector: 'IT',
    performance: '~600% in 10 years',
    source: 'Ventura',
  ),
  StockRecommendation(
    name: 'Infosys',
    sector: 'IT',
    performance: '~400% in 10 years',
    source: 'Ventura',
  ),
  StockRecommendation(
    name: 'HDFC Bank',
    sector: 'Banking',
    performance: '~300% in 10 years',
    source: 'Ventura',
  ),
  StockRecommendation(
    name: 'Asian Paints',
    sector: 'FMCG / Paints',
    performance: '~182% in 10 years',
    source: 'Ventura',
  ),
  StockRecommendation(
    name: 'Kotak Mahindra Bank',
    sector: 'Banking',
    performance: '~18%+ CAGR for a decade',
    source: 'Samco',
  ),
  StockRecommendation(
    name: 'Maruti Suzuki',
    sector: 'Auto',
    performance: '~18% CAGR over 10 years',
    source: 'Samco',
  ),
  StockRecommendation(
    name: 'HCL Technologies',
    sector: 'IT',
    performance: '~400% in 10 years',
    source: 'Ventura',
  ),
];

class RecommendationSection extends StatelessWidget {
  const RecommendationSection({
    super.key,
    this.recommendations = kStockRecommendations,
  });

  final List<StockRecommendation> recommendations;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recommendations', style: AppTextStyles.headingLarge),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: recommendations.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (context, index) {
                final recommendation = recommendations[index];
                return _RecommendationCard(recommendation: recommendation);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.recommendation});

  final StockRecommendation recommendation;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.headingSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  recommendation.sector,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  recommendation.performance,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Source: ${recommendation.source}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}
