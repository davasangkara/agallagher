import 'package:flutter/material.dart';
import '../../data/local/shared_pref_service.dart';

import '../dashboard/dashboard_page.dart';
import '../product/product_page.dart';
import '../pos/pos_page.dart';
import '../report/report_page.dart';
import '../users/users_page.dart';
import '../settings/settings_page.dart';
import '../history/transaction_history_page.dart';

class DashboardSidebar extends StatelessWidget {
  final bool isDrawer;
  const DashboardSidebar({super.key, this.isDrawer = false});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final collapsed = width < 1000 && !isDrawer;

    return FutureBuilder<String>(
      future: SharedPrefService.getRole(),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox();
        final role = snap.data!;

        return Container(
          width: isDrawer ? 280 : (collapsed ? 80 : 260),
          height: isDrawer ? double.infinity : null,
          margin: isDrawer ? null : const EdgeInsets.fromLTRB(20, 20, 0, 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                const Color(0xFFFAFBFF),
                const Color(0xFFF8F9FE),
              ],
            ),
            borderRadius: isDrawer ? null : BorderRadius.circular(30),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1,
            ),
            boxShadow: isDrawer
                ? []
                : [
                    BoxShadow(
                      color: const Color(0xFF667EEA).withOpacity(0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // === LOGO AREA ===
              if (collapsed)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF667EEA).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    size: 28,
                    color: Colors.white,
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF667EEA).withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Flexible(
                        child: Text(
                          "AGALLAGHER",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 40),

              // === MENU ITEMS ===
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Header Menu
                    if (!collapsed)
                      Container(
                        margin: const EdgeInsets.only(left: 12, bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE0E7FF), Color(0xFFFCE7F3)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "MENU UTAMA",
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF667EEA),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),

                    // Admin Menu
                    if (role == 'admin') ...[
                      _NavButton(
                        icon: Icons.dashboard_rounded,
                        label: 'Dashboard',
                        page: const DashboardPage(),
                        isActive: context.widget.runtimeType == DashboardPage,
                        collapsed: collapsed,
                        isDrawer: isDrawer,
                        gradientColors: const [Color(0xFF667EEA), Color(0xFF764BA2)],
                      ),
                      _NavButton(
                        icon: Icons.inventory_2_rounded,
                        label: 'Produk',
                        page: const ProductPage(),
                        isActive: context.widget.runtimeType == ProductPage,
                        collapsed: collapsed,
                        isDrawer: isDrawer,
                        gradientColors: const [Color(0xFF43E97B), Color(0xFF38F9D7)],
                      ),
                      _NavButton(
                        icon: Icons.assessment_rounded,
                        label: 'Laporan',
                        page: const ReportPage(),
                        isActive: context.widget.runtimeType == ReportPage,
                        collapsed: collapsed,
                        isDrawer: isDrawer,
                        gradientColors: const [Color(0xFFFEAC5E), Color(0xFFC779D0)],
                      ),
                      _NavButton(
                        icon: Icons.people_rounded,
                        label: 'Karyawan',
                        page: const UsersPage(),
                        isActive: context.widget.runtimeType == UsersPage,
                        collapsed: collapsed,
                        isDrawer: isDrawer,
                        gradientColors: const [Color(0xFFFA709A), Color(0xFFFF6B9D)],
                      ),
                    ],

                    // Kasir Menu
                    if (role == 'kasir')
                      _NavButton(
                        icon: Icons.point_of_sale_rounded,
                        label: 'Kasir',
                        page: const PosPage(),
                        isActive: context.widget.runtimeType == PosPage,
                        collapsed: collapsed,
                        isDrawer: isDrawer,
                        gradientColors: const [Color(0xFF667EEA), Color(0xFF764BA2)],
                      ),

                    const SizedBox(height: 24),

                    // Header Lainnya
                    if (!collapsed)
                      Container(
                        margin: const EdgeInsets.only(left: 12, bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFE5E5), Color(0xFFFFF0E5)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "LAINNYA",
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFFFF9966),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),

                    _NavButton(
                      icon: Icons.history_rounded,
                      label: 'Riwayat',
                      page: const TransactionHistoryPage(),
                      isActive: context.widget.runtimeType == TransactionHistoryPage,
                      collapsed: collapsed,
                      isDrawer: isDrawer,
                      gradientColors: const [Color(0xFF4299E1), Color(0xFF3182CE)],
                    ),
                    _NavButton(
                      icon: Icons.settings_rounded,
                      label: 'Pengaturan',
                      page: const SettingsPage(),
                      isActive: context.widget.runtimeType == SettingsPage,
                      collapsed: collapsed,
                      isDrawer: isDrawer,
                      gradientColors: const [Color(0xFF718096), Color(0xFF4A5568)],
                    ),
                  ],
                ),
              ),

              // === USER INFO (BOTTOM) ===
              Container(
                margin: const EdgeInsets.all(20),
                padding: EdgeInsets.all(collapsed ? 12 : 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF0FFF4), Color(0xFFE0F2FE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF9AE6B4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF43E97B).withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF48BB78),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF48BB78).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(
                          "https://i.pravatar.cc/150?img=12",
                        ),
                      ),
                    ),
                    if (!collapsed) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                role.toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: const [
                                Icon(
                                  Icons.circle,
                                  color: Color(0xFF48BB78),
                                  size: 8,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "Online",
                                  style: TextStyle(
                                    color: Color(0xFF48BB78),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Widget Tombol Navigasi
class _NavButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Widget page;
  final bool isActive;
  final bool collapsed;
  final bool isDrawer;
  final List<Color> gradientColors;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.page,
    this.isActive = false,
    required this.collapsed,
    this.isDrawer = false,
    required this.gradientColors,
  });

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (widget.isDrawer) {
            Navigator.pop(context);
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => widget.page),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 10),
          padding: EdgeInsets.symmetric(
            vertical: 16,
            horizontal: widget.collapsed ? 0 : 20,
          ),
          decoration: BoxDecoration(
            gradient: widget.isActive
                ? LinearGradient(
                    colors: widget.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: hover && !widget.isActive
                ? widget.gradientColors[0].withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isActive
                  ? widget.gradientColors[0].withOpacity(0.3)
                  : (hover
                      ? widget.gradientColors[0].withOpacity(0.2)
                      : Colors.transparent),
              width: 1.5,
            ),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: widget.gradientColors[0].withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          child: widget.collapsed
              ? Center(
                  child: Icon(
                    widget.icon,
                    color: widget.isActive
                        ? Colors.white
                        : (hover
                            ? widget.gradientColors[0]
                            : const Color(0xFF718096)),
                    size: 22,
                  ),
                )
              : Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: widget.isActive
                            ? Colors.white.withOpacity(0.2)
                            : (hover
                                ? widget.gradientColors[0].withOpacity(0.1)
                                : Colors.transparent),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.isActive
                            ? Colors.white
                            : (hover
                                ? widget.gradientColors[0]
                                : const Color(0xFF718096)),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.label,
                        style: TextStyle(
                          color: widget.isActive
                              ? Colors.white
                              : (hover
                                  ? widget.gradientColors[0]
                                  : const Color(0xFF718096)),
                          fontWeight: widget.isActive
                              ? FontWeight.bold
                              : FontWeight.w600,
                          fontSize: 14,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    if (widget.isActive)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}