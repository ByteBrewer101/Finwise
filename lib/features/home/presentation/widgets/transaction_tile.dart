import 'package:flutter/material.dart';
import 'package:finwise/features/home/domain/models/transaction.dart';


class TransactionTile extends StatelessWidget {
final Transaction transaction;


  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;

    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            radius: 22,
            backgroundColor: isIncome
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.red.withValues(alpha: 0.1),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),

          title: Text(
            transaction.title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          subtitle: Text(
            transaction.subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          trailing: Text(
            "${isIncome ? '+' : '-'}₹${transaction.amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),
        ),
        const Divider(thickness: 0.5, height: 12),
      ],
    );
  }
}
