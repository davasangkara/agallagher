import 'package:hive_flutter/hive_flutter.dart';
import '../../data/local/shared_pref_service.dart';
import '../../data/models/user_model.dart';

class AuthController {
  
  /// Mengembalikan TRUE jika login sukses, FALSE jika gagal
  static Future<bool> login(String username, String password) async {
    final u = username.trim();
    final p = password.trim();

    // ================= 1. ADMIN DARURAT (Hardcoded) =================
    // Gunakan ini jika database kosong atau lupa password
    if (u == 'admin' && p == '123456') { 
      // PERBAIKAN: Parameter pertama String (Nama), bukan int
      await SharedPrefService.saveLogin('Super Admin', 'admin'); 
      return true;
    }

    // ================= 2. CEK DATABASE HIVE (Karyawan) =================
    try {
      // Pastikan box 'users' sudah dibuka di main.dart
      if (!Hive.isBoxOpen('users')) {
        await Hive.openBox<UserModel>('users');
      }
      
      final userBox = Hive.box<UserModel>('users');

      // Cari user yang Namanya ATAU Emailnya cocok, DAN PIN-nya cocok
      final user = userBox.values.firstWhere(
        (user) => (user.name == u || user.email == u) && user.pin == p,
      );

      // Cek apakah akun aktif
      if (!user.isActive) {
        return false; // Gagal karena akun dinonaktifkan
      }

      // PERBAIKAN: Simpan Nama User dan Role yang sesuai dari database
      await SharedPrefService.saveLogin(user.name, user.role);
      return true;

    } catch (e) {
      // Jika user tidak ditemukan (error StateError dari firstWhere)
      return false;
    }
  }
}