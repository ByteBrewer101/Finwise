import 'package:flutter/material.dart';
import 'package:finwise/features/home/domain/models/transaction.dart';
import 'package:finwise/features/home/presentation/widgets/transaction_tile.dart';

class TransactionSection extends StatelessWidget {
  final List<Transaction> transactions;
  final VoidCallback? onSeeMore;

  const TransactionSection({
    super.key,
    required this.transactions,
    this.onSeeMore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
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

        ...transactions.map(
          (tx) => TransactionTile(transaction: tx),
        ),
      ],
    );
  }
}
