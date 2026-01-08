import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:math'; 
import '../../data/models/product_model.dart';
import '../../data/local/shared_pref_service.dart';
import '../../app.dart';
import 'dashboard_sidebar.dart';
import 'dashboard_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 800;
    final box = Hive.box<Product>('products');

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF), // Background biru sangat muda (Modern SaaS look)
      drawer: isMobile ? const DashboardSidebar(isDrawer: true) : null,
      appBar: isMobile
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: const Text("Dashboard", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu_rounded, color: Colors.black87),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              actions: [
                IconButton(onPressed: (){}, icon: const Icon(Icons.notifications_none_rounded, color: Colors.black87))
              ],
            )
          : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sidebar Desktop (Floating Style)
          if (!isMobile) const DashboardSidebar(),
          
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  _buildModernHeader(context),
                  
                  const SizedBox(height: 30),

                  // STATS CARDS
                  ValueListenableBuilder(
                    valueListenable: box.listenable(),
                    builder: (_, Box<Product> box, __) {
                      final total = box.length;
                      final low = box.values.where((e) => e.stock <= 5).length;
                      // Dummy data aesthetic
                      final sold = 124; 
                      final revenue = "12.5jt"; 

                      final cards = [
                        _CardData("Total Produk", total.toString(), Icons.inventory_2_rounded, [const Color(0xFF6AA5E3), const Color(0xFF6868AC)]), // Soft Blue-Purple
                        _CardData("Stok Menipis", low.toString(), Icons.warning_amber_rounded, [const Color(0xFFFF9966), const Color(0xFFFF5E62)]), // Sunset Orange
                        _CardData("Terjual", sold.toString(), Icons.shopping_bag_rounded, [const Color(0xFF56CCF2), const Color(0xFF2F80ED)]), // Ocean Blue
                        _CardData("Pendapatan", revenue, Icons.attach_money_rounded, [const Color(0xFF11998e), const Color(0xFF38ef7d)]), // Mint Green
                      ];

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          int crossAxisCount = constraints.maxWidth > 1200 ? 4 : constraints.maxWidth > 700 ? 2 : 1;
                          double aspectRatio = constraints.maxWidth > 700 ? 1.5 : 1.6;

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 24,
                              mainAxisSpacing: 24,
                              childAspectRatio: aspectRatio,
                            ),
                            itemCount: cards.length,
                            itemBuilder: (context, index) {
                              return DashboardCard(
                                title: cards[index].title,
                                value: cards[index].value,
                                icon: cards[index].icon,
                                colors: cards[index].colors,
                                onTap: () {},
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                  
                  const SizedBox(height: 30),

                  // CHART & LIST SECTION
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 1000) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 2, child: _buildChartSection()),
                            const SizedBox(width: 24),
                            Expanded(flex: 1, child: _buildRecentProducts(box)),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            _buildChartSection(),
                            const SizedBox(height: 24),
                            _buildRecentProducts(box),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Header dengan sapaan dan tanggal
  Widget _buildModernHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Selamat Datang, Admin! 👋",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2D3436),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Berikut adalah ringkasan tokomu hari ini.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        
        // Tombol Logout Bulat
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.05),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showLogoutConfirmation(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade100),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                  const SizedBox(width: 8),
                  const Text("Keluar", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  // Modern Chart Section
  Widget _buildChartSection() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.blueGrey.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Analitik Pendapatan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("7 Hari Terakhir", style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F6FF),
                  borderRadius: BorderRadius.circular(10)
                ),
                child: const Text("+2.5% vs Minggu Lalu", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
              )
            ],
          ),
          const SizedBox(height: 40),
          
          // Chart Bars
          SizedBox(
            height: 220,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final height = 60 + Random().nextInt(140).toDouble(); 
                final day = ["Sen", "Sel", "Rab", "Kam", "Jum", "Sab", "Min"][index];
                
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: height),
                      duration: Duration(milliseconds: 800 + (index * 150)),
                      curve: Curves.easeOutBack,
                      builder: (context, double val, child) {
                        return Container(
                          width: 32,
                          height: val,
                          decoration: BoxDecoration(
                            // Gradient Bar
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(10), bottom: Radius.circular(4)),
                            boxShadow: [BoxShadow(color: const Color(0xFF4facfe).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(day, style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // Recent Products List
  Widget _buildRecentProducts(Box<Product> box) {
    final recentProducts = box.values.toList().reversed.take(4).toList();

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.blueGrey.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Produk Terbaru", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          
          if (recentProducts.isEmpty)
             const Padding(
               padding: EdgeInsets.symmetric(vertical: 20),
               child: Center(child: Text("Belum ada data", style: TextStyle(color: Colors.grey))),
             )
          else
            ...recentProducts.map((product) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100)
              ),
              child: Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5)]
                    ),
                    child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF6C63FF), size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text("Stok: ${product.stock}", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                      ],
                    ),
                  ),
                  Text("Rp${product.price}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
                ],
              ),
            )),
            
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {},
              child: const Text("Lihat Semua", style: TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Konfirmasi Logout"),
          content: const Text("Apakah anda yakin ingin keluar?"),
          actionsPadding: const EdgeInsets.all(20),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), 
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent, 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await SharedPrefService.logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MyApp()),
                    (_) => false,
                  );
                }
              },
              child: const Text("Keluar", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}

class _CardData {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> colors;
  _CardData(this.title, this.value, this.icon, this.colors);
}