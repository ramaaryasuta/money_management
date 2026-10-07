import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'table_name.dart';

class DbHelper {
  DbHelper._();

  static final DbHelper instance = DbHelper._();

  static Database? _db;

  Future<Database> get database async => _db ??= await _init();

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
}
