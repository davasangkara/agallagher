import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../data/models/product_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/local/shared_pref_service.dart';
import '../../app.dart';
import 'dashboard_sidebar.dart';
import 'dashboard_card.dart';
import '../report/sales_line_chart.dart'; 
import '../product/smart_add_product_dialog.dart'; 

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;
    
    // Buka Box yang diperlukan
    final productBox = Hive.box<Product>('products');
    final transactionBox = Hive.box<TransactionModel>('transactions');

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF), 
      drawer: isMobile ? const DashboardSidebar(isDrawer: true) : null,
      appBar: isMobile ? _buildMobileAppBar(context) : null,
      
      // ==========================================
      // 🔥 TOMBOL FAB (INPUT AI) DITAMBAHKAN DISINI
      // ==========================================
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const SmartAddProductDialog(),
          );
        },
        backgroundColor: const Color(0xFF6C63FF),
        icon: const Icon(Icons.smart_toy_rounded, color: Colors.white),
        label: const Text("Input AI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      // ==========================================

      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMobile) const DashboardSidebar(),
          
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  
                  const SizedBox(height: 30),

                  // STATS CARDS (Realtime Listeners)
                  ValueListenableBuilder(
                    valueListenable: transactionBox.listenable(),
                    builder: (context, Box<TransactionModel> transBox, _) {
                      return ValueListenableBuilder(
                        valueListenable: productBox.listenable(),
                        builder: (context, Box<Product> prodBox, _) {
                          // 1. Hitung Total Produk
                          final totalProduk = prodBox.length;

                          // 2. Hitung Stok Menipis (<= 5)
                          final stokTipis = prodBox.values.where((p) => p.stock <= 5).length;
                          
                          // 3. Hitung Total Terjual
                          int totalTerjual = 0;
                          for (var t in transBox.values) {
                            for (var item in t.items) {
                              totalTerjual += item.qty;
                            }
                          }

                          // 4. Hitung Pendapatan Total
                          final totalPendapatan = transBox.values.fold(0, (sum, t) => sum + t.total);
                          
                          // Format Rupiah
                          final currencyFormat = NumberFormat.compactSimpleCurrency(locale: 'id_ID'); 
                          
                          final cards = [
                            _CardData("Total Produk", "$totalProduk", Icons.inventory_2_rounded, [const Color(0xFF6AA5E3), const Color(0xFF6868AC)]),
                            _CardData("Stok Menipis", "$stokTipis", Icons.warning_amber_rounded, [const Color(0xFFFF9966), const Color(0xFFFF5E62)]),
                            _CardData("Terjual", "$totalTerjual", Icons.shopping_bag_rounded, [const Color(0xFF56CCF2), const Color(0xFF2F80ED)]),
                            _CardData("Pendapatan", currencyFormat.format(totalPendapatan), Icons.attach_money_rounded, [const Color(0xFF11998e), const Color(0xFF38ef7d)]),
                          ];

                          return LayoutBuilder(
                            builder: (context, constraints) {
                              int crossAxisCount = constraints.maxWidth > 1200 ? 4 : constraints.maxWidth > 700 ? 2 : 1;
                              double aspectRatio = constraints.maxWidth > 700 ? 1.5 : 1.6;

                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount, crossAxisSpacing: 24, mainAxisSpacing: 24, childAspectRatio: aspectRatio,
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
                            Expanded(flex: 1, child: _buildRecentProducts(productBox)),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            _buildChartSection(),
                            const SizedBox(height: 24),
                            _buildRecentProducts(productBox),
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

  PreferredSizeWidget _buildMobileAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent, elevation: 0, centerTitle: true,
      title: const Text("Dashboard", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      leading: Builder(builder: (context) => IconButton(icon: const Icon(Icons.menu_rounded, color: Colors.black87), onPressed: () => Scaffold.of(context).openDrawer())),
      actions: [IconButton(onPressed: (){}, icon: const Icon(Icons.notifications_none_rounded, color: Colors.black87))],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        FutureBuilder<String>(
          future: SharedPrefService.getName(),
          builder: (context, snapshot) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Halo, ${snapshot.data ?? 'Admin'}! 👋", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF2D3436), letterSpacing: -0.5)),
                const SizedBox(height: 8),
                Text("Ringkasan toko Anda hari ini.", style: TextStyle(fontSize: 16, color: Colors.grey[500], fontWeight: FontWeight.w500)),
              ],
            );
          }
        ),
        
        Material(
          color: Colors.white, borderRadius: BorderRadius.circular(16), elevation: 2, shadowColor: Colors.black.withOpacity(0.05),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showLogoutConfirmation(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade100), borderRadius: BorderRadius.circular(16)),
              child: const Row(children: [Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20), SizedBox(width: 8), Text("Keluar", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent))]),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildChartSection() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.blueGrey.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Analitik Penjualan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text("Grafik Transaksi Mingguan", style: TextStyle(fontSize: 12, color: Colors.grey))]),
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFF2F6FF), borderRadius: BorderRadius.circular(10)), child: const Text("Realtime", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)))
            ],
          ),
          const SizedBox(height: 40),
          const SizedBox(height: 250, child: SalesLineChart()),
        ],
      ),
    );
  }

  Widget _buildRecentProducts(Box<Product> box) {
    return ValueListenableBuilder(
      valueListenable: box.listenable(),
      builder: (context, Box<Product> box, _) {
        final recentProducts = box.values.toList().reversed.take(4).toList(); 

        return Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.blueGrey.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Produk Terbaru", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              
              if (recentProducts.isEmpty)
                 const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: Text("Belum ada produk", style: TextStyle(color: Colors.grey))))
              else
                ...recentProducts.map((product) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFF9FAFC), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
                  child: Row(
                    children: [
                      Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5)]), child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF6C63FF), size: 20)),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), const SizedBox(height: 4), Text("Stok: ${product.stock}", style: TextStyle(color: product.stock <= 5 ? Colors.red : Colors.grey[500], fontSize: 12, fontWeight: FontWeight.bold))])),
                      Text("Rp${product.price}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
                    ],
                  ),
                )),
                
              const SizedBox(height: 8),
              if (recentProducts.isNotEmpty)
                SizedBox(width: double.infinity, child: TextButton(onPressed: () {}, child: const Text("Lihat Semua", style: TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.bold))))
            ],
          ),
        );
      }
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
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Batal", style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
              onPressed: () async {
                Navigator.of(context).pop();
                await SharedPrefService.logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MyApp()), (_) => false);
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
  final String title; final String value; final IconData icon; final List<Color> colors;
  _CardData(this.title, this.value, this.icon, this.colors);
}