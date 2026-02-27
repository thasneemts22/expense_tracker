import 'package:expense_manager/core/database/app_database.dart';
import 'package:expense_manager/features/transactions/models/category_model.dart';
import 'package:expense_manager/features/transactions/models/transactions_model.dart';
import 'package:sqflite/sqflite.dart';

class ExpenseRepository {
  final dbHelper = DBHelper.instance;

  Future<List<Map<String, dynamic>>> getTransactionsWithCategory({
    int? limit,
  }) async {
    final db = await dbHelper.database;

    String query = '''
      SELECT t.id, t.amount, t.note, t.type, t.category_id, t.timestamp,
             c.name as category_name
      FROM transactions t
      LEFT JOIN categories c
      ON t.category_id = c.id
      WHERE t.is_deleted = 0
      ORDER BY t.timestamp DESC
    ''';

    if (limit != null) {
      query += ' LIMIT $limit';
    }

    final result = await db.rawQuery(query);
    return result;
  }

  Future<Map<String, double>> getTotals() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT type, SUM(amount) as total
      FROM transactions
      WHERE is_deleted = 0
      GROUP BY type
    ''');
    double income = 0;
    double expense = 0;
    for (var row in result) {
      if (row['type'] == 'credit') income = (row['total'] as num).toDouble();
      if (row['type'] == 'debit') expense = (row['total'] as num).toDouble();
    }
    return {'income': income, 'expense': expense};
  }

  Future<double> getCurrentMonthExpense() async {
    final db = await dbHelper.database;
    final now = DateTime.now();
    String startOfMonth = DateTime(now.year, now.month, 1).toIso8601String();
    String startOfNextMonth = DateTime(
      now.year,
      now.month + 1,
      1,
    ).toIso8601String();

    final result = await db.rawQuery(
      '''
      SELECT SUM(amount) as total
      FROM transactions
      WHERE type = 'debit' AND is_deleted = 0
      AND timestamp >= ? AND timestamp < ?
    ''',
      [startOfMonth, startOfNextMonth],
    );

    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0;
  }

  Future<void> insertCategory(Category category) async {
    final db = await dbHelper.database;
    await db.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  Future<String?> getCategoryIdByName(String name) async {
  final db = await dbHelper.database;

  final result = await db.query(
    'categories',
    where: 'name = ? AND is_deleted = 0',
    whereArgs: [name],
  );

  if (result.isNotEmpty) {
    return result.first['id'] as String; 
  }

  return null;
}

  Future<List<Category>> getCategories() async {
    final db = await dbHelper.database;
    final maps = await db.query('categories', where: 'is_deleted = 0');
    return List.generate(maps.length, (i) {
      return Category.fromMap(maps[i]);
    });
  }

  Future<void> deleteCategory(String id) async {
  final db = await dbHelper.database;

  await db.update(
    'categories',
    {
      'is_deleted': 1,
      'is_synced': 0,
    },
    where: 'id = ?',
    whereArgs: [id],
  );
}

  Future<void> insertTransaction(TransactionModel txn) async {
    final db = await dbHelper.database;

    await db.insert('transactions', {
      'id': txn.id,
      'note': txn.note,
      'amount': txn.amount,
      'type': txn.type,
      'category_id': txn.categoryId,
      'timestamp': txn.timestamp,
      'is_synced': txn.isSynced,
      'is_deleted': txn.isDeleted,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteTransaction(String id) async {
    final db = await dbHelper.database;

    await db.update(
      'transactions',
      {'is_deleted': 1, 'is_synced': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
