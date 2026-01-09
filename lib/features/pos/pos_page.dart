import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../../data/models/product_model.dart';
import '../dashboard/dashboard_page.dart';
import 'pos_controller.dart';
import 'pos_cart_item.dart';

const Color kPrimaryColor = Color(0xFF2563EB); 
const Color kBgColor = Color(0xFFF2F6FF);

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
      
      // === APP BAR (Mobile Only) ===
      appBar: isMobile ? AppBar(
        title: const Text('Kasir', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white, elevation: 0, centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87), 
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardPage()))
        ),
      ) : null,

      // === FLOATING BUTTON KHUSUS KERANJANG (BUKAN INPUT AI) ===
      // Tombol ini hanya muncul di HP jika ada barang di keranjang
      floatingActionButton: isMobile && cart.items.isNotEmpty ? Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: kPrimaryColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
          gradient: const LinearGradient(colors: [kPrimaryColor, Color(0xFF00C6FF)]),
        ),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.transparent, elevation: 0,
          icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
          // Menampilkan Total Item & Harga
          label: Text('${cart.items.length} Item • Rp ${cart.grandTotal}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          onPressed: () => showModalBottomSheet(
            context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
            builder: (_) => Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
              child: _CartPanel(cart: cart, isMobile: true),
            )
          ),
        ),
      ) : null,

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
                      if (box.isEmpty) return _buildEmptyState();
                      
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          // Grid Responsif
                          int crossAxisCount = constraints.maxWidth > 1200 ? 4 : constraints.maxWidth > 800 ? 3 : 2;
                          return GridView.builder(
                            padding: const EdgeInsets.all(24),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount, mainAxisSpacing: 20, crossAxisSpacing: 20, childAspectRatio: 0.75,
                            ),
                            itemCount: box.length,
                            itemBuilder: (_, i) {
                              final product = box.getAt(i)!;
                              return TweenAnimationBuilder(
                                duration: Duration(milliseconds: 300 + (i * 50)),
                                tween: Tween<double>(begin: 0, end: 1),
                                curve: Curves.easeOutBack,
                                builder: (context, double val, child) => Transform.scale(scale: val, child: child),
                                child: _ProductItem(product: product, cart: cart, index: i),
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
          
          // ================= SIDEBAR KERANJANG (KANAN - Desktop Only) =================
          if (!isMobile)
            Container(
              width: 420,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 30, offset: const Offset(-5, 0))],
                border: Border(left: BorderSide(color: Colors.grey.shade100)),
              ),
              child: _CartPanel(cart: cart),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.production_quantity_limits_rounded, size: 80, color: Colors.grey[300]),
    const SizedBox(height: 24),
    Text("Belum ada produk", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 18)),
    const SizedBox(height: 8),
    Text("Minta Admin untuk stok barang", style: TextStyle(color: Colors.grey[400])),
  ]));

  Widget _buildDesktopHeader(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24), 
    decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]),
    child: Row(children: [
      IconButton(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardPage())), icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black87)),
      const SizedBox(width: 20),
      const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Pilih Produk', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black87)),
        Text('Kasir Siap Melayani', style: TextStyle(fontSize: 13, color: Colors.grey)),
      ]),
      const Spacer(),
      // Search Bar Sederhana
      Container(width: 300, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFF5F6FA), borderRadius: BorderRadius.circular(12)), child: const TextField(decoration: InputDecoration(hintText: 'Cari produk...', border: InputBorder.none, icon: Icon(Icons.search_rounded, color: Colors.grey)))),
    ]),
  );
}

