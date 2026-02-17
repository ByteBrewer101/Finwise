class Goal {
  final String id;
  final String name;
  final String? targetFor;
  final double targetAmount;      // target_fund in UI
  final double contribution;      // monthly contribution
  final double currentAmount;
  final String currency;
  final DateTime? startDate;
  final DateTime? endDate;

  Goal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.currency,
    required this.contribution,
    this.targetFor,
    this.startDate,
    this.endDate,
  });

  double get progress =>
      targetAmount == 0 ? 0 : currentAmount / targetAmount;

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      name: map['name'],
      targetFor: map['target_for'],
      targetAmount: (map['target_amount'] as num).toDouble(),
      currentAmount: (map['current_amount'] as num).toDouble(),
      contribution: (map['contribution'] ?? 0 as num).toDouble(),
      currency: map['currency'] ?? 'INR',
      startDate: map['start_date'] != null
          ? DateTime.parse(map['start_date'])
          : null,
      endDate: map['end_date'] != null
          ? DateTime.parse(map['end_date'])
          : null,
    );
  }
}
