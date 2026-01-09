import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/product_model.dart';

class ProductForm extends StatefulWidget {
  const ProductForm({super.key});

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController(); // NEW
  final _skuCtrl = TextEditingController(); // NEW
  final _descCtrl = TextEditingController(); // NEW

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Product>('products');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Tambah Produk Baru', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Informasi Dasar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 20),

                // Baris 1: Nama & Kategori
                Row(
                  children: [
                    Expanded(flex: 2, child: _ColorfulField(controller: _nameCtrl, label: 'Nama Produk', icon: Icons.tag, accentColor: const Color(0xFF6C63FF))),
                    const SizedBox(width: 20),
                    Expanded(child: _ColorfulField(controller: _categoryCtrl, label: 'Kategori', icon: Icons.category_rounded, accentColor: const Color(0xFFFF7675))),
                  ],
                ),
                const SizedBox(height: 20),

                // Baris 2: SKU & Harga & Stok
                Row(
                  children: [
                    Expanded(child: _ColorfulField(controller: _skuCtrl, label: 'Kode SKU', icon: Icons.qr_code_rounded, accentColor: Colors.black87)),
                    const SizedBox(width: 20),
                    Expanded(child: _ColorfulField(controller: _priceCtrl, label: 'Harga', icon: Icons.attach_money_rounded, isNumber: true, accentColor: const Color(0xFF00B894))),
                    const SizedBox(width: 20),
                    Expanded(child: _ColorfulField(controller: _stockCtrl, label: 'Stok', icon: Icons.inventory_2_rounded, isNumber: true, accentColor: const Color(0xFFE17055))),
                  ],
                ),
                
                const SizedBox(height: 32),
                const Text("Detail Tambahan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 20),

                // Deskripsi (TextArea)
                _ColorfulField(
                  controller: _descCtrl, 
                  label: 'Deskripsi Produk (Opsional)', 
                  icon: Icons.description_rounded, 
                  accentColor: Colors.blueGrey,
                  isTextArea: true,
                ),

                const SizedBox(height: 48),
                
                // Save Button
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(colors: [Color(0xFF0984E3), Color(0xFF74B9FF)]), 
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF0984E3).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
                    ]
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_nameCtrl.text.isEmpty || _priceCtrl.text.isEmpty || _stockCtrl.text.isEmpty) return;
                      
                      box.add(Product(
                        name: _nameCtrl.text,
                        price: int.parse(_priceCtrl.text),
                        stock: int.parse(_stockCtrl.text),
                        category: _categoryCtrl.text.isEmpty ? 'Umum' : _categoryCtrl.text,
                        sku: _skuCtrl.text.isEmpty ? '-' : _skuCtrl.text,
                        description: _descCtrl.text,
                      ));
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('SIMPAN PRODUK', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white)),
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

// Widget Custom Field
class _ColorfulField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isNumber;
  final bool isTextArea;
  final Color accentColor;

  const _ColorfulField({
    required this.controller, 
    required this.label, 
    required this.icon, 
    this.isNumber = false,
    this.isTextArea = false,
    required this.accentColor
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey[600], fontSize: 13)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.05), // Tint background
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : (isTextArea ? TextInputType.multiline : TextInputType.text),
            maxLines: isTextArea ? 4 : 1,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            decoration: InputDecoration(
              prefixIcon: isTextArea ? Padding(padding: const EdgeInsets.only(bottom: 50), child: Icon(icon, color: accentColor)) : Icon(icon, color: accentColor),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              hintText: 'Isi $label...',
              hintStyle: TextStyle(color: accentColor.withOpacity(0.3)),
            ),
          ),
        ),
      ],
    );
  }
}