import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _keyPhoneNumber = 'user_phone_number';

  // Save session
  static Future<void> saveSession(String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPhoneNumber, phoneNumber);
  }

  // Get session
  static Future<String?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPhoneNumber);
  }

  // Clear session
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPhoneNumber);
  }

  // Check if logged in
  static Future<bool> isLoggedIn() async {
    final phoneNumber = await getSession();
    return phoneNumber != null && phoneNumber.isNotEmpty;
  }
}
