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
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ilustrasi Kecil (Opsional, atau text header)
                const Text("Detail Produk", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54)),
                const SizedBox(height: 20),

                _ColorfulField(
                  controller: _nameCtrl, 
                  label: 'Nama Produk', 
                  icon: Icons.tag, 
                  accentColor: const Color(0xFF6C63FF) // Purple Accent
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _ColorfulField(
                        controller: _priceCtrl, 
                        label: 'Harga (Rp)', 
                        icon: Icons.attach_money_rounded, 
                        isNumber: true,
                        accentColor: const Color(0xFF00B894) // Green Accent
                      )
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _ColorfulField(
                        controller: _stockCtrl, 
                        label: 'Stok Awal', 
                        icon: Icons.inventory_2_rounded, 
                        isNumber: true,
                        accentColor: const Color(0xFFE17055) // Orange Accent
                      )
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                
                // Gradient Button
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(colors: [Color(0xFF0984E3), Color(0xFF74B9FF)]), // Blue Gradient
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
                      ));
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('SIMPAN KE KATALOG', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white)),
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

// Custom Field yang lebih colorful
class _ColorfulField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isNumber;
  final Color accentColor;

  const _ColorfulField({
    required this.controller, 
    required this.label, 
    required this.icon, 
    this.isNumber = false,
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
            color: accentColor.withOpacity(0.05), // Latar belakang tint warna
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: accentColor),
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