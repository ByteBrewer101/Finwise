enum TransactionType { income, expense, transfer }

class Transaction {
  final String id;
  final String userId;

  final String? walletId;
  final String? targetWalletId;
  final String? categoryId;

  final TransactionType type;
  final double amount;
  final String? description;

  final DateTime transactionDate;
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.transactionDate,
    required this.createdAt,
    this.walletId,
    this.targetWalletId,
    this.categoryId,
    this.description,
  });

  // ==============================
  // FROM SUPABASE MAP
  // ==============================

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      userId: map['user_id'],
      walletId: map['wallet_id'],
      targetWalletId: map['target_wallet_id'],
      categoryId: map['category_id'],
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
      ),
      amount: (map['amount'] as num).toDouble(),
      description: map['description'],
      transactionDate: DateTime.parse(map['transaction_date']),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  // ==============================
  // TO SUPABASE MAP (INSERT)
  // ==============================

  Map<String, dynamic> toMap() {
    return {
      'wallet_id': walletId,
      'target_wallet_id': targetWalletId,
      'category_id': categoryId,
      'type': type.name,
      'amount': amount,
      'description': description,
      'transaction_date': transactionDate.toIso8601String(),
    };
  }
}
