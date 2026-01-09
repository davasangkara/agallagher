import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/models/product_model.dart';
import '../../data/local/shared_pref_service.dart';
import '../dashboard/dashboard_page.dart';
import 'product_form.dart';
import 'product_edit.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  // Variable untuk menyimpan kategori yang sedang dipilih
  String _selectedCategory = 'Semua';

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Product>('products');

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: Column(
        children: [
          // ================= HEADER =================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
              boxShadow: [
                BoxShadow(color: Colors.blueGrey.withOpacity(0.06), blurRadius: 30, offset: const Offset(0, 10))
              ],
            ),
            child: Row(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardPage())),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black87),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Katalog Produk', 
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF2D3436), letterSpacing: -0.5)
                    ),
                    SizedBox(height: 4),
                    Text('Kelola & Filter Barang', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600)),
                  ],
                ),
                const Spacer(),
                
                // ADD BUTTON
                FutureBuilder<bool>(
                  future: SharedPrefService.isAdmin(),
                  builder: (context, snapshot) {
                    if (snapshot.data != true) return const SizedBox();
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF4834D4)]),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))
                        ]
                      ),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 22),
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

          // ================= KATEGORI & GRID =================
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: box.listenable(),
              builder: (context, Box<Product> box, _) {
                if (box.isEmpty) {
                  return _buildEmptyState();
                }

                // 1. Ambil semua kategori unik dari data produk
                final Set<String> categories = {'Semua'};
                for (var p in box.values) {
                  if (p.category.isNotEmpty) categories.add(p.category);
                }
                
                // 2. Filter produk berdasarkan kategori yang dipilih
                final filteredProducts = _selectedCategory == 'Semua'
                    ? box.values.toList()
                    : box.values.where((p) => p.category == _selectedCategory).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- CATEGORY SELECTOR (Horizontal Scroll) ---
                    Container(
                      height: 60,
                      margin: const EdgeInsets.only(top: 24),
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_,__) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final category = categories.elementAt(index);
                          final isSelected = category == _selectedCategory;
                          
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF6C63FF) : Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: isSelected ? Colors.transparent : Colors.grey.shade300
                                ),
                                boxShadow: isSelected 
                                  ? [BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))]
                                  : [],
                              ),
                              child: Text(
                                category.toUpperCase(),
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 0.5
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // --- GRID PRODUK ---
                    Expanded(
                      child: filteredProducts.isEmpty
                        ? Center(
                            child: Text(
                              'Tidak ada produk di kategori "$_selectedCategory"', 
                              style: TextStyle(color: Colors.grey[400])
                            )
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              int crossAxisCount = constraints.maxWidth > 1200 ? 4 : constraints.maxWidth > 800 ? 3 : 2;
                              if (constraints.maxWidth < 600) crossAxisCount = 1;

                              return GridView.builder(
                                padding: const EdgeInsets.all(32),
                                itemCount: filteredProducts.length,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  mainAxisSpacing: 24,
                                  crossAxisSpacing: 24,
                                  childAspectRatio: 0.72,
                                ),
                                itemBuilder: (context, index) {
                                  final product = filteredProducts[index];
                                  return _ProductCard(product: product, index: index);
                                },
                              );
                            },
                          ),
                    ),
                  ],
                );
              },
            ),
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
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 20)]
            ),
            child: Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey[300]),
          ),
          const SizedBox(height: 24),
          Text('Belum ada data produk', style: TextStyle(color: Colors.grey[400], fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ================= WIDGET KARTU PRODUK (ANIMATED & COLORFUL) =================
class _ProductCard extends StatefulWidget {
  final Product product;
  final int index;
  const _ProductCard({required this.product, required this.index});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> with SingleTickerProviderStateMixin {
  bool isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  final List<List<Color>> _gradients = [
    [const Color(0xFF6C63FF), const Color(0xFF8E2DE2)], // Purple
    [const Color(0xFF00B894), const Color(0xFF55EFC4)], // Teal
    [const Color(0xFFFF7675), const Color(0xFFFF9F43)], // Orange-Pink
    [const Color(0xFF0984E3), const Color(0xFF74B9FF)], // Blue
    [const Color(0xFFFD79A8), const Color(0xFFE84393)], // Pink
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Pilih warna berdasarkan hashCode nama produk agar konsisten meski difilter
    final colorIndex = widget.product.name.hashCode.abs() % _gradients.length;
    final gradient = _gradients[colorIndex];
    final primaryColor = gradient.first;
    final bool isLowStock = widget.product.stock <= 5;

    return MouseRegion(
      onEnter: (_) {
        setState(() => isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => isHovered = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation, 
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
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: isHovered
                  ? [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 25, offset: const Offset(0, 15))]
                  : [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 8))],
              border: isHovered 
                  ? Border.all(color: primaryColor.withOpacity(0.5), width: 2) 
                  : Border.all(color: Colors.transparent),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Header Gambar / Icon (Gradient Background)
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      gradient: LinearGradient(
                        colors: gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -15, top: -15,
                          child: Icon(Icons.blur_on_rounded, size: 100, color: Colors.white.withOpacity(0.1)),
                        ),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5)
                            ),
                            child: const Icon(Icons.inventory_2_rounded, size: 42, color: Colors.white),
                          ),
                        ),
                        
                        // Badge Kategori (Kiri Atas)
                        Positioned(
                          top: 16, left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]
                            ),
                            child: Text(
                              widget.product.category.toUpperCase(),
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryColor),
                            ),
                          ),
                        ),

                        // Badge Low Stock (Kanan Bawah)
                        if (isLowStock)
                          Positioned(
                            bottom: 12, right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [BoxShadow(color: Colors.redAccent.withOpacity(0.4), blurRadius: 6)]
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.warning_amber_rounded, size: 10, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text('LOW STOCK', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                
                // 2. Info Detail Produk
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF2D3436)),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.qr_code_rounded, size: 14, color: Colors.grey[400]),
                                const SizedBox(width: 6),
                                Text(
                                  widget.product.sku.isEmpty ? '-' : widget.product.sku,
                                  style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w600, fontFamily: 'Courier'),
                                ),
                              ],
                            )
                          ],
                        ),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Harga', style: TextStyle(fontSize: 10, color: Colors.grey[400], fontWeight: FontWeight.bold)),
                                Text('Rp ${widget.product.price}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: primaryColor)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Stok', style: TextStyle(fontSize: 10, color: Colors.grey[400], fontWeight: FontWeight.bold)),
                                Text(
                                  '${widget.product.stock}', 
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900, 
                                    fontSize: 16, 
                                    color: isLowStock ? Colors.red : Colors.black87
                                  )
                                ),
                              ],
                            ),
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
      ),
    );
  }
}