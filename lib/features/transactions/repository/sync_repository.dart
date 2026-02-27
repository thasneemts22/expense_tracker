import 'package:expense_manager/core/database/app_database.dart';
import 'package:expense_manager/features/transactions/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class SyncRepository {
  final DBHelper dbHelper = DBHelper.instance;
  final ApiService apiService = ApiService();

  Future<void> syncData() async {
    print(" SYNC FUNCTION STARTED");
    final db = await dbHelper.database;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      throw Exception("User not authenticated");
    }

    
    final deletedTransactions = await db.query(
      "transactions",
      where: "is_deleted = 1 AND is_synced = 1",
    );

    if (deletedTransactions.isNotEmpty) {
      final ids = deletedTransactions.map((e) => e["id"] as String).toList();

      await apiService.deleteTransactions(ids, token);

      await db.delete(
        "transactions",
        where: "id IN (${List.filled(ids.length, '?').join(',')})",
        whereArgs: ids,
      );
    }

    
    final deletedCategories = await db.query(
      "categories",
      where: "is_deleted = 1", 
    );

    if (deletedCategories.isNotEmpty) {
      final ids = deletedCategories.map((e) => e["id"] as String).toList();

      await apiService.deleteCategories(ids, token);

      
      await db.delete(
        "categories",
        where: "id IN (${List.filled(ids.length, '?').join(',')})",
        whereArgs: ids,
      );
    }

    
    final unsyncedCategories = await db.query(
      "categories",
      where: "is_synced = 0 AND is_deleted = 0",
    );

    if (unsyncedCategories.isNotEmpty) {
      final response = await apiService.uploadCategories(
        unsyncedCategories,
        token,
      );

      if (response["status"] != "success") {
        throw Exception("Category sync failed");
      }

      
      await db.update("categories", {
        "is_synced": 1,
      }, where: "is_synced = 0 AND is_deleted = 0");
    }

    
    final unsyncedTransactions = await db.query(
      "transactions",
      where: "is_synced = 0 AND is_deleted = 0",
    );

    if (unsyncedTransactions.isNotEmpty) {
      await apiService.uploadTransactions(unsyncedTransactions, token);

      for (var txn in unsyncedTransactions) {
        await db.update(
          "transactions",
          {"is_synced": 1},
          where: "id = ?",
          whereArgs: [txn["id"]],
        );
      }
    }

    

    print(" FETCHING SERVER DATA");

    final serverCategories = await apiService.fetchCategories(token);
    final serverTransactions = await apiService.fetchTransactions(token);

    print(" Server Categories Count = ${serverCategories.length}");
    print(" Server Transactions Count = ${serverTransactions.length}");

    
    for (var category in serverCategories) {
      await db.insert("categories", {
        "id": category["id"],
        "name": category["name"] ?? "",
        "is_synced": 1,
        "is_deleted": 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

  
    for (var txn in serverTransactions) {
      await db.insert("transactions", {
        "id": txn["id"],
        "amount": txn["amount"] ?? 0,
        "note": txn["note"] ?? "",
        "type": txn["type"] ?? "debit",
        "category_id": txn["category_id"] ?? "",
        "timestamp": txn["timestamp"] ?? DateTime.now().toIso8601String(),
        "is_synced": 1,
        "is_deleted": 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    print("SYNC COMPLETED");
  }
}
