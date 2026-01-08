import 'package:flutter/material.dart';
import '../../data/local/shared_pref_service.dart';

import '../dashboard/dashboard_page.dart';
import '../product/product_page.dart';
import '../pos/pos_page.dart';
import '../report/report_page.dart';

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
          width: collapsed ? 80 : 260,
          margin: isDrawer ? null : const EdgeInsets.fromLTRB(20, 20, 0, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: isDrawer ? null : BorderRadius.circular(30),
            boxShadow: isDrawer
                ? []
                : [
                    BoxShadow(
                      color: Colors.blueGrey.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(5, 0),
                    ),
                  ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // LOGO AREA
              if (collapsed)
                const Icon(
                  Icons.flash_on_rounded,
                  size: 32,
                  color: Color(0xFF6C63FF),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.flash_on_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "AGALLAGHER",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 50),

              // MENU ITEMS
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    if (role == 'admin') ...[
                      _NavButton(
                        icon: Icons.grid_view_rounded,
                        label: 'Dashboard',
                        page: const DashboardPage(),
                        isActive: true,
                        collapsed: collapsed,
                      ),
                      _NavButton(
                        icon: Icons.inventory_2_outlined,
                        label: 'Produk',
                        page: const ProductPage(),
                        collapsed: collapsed,
                      ),
                      _NavButton(
                        icon: Icons.pie_chart_outline_rounded,
                        label: 'Laporan',
                        page: const ReportPage(),
                        collapsed: collapsed,
                      ),
                    ],
                    if (role == 'kasir')
                      _NavButton(
                        icon: Icons.point_of_sale_rounded,
                        label: 'Kasir',
                        page: const PosPage(),
                        collapsed: collapsed,
                      ),
                  ],
                ),
              ),

              // USER INFO
              Container(
                margin: const EdgeInsets.all(20),
                padding: EdgeInsets.all(collapsed ? 10 : 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6FA),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey,
                      backgroundImage: NetworkImage(
                        "https://i.pravatar.cc/150?img=12",
                      ), // Dummy Avatar
                    ),
                    if (!collapsed) ...[
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            role.toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const Text(
                            "Online",
                            style: TextStyle(color: Colors.green, fontSize: 10),
                          ),
                        ],
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

class _NavButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Widget page;
  final bool isActive;
  final bool collapsed;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.page,
    this.isActive = false,
    required this.collapsed,
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
      child: GestureDetector(
        onTap: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => widget.page),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.symmetric(
            vertical: 16,
            horizontal: widget.collapsed ? 0 : 20,
          ),
          decoration: BoxDecoration(
            color: widget.isActive
                ? const Color(0xFF6C63FF)
                : (hover
                      ? const Color(0xFF6C63FF).withOpacity(0.05)
                      : Colors.transparent),
            borderRadius: BorderRadius.circular(16),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: widget.collapsed
              ? Icon(
                  widget.icon,
                  color: widget.isActive ? Colors.white : Colors.grey,
                )
              : Row(
                  children: [
                    Icon(
                      widget.icon,
                      color: widget.isActive
                          ? Colors.white
                          : (hover ? const Color(0xFF6C63FF) : Colors.grey),
                      size: 22,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: widget.isActive
                            ? Colors.white
                            : (hover
                                  ? const Color(0xFF6C63FF)
                                  : Colors.grey[600]),
                        fontWeight: widget.isActive
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
