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
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins', // Opsional jika punya font
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
      ),
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
        // Loading State
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ❌ BELUM LOGIN -> Login Page
        if (snapshot.data == false) {
          return const LoginPage();
        }

        // ✅ SUDAH LOGIN -> Cek Role untuk Redirect
        return FutureBuilder<String>(
          future: SharedPrefService.getRole(),
          builder: (context, roleSnap) {
            if (roleSnap.connectionState == ConnectionState.waiting) {
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

            // Fallback
            return const LoginPage();
          },
        );
      },
    );
  }
}