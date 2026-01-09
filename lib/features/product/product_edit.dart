import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/models/product_model.dart';
import '../../data/models/audit_log_model.dart';
import '../../data/local/shared_pref_service.dart';

class ProductEdit extends StatefulWidget {
  final Product product;
  const ProductEdit({super.key, required this.product});

  @override
  State<ProductEdit> createState() => _ProductEditState();
}

class _ProductEditState extends State<ProductEdit> {
  // Controllers
  late TextEditingController nameCtrl;
  late TextEditingController priceCtrl;
  late TextEditingController stockCtrl;
  late TextEditingController categoryCtrl;
  late TextEditingController skuCtrl;
  late TextEditingController descCtrl;

  // Initial Values (Untuk validasi perubahan)
  late String iName;
  late int iPrice;
  late int iStock;
  late String iCategory;
  late String iSku;
  late String iDesc;

  // Logic: Field akan bernilai true jika teks di dalamnya berbeda dengan data awal
  bool get nameChanged => nameCtrl.text != iName;
  bool get priceChanged => (int.tryParse(priceCtrl.text) ?? 0) != iPrice;
  bool get stockChanged => (int.tryParse(stockCtrl.text) ?? 0) != iStock;
  bool get categoryChanged => categoryCtrl.text != iCategory;
  bool get skuChanged => skuCtrl.text != iSku;
  bool get descChanged => descCtrl.text != iDesc;

  // Gabungan: Tombol simpan aktif jika ada satu saja perubahan
  bool get hasChange => 
    nameChanged || priceChanged || stockChanged || categoryChanged || skuChanged || descChanged;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    
    // Simpan state awal
    iName = p.name; 
    iPrice = p.price; 
    iStock = p.stock;
    iCategory = p.category; 
    iSku = p.sku; 
    iDesc = p.description;

