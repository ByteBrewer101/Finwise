import '../models/investment_recommendation.dart';

InvestmentRecommendation _recommendation(
  String title,
  List<InvestmentAllocation> allocations,
) {
  return InvestmentRecommendation(title: title, allocations: allocations);
}

const _sip = 'SIP';
const _mutualFunds = 'Mutual Funds';
const _gold = 'Gold';
const _silver = 'Silver';
const _stocks = 'Stocks';

final Map<GoalPriceSegment, List<InvestmentRecommendation>>
goalInvestmentRecommendations = {
  GoalPriceSegment.under50k: [
    _recommendation('Starter Stable Mix', const [
      InvestmentAllocation(label: _sip, percentage: 45),
      InvestmentAllocation(label: _mutualFunds, percentage: 25),
      InvestmentAllocation(label: _gold, percentage: 20),
      InvestmentAllocation(label: _silver, percentage: 10),
    ]),
    _recommendation('Balanced Growth Mix', const [
      InvestmentAllocation(label: _sip, percentage: 40),
      InvestmentAllocation(label: _mutualFunds, percentage: 20),
      InvestmentAllocation(label: _gold, percentage: 25),
      InvestmentAllocation(label: _silver, percentage: 15),
    ]),
    _recommendation('Conservative Saver Mix', const [
      InvestmentAllocation(label: _sip, percentage: 50),
      InvestmentAllocation(label: _gold, percentage: 20),
      InvestmentAllocation(label: _silver, percentage: 10),
      InvestmentAllocation(label: _mutualFunds, percentage: 20),
    ]),
    _recommendation('Precious Metal Lean', const [
      InvestmentAllocation(label: _sip, percentage: 35),
      InvestmentAllocation(label: _gold, percentage: 30),
      InvestmentAllocation(label: _silver, percentage: 15),
      InvestmentAllocation(label: _mutualFunds, percentage: 20),
    ]),
    _recommendation('Steady SIP Focus', const [
      InvestmentAllocation(label: _sip, percentage: 55),
      InvestmentAllocation(label: _mutualFunds, percentage: 20),
      InvestmentAllocation(label: _gold, percentage: 15),
      InvestmentAllocation(label: _silver, percentage: 10),
    ]),
    _recommendation('Disciplined Monthly Mix', const [
      InvestmentAllocation(label: _sip, percentage: 48),
      InvestmentAllocation(label: _mutualFunds, percentage: 22),
      InvestmentAllocation(label: _gold, percentage: 18),
      InvestmentAllocation(label: _silver, percentage: 12),
    ]),
    _recommendation('Beginner Diversified Mix', const [
      InvestmentAllocation(label: _sip, percentage: 42),
      InvestmentAllocation(label: _mutualFunds, percentage: 28),
      InvestmentAllocation(label: _gold, percentage: 20),
      InvestmentAllocation(label: _silver, percentage: 10),
    ]),
    _recommendation('Safe Growth Mix', const [
      InvestmentAllocation(label: _sip, percentage: 46),
      InvestmentAllocation(label: _mutualFunds, percentage: 24),
      InvestmentAllocation(label: _gold, percentage: 20),
      InvestmentAllocation(label: _silver, percentage: 10),
    ]),
    _recommendation('Defensive Starter Mix', const [
      InvestmentAllocation(label: _sip, percentage: 38),
      InvestmentAllocation(label: _mutualFunds, percentage: 27),
      InvestmentAllocation(label: _gold, percentage: 20),
      InvestmentAllocation(label: _silver, percentage: 15),
    ]),
    _recommendation('Quick Goal Mix', const [
      InvestmentAllocation(label: _sip, percentage: 44),
      InvestmentAllocation(label: _mutualFunds, percentage: 26),
      InvestmentAllocation(label: _gold, percentage: 20),
      InvestmentAllocation(label: _silver, percentage: 10),
    ]),
  ],
  GoalPriceSegment.from50kTo100k: [
    _recommendation('Moderate Growth Mix', const [
      InvestmentAllocation(label: _sip, percentage: 40),
      InvestmentAllocation(label: _mutualFunds, percentage: 25),
      InvestmentAllocation(label: _gold, percentage: 20),
      InvestmentAllocation(label: _stocks, percentage: 15),
    ]),
    _recommendation('Gold Cushion Mix', const [
      InvestmentAllocation(label: _sip, percentage: 35),
      InvestmentAllocation(label: _mutualFunds, percentage: 25),
      InvestmentAllocation(label: _gold, percentage: 25),
      InvestmentAllocation(label: _stocks, percentage: 15),
    ]),
    _recommendation('Growth With Stability', const [
      InvestmentAllocation(label: _sip, percentage: 42),
      InvestmentAllocation(label: _stocks, percentage: 18),
      InvestmentAllocation(label: _gold, percentage: 20),
      InvestmentAllocation(label: _mutualFunds, percentage: 20),
    ]),
    _recommendation('Balanced Market Mix', const [
      InvestmentAllocation(label: _sip, percentage: 38),
      InvestmentAllocation(label: _stocks, percentage: 20),
      InvestmentAllocation(label: _mutualFunds, percentage: 22),
      InvestmentAllocation(label: _gold, percentage: 20),
    ]),
    _recommendation('Goal Booster Mix', const [
      InvestmentAllocation(label: _sip, percentage: 45),
      InvestmentAllocation(label: _mutualFunds, percentage: 20),
      InvestmentAllocation(label: _stocks, percentage: 20),
      InvestmentAllocation(label: _gold, percentage: 15),
    ]),
    _recommendation('Core Equity Light Mix', const [
      InvestmentAllocation(label: _sip, percentage: 40),
      InvestmentAllocation(label: _mutualFunds, percentage: 20),
      InvestmentAllocation(label: _gold, percentage: 15),
      InvestmentAllocation(label: _stocks, percentage: 25),
    ]),
    _recommendation('Defensive Mid Mix', const [
      InvestmentAllocation(label: _sip, percentage: 36),
      InvestmentAllocation(label: _mutualFunds, percentage: 29),
      InvestmentAllocation(label: _gold, percentage: 20),
      InvestmentAllocation(label: _stocks, percentage: 15),
    ]),
    _recommendation('Compounded Saver Mix', const [
      InvestmentAllocation(label: _sip, percentage: 43),
      InvestmentAllocation(label: _mutualFunds, percentage: 22),
      InvestmentAllocation(label: _stocks, percentage: 20),
      InvestmentAllocation(label: _gold, percentage: 15),
    ]),
    _recommendation('Mid Goal Shield Mix', const [
      InvestmentAllocation(label: _sip, percentage: 34),
      InvestmentAllocation(label: _mutualFunds, percentage: 26),
      InvestmentAllocation(label: _gold, percentage: 25),
      InvestmentAllocation(label: _stocks, percentage: 15),
    ]),
    _recommendation('Hybrid Mid Mix', const [
      InvestmentAllocation(label: _sip, percentage: 39),
      InvestmentAllocation(label: _mutualFunds, percentage: 21),
      InvestmentAllocation(label: _gold, percentage: 20),
      InvestmentAllocation(label: _stocks, percentage: 20),
    ]),
  ],
  GoalPriceSegment.from100kTo500k: [
    _recommendation('Growth Plus Mix', const [
      InvestmentAllocation(label: _sip, percentage: 35),
      InvestmentAllocation(label: _stocks, percentage: 25),
      InvestmentAllocation(label: _mutualFunds, percentage: 25),
      InvestmentAllocation(label: _gold, percentage: 15),
    ]),
    _recommendation('Balanced Wealth Mix', const [
      InvestmentAllocation(label: _sip, percentage: 30),
      InvestmentAllocation(label: _stocks, percentage: 30),
      InvestmentAllocation(label: _mutualFunds, percentage: 25),
      InvestmentAllocation(label: _gold, percentage: 15),
    ]),
    _recommendation('Compounding Focus Mix', const [
      InvestmentAllocation(label: _sip, percentage: 38),
      InvestmentAllocation(label: _mutualFunds, percentage: 22),
      InvestmentAllocation(label: _stocks, percentage: 25),
      InvestmentAllocation(label: _gold, percentage: 15),
    ]),
    _recommendation('Moderate Equity Mix', const [
      InvestmentAllocation(label: _sip, percentage: 32),
      InvestmentAllocation(label: _stocks, percentage: 28),
      InvestmentAllocation(label: _mutualFunds, percentage: 20),
      InvestmentAllocation(label: _gold, percentage: 20),
    ]),
    _recommendation('Target Accelerator Mix', const [
      InvestmentAllocation(label: _sip, percentage: 34),
      InvestmentAllocation(label: _stocks, percentage: 32),
      InvestmentAllocation(label: _mutualFunds, percentage: 19),
      InvestmentAllocation(label: _gold, percentage: 15),
    ]),
    _recommendation('Goal Builder Mix', const [
      InvestmentAllocation(label: _sip, percentage: 28),
      InvestmentAllocation(label: _stocks, percentage: 30),
      InvestmentAllocation(label: _mutualFunds, percentage: 27),
      InvestmentAllocation(label: _gold, percentage: 15),
    ]),
    _recommendation('Diversified Growth Mix', const [
      InvestmentAllocation(label: _sip, percentage: 31),
      InvestmentAllocation(label: _stocks, percentage: 29),
      InvestmentAllocation(label: _mutualFunds, percentage: 25),
      InvestmentAllocation(label: _gold, percentage: 15),
    ]),
    _recommendation('Stable Wealth Mix', const [
      InvestmentAllocation(label: _sip, percentage: 36),
      InvestmentAllocation(label: _stocks, percentage: 24),
      InvestmentAllocation(label: _mutualFunds, percentage: 25),
      InvestmentAllocation(label: _gold, percentage: 15),
    ]),
    _recommendation('Equity Tilt Mix', const [
      InvestmentAllocation(label: _sip, percentage: 30),
      InvestmentAllocation(label: _stocks, percentage: 35),
      InvestmentAllocation(label: _mutualFunds, percentage: 20),
      InvestmentAllocation(label: _gold, percentage: 15),
    ]),
    _recommendation('Long Horizon Mix', const [
      InvestmentAllocation(label: _sip, percentage: 33),
      InvestmentAllocation(label: _stocks, percentage: 27),
      InvestmentAllocation(label: _mutualFunds, percentage: 25),
      InvestmentAllocation(label: _gold, percentage: 15),
    ]),
  ],
  GoalPriceSegment.from500kTo1m: [
    _recommendation('Aggressive Balanced Mix', const [
      InvestmentAllocation(label: _sip, percentage: 25),
      InvestmentAllocation(label: _stocks, percentage: 35),
      InvestmentAllocation(label: _mutualFunds, percentage: 25),
      InvestmentAllocation(label: _gold, percentage: 15),
    ]),
    _recommendation('Large Goal Growth Mix', const [
      InvestmentAllocation(label: _sip, percentage: 22),
      InvestmentAllocation(label: _stocks, percentage: 38),
      InvestmentAllocation(label: _mutualFunds, percentage: 25),
      InvestmentAllocation(label: _gold, percentage: 15),
    ]),
    _recommendation('High Momentum Mix', const [
      InvestmentAllocation(label: _sip, percentage: 20),
      InvestmentAllocation(label: _stocks, percentage: 40),
      InvestmentAllocation(label: _mutualFunds, percentage: 25),
      InvestmentAllocation(label: _gold, percentage: 15),
    ]),
    _recommendation('Core Builder Mix', const [
      InvestmentAllocation(label: _sip, percentage: 24),
      InvestmentAllocation(label: _stocks, percentage: 34),
      InvestmentAllocation(label: _mutualFunds, percentage: 27),
      InvestmentAllocation(label: _gold, percentage: 15),
    ]),
    _recommendation('Protected Growth Mix', const [
      InvestmentAllocation(label: _sip, percentage: 26),
      InvestmentAllocation(label: _stocks, percentage: 32),
      InvestmentAllocation(label: _mutualFunds, percentage: 24),
      InvestmentAllocation(label: _gold, percentage: 18),
    ]),
    _recommendation('Large Goal Hybrid Mix', const [
      InvestmentAllocation(label: _sip, percentage: 23),
      InvestmentAllocation(label: _stocks, percentage: 36),
      InvestmentAllocation(label: _mutualFunds, percentage: 23),
      InvestmentAllocation(label: _gold, percentage: 18),
    ]),
    _recommendation('Strategic Wealth Mix', const [
      InvestmentAllocation(label: _sip, percentage: 21),
      InvestmentAllocation(label: _stocks, percentage: 37),
      InvestmentAllocation(label: _mutualFunds, percentage: 27),
      InvestmentAllocation(label: _gold, percentage: 15),
    ]),
    _recommendation('Goal Maximizer Mix', const [
      InvestmentAllocation(label: _sip, percentage: 20),
      InvestmentAllocation(label: _stocks, percentage: 39),
      InvestmentAllocation(label: _mutualFunds, percentage: 26),
      InvestmentAllocation(label: _gold, percentage: 15),
    ]),
    _recommendation('Resilient Equity Mix', const [
      InvestmentAllocation(label: _sip, percentage: 25),
      InvestmentAllocation(label: _stocks, percentage: 33),
      InvestmentAllocation(label: _mutualFunds, percentage: 24),
      InvestmentAllocation(label: _gold, percentage: 18),
    ]),
    _recommendation('Advanced Growth Mix', const [
      InvestmentAllocation(label: _sip, percentage: 22),
      InvestmentAllocation(label: _stocks, percentage: 35),
      InvestmentAllocation(label: _mutualFunds, percentage: 28),
      InvestmentAllocation(label: _gold, percentage: 15),
    ]),
  ],
  GoalPriceSegment.above1m: [
    _recommendation('Wealth Creation Mix', const [
      InvestmentAllocation(label: _sip, percentage: 20),
      InvestmentAllocation(label: _stocks, percentage: 40),
      InvestmentAllocation(label: _mutualFunds, percentage: 25),
      InvestmentAllocation(label: _gold, percentage: 15),
    ]),
    _recommendation('High Value Goal Mix', const [
      InvestmentAllocation(label: _sip, percentage: 18),
      InvestmentAllocation(label: _stocks, percentage: 42),
      InvestmentAllocation(label: _mutualFunds, percentage: 25),
      InvestmentAllocation(label: _gold, percentage: 15),
    ]),
    _recommendation('Aggressive Long-Term Mix', const [
      InvestmentAllocation(label: _sip, percentage: 15),
      InvestmentAllocation(label: _stocks, percentage: 45),
      InvestmentAllocation(label: _mutualFunds, percentage: 25),
      InvestmentAllocation(label: _gold, percentage: 15),
    ]),
    _recommendation('Diversified Wealth Builder', const [
      InvestmentAllocation(label: _sip, percentage: 19),
      InvestmentAllocation(label: _stocks, percentage: 38),
      InvestmentAllocation(label: _mutualFunds, percentage: 28),
      InvestmentAllocation(label: _gold, percentage: 15),
    ]),
    _recommendation('Premium Growth Mix', const [
      InvestmentAllocation(label: _sip, percentage: 17),
      InvestmentAllocation(label: _stocks, percentage: 43),
      InvestmentAllocation(label: _mutualFunds, percentage: 25),
      InvestmentAllocation(label: _gold, percentage: 15),
    ]),
    _recommendation('High Conviction Mix', const [
      InvestmentAllocation(label: _sip, percentage: 16),
      InvestmentAllocation(label: _stocks, percentage: 44),
      InvestmentAllocation(label: _mutualFunds, percentage: 25),
      InvestmentAllocation(label: _gold, percentage: 15),
    ]),
    _recommendation('Future Wealth Mix', const [
      InvestmentAllocation(label: _sip, percentage: 20),
      InvestmentAllocation(label: _stocks, percentage: 39),
      InvestmentAllocation(label: _mutualFunds, percentage: 26),
      InvestmentAllocation(label: _gold, percentage: 15),
    ]),
    _recommendation('Advanced Portfolio Mix', const [
      InvestmentAllocation(label: _sip, percentage: 18),
      InvestmentAllocation(label: _stocks, percentage: 41),
      InvestmentAllocation(label: _mutualFunds, percentage: 26),
      InvestmentAllocation(label: _gold, percentage: 15),
    ]),
    _recommendation('Long Horizon Premium Mix', const [
      InvestmentAllocation(label: _sip, percentage: 15),
      InvestmentAllocation(label: _stocks, percentage: 42),
      InvestmentAllocation(label: _mutualFunds, percentage: 28),
      InvestmentAllocation(label: _gold, percentage: 15),
    ]),
    _recommendation('Compound Rich Mix', const [
      InvestmentAllocation(label: _sip, percentage: 19),
      InvestmentAllocation(label: _stocks, percentage: 40),
      InvestmentAllocation(label: _mutualFunds, percentage: 26),
      InvestmentAllocation(label: _gold, percentage: 15),
    ]),
  ],
};
