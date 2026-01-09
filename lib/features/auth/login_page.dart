import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  late AnimationController _animController;
  late AnimationController _pulseController;
  late AnimationController _particleController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutQuart),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _animController.forward();
    _pulseController.repeat(reverse: true);
    _particleController.repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (usernameCtrl.text.isEmpty || passwordCtrl.text.isEmpty) {
      _showSnack('Username dan PIN harus diisi', SnackType.error);
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));

    final inputName = usernameCtrl.text.trim();
    final inputPin = passwordCtrl.text.trim();

    // Admin Hardcode
    if (inputName == 'admin' && inputPin == '123456') {
      await SharedPrefService.saveLogin('Super Admin', 'admin');
      if (mounted) {
        _showSnack('Selamat datang, Super Admin!', SnackType.success);
        await Future.delayed(const Duration(milliseconds: 500));
        _navigate('admin');
      }
      return;
    }

    // Database Check
    if (!Hive.isBoxOpen('users')) await Hive.openBox<UserModel>('users');
    final userBox = Hive.box<UserModel>('users');

    try {
      final user = userBox.values.firstWhere(
        (u) => (u.name == inputName || u.email == inputName) && u.pin == inputPin,
      );

      if (user.isActive) {
        await SharedPrefService.saveLogin(user.name, user.role);
        TextInput.finishAutofillContext();
        if (mounted) {
          _showSnack('Selamat datang, ${user.name}!', SnackType.success);
          await Future.delayed(const Duration(milliseconds: 500));
          _navigate(user.role);
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          _showSnack('Akun Anda telah dinonaktifkan', SnackType.warning);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnack('Username atau PIN salah!', SnackType.error);
      }
    }
  }

  void _navigate(String role) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            role == 'admin' ? const DashboardPage() : const PosPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _showSnack(String msg, SnackType type) {
    final config = _getSnackConfig(type);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: config.gradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(config.icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1F2937),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        elevation: 10,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  SnackConfig _getSnackConfig(SnackType type) {
    switch (type) {
      case SnackType.success:
        return SnackConfig(
          icon: Icons.check_circle_rounded,
          gradient: const LinearGradient(
            colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
          ),
        );
      case SnackType.error:
        return SnackConfig(
          icon: Icons.error_rounded,
          gradient: const LinearGradient(
            colors: [Color(0xFFf093fb), Color(0xFFF5576C)],
          ),
        );
      case SnackType.warning:
        return SnackConfig(
          icon: Icons.warning_rounded,
          gradient: const LinearGradient(
            colors: [Color(0xFFfa709a), Color(0xFFfee140)],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final isDesktop = width > 900;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Animated Background Pattern
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ParticlePainter(_particleController.value),
                  size: Size(width, height),
                );
              },
            ),

            Row(
              children: [
                // ================= LEFT BRANDING (DESKTOP) =================
                if (isDesktop)
                  Expanded(
                    flex: 5,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF667eea),
                            Color(0xFF764ba2),
                            Color(0xFF667eea),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Floating Gradient Orbs
                          ...List.generate(4, (index) {
                            return Positioned(
                              top: (index * height * 0.25) + 50,
                              left: (index % 2 == 0) ? -100 : null,
                              right: (index % 2 == 1) ? -100 : null,
                              child: AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _pulseAnim.value + (index * 0.05),
                                    child: Container(
                                      width: 300 + (index * 50),
                                      height: 300 + (index * 50),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            Colors.white.withOpacity(0.1),
                                            Colors.white.withOpacity(0.02),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }),

                          // Main Content
                          Padding(
                            padding: const EdgeInsets.all(80),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Animated Logo
                                AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: _pulseAnim.value,
                                      child: Container(
                                        padding: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.white.withOpacity(0.25),
                                              Colors.white.withOpacity(0.15),
                                            ],
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.3),
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.white.withOpacity(0.3),
                                              blurRadius: 40,
                                              spreadRadius: 10,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.store_rounded,
                                          size: 64,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 60),

                                // Hero Title
                                const Text(
                                  'Kelola Bisnis\nJadi Lebih Mudah',
                                  style: TextStyle(
                                    fontSize: 56,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 1.1,
                                    letterSpacing: -1.5,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 30,
                                        color: Colors.black26,
                                        offset: Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                Container(
                                  width: 80,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Colors.white, Colors.transparent],
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),

                                const SizedBox(height: 32),

                                Text(
                                  'Sistem POS dan Inventory modern untuk\npertumbuhan bisnis yang lebih efisien\ndan terukur.',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white.withOpacity(0.95),
                                    height: 1.7,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.3,
                                  ),
                                ),

                                const SizedBox(height: 60),

                                // Feature Pills
                                Wrap(
                                  spacing: 14,
                                  runSpacing: 14,
                                  children: [
                                    _FeaturePill(
                                      icon: Icons.flash_on_rounded,
                                      text: 'Cepat & Mudah',
                                    ),
                                    _FeaturePill(
                                      icon: Icons.workspace_premium_rounded,
                                      text: 'Professional',
                                    ),
                                    _FeaturePill(
                                      icon: Icons.insights_rounded,
                                      text: 'Smart Analytics',
                                    ),
                                    _FeaturePill(
                                      icon: Icons.security_rounded,
                                      text: 'Secure',
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 60),

                                // Stats
                                Row(
                                  children: [
                                    _StatItem(number: '1000+', label: 'Pengguna'),
                                    const SizedBox(width: 50),
                                    _StatItem(number: '99.9%', label: 'Uptime'),
                                    const SizedBox(width: 50),
                                    _StatItem(number: '24/7', label: 'Support'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // ================= RIGHT FORM =================
                Expanded(
                  flex: isDesktop ? 4 : 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: isDesktop
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 30,
                                offset: const Offset(-10, 0),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(isDesktop ? 60 : 32),
                        child: FadeTransition(
                          opacity: _fadeAnim,
                          child: SlideTransition(
                            position: _slideAnim,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 420),
                              child: AutofillGroup(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Mobile Logo
                                    if (!isDesktop) ...[
                                      Center(
                                        child: Container(
                                          padding: const EdgeInsets.all(28),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF667eea),
                                                Color(0xFF764ba2),
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF667eea)
                                                    .withOpacity(0.4),
                                                blurRadius: 30,
                                                spreadRadius: 5,
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.store_rounded,
                                            size: 40,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 48),
                                    ],

                                    // Welcome Text
                                    Row(
                                      children: [
                                        const Text(
                                          'Selamat Datang',
                                          style: TextStyle(
                                            fontSize: 34,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF1F2937),
                                            letterSpacing: -1,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        AnimatedBuilder(
                                          animation: _pulseController,
                                          builder: (context, child) {
                                            return Transform.scale(
                                              scale: _pulseAnim.value,
                                              child: const Text(
                                                '👋',
                                                style: TextStyle(fontSize: 32),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Masuk ke akun Anda untuk melanjutkan',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 50),

                                    // Form Inputs
                                    _ModernInput(
                                      controller: usernameCtrl,
                                      label: 'Username / Email',
                                      icon: Icons.person_outline_rounded,
                                      autofillHints: const [AutofillHints.username],
                                      textInputAction: TextInputAction.next,
                                    ),
                                    const SizedBox(height: 24),
                                    _ModernInput(
                                      controller: passwordCtrl,
                                      label: 'PIN / Password',
                                      icon: Icons.lock_outline_rounded,
                                      isPassword: true,
                                      isVisible: _isPasswordVisible,
                                      autofillHints: const [AutofillHints.password],
                                      textInputAction: TextInputAction.done,
                                      onSubmitted: (_) => _handleLogin(),
                                      onVisibilityToggle: () {
                                        setState(() =>
                                            _isPasswordVisible = !_isPasswordVisible);
                                      },
                                    ),

                                    const SizedBox(height: 50),

                                    // Login Button
                                    SizedBox(
                                      width: double.infinity,
                                      height: 62,
                                      child: Stack(
                                        children: [
                                          // Gradient Shadow
                                          Positioned.fill(
                                            child: Container(
                                              margin: const EdgeInsets.only(top: 8),
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xFF667eea),
                                                    Color(0xFF764ba2),
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(0xFF667eea)
                                                        .withOpacity(0.4),
                                                    blurRadius: 25,
                                                    spreadRadius: 2,
                                                    offset: const Offset(0, 10),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // Button
                                          Container(
                                            decoration: BoxDecoration(
                                              gradient: _isLoading
                                                  ? LinearGradient(
                                                      colors: [
                                                        Colors.grey[400]!,
                                                        Colors.grey[500]!,
                                                      ],
                                                    )
                                                  : const LinearGradient(
                                                      colors: [
                                                        Color(0xFF667eea),
                                                        Color(0xFF764ba2),
                                                      ],
                                                    ),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: ElevatedButton(
                                              onPressed: _isLoading ? null : _handleLogin,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.transparent,
                                                shadowColor: Colors.transparent,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                              ),
                                              child: _isLoading
                                                  ? const SizedBox(
                                                      width: 26,
                                                      height: 26,
                                                      child: CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 3,
                                                      ),
                                                    )
                                                  : Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.center,
                                                      children: [
                                                        const Text(
                                                          'MASUK',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w800,
                                                            letterSpacing: 2,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 12),
                                                        Container(
                                                          padding: const EdgeInsets.all(6),
                                                          decoration: BoxDecoration(
                                                            color: Colors.white
                                                                .withOpacity(0.2),
                                                            borderRadius:
                                                                BorderRadius.circular(8),
                                                          ),
                                                          child: const Icon(
                                                            Icons.arrow_forward_rounded,
                                                            color: Colors.white,
                                                            size: 20,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 70),

                                    // Footer
                                    Center(
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  const Color(0xFF667eea)
                                                      .withOpacity(0.1),
                                                  const Color(0xFF764ba2)
                                                      .withOpacity(0.05),
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.verified_rounded,
                                                  color: Color(0xFF667eea),
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  "Nexus POS System",
                                                  style: TextStyle(
                                                    color: Colors.grey[800],
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            "Version 1.0.0 • Secure & Reliable",
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
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
          ],
        ),
      ),
    );
  }
}

// Modern Input Widget
class _ModernInput extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;
  final bool isVisible;
  final VoidCallback? onVisibilityToggle;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final Function(String)? onSubmitted;

  const _ModernInput({
    required this.controller,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.isVisible = false,
    this.onVisibilityToggle,
    this.autofillHints,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  State<_ModernInput> createState() => _ModernInputState();
}

class _ModernInputState extends State<_ModernInput>
    with SingleTickerProviderStateMixin {
  bool _isFocused = false;
  late AnimationController _focusAnimController;
  late Animation<double> _focusAnimation;

  @override
  void initState() {
    super.initState();
    _focusAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _focusAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _focusAnimController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _focusAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            widget.label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF374151),
              fontSize: 14,
              letterSpacing: 0.3,
            ),
          ),
        ),
        Focus(
          onFocusChange: (hasFocus) {
            setState(() => _isFocused = hasFocus);
            if (hasFocus) {
              _focusAnimController.forward();
            } else {
              _focusAnimController.reverse();
            }
          },
          child: AnimatedBuilder(
            animation: _focusAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.white,
                  border: Border.all(
                    color: _isFocused
                        ? const Color(0xFF667eea)
                        : Colors.grey.shade200,
                    width: _isFocused ? 2.5 : 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _isFocused
                          ? const Color(0xFF667eea).withOpacity(0.15)
                          : Colors.black.withOpacity(0.03),
                      blurRadius: _isFocused ? 25 : 10,
                      spreadRadius: _isFocused ? 1 : 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: widget.controller,
                  obscureText: widget.isPassword && !widget.isVisible,
                  keyboardType: widget.isPassword
                      ? TextInputType.visiblePassword
                      : TextInputType.emailAddress,
                  autofillHints: widget.autofillHints,
                  textInputAction: widget.textInputAction,
                  onSubmitted: widget.onSubmitted,
                  style: const TextStyle(
                    color: Color(0xFF1f2937),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 22,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 16),
                      child: Icon(
                        widget.icon,
                        color: _isFocused
                            ? const Color(0xFF667eea)
                            : Colors.grey[400],
                        size: 24,
                      ),
                    ),
                    border: InputBorder.none,
                    hintText: 'Masukkan ${widget.label.toLowerCase()}',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    suffixIcon: widget.isPassword
                        ? Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: IconButton(
                              icon: Icon(
                                widget.isVisible
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                                color: _isFocused
                                    ? const Color(0xFF667eea)
                                    : Colors.grey[400],
                                size: 24,
                              ),
                              onPressed: widget.onVisibilityToggle,
                            ),
                          )
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Feature Pill
class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeaturePill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// Stat Item
class _StatItem extends StatelessWidget {
  final String number;
  final String label;

  const _StatItem({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class SnackConfig {
  final IconData icon;
  final LinearGradient gradient;

  SnackConfig({required this.icon, required this.gradient});
}

enum SnackType { success, error, warning }

/// Particle Painter for Background
class _ParticlePainter extends CustomPainter {
  final double progress;

  _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF667eea).withOpacity(0.03)
      ..style = PaintingStyle.fill;

    // Draw floating circles
    for (int i = 0; i < 8; i++) {
      final x = (size.width * (i / 8) + (progress * 100)) % size.width;
      final y = (size.height * ((i * 0.3) % 1) + (progress * 50)) % size.height;
      
      // PERBAIKAN DISINI: Tambahkan .0 atau .toDouble()
      final double radius = 30.0 + (i * 10); 
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}