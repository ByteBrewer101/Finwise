import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/wallet_provider.dart';

class TransactionTile extends ConsumerWidget {
  final Transaction transaction;

  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isIncome = transaction.type == TransactionType.income;
    final baseColor = isIncome ? Colors.green : Colors.red;

    final title = transaction.description ?? (isIncome ? 'Income' : 'Expense');

    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          onLongPress: () => _confirmDelete(context, ref),
          leading: CircleAvatar(
            radius: 22,
            backgroundColor: baseColor.withValues(alpha: 0.1),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: baseColor,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          trailing: Text(
            "${isIncome ? '+' : '-'}₹${transaction.amount.toStringAsFixed(2)}",
            style: TextStyle(fontWeight: FontWeight.bold, color: baseColor),
          ),
        ),
        const Divider(thickness: 0.5, height: 12),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete Transaction"),
        content: const Text(
          "Are you sure you want to delete this transaction?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref
          .read(transactionProvider.notifier)
          .deleteTransaction(transaction.id);

      await ref.read(walletProvider.notifier).loadWallets();
    }
  }
}
