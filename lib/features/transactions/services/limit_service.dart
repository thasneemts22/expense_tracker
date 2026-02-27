import 'package:shared_preferences/shared_preferences.dart';

class LimitService {
  static const String limitKey = "monthly_limit";

  Future<void> setLimit(double limit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(limitKey, limit);
  }

  Future<double> getLimit() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey(limitKey)) {
      return 10000; 
    }

    return prefs.getDouble(limitKey) ?? 10000;
  }
}
