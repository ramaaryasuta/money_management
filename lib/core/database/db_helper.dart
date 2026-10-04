import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/transaction.dart';
import 'table_name.dart';

class DbHelper {
  DbHelper._();

  static final DbHelper instance = DbHelper._();

  static Database? _db;

  Future<Database> get database async => _db ?? await _init();

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'money_management.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE ${TableName.transaction} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          value INTEGER NOT NULL,
          type INTEGER NOT NULL, 
          date TEXT NOT NULL
        )
        ''');
      },
    );
  }

  // CREATE
  Future<int> insert(TransactionData t) async {
    final db = await database;
    final data = t.toMap()..remove('id'); // create auto id when insert
    return db.insert(TableName.transaction, data);
  }

  // READ
  Future<List<TransactionData>> getAll() async {
    final db = await database;
    final rows = await db.query(TableName.transaction, orderBy: 'date DESC');
    return rows.map(TransactionData.fromMap).toList();
  }

  // UPDATE
  Future<int> update(TransactionData t) async {
    final db = await database;
    return db.update(
      TableName.transaction,
      t.toMap(),
      where: 'id = ?',
      whereArgs: [t.id],
    );
  }

  // DELETE
  Future<int> delete(int id) async {
    final db = await database;
    return db.delete(TableName.transaction, where: 'id = ?', whereArgs: [id]);
  }
}
