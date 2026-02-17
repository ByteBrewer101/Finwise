class Budget {
  final String id;
  final String name;
  final double amount;
  final String category;
  final String wallet;
  final String recurrence;
  final DateTime startDate;

  Budget({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.wallet,
    required this.recurrence,
    required this.startDate,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      name: json['name'],
      amount: (json['amount'] as num).toDouble(),
      category: json['category'],
      wallet: json['wallet'],
      recurrence: json['recurrence'],
      startDate: DateTime.parse(json['start_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'category': category,
      'wallet': wallet,
      'recurrence': recurrence,
      'start_date': startDate.toIso8601String(),
    };
  }
}
