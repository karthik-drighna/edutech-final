import 'package:shared_preferences/shared_preferences.dart';

class Utility {
  static Future<void> setString(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<double> changeAmount(double amount, double basePrice) async {
    // Assuming basePrice is the conversion rate from the currency to the desired currency
    return amount * basePrice;
  }

  // Add other utility methods as needed
}
