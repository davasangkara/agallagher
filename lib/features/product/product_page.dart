import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/models/product_model.dart';
import '../../data/local/shared_pref_service.dart';
import '../dashboard/dashboard_page.dart';
import 'product_form.dart';
import 'product_edit.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Product>('products');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Background netral agar kartu menonjol
      body: Column(
        children: [
          // ================= HEADER AESTHETIC =================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
              boxShadow: [
                BoxShadow(color: Colors.blueGrey.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))
              ],
            ),
            child: Row(
              children: [
                // Tombol Back Custom
                Material(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardPage())),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black87),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Produk',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF2D3436)),
                    ),
                    Text(
                      'Kelola katalog barang',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500], fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const Spacer(),
                
                // ADD BUTTON (Gradient)
                FutureBuilder<bool>(
                  future: SharedPrefService.isAdmin(),
                  builder: (context, snapshot) {
                    if (snapshot.data != true) return const SizedBox();
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF4834D4)]), // Deep Purple Gradient
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))
                        ],
                      ),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white),
                        label: const Text('Tambah', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductForm())),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // ================= CONTENT GRID =================
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: box.listenable(),
              builder: (context, Box<Product> box, _) {
                if (box.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network('https://cdn-icons-png.flaticon.com/512/7486/7486754.png', width: 120, color: Colors.grey[300]),
                        const SizedBox(height: 20),
                        Text('Katalog Kosong', style: TextStyle(color: Colors.grey[400], fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = constraints.maxWidth > 1200 ? 4 : constraints.maxWidth > 800 ? 3 : 2;
                    return GridView.builder(
                      padding: const EdgeInsets.all(32),
                      itemCount: box.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 24,
                        crossAxisSpacing: 24,
                        childAspectRatio: 0.8,
                      ),
                      itemBuilder: (context, index) {
                        final product = box.getAt(index)!;
                        // Mengirim index agar warna gradien berbeda tiap kartu
                        return _ColorfulProductCard(product: product, index: index);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ================= COLORFUL CARD WIDGET =================
class _ColorfulProductCard extends StatefulWidget {
  final Product product;
  final int index;
  const _ColorfulProductCard({required this.product, required this.index});

  @override
  State<_ColorfulProductCard> createState() => _ColorfulProductCardState();
}

class _ColorfulProductCardState extends State<_ColorfulProductCard> {
  bool isHovered = false;

  // Daftar Gradien Aesthic
  final List<List<Color>> _gradients = [
    [const Color(0xFF8EC5FC), const Color(0xFFE0C3FC)], // Soft Blue -> Purple
    [const Color(0xFF85FFBD), const Color(0xFFFFFB7D)], // Mint -> Yellow
    [const Color(0xFFFF9A9E), const Color(0xFFFECFEF)], // Peach -> Pink
    [const Color(0xFF43E97B), const Color(0xFF38F9D7)], // Green -> Aqua
    [const Color(0xFFFA709A), const Color(0xFFFEE140)], // Red -> Yellow
  ];

  @override
  Widget build(BuildContext context) {
    final gradient = _gradients[widget.index % _gradients.length];
    final bool isLowStock = widget.product.stock <= 5;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: () async {
          if (!await SharedPrefService.isAdmin()) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Akses terbatas Admin'), backgroundColor: Colors.redAccent),
            );
            return;
          }
          showDialog(context: context, builder: (_) => ProductEdit(product: widget.product));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: isHovered ? (Matrix4.identity()..translate(0.0, -8.0)) : Matrix4.identity(),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: isHovered
                ? [BoxShadow(color: gradient.first.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))]
                : [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Image Area (Gradient Background)
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // White Icon Overlay
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.4), width: 1)
                          ),
                          child: const Icon(Icons.inventory_2_rounded, size: 40, color: Colors.white),
                        ),
                      ),
                      // Stock Badge
                      Positioned(
                        top: 12, right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Stok: ${widget.product.stock}',
                            style: TextStyle(
                              fontSize: 11, 
                              fontWeight: FontWeight.bold, 
                              color: isLowStock ? const Color(0xFFFF6B6B) : Colors.white
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // 2. Info Area
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
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF2D3436), height: 1.1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Harga Satuan', style: TextStyle(fontSize: 10, color: Colors.grey[400], fontWeight: FontWeight.w600)),
                              Text(
                                'Rp ${widget.product.price}',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: gradient.first), // Warna harga ikut gradient
                              ),
                            ],
                          ),
                          // Edit Button Mini
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.edit_rounded, size: 18, color: Colors.grey[400]),
                          )
                        ],
                      )
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