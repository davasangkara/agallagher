import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:intl/intl.dart';

import '../../data/models/product_model.dart';
import '../dashboard/dashboard_page.dart';
import 'pos_controller.dart';
import 'pos_cart_item.dart';

// Gradient Colors - Vibrant & Modern
const kPrimaryGradient = LinearGradient(
  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const kAccentGradient = LinearGradient(
  colors: [Color(0xFFf093fb), Color(0xFFF5576C)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const kSuccessGradient = LinearGradient(
  colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class PosPage extends StatelessWidget {
  const PosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;
    
    final cart = context.watch<PosController>(); 
    final box = Hive.box<Product>('products');

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      
      // === MODERN APP BAR (Mobile) ===
      appBar: isMobile ? AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: kPrimaryGradient),
        ),
        title: const Text(
          'Kasir POS', 
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          ),
          onPressed: () => Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (_) => const DashboardPage()),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              onPressed: () => _openScanner(context, cart), 
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF667EEA), size: 20),
              ),
              tooltip: "Scan Barcode",
            ),
          ),
        ],
      ) : null,

      // === FLOATING CART BUTTON (Mobile) ===
      floatingActionButton: isMobile && cart.items.isNotEmpty 
        ? Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667EEA).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              backgroundColor: const Color(0xFF667EEA),
              elevation: 0,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 20),
              ),
              label: Text(
                '${cart.items.length} Item • Rp ${NumberFormat('#,###').format(cart.grandTotal)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => Container(
                  height: MediaQuery.of(context).size.height * 0.85,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: const _CartPanel(isMobile: true),
                ),
              ),
            ),
          )
        : null,

      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= PRODUCT GRID =================
          Expanded(
            flex: 7,
            child: Column(
              children: [
                if (!isMobile) _buildDesktopHeader(context, cart),
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: box.listenable(),
                    builder: (_, Box<Product> box, __) {
                      if (box.isEmpty) return _buildEmptyState();
                      
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          int crossAxisCount = constraints.maxWidth > 1200 
                              ? 5 
                              : constraints.maxWidth > 900 
                                  ? 4 
                                  : constraints.maxWidth > 600 
                                      ? 3 
                                      : 2;
                          
                          return GridView.builder(
                            padding: const EdgeInsets.all(24),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: 20,
                              crossAxisSpacing: 20,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: box.length,
                            itemBuilder: (_, i) {
                              final product = box.getAt(i)!;
                              return _ProductCard(
                                product: product,
                                cart: cart,
                                index: i,
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
          
          // ================= CART SIDEBAR (Desktop) =================
          if (!isMobile)
            Container(
              width: 440,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 30,
                    offset: const Offset(-5, 0),
                  ),
                ],
              ),
              child: const _CartPanel(),
            ),
        ],
      ),
    );
  }

  void _openScanner(BuildContext context, PosController cart) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => _BarcodeScannerView(
          onDetect: (code) {
            final found = cart.handleBarcode(code);
            if (found) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 12),
                      Text("Produk ditambahkan: $code"),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  duration: const Duration(milliseconds: 1500),
                ),
              );
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white),
                      const SizedBox(width: 12),
                      Text("Produk tidak ditemukan: $code"),
                    ],
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.grey[100]!,
                Colors.grey[50]!,
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.inventory_2_rounded,
            size: 80,
            color: Colors.grey[400],
          ),
        ),
        const SizedBox(height: 32),
        Text(
          "Belum ada produk",
          style: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Minta Admin untuk menambah stok",
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
      ],
    ),
  );

  Widget _buildDesktopHeader(BuildContext context, PosController cart) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DashboardPage()),
            ),
            icon: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => kPrimaryGradient.createShader(bounds),
                child: const Text(
                  'Pilih Produk',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Kasir Siap Melayani Anda',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 400,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FE),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: kPrimaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.search_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari produk...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _openScanner(context, cart),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner_rounded,
                      color: Color(0xFF667EEA),
                      size: 20,
                    ),
                  ),
                  tooltip: "Scan Barcode",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// === BARCODE SCANNER VIEW ===
