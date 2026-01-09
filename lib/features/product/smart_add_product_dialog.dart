import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/services/product_ai_service.dart';
import '../../data/models/product_model.dart';

class SmartAddProductDialog extends StatefulWidget {
  const SmartAddProductDialog({super.key});

  @override
  State<SmartAddProductDialog> createState() => _SmartAddProductDialogState();
}

class _SmartAddProductDialogState extends State<SmartAddProductDialog> {
  // Controller
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _skuCtrl = TextEditingController(); 

  String _selectedCategory = 'Umum';
  final List<String> _categories = ['Umum', 'Makanan', 'Minuman', 'Rokok', 'Sembako', 'Perlengkapan'];

  // Fungsi saat User memilih saran AI
  void _onAiSelection(String productName) {
    final details = ProductAiService.getProductDetails(productName);
    if (details != null) {
      setState(() {
        _nameCtrl.text = productName; // Auto isi Nama
        _selectedCategory = details['category']; // Auto isi Kategori
        _priceCtrl.text = details['price'].toString(); // Auto isi Harga Pasar
      });
      
      // Auto Focus ke kolom Stok
      Future.delayed(const Duration(milliseconds: 100), () {
        FocusScope.of(context).nextFocus(); 
      });
    }
  }

  void _saveProduct() {
    if (_nameCtrl.text.isEmpty || _priceCtrl.text.isEmpty || _stockCtrl.text.isEmpty) return;

    final box = Hive.box<Product>('products');
    
    final newProduct = Product(
      name: _nameCtrl.text,
      price: int.parse(_priceCtrl.text),
      stock: int.parse(_stockCtrl.text),
      sku: _skuCtrl.text.isEmpty ? '-' : _skuCtrl.text,
      category: _selectedCategory,
      // imagePath: '', <--- BAGIAN INI SUDAH DIHAPUS KARENA TIDAK ADA DI MODEL
      description: '', // Opsional, default kosong
    );

    box.add(newProduct);
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Produk berhasil disimpan!'), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.smart_toy_rounded, color: Colors.blue), // Ikon AI
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Smart Input Produk", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("Ketik nama, AI akan melengkapi", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 1. NAMA PRODUK (AUTOCOMPLETE AI)
              const Text("Nama Produk", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue val) {
                  return ProductAiService.getSuggestions(val.text);
                },
                onSelected: _onAiSelection,
                fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                  if (_nameCtrl.text.isEmpty && controller.text.isNotEmpty) {
                     _nameCtrl.text = controller.text;
                  }
                  controller.addListener(() {
                    _nameCtrl.text = controller.text;
                  });

                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    onEditingComplete: onEditingComplete,
                    decoration: InputDecoration(
                      hintText: "Cth: Coca Cola...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.search_rounded),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // 2. KATEGORI (Auto-Filled)
              const Text("Kategori", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _categories.contains(_selectedCategory) ? _selectedCategory : 'Umum',
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),

              const SizedBox(height: 16),

              // 3. HARGA & STOK (Row)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Harga Jual (Rp)", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _priceCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "0",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Stok Awal (Qty)", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _stockCtrl,
                          autofocus: true, 
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "0",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true, fillColor: Colors.blue[50], 
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // BUTTONS
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _saveProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.save_rounded, color: Colors.white),
                    label: const Text("Simpan Produk", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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