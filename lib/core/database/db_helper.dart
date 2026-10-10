import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'table_name.dart';
import 'transaction_column.dart';

final dbHelperProvider = Provider<DbHelper>((ref) {
  return DbHelper.instance;
});

class DbHelper {
  DbHelper._();

  static final DbHelper instance = DbHelper._();

  static Database? _db;

  Future<Database> get database async => _db ??= await _init();

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'money_management.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE ${TableName.transaction} (
          ${TransactionColumn.id} INTEGER PRIMARY KEY AUTOINCREMENT,
          ${TransactionColumn.title} TEXT NOT NULL,
          ${TransactionColumn.amount} INTEGER NOT NULL,
          ${TransactionColumn.type} INTEGER NOT NULL, 
          ${TransactionColumn.date} TEXT NOT NULL
        )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
          CREATE TABLE transaction_user_new (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            amount INTEGER NOT NULL,
            type INTEGER NOT NULL,
            date TEXT NOT NULL
          )
          ''');

          await db.execute('''
          INSERT INTO transaction_user_new (id, title, amount, type, date)
          SELECT id, title, value, type, date FROM transaction_user
          ''');

          await db.execute('DROP TABLE transaction_user');

          await db.execute(
            'ALTER TABLE transaction_user_new RENAME to transaction_user',
          );
        }
      },
    );
  }
}
