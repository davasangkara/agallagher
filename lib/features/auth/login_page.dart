import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/local/shared_pref_service.dart';
import '../../data/models/user_model.dart';
import '../dashboard/dashboard_page.dart';
import '../pos/pos_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  // LOGIKA LOGIN DATABASE
  Future<void> _handleLogin() async {
    if (usernameCtrl.text.isEmpty || passwordCtrl.text.isEmpty) {
      _showSnack('Username dan PIN harus diisi', Colors.red);
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800)); // Efek loading

    final inputName = usernameCtrl.text.trim();
    final inputPin = passwordCtrl.text.trim();

    // 1. Cek Admin Darurat (Jika database kosong/rusak)
    if (inputName == 'admin' && inputPin == '123456') {
      await SharedPrefService.saveLogin('Super Admin', 'admin');
      if (mounted) _navigate('admin');
      return;
    }

    // 2. Cek Database Hive
    final userBox = Hive.box<UserModel>('users');
    
    try {
      // Cari user yang cocok (Nama/Email & PIN)
      final user = userBox.values.firstWhere(
        (u) => (u.name == inputName || u.email == inputName) && u.pin == inputPin,
      );

      if (user.isActive) {
        // SUKSES
        await SharedPrefService.saveLogin(user.name, user.role);
        if (mounted) _navigate(user.role);
      } else {
        // AKUN NONAKTIF
        if (mounted) {
          setState(() => _isLoading = false);
          _showSnack('Akun Anda telah dinonaktifkan Admin.', Colors.orange);
        }
      }
    } catch (e) {
      // GAGAL
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnack('Username atau PIN salah!', Colors.red);
      }
    }
  }

  void _navigate(String role) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => role == 'admin' ? const DashboardPage() : const PosPage(),
      ),
    );
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // ================= LEFT SIDE (BRANDING) =================
          if (isDesktop)
            Expanded(
              flex: 5,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF4A00E0)], 
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -100, right: -100,
                      child: Container(
                        width: 400, height: 400,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(60),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.inventory_2_rounded, size: 80, color: Colors.white),
                          const SizedBox(height: 30),
                          const Text(
                            'Kelola Bisnis\nJadi Lebih Mudah.',
                            style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white, height: 1.2),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Sistem POS dan Inventory modern untuk pertumbuhan bisnis Anda.',
                            style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8), height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ================= RIGHT SIDE (FORM) =================
          Expanded(
            flex: isDesktop ? 4 : 1,
            child: Container(
              color: Colors.white,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(40),
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!isDesktop) ...[
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: const BoxDecoration(color: Color(0xFFF5F6FA), shape: BoxShape.circle),
                                  child: const Icon(Icons.inventory_2_rounded, size: 40, color: Color(0xFF6C63FF)),
                                ),
                              ),
                              const SizedBox(height: 30),
                            ],

                            const Text(
                              'Selamat Datang!',
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Silakan login untuk melanjutkan',
                              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                            ),
                            const SizedBox(height: 40),

                            _ModernInput(
                              controller: usernameCtrl,
                              label: 'Username / Email',
                              icon: Icons.person_outline_rounded,
                            ),
                            const SizedBox(height: 20),
                            _ModernInput(
                              controller: passwordCtrl,
                              label: 'PIN / Password',
                              icon: Icons.lock_outline_rounded,
                              isPassword: true,
                              isVisible: _isPasswordVisible,
                              onVisibilityToggle: () {
                                setState(() => _isPasswordVisible = !_isPasswordVisible);
                              },
                            ),
                            
                            const SizedBox(height: 40),

                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6C63FF),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 5,
                                  shadowColor: const Color(0xFF6C63FF).withOpacity(0.4),
                                ),
                                child: _isLoading
                                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Text(
                                        'MASUK',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white),
                                      ),
                              ),
                            ),
                            
                            const SizedBox(height: 40),
                            const Center(child: Text("Versi 1.0.0 • Nexus POS", style: TextStyle(color: Colors.grey, fontSize: 12))),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernInput extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;
  final bool isVisible;
  final VoidCallback? onVisibilityToggle;

  const _ModernInput({
    required this.controller,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.isVisible = false,
    this.onVisibilityToggle,
  });

  @override
  State<_ModernInput> createState() => _ModernInputState();
}

class _ModernInputState extends State<_ModernInput> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
        const SizedBox(height: 8),
        Focus(
          onFocusChange: (hasFocus) => setState(() => _isFocused = hasFocus),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA), 
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isFocused ? const Color(0xFF6C63FF) : Colors.transparent, 
                width: 1.5,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: widget.controller,
              obscureText: widget.isPassword && !widget.isVisible,
              keyboardType: widget.isPassword ? TextInputType.number : TextInputType.text,
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                icon: Icon(widget.icon, color: _isFocused ? const Color(0xFF6C63FF) : Colors.grey),
                border: InputBorder.none,
                hintText: 'Masukkan data...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                suffixIcon: widget.isPassword
                    ? IconButton(
                        icon: Icon(widget.isVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: Colors.grey),
                        onPressed: widget.onVisibilityToggle,
                      )
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}