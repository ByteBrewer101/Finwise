class GoalContribution {
  final String id;
  final String goalId;
  final double amount;
  final DateTime contributedAt;

  GoalContribution({
    required this.id,
    required this.goalId,
    required this.amount,
    required this.contributedAt,
  });

  factory GoalContribution.fromMap(Map<String, dynamic> map) {
    return GoalContribution(
      id: map['id'],
      goalId: map['goal_id'],
      amount: (map['amount'] as num).toDouble(),
      contributedAt: DateTime.parse(map['contributed_at']),
    );
  }
}
