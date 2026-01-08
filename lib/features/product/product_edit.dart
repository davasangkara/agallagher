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
  late TextEditingController nameCtrl;
  late TextEditingController priceCtrl;
  late TextEditingController stockCtrl;

  late String initName;
  late int initPrice;
  late int initStock;

  bool get nameChanged => nameCtrl.text != initName;
  bool get priceChanged => (int.tryParse(priceCtrl.text) ?? 0) != initPrice;
  bool get stockChanged => (int.tryParse(stockCtrl.text) ?? 0) != initStock;
  bool get hasChange => nameChanged || priceChanged || stockChanged;

  @override
  void initState() {
    super.initState();
    initName = widget.product.name;
    initPrice = widget.product.price;
    initStock = widget.product.stock;

    nameCtrl = TextEditingController(text: initName)..addListener(() => setState(() {}));
    priceCtrl = TextEditingController(text: initPrice.toString())..addListener(() => setState(() {}));
    stockCtrl = TextEditingController(text: initStock.toString())..addListener(() => setState(() {}));
  }

  Future<void> _deleteProduct() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Produk?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Produk "${widget.product.name}" akan dihapus permanen.', style: TextStyle(color: Colors.grey[600])),
        actionsPadding: const EdgeInsets.all(20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), 
            child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Hapus'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7675), // Soft Red
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
      final name = widget.product.name;
      await widget.product.delete();
      
      Hive.box<AuditLog>('audit_logs').add(AuditLog(
        action: 'DELETE', productName: name, role: 'admin', time: DateTime.now()
      ));

      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _save() async {
    widget.product
      ..name = nameCtrl.text
      ..price = int.parse(priceCtrl.text)
      ..stock = int.parse(stockCtrl.text);
    
    await widget.product.save();

    final role = await SharedPrefService.getRole();
    Hive.box<AuditLog>('audit_logs').add(AuditLog(
      action: 'UPDATE', productName: widget.product.name, role: role, time: DateTime.now()
    ));

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 400),
        tween: Tween(begin: 0.8, end: 1),
        curve: Curves.elasticOut,
        builder: (context, val, child) => Transform.scale(scale: val, child: child),
        child: Container(
          width: 450,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 40, offset: const Offset(0, 10))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Edit Produk', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF2D3436))),
                  IconButton(
                    icon: const Icon(Icons.delete_forever_rounded, color: Color(0xFFFF7675), size: 28),
                    onPressed: _deleteProduct,
                    tooltip: 'Hapus Produk',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(height: 24),
              
              _ColorEditField(label: 'Nama Produk', controller: nameCtrl, hasChanged: nameChanged, color: const Color(0xFF6C63FF)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _ColorEditField(label: 'Harga', controller: priceCtrl, hasChanged: priceChanged, isNumber: true, color: const Color(0xFF00B894))),
                  const SizedBox(width: 20),
                  Expanded(child: _ColorEditField(label: 'Stok', controller: stockCtrl, hasChanged: stockChanged, isNumber: true, color: const Color(0xFFE17055))),
                ],
              ),

              const SizedBox(height: 40),
              
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        foregroundColor: Colors.grey[600],
                      ),
                      child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: hasChange 
                            ? const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF4834D4)]) // Purple Gradient
                            : LinearGradient(colors: [Colors.grey.shade300, Colors.grey.shade400]),
                        boxShadow: hasChange 
                            ? [BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))] 
                            : [],
                      ),
                      child: ElevatedButton(
                        onPressed: hasChange ? _save : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          disabledBackgroundColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorEditField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool hasChanged;
  final bool isNumber;
  final Color color;

  const _ColorEditField({required this.label, required this.controller, required this.hasChanged, this.isNumber = false, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: hasChanged ? color : Colors.grey[500])),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: hasChanged ? color.withOpacity(0.05) : const Color(0xFFF5F6FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: hasChanged ? color : Colors.transparent, width: 1.5)
          ),
          child: TextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: TextStyle(fontWeight: FontWeight.w700, color: hasChanged ? color : Colors.black87),
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}