    // Inisialisasi Controller & Listener
    nameCtrl = TextEditingController(text: iName)..addListener(() => setState(() {}));
    priceCtrl = TextEditingController(text: iPrice.toString())..addListener(() => setState(() {}));
    stockCtrl = TextEditingController(text: iStock.toString())..addListener(() => setState(() {}));
    categoryCtrl = TextEditingController(text: iCategory)..addListener(() => setState(() {}));
    skuCtrl = TextEditingController(text: iSku)..addListener(() => setState(() {}));
    descCtrl = TextEditingController(text: iDesc)..addListener(() => setState(() {}));
  }

  // --- LOGIC HAPUS ---
  Future<void> _deleteProduct() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Produk?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Produk ini akan dihapus permanen dari database. Lanjutkan?'),
        actionsPadding: const EdgeInsets.all(20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), 
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Hapus'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7675),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, true), 
          ),
        ],
      ),
    );

    if (confirm == true) {
      await widget.product.delete();
      if(Hive.isBoxOpen('audit_logs')) {
         Hive.box<AuditLog>('audit_logs').add(AuditLog(action: 'DELETE', productName: iName, role: 'admin', time: DateTime.now()));
      }
      if (mounted) Navigator.pop(context);
    }
  }

  // --- LOGIC SIMPAN ---
  Future<void> _save() async {
    widget.product
      ..name = nameCtrl.text
      ..price = int.parse(priceCtrl.text)
      ..stock = int.parse(stockCtrl.text)
      ..category = categoryCtrl.text
      ..sku = skuCtrl.text
      ..description = descCtrl.text;
    
    await widget.product.save();
    
    final role = await SharedPrefService.getRole();
    if(Hive.isBoxOpen('audit_logs')) {
      Hive.box<AuditLog>('audit_logs').add(AuditLog(action: 'UPDATE', productName: widget.product.name, role: role, time: DateTime.now()));
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 350),
        tween: Tween(begin: 0.8, end: 1),
        curve: Curves.easeOutBack,
        builder: (context, val, child) => Transform.scale(scale: val, child: child),
        child: Container(
          width: 600, // Lebar dialog
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 40, offset: const Offset(0, 15))
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER: Title & Delete Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Edit Produk', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF2D3436))),
                        Text('Perbarui informasi barang', style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w500)),
                      ],
                    ),
                    // Tombol Hapus (Style Merah Soft)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF7675).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.delete_forever_rounded, color: Color(0xFFFF7675)),
                        onPressed: _deleteProduct,
                        tooltip: 'Hapus Produk Ini',
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // --- FORM FIELDS ---
                
                // 1. Nama Produk (Full Width)
                _ModernEditField(
                  controller: nameCtrl, 
                  label: 'Nama Produk', 
                  icon: Icons.tag, 
                  isChanged: nameChanged,
                  accentColor: const Color(0xFF6C63FF), // Purple
                ),
                
                const SizedBox(height: 16),

                // 2. Baris: Kategori & SKU
                Row(
                  children: [
                    Expanded(
                      child: _ModernEditField(
                        controller: categoryCtrl, 
                        label: 'Kategori', 
                        icon: Icons.category_rounded, 
                        isChanged: categoryChanged,
                        accentColor: const Color(0xFFFF7675), // Pink/Red
                      )
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ModernEditField(
                        controller: skuCtrl, 
                        label: 'Kode SKU', 
                        icon: Icons.qr_code_rounded, 
                        isChanged: skuChanged,
                        accentColor: Colors.black87,
                      )
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 3. Baris: Harga & Stok
                Row(
                  children: [
                    Expanded(
                      child: _ModernEditField(
                        controller: priceCtrl, 
                        label: 'Harga (Rp)', 
                        icon: Icons.attach_money_rounded, 
                        isNumber: true,
                        isChanged: priceChanged,
                        accentColor: const Color(0xFF00B894), // Green
                      )
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ModernEditField(
                        controller: stockCtrl, 
                        label: 'Stok', 
                        icon: Icons.inventory_2_rounded, 
                        isNumber: true,
                        isChanged: stockChanged,
                        accentColor: const Color(0xFFE17055), // Orange
                      )
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 4. Deskripsi
                _ModernEditField(
                  controller: descCtrl, 
                  label: 'Deskripsi Produk', 
                  icon: Icons.description_rounded, 
                  isChanged: descChanged,
                  accentColor: Colors.blueGrey,
                  isTextArea: true,
                ),

                const SizedBox(height: 40),
                
                // --- ACTION BUTTONS ---
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          foregroundColor: Colors.grey[600],
                        ),
                        child: const Text('Batalkan', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: hasChange 
                              ? const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF4834D4)]) // Gradient Aktif
                              : LinearGradient(colors: [Colors.grey.shade200, Colors.grey.shade300]), // Disable state
                          boxShadow: hasChange 
                              ? [BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))] 
                              : [],
                        ),
                        child: ElevatedButton(
                          onPressed: hasChange ? _save : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            disabledBackgroundColor: Colors.transparent, // Penting agar gradient terlihat
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            'Simpan Perubahan', 
                            style: TextStyle(
                              color: hasChange ? Colors.white : Colors.grey[500], 
                              fontWeight: FontWeight.bold,
                              fontSize: 16
                            )
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================= WIDGET FIELD MODERN =================
// Widget ini akan berubah warna border dan icon-nya jika datanya diedit
class _ModernEditField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool isChanged;
  final bool isNumber;
  final bool isTextArea;
  final Color accentColor;

  const _ModernEditField({
    required this.label, 
    required this.controller, 
    required this.icon,
    required this.isChanged, 
    this.isNumber = false, 
    this.isTextArea = false,
    required this.accentColor
  });

  @override
  Widget build(BuildContext context) {
    // Warna aktif jika diedit, warna default jika tidak
    final activeColor = isChanged ? accentColor : Colors.grey[400]!;
    final bgFill = isChanged ? accentColor.withOpacity(0.05) : const Color(0xFFF7F9FC);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label dengan indikator dot jika berubah
        Row(
          children: [
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isChanged ? accentColor : Colors.grey[600])),
            if (isChanged) ...[
              const SizedBox(width: 4),
              Container(width: 6, height: 6, decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle))
            ]
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: bgFill,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isChanged ? accentColor : Colors.transparent, 
              width: 1.5
            )
          ),
          child: TextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : (isTextArea ? TextInputType.multiline : TextInputType.text),
            maxLines: isTextArea ? 3 : 1,
            style: TextStyle(
              fontWeight: FontWeight.w700, 
              color: isChanged ? Colors.black87 : Colors.black54
            ),
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: isTextArea ? const EdgeInsets.only(bottom: 40) : EdgeInsets.zero,
                child: Icon(icon, color: isChanged ? accentColor : Colors.grey[400]),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }
}