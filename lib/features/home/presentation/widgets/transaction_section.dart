import 'package:flutter/material.dart';
import 'package:finwise/core/theme/app_spacing.dart';
import 'package:finwise/features/home/domain/models/transaction.dart';
import 'package:finwise/features/home/presentation/widgets/transaction_tile.dart';

class TransactionSection extends StatelessWidget {
  final List<Transaction> transactions;
  final VoidCallback? onSeeMore;
  final bool showHeader;

  const TransactionSection({
    super.key,
    required this.transactions,
    this.onSeeMore,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    final sortedTransactions = [...transactions]
      ..sort((a, b) {
        final byDate = b.transactionDate.compareTo(a.transactionDate);
        if (byDate != 0) return byDate;
        return b.createdAt.compareTo(a.createdAt);
      });

    final recentTransactions = sortedTransactions.take(5).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Transaction",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: onSeeMore,
                  child: const Text(
                    "See More",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          /// Empty State
          if (recentTransactions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  "No transactions yet",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...recentTransactions.map(
              (tx) => TransactionTile(transaction: tx),
            ),
        ],
      ),
    );
  }
}
