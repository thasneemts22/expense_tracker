import 'dart:convert';
import 'package:expense_manager/constants/api_constant.dart';
import 'package:http/http.dart' as http;

class AuthService {
  Future<Map<String, dynamic>> sendOtp(String phone) async {
    final url = Uri.parse("${ApiConstants.baseUrl}/auth/send-otp/");

    final res = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({"phone": phone}),
    );

    print(res.statusCode);
    print(res.body);

    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body);
    } else {
      throw Exception(res.body);
    }
  }

  Future<Map<String, dynamic>> createAccount(
    String phone,
    String nickname,
  ) async {
    final res = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/auth/create-account/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"phone": phone, "nickname": nickname}),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Create account failed");
    }
  }
}
