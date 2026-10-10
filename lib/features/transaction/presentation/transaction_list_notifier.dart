import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/riverpod_util.dart';
import '../data/transaction_repository_impl.dart';
import '../domain/transaction_data.dart';

final transactionListProvider =
    AsyncNotifierProvider<TransactionListNotifier, List<TransactionData>>(
      TransactionListNotifier.new,
      retry: fixedRetry,
    );

class TransactionListNotifier extends AsyncNotifier<List<TransactionData>> {
  @override
  FutureOr<List<TransactionData>> build() {
    final repo = ref.watch(transactionRepositoryProvider);
    return repo.getAll();
  }

  Future<void> add(TransactionData t) async {
    final repo = ref.read(transactionRepositoryProvider);
    final saved = await repo.add(t);

    final current = state.value ?? [];
    state = AsyncData([saved, ...current]);
  }

  Future<void> delete(int id) async {
    final repo = ref.read(transactionRepositoryProvider);

    await repo.delete(id);
    final previous = state.value ?? [];
    state = AsyncData(
      previous.where((item) => item.id != id).toList(),
    ); // without deleted item
  }
}
