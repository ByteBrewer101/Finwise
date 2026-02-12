class Budget {
  final String id;
  final String name;
  final double amount;
  final String category;
  final String wallet;
  final String recurrence;
  final DateTime startDate;

  const Budget({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.wallet,
    required this.recurrence,
    required this.startDate,
  });
}
