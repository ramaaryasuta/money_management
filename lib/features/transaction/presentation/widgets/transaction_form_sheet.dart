import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/transaction_data.dart';
import '../../domain/transaction_failure.dart';
import '../notifiers/transaction_list_notifier.dart';

class TransactionFormSheet extends ConsumerStatefulWidget {
  const TransactionFormSheet({super.key, this.initial});

  final TransactionData? initial;

  @override
  ConsumerState<TransactionFormSheet> createState() =>
      _TransactionFormSheetState();
}

class _TransactionFormSheetState extends ConsumerState<TransactionFormSheet> {
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  bool _isIncome = false;
  bool _isSaving = false;
  String? _errorMsg;

  bool get _isEditing => widget.initial != null;

  int? get _parsedAmount => int.tryParse(_amountCtrl.text.trim());

  TransactionData? get _draft {
    final amount = _parsedAmount;
    final title = _titleCtrl.text.trim();
    if (title.isEmpty || amount == null) return null;

    final initial = widget.initial;
    if (initial != null) {
      return initial.copyWith(title: title, value: amount, isIncome: _isIncome);
    }
    return TransactionData(
      title: title,
      value: amount,
      isIncome: _isIncome,
      date: DateTime.now(),
    );
  }

  bool get _canSave {
    final draft = _draft;

    // input tidak valid, atau sedang menyimpan
    if (draft == null || _isSaving) return false;

    // mode edit tanpa perubahan
    if (_isEditing && draft == widget.initial) return false;
    return true;
  }

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _titleCtrl.text = initial.title;
      _amountCtrl.text = initial.value.toString();
      _isIncome = initial.isIncome;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _errorMsg = null;
      _isSaving = true;
    });

    try {
      if (_isEditing) {
        // save edit transaction
        await ref.read(transactionListProvider.notifier).edit(_draft!);
      } else {
        // create new transaction
        await ref.read(transactionListProvider.notifier).add(_draft!);
      }

      if (mounted) Navigator.pop(context);
    } on TransactionFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMsg = e.message;
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsetsGeometry.fromLTRB(16, 0, 16, keyboardHeight + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // header
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                Expanded(
                  child: Text(
                    _isEditing ? 'Edit Transaction' : 'New Transaction',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                ListenableBuilder(
                  listenable: Listenable.merge([_titleCtrl, _amountCtrl]),
                  builder: (context, _) {
                    return TextButton(
                      onPressed: _canSave ? _save : null,
                      child: Text(widget.initial != null ? 'Save' : 'Add'),
                    );
                  },
                ),
              ],
            ),

            // error message
            // on the top. so user easier to see if there is an error
            if (_errorMsg != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: .1),
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  spacing: 8,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.red),
                    Text(_errorMsg!, style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],

            // Field
            TextField(
              autofocus: true,
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            const SizedBox(height: 20),

            // segmented
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Expense')),
                ButtonSegment(value: true, label: Text('Income')),
              ],
              selected: {_isIncome}, // Set berisi satu nilai
              onSelectionChanged: (selection) {
                setState(() => _isIncome = selection.first);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
