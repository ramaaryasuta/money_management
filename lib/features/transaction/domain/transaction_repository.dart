import 'transaction_data.dart';
import 'transaction_failure.dart';

/// all method can be throw [TransactionFailure] class
abstract interface class TransactionRepository {
  Future<TransactionData> add(TransactionData t);
  Future<List<TransactionData>> getAll();
  Future<void> update(TransactionData t);
  Future<void> delete(int id);
}
