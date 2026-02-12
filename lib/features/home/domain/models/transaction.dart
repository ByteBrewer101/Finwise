enum TransactionType { income, expense }

class Transaction {
  final String title;
  final String subtitle;
  final double amount;
  final TransactionType type;
  final DateTime date;

  const Transaction({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.type,
    required this.date,
  });
}