class _BarcodeScannerView extends StatelessWidget {
  final Function(String) onDetect;
  const _BarcodeScannerView({required this.onDetect});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Scan Barcode Produk"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              for (final barcode in capture.barcodes) {
                if (barcode.rawValue != null) {
                  onDetect(barcode.rawValue!);
                  break;
                }
              }
            },
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// === PRODUCT CARD ===
class _ProductCard extends StatefulWidget {
  final Product product;
  final PosController cart;
  final int index;

  const _ProductCard({
    required this.product,
    required this.cart,
    required this.index,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool isHovered = false;

  final List<List<Color>> _gradients = [
    [const Color(0xFF667EEA), const Color(0xFF764BA2)],
    [const Color(0xFFf093fb), const Color(0xFFF5576C)],
    [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
    [const Color(0xFF43e97b), const Color(0xFF38f9d7)],
    [const Color(0xFFfa709a), const Color(0xFFfee140)],
    [const Color(0xFF30cfd0), const Color(0xFF330867)],
  ];

  @override
  Widget build(BuildContext context) {
    final outOfStock = widget.product.stock <= 0;
    final gradient = _gradients[widget.index % _gradients.length];

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: outOfStock ? null : () => widget.cart.addProduct(widget.product),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          transform: isHovered && !outOfStock
              ? (Matrix4.identity()..translate(0.0, -8.0))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: isHovered && !outOfStock
                ? [
                    BoxShadow(
                      color: gradient[0].withOpacity(0.3),
                      blurRadius: 25,
                      offset: const Offset(0, 12),
                      spreadRadius: 2,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // PRODUCT IMAGE AREA
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: outOfStock
                        ? LinearGradient(
                            colors: [Colors.grey[300]!, Colors.grey[200]!],
                          )
                        : LinearGradient(
                            colors: gradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // ICON
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            outOfStock
                                ? Icons.block_rounded
                                : Icons.shopping_bag_rounded,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      // OUT OF STOCK BADGE
                      if (outOfStock)
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Text(
                              "HABIS",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),

                      // STOCK BADGE
                      if (!outOfStock)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.inventory_2_rounded,
                                  size: 14,
                                  color: gradient[0],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${widget.product.stock}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: gradient[0],
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

              // PRODUCT INFO
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
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF1F2937),
                          height: 1.3,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Rp ${NumberFormat('#,###').format(widget.product.price)}',
                              style: TextStyle(
                                color: outOfStock ? Colors.grey : gradient[0],
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: outOfStock
                                  ? LinearGradient(
                                      colors: [Colors.grey[300]!, Colors.grey[400]!],
                                    )
                                  : LinearGradient(colors: gradient),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: outOfStock
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: gradient[0].withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
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

// ================= CART PANEL =================
class _CartPanel extends StatelessWidget {
  final bool isMobile;
  const _CartPanel({this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<PosController>(
      builder: (context, cart, child) {
        return ValueListenableBuilder(
          valueListenable: Hive.box('settings').listenable(),
          builder: (context, Box box, _) {
            final taxRate = box.get('tax_rate', defaultValue: 0);

            return Column(
              children: [
                // HEADER
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  decoration: BoxDecoration(
                    gradient: kPrimaryGradient,
                    borderRadius: isMobile
                        ? const BorderRadius.vertical(top: Radius.circular(32))
                        : null,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Pesanan',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Row(
                            children: [
                              // RECALL BUTTON
                              _IconButtonGlass(
                                icon: Icons.restore_page_rounded,
                                color: Colors.orange,
                                onPressed: () => _showHeldOrders(context, cart),
                                tooltip: "Ambil Pesanan",
                              ),
                              const SizedBox(width: 8),
                              // HOLD BUTTON
                              _IconButtonGlass(
                                icon: Icons.pause_circle_filled_rounded,
                                color: Colors.amber,
                                onPressed: cart.items.isEmpty
                                    ? null
                                    : () => _showHoldDialog(context, cart),
                                tooltip: "Simpan Sementara",
                              ),
                              const SizedBox(width: 8),
                              // CLEAR BUTTON
                              _IconButtonGlass(
                                icon: Icons.delete_outline_rounded,
                                color: Colors.red,
                                onPressed: cart.items.isEmpty
                                    ? null
                                    : () => cart.clearCart(),
                                tooltip: "Kosongkan",
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (cart.items.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.shopping_bag_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${cart.items.length} Item dalam keranjang',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // CART ITEMS
                Expanded(
                  child: cart.items.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.grey[100]!,
                                      Colors.grey[50]!,
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 60,
                                  color: Colors.grey[300],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Keranjang Kosong',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tambahkan produk untuk memulai',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(24),
                          itemCount: cart.items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (_, i) => PosCartItem(item: cart.items[i]),
                        ),
                ),

                // SUMMARY & CHECKOUT
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FE),
                    borderRadius: isMobile
                        ? null
                        : const BorderRadius.only(topLeft: Radius.circular(32)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _summaryRow('Subtotal', cart.subtotal),
                      const SizedBox(height: 12),
                      _summaryRow('Pajak ($taxRate%)', cart.taxAmount, isAccent: true),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Divider(color: Colors.grey[300], thickness: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                kPrimaryGradient.createShader(bounds),
                            child: Text(
                              'Rp ${NumberFormat('#,###').format(cart.grandTotal)}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: cart.items.isEmpty
                                ? LinearGradient(
                                    colors: [Colors.grey[300]!, Colors.grey[400]!],
                                  )
                                : kSuccessGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: cart.items.isEmpty
                                ? []
                                : [
                                    BoxShadow(
                                      color: const Color(0xFF11998e).withOpacity(0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: cart.items.isEmpty
                                ? null
                                : () => cart.checkout(context),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.payment_rounded, color: Colors.white, size: 24),
                                SizedBox(width: 12),
                                Text(
                                  'PROSES BAYAR',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // HOLD DIALOG
  void _showHoldDialog(BuildContext context, PosController cart) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFfa709a), Color(0xFFfee140)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.pause_circle_filled, color: Colors.white),
            ),
            const SizedBox(width: 16),
            const Text("Simpan Pesanan"),
          ],
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            labelText: "Nama Pelanggan / Catatan",
            hintText: "Cth: Bapak Budi",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.person_outline_rounded),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFfa709a), Color(0xFFfee140)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                cart.holdOrder(context, ctrl.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: const Text(
                "Simpan",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // RECALL DIALOG
  void _showHeldOrders(BuildContext context, PosController cart) async {
    final box = await Hive.openBox('held_orders');

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFf093fb), Color(0xFFF5576C)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.restore_page, color: Colors.white),
              ),
              const SizedBox(width: 16),
              const Text("Pesanan Disimpan"),
            ],
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: SizedBox(
            width: 400,
            height: 400,
            child: ValueListenableBuilder(
              valueListenable: box.listenable(),
              builder: (ctx, Box box, _) {
                if (box.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_rounded, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          "Tidak ada pesanan disimpan",
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: box.length,
                  separatorBuilder: (_, __) => Divider(color: Colors.grey[200]),
                  itemBuilder: (ctx, i) {
                    final data = box.getAt(i) as Map;
                    final note = data['note'] ?? 'Tanpa Nama';
                    final total = data['total'] ?? 0;
                    final time = DateTime.parse(data['time']);

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange[50]!, Colors.orange[100]!],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.pause, color: Colors.white),
                        ),
                        title: Text(
                          note,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "${DateFormat('HH:mm').format(time)} • Rp ${NumberFormat('#,###').format(total)}",
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.restore, color: Colors.green),
                              onPressed: () => cart.restoreOrder(context, i),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => cart.deleteHeldOrder(i),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Tutup"),
            ),
          ],
        ),
      );
    }
  }

  Widget _summaryRow(String label, int value, {bool isAccent = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        Text(
          'Rp ${NumberFormat('#,###').format(value)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isAccent ? Colors.orange : const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }
}

// GLASS ICON BUTTON
class _IconButtonGlass extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  final String? tooltip;

  const _IconButtonGlass({
    required this.icon,
    required this.color,
    this.onPressed,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(onPressed == null ? 0.1 : 0.25),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Icon(
          icon,
          color: onPressed == null ? Colors.white.withOpacity(0.4) : Colors.white,
          size: 20,
        ),
      ),
    );
  }
}