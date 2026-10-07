import '../../../core/database/db_helper.dart';
import '../../../core/database/table_name.dart';
import '../domain/transaction_data.dart';
import 'transaction_mapper.dart';

class TransactionLocalDatasource {
  TransactionLocalDatasource(this._dbHelper);

  final DbHelper _dbHelper;

  // CREATE
  Future<int> insert(TransactionData t) async {
    final db = await _dbHelper.database;
    final data = t.toMap()..remove('id'); // create auto id when insert
    return db.insert(TableName.transaction, data);
  }

  // READ
  Future<List<TransactionData>> getAll() async {
    final db = await _dbHelper.database;
    final rows = await db.query(TableName.transaction, orderBy: 'date DESC');
    return rows.map(transactionDataFromMap).toList();
  }

  // UPDATE
  Future<int> update(TransactionData t) async {
    final db = await _dbHelper.database;
    return db.update(
      TableName.transaction,
      t.toMap(),
      where: 'id = ?',
      whereArgs: [t.id],
    );
  }

  // DELETE
  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return db.delete(TableName.transaction, where: 'id = ?', whereArgs: [id]);
  }
}
