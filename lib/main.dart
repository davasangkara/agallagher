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

  await initializeDateFormatting('id_ID', null);
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(ProductAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(AuditLogAdapter());
  if (!Hive.isAdapterRegistered(3))
    Hive.registerAdapter(TransactionModelAdapter());
  if (!Hive.isAdapterRegistered(4))
    Hive.registerAdapter(TransactionItemAdapter());
  if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(UserModelAdapter());

  await Hive.openBox<Product>('products');
  await Hive.openBox<AuditLog>('audit_logs');
  await Hive.openBox<TransactionModel>('transactions');
  await Hive.openBox('settings');

  var userBox = await Hive.openBox<UserModel>('users');

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
