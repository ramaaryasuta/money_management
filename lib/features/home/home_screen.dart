import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../transaction/data/transaction_repository_impl.dart';
import '../transaction/domain/transaction_data.dart';
import '../transaction/domain/transaction_repository.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late TransactionRepository _repo;

  List<TransactionData> _data = [];

  @override
  void initState() {
    super.initState();
    _repo = ref.read(transactionRepositoryProvider);
    _load();
  }

  Future<void> _load() async {
    final result = await _repo.getAll();
    setState(() {
      _data = result;
    });
  }

  int get _saldo =>
      _data.fold(0, (sum, t) => sum + (t.isIncome ? t.value : -t.value));

  Future<void> _tambah() async {
    final judulC = TextEditingController();
    final jumlahC = TextEditingController();
    bool pemasukan = false;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: const Text('Transaksi Baru'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: judulC,
                decoration: const InputDecoration(labelText: 'Judul'),
              ),
              TextField(
                controller: jumlahC,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Jumlah'),
              ),
              SwitchListTile(
                title: Text(pemasukan ? 'Pemasukan' : 'Pengeluaran'),
                value: pemasukan,
                onChanged: (v) => setLocal(() => pemasukan = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () async {
                final jumlah = int.tryParse(jumlahC.text);
                if (judulC.text.isEmpty || jumlah == null) return;
                await _repo.add(
                  TransactionData(
                    title: judulC.text,
                    value: jumlah,
                    isIncome: pemasukan,
                    date: DateTime.now(),
                  ),
                );
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
    _load(); // refresh list setelah dialog tertutup
  }

  Future<void> _hapus(TransactionData t) async {
    await _repo.delete(t.id!);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catat Uang')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Saldo: Rp $_saldo',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _data.length,
              itemBuilder: (_, i) {
                final t = _data[i];
                return Dismissible(
                  key: ValueKey(t.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => _hapus(t),
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
        onPressed: _tambah,
        child: const Icon(Icons.add),
      ),
    );
  }
}
