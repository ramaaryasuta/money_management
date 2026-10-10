import 'package:flutter/material.dart';

import '../../domain/transaction_data.dart';

class TransactionTile extends StatelessWidget {
  final TransactionData transaction;
  final Future<bool?> Function(TransactionData t) onDelete;
  const TransactionTile({
    super.key,
    required this.transaction,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = transaction.isIncome ? Colors.green : Colors.red;

    return Dismissible(
      key: ValueKey(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) => onDelete(transaction),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: .15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            transaction.isIncome
                ? Icons.arrow_downward_rounded
                : Icons.arrow_outward_rounded,
            color: iconColor,
            size: 20,
          ),
        ),
        title: Text(transaction.title),
        subtitle: Text(transaction.date.toString().substring(0, 16)),
        trailing: Text(
          '${transaction.isIncome ? '+' : '-'}Rp${transaction.value}',
          style: TextStyle(color: iconColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
