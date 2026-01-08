import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../../data/models/product_model.dart';
import '../dashboard/dashboard_page.dart';
import 'pos_controller.dart';
import 'pos_cart_item.dart';

// Warna Utama Aplikasi yang Cerah
const Color kPrimaryColor = Color(0xFF2563EB); // Biru terang modern
const Color kBgColor = Color(0xFFF8F9FD); // Background sangat bersih

class PosPage extends StatelessWidget {
  const PosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;
    final cart = context.watch<PosController>();
    final box = Hive.box<Product>('products');

    return Scaffold(
      backgroundColor: kBgColor,
      
      // AppBar Mobile (Clean White)
      appBar: isMobile
          ? AppBar(
              title: const Text(
                'Kasir',
                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardPage()),
                ),
              ),
            )
          : null,

      // Floating Button Cart (Mobile - Bright Gradient)
      floatingActionButton: isMobile && cart.items.isNotEmpty
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: kPrimaryColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
                ],
                gradient: const LinearGradient(colors: [kPrimaryColor, Color(0xFF00C6FF)]),
              ),
              child: FloatingActionButton.extended(
                backgroundColor: Colors.transparent,
                elevation: 0,
                icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                label: Text(
                  '${cart.items.length} Item • Rp ${cart.total}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => Container(
                      height: MediaQuery.of(context).size.height * 0.85,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: _CartPanel(cart: cart, isMobile: true),
                    ),
                  );
                },
              ),
            )
          : null,

      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= GRID PRODUK (KIRI) =================
          Expanded(
            flex: 7,
            child: Column(
              children: [
                if (!isMobile) _buildDesktopHeader(context),

                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: box.listenable(),
                    builder: (_, Box<Product> box, __) {
                      if (box.isEmpty) {
                        return _buildEmptyState();
                      }

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          int crossAxisCount = constraints.maxWidth > 1200 ? 4 : constraints.maxWidth > 800 ? 3 : 2;
                          return GridView.builder(
                            padding: const EdgeInsets.all(24),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: 24,
                              crossAxisSpacing: 24,
                              childAspectRatio: 0.78, 
                            ),
                            itemCount: box.length,
                            itemBuilder: (_, i) {
                              final p = box.getAt(i)!;
                              return TweenAnimationBuilder(
                                duration: Duration(milliseconds: 300 + (i * 50)),
                                tween: Tween<double>(begin: 0, end: 1),
                                curve: Curves.easeOutBack,
                                builder: (context, double val, child) {
                                  return Transform.scale(scale: val, child: child);
                                },
                                // Pass index untuk penentuan warna gradien
                                child: _ProductItem(product: p, cart: cart, index: i),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ================= SIDEBAR KERANJANG (KANAN) =================
          if (!isMobile)
            Container(
              width: 440,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 30, offset: const Offset(-5, 0)),
                ],
              ),
              child: _CartPanel(cart: cart),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network('https://cdn-icons-png.flaticon.com/512/7486/7486744.png', width: 150),
          const SizedBox(height: 24),
          Text("Belum ada produk", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          Text("Tambahkan produk di menu dashboard", style: TextStyle(color: Colors.grey[400])),
        ],
      ),
    );
  }

  Widget _buildDesktopHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardPage())),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black87),
            tooltip: "Kembali",
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Produk',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.fiber_manual_record, size: 10, color: Colors.greenAccent),
                  const SizedBox(width: 6),
                  Text('Kasir Siap Melayani', style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          const Spacer(),
          // Search Bar Modern White
          Container(
            width: 350,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
              color: kBgColor,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                border: InputBorder.none,
                icon: Icon(Icons.search_rounded, color: kPrimaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================= WIDGET ITEM PRODUK (VIBRANT GRADIENT CARD) =================
class _ProductItem extends StatefulWidget {
  final Product product;
  final PosController cart;
  final int index;

  const _ProductItem({required this.product, required this.cart, required this.index});

  @override
  State<_ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<_ProductItem> {
  bool isHovered = false;

  // Daftar Gradien Cerah & Modern
  final List<List<Color>> _gradients = [
    [const Color(0xFF4FACFE), const Color(0xFF00F2FE)], // Cyan Blue bright
    [const Color(0xFFFA709A), const Color(0xFFFEE140)], // Pink Yellow bright
    [const Color(0xFF43E97B), const Color(0xFF38F9D7)], // Green Cyan bright
    [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)], // Purple bright
    [const Color(0xFFFF0844), const Color(0xFFFFB199)], // Red Orange bright
    [const Color(0xFFFBAB7E), const Color(0xFFF7CE68)], // Orange Yellow bright
  ];

  @override
  Widget build(BuildContext context) {
    final outOfStock = widget.product.stock <= 0;
    // Pilih gradien berdasarkan index agar bervariasi
    final gradientColors = _gradients[widget.index % _gradients.length];
    final primaryAccent = gradientColors.first;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: outOfStock ? null : () => widget.cart.addProduct(widget.product),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: isHovered ? (Matrix4.identity()..translate(0.0, -8.0)) : Matrix4.identity(),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: isHovered
                ? [BoxShadow(color: primaryAccent.withOpacity(0.3), blurRadius: 25, offset: const Offset(0, 12))]
                : [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Area Gambar dengan Gradien Cerah
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    gradient: LinearGradient(
                      colors: outOfStock
                          ? [Colors.grey.shade300, Colors.grey.shade400]
                          : gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Pattern background halus
                      Positioned(
                        right: -20, top: -20,
                        child: Icon(Icons.fastfood, size: 120, color: Colors.white.withOpacity(0.15)),
                      ),
                      Center(
                        child: Icon(
                          outOfStock ? Icons.production_quantity_limits_rounded : Icons.inventory_2_rounded,
                          size: 56,
                          color: Colors.white, // Icon putih agar kontras dengan gradien
                        ),
                      ),
                      // Badge Stok Modern
                      Positioned(
                        top: 12, left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)],
                          ),
                          child: Text(
                            'Stok: ${widget.product.stock}',
                            style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold,
                              color: outOfStock ? Colors.red : Colors.black87,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              // 2. Info Produk (Background Putih Bersih)
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.black87, height: 1.2),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Rp ${widget.product.price}',
                            style: TextStyle(
                              color: primaryAccent, // Warna harga mengikuti warna utama gradien
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                          // Tombol Tambah Ber-Gradien
                          Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              gradient: outOfStock 
                                ? null 
                                : LinearGradient(colors: gradientColors),
                              color: outOfStock ? Colors.grey[300] : null,
                              shape: BoxShape.circle,
                              boxShadow: outOfStock ? null : [BoxShadow(color: primaryAccent.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))]
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 20),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= PANEL KERANJANG (BRIGHT & CLEAN) =================
class _CartPanel extends StatelessWidget {
  final PosController cart;
  final bool isMobile;

  const _CartPanel({required this.cart, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header Clean
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
          child: Column(
            children: [
              if (isMobile)
                Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10))),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Pesanan Aktif', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('#TX-9921', style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        Divider(height: 1, color: Colors.grey[100]),

        // List Item
        Expanded(
          child: cart.items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.network('https://cdn-icons-png.flaticon.com/512/11329/11329060.png', width: 120), // Ilustrasi keranjang cerah
                      const SizedBox(height: 24),
                      Text('Keranjang Kosong', style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 8),
                      Text('Yuk, pilih produk di samping!', style: TextStyle(color: Colors.grey[500])),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (_, i) => PosCartItem(item: cart.items[i]),
                ),
        ),

        // Bottom Section (BRIGHT & VIBRANT TOTAL)
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white, // Kembali ke putih bersih
            borderRadius: isMobile ? null : const BorderRadius.only(topLeft: Radius.circular(32)),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -10))],
          ),
          child: Column(
            children: [
              _billRow('Subtotal', cart.total),
              const SizedBox(height: 12),
              _billRow('Pajak (10%)', (cart.total * 0.1).toInt(), isTax: true),
              
              const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Divider()),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Tagihan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87)),
                  // Total Harga Besar & Cerah
                  Text(
                    'Rp ${(cart.total * 1.1).toInt()}',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: kPrimaryColor),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Tombol Checkout Ber-Gradien Cerah
              Container(
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(colors: [kPrimaryColor, Color(0xFF00C6FF)]), // Gradien Biru Cerah
                  boxShadow: [BoxShadow(color: kPrimaryColor.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))],
                ),
                child: ElevatedButton(
                  onPressed: cart.items.isEmpty ? null : () => cart.checkout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.payment_rounded, color: Colors.white),
                      SizedBox(width: 12),
                      Text('PROSES PEMBAYARAN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _billRow(String label, int value, {bool isTax = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w600)),
        Text(
          'Rp $value',
          style: TextStyle(fontWeight: FontWeight.bold, color: isTax ? Colors.orangeAccent : Colors.black87),
        ),
      ],
    );
  }
}