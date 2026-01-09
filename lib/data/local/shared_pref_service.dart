import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  static const _keyLogin = 'is_login';
  static const _keyUserName = 'user_name'; // Disimpan sebagai String Nama
  static const _keyRole = 'role';

  // ===============================
  // SIMPAN LOGIN + ROLE
  // ===============================
  static Future<void> saveLogin(String name, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLogin, true);
    await prefs.setString(_keyUserName, name);
    await prefs.setString(_keyRole, role); // 'admin' atau 'kasir'
  }

  // ===============================
  // CEK LOGIN
  // ===============================
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLogin) ?? false;
  }

  // ===============================
  // AMBIL DATA
  // ===============================
  static Future<String> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRole) ?? 'kasir'; // Default ke kasir jika null
  }

  static Future<String> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName) ?? 'User';
  }

  static Future<bool> isAdmin() async {
    return await getRole() == 'admin';
  }

  // ===============================
  // LOGOUT
  // ===============================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}