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

class _ProductPageState extends State<ProductPage>
    with SingleTickerProviderStateMixin {
  String _selectedCategory = 'Semua';
  late AnimationController _headerAnimController;
  late Animation<double> _headerFadeAnim;

  @override
  void initState() {
    super.initState();
    _headerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerFadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _headerAnimController, curve: Curves.easeOut),
    );
    _headerAnimController.forward();
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Product>('products');
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;
    final isTablet = size.width > 600 && size.width <= 900;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFF8F9FE),
              Colors.white,
              const Color(0xFFFFF5F7).withOpacity(0.3),
            ],
          ),
        ),
        child: Column(
          children: [
            // ================= HEADER =================
            FadeTransition(
              opacity: _headerFadeAnim,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  isDesktop ? 32 : 20,
                  isDesktop ? 32 : 24,
                  isDesktop ? 32 : 20,
                  isDesktop ? 24 : 20,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(isDesktop ? 40 : 32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667eea).withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Top Row: Back Button + Title + Add Button
                    Row(
                      children: [
                        // Back Button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DashboardPage(),
                              ),
                            ),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Title - Responsive
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Katalog Produk',
                                style: TextStyle(
                                  fontSize: isDesktop ? 28 : 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              if (isDesktop || isTablet) ...[
                                const SizedBox(height: 4),
                                const Text(
                                  'Kelola & Filter Barang',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Add Button
                        FutureBuilder<bool>(
                          future: SharedPrefService.isAdmin(),
                          builder: (context, snapshot) {
                            if (snapshot.data != true) return const SizedBox();
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF6B9D),
                                    Color(0xFFC44569),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFFF6B9D,
                                    ).withOpacity(0.4),
                                    blurRadius: 15,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ProductForm(),
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isDesktop ? 20 : 16,
                                      vertical: 14,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.add_circle_outline_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        if (isDesktop || isTablet) ...[
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Tambah',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    // Stats Cards - Responsive Layout
                    SizedBox(height: isDesktop ? 24 : 16),
                    ValueListenableBuilder(
                      valueListenable: box.listenable(),
                      builder: (context, Box<Product> box, _) {
                        final totalProducts = box.length;
                        final lowStock = box.values
                            .where((p) => p.stock <= 5)
                            .length;
                        final totalValue = box.values.fold<int>(
                          0,
                          (sum, p) => sum + (p.price * p.stock),
                        );

                        if (isDesktop || isTablet) {
                          // Desktop/Tablet: Row layout
                          return Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.shopping_bag_rounded,
                                  label: 'Total Produk',
                                  value: '$totalProducts',
                                  color: const Color(0xFF4ECDC4),
                                  isCompact: !isDesktop,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.warning_amber_rounded,
                                  label: 'Stok Rendah',
                                  value: '$lowStock',
                                  color: const Color(0xFFFFBE76),
                                  isCompact: !isDesktop,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.payments_rounded,
                                  label: 'Total Nilai',
                                  value: 'Rp ${_formatCurrency(totalValue)}',
                                  color: const Color(0xFF95E1D3),
                                  isCompact: !isDesktop,
                                ),
                              ),
                            ],
                          );
                        } else {
                          // Mobile: Compact single row or grid
                          return Row(
                            children: [
                              Expanded(
                                child: _StatCardMobile(
                                  icon: Icons.shopping_bag_rounded,
                                  value: '$totalProducts',
                                  label: 'Produk',
                                  color: const Color(0xFF4ECDC4),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _StatCardMobile(
                                  icon: Icons.warning_amber_rounded,
                                  value: '$lowStock',
                                  label: 'Low',
                                  color: const Color(0xFFFFBE76),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _StatCardMobile(
                                  icon: Icons.payments_rounded,
                                  value: _formatCurrency(totalValue),
                                  label: 'Nilai',
                                  color: const Color(0xFF95E1D3),
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
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

                  final Set<String> categories = {'Semua'};
                  for (var p in box.values) {
                    if (p.category.isNotEmpty) categories.add(p.category);
                  }

                  final filteredProducts = _selectedCategory == 'Semua'
                      ? box.values.toList()
                      : box.values
                            .where((p) => p.category == _selectedCategory)
                            .toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Selector
                      Container(
                        height: isDesktop ? 70 : 60,
                        margin: EdgeInsets.only(top: isDesktop ? 24 : 16),
                        child: ListView.separated(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 32 : 20,
                          ),
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 10),
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
                                curve: Curves.easeInOut,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isDesktop ? 24 : 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFF667eea),
                                            Color(0xFF764ba2),
                                          ],
                                        )
                                      : null,
                                  color: isSelected ? null : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.transparent
                                        : Colors.grey.shade200,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isSelected
                                          ? const Color(
                                              0xFF667eea,
                                            ).withOpacity(0.4)
                                          : Colors.black.withOpacity(0.03),
                                      blurRadius: isSelected ? 12 : 6,
                                      offset: Offset(0, isSelected ? 4 : 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getCategoryIcon(category),
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF667eea),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      category,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.grey[700],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Grid Produk
                      Expanded(
                        child: filteredProducts.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.search_off_rounded,
                                        size: 48,
                                        color: Colors.grey[300],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Tidak ada produk',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'di kategori "$_selectedCategory"',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : LayoutBuilder(
                                builder: (context, constraints) {
                                  int crossAxisCount;
                                  double childAspectRatio;

                                  if (constraints.maxWidth > 1200) {
                                    crossAxisCount = 4;
                                    childAspectRatio = 0.75;
                                  } else if (constraints.maxWidth > 900) {
                                    crossAxisCount = 3;
                                    childAspectRatio = 0.75;
                                  } else if (constraints.maxWidth > 600) {
                                    crossAxisCount = 2;
                                    childAspectRatio = 0.8;
                                  } else {
                                    crossAxisCount = 1;
                                    childAspectRatio = 1.4;
                                  }

                                  return GridView.builder(
                                    padding: EdgeInsets.all(
                                      isDesktop ? 32 : 20,
                                    ),
                                    itemCount: filteredProducts.length,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: crossAxisCount,
                                          mainAxisSpacing: isDesktop ? 24 : 16,
                                          crossAxisSpacing: isDesktop ? 24 : 16,
                                          childAspectRatio: childAspectRatio,
                                        ),
                                    itemBuilder: (context, index) {
                                      final product = filteredProducts[index];
                                      return _ProductCard(
                                        product: product,
                                        index: index,
                                        isMobile: constraints.maxWidth <= 600,
                                      );
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
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF667eea).withOpacity(0.1),
                  const Color(0xFF764ba2).withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Belum ada produk',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan produk pertama Anda',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'semua':
        return Icons.grid_view_rounded;
      case 'elektronik':
        return Icons.devices_rounded;
      case 'makanan':
        return Icons.restaurant_rounded;
      case 'fashion':
        return Icons.checkroom_rounded;
      case 'kesehatan':
        return Icons.health_and_safety_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  String _formatCurrency(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toString();
  }
}

// ================= STAT CARD (Desktop/Tablet) =================
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isCompact;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isCompact ? 10 : 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: isCompact ? 20 : 24),
          ),
          SizedBox(width: isCompact ? 10 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isCompact ? 10 : 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isCompact ? 14 : 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================= STAT CARD MOBILE (Compact) =================
class _StatCardMobile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCardMobile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ================= PRODUCT CARD =================
class _ProductCard extends StatefulWidget {
  final Product product;
  final int index;
  final bool isMobile;

  const _ProductCard({
    required this.product,
    required this.index,
    this.isMobile = false,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard>
    with SingleTickerProviderStateMixin {
  bool isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  final List<List<Color>> _gradients = [
    [const Color(0xFF667eea), const Color(0xFF764ba2)],
    [const Color(0xFF4ECDC4), const Color(0xFF44A08D)],
    [const Color(0xFFFF6B9D), const Color(0xFFC44569)],
    [const Color(0xFFFFBE76), const Color(0xFFF9CA24)],
    [const Color(0xFF95E1D3), const Color(0xFF38B2AC)],
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                SnackBar(
                  content: const Text('Akses terbatas Admin'),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
              return;
            }
            showDialog(
              context: context,
              builder: (_) => ProductEdit(product: widget.product),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: isHovered
                  ? [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: widget.isMobile
                ? _buildMobileLayout(gradient, primaryColor, isLowStock)
                : _buildDesktopLayout(gradient, primaryColor, isLowStock),
          ),
        ),
      ),
    );
  }

  // Mobile Layout - Horizontal
  Widget _buildMobileLayout(
    List<Color> gradient,
    Color primaryColor,
    bool isLowStock,
  ) {
    return Row(
      children: [
        // Left Side - Gradient with Icon
        Container(
          width: 120,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(24),
            ),
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.inventory_2_rounded,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
              ),
              if (isLowStock)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF6B6B),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Right Side - Info
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.product.category.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: Color(0xFF1a1a1a),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.product.sku.isEmpty ? '-' : widget.product.sku,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Harga',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Rp ${widget.product.price}',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isLowStock
                            ? const Color(0xFFFF6B6B).withOpacity(0.1)
                            : primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Stok',
                            style: TextStyle(
                              fontSize: 9,
                              color: isLowStock
                                  ? const Color(0xFFFF6B6B)
                                  : primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${widget.product.stock}',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: isLowStock
                                  ? const Color(0xFFFF6B6B)
                                  : primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Desktop Layout - Vertical
  Widget _buildDesktopLayout(
    List<Color> gradient,
    Color primaryColor,
    bool isLowStock,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header Gradient
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // Background Pattern
                Positioned(
                  right: -30,
                  top: -30,
                  child: Icon(
                    Icons.circle,
                    size: 100,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),

                // Icon Center
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.inventory_2_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Category Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_offer_rounded,
                          size: 11,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.product.category.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Low Stock Badge
                if (isLowStock)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B6B),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6B6B).withOpacity(0.4),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 11,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'LOW',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Product Info
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Color(0xFF1a1a1a),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.qr_code_2_rounded,
                          size: 14,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.product.sku.isEmpty ? '-' : widget.product.sku,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Harga',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Rp ${widget.product.price}',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isLowStock
                            ? const Color(0xFFFF6B6B).withOpacity(0.1)
                            : primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Stok',
                            style: TextStyle(
                              fontSize: 10,
                              color: isLowStock
                                  ? const Color(0xFFFF6B6B)
                                  : primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${widget.product.stock}',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: isLowStock
                                  ? const Color(0xFFFF6B6B)
                                  : primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
