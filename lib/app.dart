import 'package:flutter/material.dart';
import 'features/auth/login_page.dart';
import 'features/dashboard/dashboard_page.dart';
import 'features/pos/pos_page.dart';
import 'data/local/shared_pref_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory POS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const _RootPage(),
    );
  }
}

// ================= ROOT REDIRECT =================
class _RootPage extends StatelessWidget {
  const _RootPage();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: SharedPrefService.isLoggedIn(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ❌ BELUM LOGIN
        if (snapshot.data == false) {
          return LoginPage();
        }

        // ✅ SUDAH LOGIN → CEK ROLE
        return FutureBuilder<String>(
          future: SharedPrefService.getRole(),
          builder: (context, roleSnap) {
            if (!roleSnap.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final role = roleSnap.data;

            if (role == 'admin') {
              return const DashboardPage();
            }

            if (role == 'kasir') {
              return const PosPage();
            }

            // fallback
            return LoginPage();
          },
        );
      },
    );
  }
}
