import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../transaction/domain/transaction_data.dart';
import '../transaction/domain/transaction_failure.dart';
import '../transaction/presentation/transaction_list_notifier.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Future<void> _add() async {
    final titleC = TextEditingController();
    final totalC = TextEditingController();
    String? errorMessage;
    bool income = false;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: const Text('New Transaction'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleC,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: totalC,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Total'),
              ),
              SwitchListTile(
                title: Text(income ? 'Income' : 'Expense'),
                value: income,
                onChanged: (v) => setLocal(() => income = v),
              ),

              // error message
              if (errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: .1),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ],
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final total = int.tryParse(totalC.text);
                if (titleC.text.isEmpty || total == null) return;
                setLocal(() {
                  errorMessage = null;
                });
                try {
                  await ref
                      .read(transactionListProvider.notifier)
                      .add(
                        TransactionData(
                          title: titleC.text,
                          value: total,
                          isIncome: income,
                          date: DateTime.now(),
                        ),
                      );
                  if (context.mounted) Navigator.pop(context);
                } on TransactionFailure catch (e) {
                  if (!context.mounted) return;
                  setLocal(() {
                    errorMessage = e.message;
                  });
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _delete(TransactionData t) async {
    try {
      await ref.read(transactionListProvider.notifier).delete(t.id!);
      return true;
    } on TransactionFailure catch (e) {
      if (!mounted) return false;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
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
          Text('Balance: ${balance ?? '-'}'),

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
                        '${transactionListAsync.isLoading ? 'Retry' : 'Failed'} to load transaction',
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
                    return Dismissible(
                      key: ValueKey(t.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (_) => _delete(t),
                      child: ListTile(
                        leading: Icon(
                          t.isIncome
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          color: t.isIncome ? Colors.green : Colors.red,
                        ),
                        title: Text(t.title),
                        subtitle: Text(t.date.toString().substring(0, 16)),
                        trailing: Text(
                          '${t.isIncome ? '+' : '-'}${t.value}',
                          style: TextStyle(
                            color: t.isIncome ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        child: const Icon(Icons.add),
      ),
    );
  }
}
