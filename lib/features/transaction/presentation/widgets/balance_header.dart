import 'package:flutter/material.dart';

class BalanceHeader extends StatelessWidget {
  final int? balance;

  const BalanceHeader({super.key, this.balance});

  @override
  Widget build(BuildContext context) {
    final value = balance;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Balance'),

        // total balance
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (value != null) Text(value < 0 ? '-Rp' : 'Rp'),
            Text(
              value?.abs().toString() ?? '-',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
          ],
        ),

        // warning
        if (value != null && value < 0) ...[
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Expenses exceed income',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
