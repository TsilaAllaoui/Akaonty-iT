import 'package:shared_preferences/shared_preferences.dart';

class PINManager {
  static const String pinKey = "user_pin";

  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(pinKey) == null;
  }

  static Future<String?> getCurrentPIN() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(pinKey);
  }

  static Future<bool> setPIN(String pin) async {
    if (pin == '1234') {
      return false; // Don't allow '1234' as the PIN
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(pinKey, pin);
    return true;
  }

  static Future<bool> isDefaultPIN() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(pinKey) == '1234';
  }
}
