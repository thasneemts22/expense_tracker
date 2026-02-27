import 'dart:convert';
import 'package:expense_manager/constants/api_constant.dart';
import 'package:http/http.dart' as http;

class ApiService {
  
  Future<void> deleteTransactions(List<String> ids, String token) async {
    if (ids.isEmpty) return;

    print(" TRANSACTION DELETE API CALL");
    print("IDs: $ids");

    try {
      
      for (String id in ids) {
        final response = await http.delete(
          Uri.parse("${ApiConstants.baseUrl}/transactions/delete/"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode({"transaction_id": id}),
        );

        print("Delete Status = ${response.statusCode}");
        print("Delete Response = ${response.body}");
      }
    } catch (e) {
      print("Delete API error → $e");
    }
  }

  /// ===============================
  /// DELETE CATEGORIES
  /// ===============================
  Future<void> deleteCategories(List<String> ids, String token) async {
    if (ids.isEmpty) return;

    print(" CATEGORY DELETE API CALL");
    print("IDs: $ids");

    try {
      final response = await http
          .delete(
            Uri.parse("${ApiConstants.baseUrl}/categories/delete/"),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
            body: jsonEncode({"ids": ids}),
          )
          .timeout(const Duration(seconds: 30));

      print("Delete Status = ${response.statusCode}");
      print("Delete Response = ${response.body}");

      if (![200, 201, 204].contains(response.statusCode)) {
        print("Category delete failed but sync continues");
      }
    } catch (e) {
      print("Delete API error → $e");
    }
  }


  Future<Map<String, dynamic>> uploadCategories(
    List<Map<String, dynamic>> categories,
    String token,
  ) async {
    if (categories.isEmpty) {
      return {"status": "success"};
    }

    print("CATEGORY UPLOAD API CALL");

    for (var c in categories) {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/categories/add/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"name": c["name"]}),
      );

      final responseBody = jsonDecode(response.body);

      print("Upload Status = ${response.statusCode}");
      print("Upload Response = ${response.body}");

      
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          responseBody["message"] == "Category already exists") {
        print(" Category sync success");
        continue;
      }


      throw Exception("Category upload failed");
    }
    return {"status": "success"};
  }

  
  Future<Map<String, dynamic>> uploadTransactions(
    List<Map<String, dynamic>> txns,
    String token,
  ) async {
    if (txns.isEmpty) {
      return {"status": "success"};
    }

    final response = await http
        .post(
          Uri.parse("${ApiConstants.baseUrl}/transactions/add/"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode({"transactions": txns}),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    throw Exception("Transaction upload failed");
  }

  
  Future<List<dynamic>> fetchCategories(String token) async {
    print(" CATEGORY FETCH API CALL");

    final response = await http
        .get(
          Uri.parse("${ApiConstants.baseUrl}/categories/"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        )
        .timeout(const Duration(seconds: 30));

    print("Status = ${response.statusCode}");
    print("Body = ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["categories"] ?? [];
    }

    throw Exception("Category fetch failed");
  }

  
  Future<List<dynamic>> fetchTransactions(String token) async {
    print(" TRANSACTION FETCH API CALL");

    final response = await http
        .get(
          Uri.parse("${ApiConstants.baseUrl}/transactions/"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        )
        .timeout(const Duration(seconds: 30));

    print("Status = ${response.statusCode}");
    print("Body = ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      print("Transactions Fetch Success");

      return data["transactions"] ?? [];
    }

    print(" Transaction fetch failed");

    throw Exception("Transaction fetch failed");
  }
}
