import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../transaction/domain/transaction_data.dart';
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
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _delete(TransactionData t) async {
    await ref.read(transactionListProvider.notifier).delete(t.id!);
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionListProvider).value ?? [];
    final balance = transactions.fold(0, (sum, t) => sum + t.signedValue);

    return Scaffold(
      appBar: AppBar(title: const Text('Money Note')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Balance: Rp $balance',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          Expanded(
            child: ListView.builder(
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
                  onDismissed: (_) => _delete(t),
                  child: ListTile(
                    leading: Icon(
                      t.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
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
