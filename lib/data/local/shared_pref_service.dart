import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  static const _keyLogin = 'is_login';
  static const _keyUserId = 'user_id';
  static const _keyRole = 'role';

  // ===============================
  // SIMPAN LOGIN + ROLE
  // ===============================
  static Future<void> saveLogin(int id, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLogin, true);
    await prefs.setInt(_keyUserId, id);
    await prefs.setString(_keyRole, role); // admin / kasir
  }

  // ===============================
  // CEK LOGIN
  // ===============================
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLogin) ?? false;
  }

  // ===============================
  // ROLE
  // ===============================
  static Future<String> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRole) ?? '';
  }

  static Future<bool> isAdmin() async {
    return await getRole() == 'admin';
  }

  static Future<bool> isKasir() async {
    return await getRole() == 'kasir';
  }

  // ===============================
  // USER ID
  // ===============================
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  // ===============================
  // LOGOUT
  // ===============================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
