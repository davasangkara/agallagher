import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/theme/theme_provider.dart';
import 'features/pos/pos_controller.dart';

// ================= MODELS =================
import 'data/models/product_model.dart';
import 'data/models/audit_log_model.dart';
import 'data/models/transaction_model.dart';
import 'data/models/transaction_adapter.dart';

Future<void> main() async {
  // ================= INIT FLUTTER =================
  WidgetsFlutterBinding.ensureInitialized();

  // ================= INIT HIVE =================
  await Hive.initFlutter();

  // ================= REGISTER ADAPTER (SAFE) =================
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(ProductAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(AuditLogAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(TransactionModelAdapter());
  }
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(TransactionItemAdapter());
  }

  // ================= OPEN BOX =================
  await Hive.openBox<Product>('products');
  await Hive.openBox<AuditLog>('audit_logs');
  await Hive.openBox<TransactionModel>('transactions');

  // ================= RUN APP =================
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => PosController(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
