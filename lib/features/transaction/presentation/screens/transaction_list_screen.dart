import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/transaction_data.dart';
import '../../domain/transaction_failure.dart';
import '../notifiers/transaction_list_notifier.dart';
import '../widgets/balance_header.dart';
import '../widgets/transaction_form_sheet.dart';
import '../widgets/transaction_tile.dart';

class TransactionListScreen extends ConsumerWidget {
  const TransactionListScreen({super.key});

  void _openTransactionFormSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => const TransactionFormSheet(),
    );
  }

  Future<bool> _delete(
    BuildContext context,
    WidgetRef ref,
    TransactionData t,
  ) async {
    try {
      await ref.read(transactionListProvider.notifier).delete(t.id!);
      return true;
    } on TransactionFailure catch (e) {
      if (!context.mounted) return false;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
      return false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionListAsync = ref.watch(transactionListProvider);
    final loadedTransactions = transactionListAsync.value;
    final balance = loadedTransactions?.fold(
      0,
      (sum, t) => sum + t.signedValue,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Money Note')),
      body: Column(
        children: [
          // Total Amount
          BalanceHeader(balance: balance),

          // Transaction List Content
          Expanded(
            child: transactionListAsync.when(
              skipLoadingOnReload: true,
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) {
                return Center(
                  child: Column(
                    spacing: 12,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        transactionListAsync.isLoading
                            ? 'Retrying...'
                            : 'Retry to load transaction',
                      ),
                      if (transactionListAsync.isLoading)
                        const CircularProgressIndicator()
                      else
                        TextButton(
                          onPressed: () {
                            ref.invalidate(
                              transactionListProvider,
                              asReload: true,
                            );
                          },
                          child: const Text('Retry'),
                        ),
                    ],
                  ),
                );
              },
              data: (transactions) {
                return ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (_, i) {
                    final t = transactions[i];
                    return TransactionTile(
                      transaction: t,
                      onDelete: (t) async => _delete(context, ref, t),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openTransactionFormSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
