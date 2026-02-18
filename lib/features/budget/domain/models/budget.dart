class Budget {
  final String id;
  final String name;
  final double amount;
  final String categoryId;
  final String walletId;
  final String recurrence;
  final DateTime startDate;
  final DateTime? endDate;
  final String currency; // ✅ NEW

  Budget({
    required this.id,
    required this.name,
    required this.amount,
    required this.categoryId,
    required this.walletId,
    required this.recurrence,
    required this.startDate,
    this.endDate,
    required this.currency, // ✅ NEW
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      name: json['name'],
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['category_id'],
      walletId: json['wallet_id'],
      recurrence: json['recurrence'],
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : null,
      currency: json['currency'] ?? 'INR', // ✅ SAFE DEFAULT
    );
  }

  Map<String, dynamic> toJson(String userId) {
    return {
      'user_id': userId,
      'name': name,
      'amount': amount,
      'category_id': categoryId,
      'wallet_id': walletId,
      'recurrence': recurrence,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'currency': currency, // ✅ NEW
    };
  }
}