// Widget Item Produk (Tampilan Card)
class _ProductItem extends StatefulWidget {
  final Product product; final PosController cart; final int index;
  const _ProductItem({required this.product, required this.cart, required this.index});
  @override State<_ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<_ProductItem> {
  bool isHovered = false;
  final List<Color> _colors = [const Color(0xFFE3F2FD), const Color(0xFFF3E5F5), const Color(0xFFE8F5E9), const Color(0xFFFFF3E0), const Color(0xFFFCE4EC)];
  final List<Color> _accents = [Colors.blue, Colors.purple, Colors.green, Colors.orange, Colors.pink];

  @override Widget build(BuildContext context) {
    final outOfStock = widget.product.stock <= 0;
    final bgColor = _colors[widget.index % _colors.length];
    final accentColor = _accents[widget.index % _accents.length];
    
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true), onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: outOfStock ? null : () => widget.cart.addProduct(widget.product),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: isHovered ? (Matrix4.identity()..translate(0.0, -8.0)) : Matrix4.identity(),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isHovered ? accentColor.withOpacity(0.5) : Colors.transparent, width: 2),
            boxShadow: isHovered ? [BoxShadow(color: accentColor.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))] : [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(flex: 3, child: Container(
              decoration: BoxDecoration(borderRadius: const BorderRadius.vertical(top: Radius.circular(18)), color: outOfStock ? Colors.grey[200] : bgColor),
              child: Stack(children: [
                Center(child: Icon(outOfStock ? Icons.block_rounded : Icons.inventory_2_rounded, size: 48, color: outOfStock ? Colors.grey : accentColor)),
                if (outOfStock) Center(child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.red.withOpacity(0.9), borderRadius: BorderRadius.circular(20)), child: const Text("HABIS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)))),
                if (!outOfStock) Positioned(top: 10, right: 10, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)), child: Text("Stok: ${widget.product.stock}", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: accentColor)))),
              ]),
            )),
            Expanded(flex: 2, child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(widget.product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2D3436))),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Rp ${widget.product.price}', style: TextStyle(color: accentColor, fontWeight: FontWeight.w900, fontSize: 15)),
                CircleAvatar(radius: 14, backgroundColor: outOfStock ? Colors.grey[300] : accentColor, child: const Icon(Icons.add, color: Colors.white, size: 16))
              ])
            ])))
          ]),
        ),
      ),
    );
  }
}

// ================= PANEL KERANJANG (Cart Panel) =================
class _CartPanel extends StatelessWidget {
  final PosController cart; final bool isMobile;
  const _CartPanel({required this.cart, this.isMobile = false});

  @override Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('settings').listenable(),
      builder: (context, Box box, _) {
        final taxRate = box.get('tax_rate', defaultValue: 0);
        
        return Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(24, 32, 24, 16), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Pesanan', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(20)), child: const Text('Aktif', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 12))),
          ])),
          Divider(height: 1, color: Colors.grey[200]),
          
          Expanded(child: cart.items.isEmpty 
            ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.shopping_cart_outlined, size: 60, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text('Keranjang Kosong', style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold))
              ])) 
            : ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24), itemCount: cart.items.length, separatorBuilder: (_, __) => const SizedBox(height: 16), itemBuilder: (_, i) => PosCartItem(item: cart.items[i]))
          ),
          
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: const Color(0xFFF8F9FD), borderRadius: isMobile ? null : const BorderRadius.only(topLeft: Radius.circular(32))),
            child: Column(children: [
              _row('Subtotal', cart.subtotal), 
              const SizedBox(height: 8), 
              _row('Pajak ($taxRate%)', cart.taxAmount, isColor: true),
              const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Rp ${cart.grandTotal}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF2563EB)))
              ]),
              const SizedBox(height: 24),
              SizedBox(width: double.infinity, height: 56, child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 5, shadowColor: const Color(0xFF2563EB).withOpacity(0.4)),
                onPressed: cart.items.isEmpty ? null : () => cart.checkout(context), 
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.payment, color: Colors.white), SizedBox(width: 12), Text('PROSES BAYAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))])
              ))
            ]),
          )
        ]);
      }
    );
  }
  Widget _row(String l, int v, {bool isColor = false}) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600)), Text('Rp $v', style: TextStyle(fontWeight: FontWeight.bold, color: isColor ? Colors.orange : Colors.black87))]);
}