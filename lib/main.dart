import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/theme/theme_provider.dart';
import 'features/pos/pos_controller.dart';

// ================= MODELS =================
import 'data/models/product_model.dart';
import 'data/models/audit_log_model.dart';
import 'data/models/transaction_model.dart';
import 'data/models/transaction_adapter.dart';
import 'data/models/user_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Init Format Tanggal (Penting buat Rupiah & Laporan)
  await initializeDateFormatting('id_ID', null);

  // 2. Init Database (Hive)
  // Di Web: Ini akan pakai IndexedDB browser.
  // Di HP: Ini akan pakai File System.
  await Hive.initFlutter();

  // 3. Register Adapter (Struktur Data)
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(ProductAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(AuditLogAdapter());
  if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(TransactionModelAdapter());
  if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(TransactionItemAdapter());
  if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(UserModelAdapter());

  // 4. Buka Kotak Penyimpanan
  // JANGAN PERNAH PAKE .clear() DISINI!
  await Hive.openBox<Product>('products');
  await Hive.openBox<AuditLog>('audit_logs');
  await Hive.openBox<TransactionModel>('transactions');
  await Hive.openBox('settings');
  
  var userBox = await Hive.openBox<UserModel>('users');

  // ============================================================
  // 🔥 LOGIKA DATA AMAN (ANTI-RESET) 🔥
  // ============================================================
  
  // Cek isi database lewat Terminal
  print("📊 STATUS DATABASE: ${userBox.length} User tersimpan.");

  if (userBox.isEmpty) {
    print("⚠️ Database Kosong. Membuat User Admin Baru...");
    await userBox.add(
      UserModel(
        name: 'Super Admin',
        email: 'dava',
        role: 'admin',
        pin: '456',
        isActive: true,
      ),
    );
    print("✅ User Default Dibuat: dava / 456");
  } else {
    // Kalau sudah ada data, biarkan saja.
    print("✅ Database Aman. Data lama TIDAK dihapus.");
  }
  // ============================================================

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => PosController()),
      ],
      child: const MyApp(),
    ),
  );
}