import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../domain/transaction_data.dart';
import '../domain/transaction_failure.dart';
import '../domain/transaction_repository.dart';
import 'transaction_local_datasource.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final localDatasource = ref.watch(transactionLocalDatasourceProvider);
  return TransactionRepositoryImpl(localDatasource);
});

class TransactionRepositoryImpl implements TransactionRepository {
  const TransactionRepositoryImpl(this._localData);

  final TransactionLocalDatasource _localData;

  @override
  Future<TransactionData> add(TransactionData t) async {
    try {
      final newId = await _localData.insert(t);

      return t.copyWith(id: newId);
    } on DatabaseException catch (e) {
      throw TransactionFailure(
        message: 'Failed to add new transaction',
        cause: e,
      );
    }
  }

  @override
  Future<void> delete(int id) async {
    try {
      await _localData.delete(id);
    } on DatabaseException catch (e) {
      throw TransactionFailure(
        message: 'Failed to delete transaction',
        cause: e,
      );
    }
  }

  @override
  Future<List<TransactionData>> getAll() async {
    try {
      return await _localData.getAll();
    } on DatabaseException catch (e) {
      throw TransactionFailure(message: 'Failed load transactions', cause: e);
    }
  }

  @override
  Future<void> update(TransactionData t) async {
    try {
      if (t.id == null) {
        throw const TransactionFailure(
          message: 'Cannot update a transaction without an id',
        );
      }

      final affectedRow = await _localData.update(t);

      if (affectedRow == 0) {
        throw TransactionFailure(
          message: 'Transaction with id ${t.id} not found',
        );
      }
    } on DatabaseException catch (e) {
      throw TransactionFailure(
        message: 'Failed to update ${t.title} transaction',
        cause: e,
      );
    }
  }
}
