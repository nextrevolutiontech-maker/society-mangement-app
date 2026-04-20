import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveUserSession(String role, String identifier) async {
    await _prefs.setString('user_role', role);
    await _prefs.setString('user_identifier', identifier);
    await _prefs.setBool('is_logged_in', true);
  }

  static String? getUserRole() {
    return _prefs.getString('user_role');
  }

  static String? getUserIdentifier() {
    return _prefs.getString('user_identifier');
  }

  static bool isLoggedIn() {
    return _prefs.getBool('is_logged_in') ?? false;
  }

  static Future<void> clearSession() async {
    await _prefs.clear();
  }
}
