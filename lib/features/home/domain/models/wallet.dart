class Wallet {
  final String id;
  final String userId;
  final String name;
  final String type;
  final double balance;
  final String currency;
  final DateTime createdAt;

  const Wallet({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.balance,
    required this.currency,
    required this.createdAt,
  });

  factory Wallet.fromMap(Map<String, dynamic> map) {
    return Wallet(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      type: map['type'],
      balance: (map['balance'] as num).toDouble(),
      currency: map['currency'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
