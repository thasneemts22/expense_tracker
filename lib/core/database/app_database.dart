import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expense_manager.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
      if (oldVersion < 2) {
        await db.execute(
          'ALTER TABLE transactions ADD COLUMN timestamp TEXT DEFAULT ""',
        );
      }

      if (oldVersion < 3) {
        final tables = await db.rawQuery("PRAGMA table_info(categories)");

        final columns = tables.map((e) => e["name"].toString()).toList();

        if (!columns.contains("is_synced")) {
          await db.execute(
            'ALTER TABLE categories ADD COLUMN is_synced INTEGER DEFAULT 0',
          );
        }

        if (!columns.contains("is_deleted")) {
          await db.execute(
            'ALTER TABLE categories ADD COLUMN is_deleted INTEGER DEFAULT 0',
          );
        }
      }

      if (oldVersion < 4) {
        final txnTable = await db.rawQuery("PRAGMA table_info(transactions)");

        final txnColumns = txnTable.map((e) => e["name"].toString()).toList();

        if (!txnColumns.contains("is_synced")) {
          await db.execute(
            'ALTER TABLE transactions ADD COLUMN is_synced INTEGER DEFAULT 0',
          );
        }

        if (!txnColumns.contains("is_deleted")) {
          await db.execute(
            'ALTER TABLE transactions ADD COLUMN is_deleted INTEGER DEFAULT 0',
          );
        }
      }
    } catch (e) {
      print("DB Upgrade Error: $e");
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories(
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  is_synced INTEGER DEFAULT 0,
  is_deleted INTEGER DEFAULT 0
)
    ''');

    await db.execute('''
CREATE TABLE transactions(
  id TEXT PRIMARY KEY,
  amount REAL NOT NULL,
  note TEXT,
  type TEXT NOT NULL,
  category_id TEXT,
  timestamp TEXT NOT NULL,
  is_synced INTEGER DEFAULT 0,
  is_deleted INTEGER DEFAULT 0
)

    ''');
    await db.execute(
      'CREATE INDEX idx_transactions_sync ON transactions(is_synced, is_deleted)',
    );
  }

  Future close() async {
    final db = await instance.database;
    await db.close();
  }
}
