import '../../data/local/shared_pref_service.dart';

class AuthController {
  static Future<bool> login(String username, String password) async {
    final u = username.trim();
    final p = password.trim();

    // ================= ADMIN =================
    if (u == 'admin' && p == '123') {
      await SharedPrefService.saveLogin(1, 'admin');
      return true;
    }

    // ================= KASIR =================
    if (u == 'kasir' && p == '123') {
      await SharedPrefService.saveLogin(2, 'kasir');
      return true;
    }

    return false;
  }
}
