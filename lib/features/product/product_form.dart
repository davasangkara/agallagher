import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/product_model.dart';

class ProductForm extends StatefulWidget {
  const ProductForm({super.key});

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> with SingleTickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _skuCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _categoryCtrl.dispose();
    _skuCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _save() async {
    if (_nameCtrl.text.isEmpty || _priceCtrl.text.isEmpty || _stockCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Nama, Harga, dan Stok wajib diisi!",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFFF6B6B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 800));

    final box = Hive.box<Product>('products');
    
    box.add(Product(
      name: _nameCtrl.text,
      price: int.parse(_priceCtrl.text),
      stock: int.parse(_stockCtrl.text),
      category: _categoryCtrl.text.isEmpty ? 'Umum' : _categoryCtrl.text,
      sku: _skuCtrl.text.isEmpty ? '-' : _skuCtrl.text,
      description: _descCtrl.text,
    ));
    
    if (mounted) {
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  '✨ Produk berhasil disimpan!',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF4ECDC4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 900;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: isMobile 
              ? const EdgeInsets.all(16) 
              : const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Container(
                  width: isMobile ? double.infinity : (isTablet ? 600 : 650),
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.9,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF667eea).withOpacity(0.2),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header dengan Gradient
                      Container(
                        padding: EdgeInsets.all(isMobile ? 20 : 28),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(32),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.add_shopping_cart_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Tambah Produk Baru",
                                    style: TextStyle(
                                      fontSize: isMobile ? 18 : 22,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Lengkapi informasi produk",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: isMobile ? 12 : 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => Navigator.pop(context),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Form Content
                      Flexible(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(isMobile ? 20 : 28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Nama Produk
                              _ModernField(
                                controller: _nameCtrl,
                                label: 'Nama Produk',
                                hint: 'Contoh: Indomie Goreng',
                                icon: Icons.shopping_bag_rounded,
                                accentColor: const Color(0xFF667eea),
                                isMobile: isMobile,
                              ),
                              SizedBox(height: isMobile ? 16 : 20),

                              // Kategori & SKU
                              if (isMobile)
                                Column(
                                  children: [
                                    _ModernField(
                                      controller: _categoryCtrl,
                                      label: 'Kategori',
                                      hint: 'Umum',
                                      icon: Icons.category_rounded,
                                      accentColor: const Color(0xFFFF6B9D),
                                      isMobile: isMobile,
                                    ),
                                    const SizedBox(height: 16),
                                    _ModernField(
                                      controller: _skuCtrl,
                                      label: 'Kode SKU',
                                      hint: 'Scan/Ketik',
                                      icon: Icons.qr_code_2_rounded,
                                      accentColor: const Color(0xFF4ECDC4),
                                      isMobile: isMobile,
                                    ),
                                  ],
                                )
                              else
                                Row(
                                  children: [
                                    Expanded(
                                      child: _ModernField(
                                        controller: _categoryCtrl,
                                        label: 'Kategori',
                                        hint: 'Umum',
                                        icon: Icons.category_rounded,
                                        accentColor: const Color(0xFFFF6B9D),
                                        isMobile: isMobile,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _ModernField(
                                        controller: _skuCtrl,
                                        label: 'Kode SKU',
                                        hint: 'Scan/Ketik',
                                        icon: Icons.qr_code_2_rounded,
                                        accentColor: const Color(0xFF4ECDC4),
                                        isMobile: isMobile,
                                      ),
                                    ),
                                  ],
                                ),
                              SizedBox(height: isMobile ? 16 : 20),

                              // Harga & Stok
                              if (isMobile)
                                Column(
                                  children: [
                                    _ModernField(
                                      controller: _priceCtrl,
                                      label: 'Harga (Rp)',
                                      hint: '0',
                                      icon: Icons.monetization_on_rounded,
                                      isNumber: true,
                                      accentColor: const Color(0xFF95E1D3),
                                      isMobile: isMobile,
                                    ),
                                    const SizedBox(height: 16),
                                    _ModernField(
                                      controller: _stockCtrl,
                                      label: 'Stok Awal',
                                      hint: '0',
                                      icon: Icons.inventory_rounded,
                                      isNumber: true,
                                      accentColor: const Color(0xFFFFBE76),
                                      isMobile: isMobile,
                                    ),
                                  ],
                                )
                              else
                                Row(
                                  children: [
                                    Expanded(
                                      child: _ModernField(
                                        controller: _priceCtrl,
                                        label: 'Harga (Rp)',
                                        hint: '0',
                                        icon: Icons.monetization_on_rounded,
                                        isNumber: true,
                                        accentColor: const Color(0xFF95E1D3),
                                        isMobile: isMobile,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _ModernField(
                                        controller: _stockCtrl,
                                        label: 'Stok Awal',
                                        hint: '0',
                                        icon: Icons.inventory_rounded,
                                        isNumber: true,
                                        accentColor: const Color(0xFFFFBE76),
                                        isMobile: isMobile,
                                      ),
                                    ),
                                  ],
                                ),
                              SizedBox(height: isMobile ? 16 : 20),

                              // Deskripsi
                              _ModernField(
                                controller: _descCtrl,
                                label: 'Deskripsi (Opsional)',
                                hint: 'Tambahkan catatan produk...',
                                icon: Icons.description_rounded,
                                isTextArea: true,
                                accentColor: const Color(0xFF764ba2),
                                isMobile: isMobile,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Action Buttons
                      Container(
                        padding: EdgeInsets.all(isMobile ? 20 : 28),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(32),
                          ),
                        ),
                        child: Row(
                          children: [
                            if (!isMobile)
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _isSaving ? null : () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    side: BorderSide(color: Colors.grey.shade300, width: 2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text(
                                    "Batal",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            if (!isMobile) const SizedBox(width: 16),
                            Expanded(
                              flex: isMobile ? 1 : 2,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF667eea).withOpacity(0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _isSaving ? null : _save,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: EdgeInsets.symmetric(
                                      vertical: isMobile ? 16 : 18,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: _isSaving
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.check_circle_rounded,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              "SIMPAN",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: isMobile ? 14 : 15,
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
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Modern Input Field Widget
class _ModernField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool isNumber;
  final bool isTextArea;
  final Color accentColor;
  final bool isMobile;

  const _ModernField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.isNumber = false,
    this.isTextArea = false,
    required this.accentColor,
    this.isMobile = false,
  });

  @override
  State<_ModernField> createState() => _ModernFieldState();
}

class _ModernFieldState extends State<_ModernField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: widget.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  widget.icon,
                  size: 14,
                  color: widget.accentColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[700],
                  fontSize: widget.isMobile ? 12 : 13,
                ),
              ),
            ],
          ),
        ),
        Focus(
          onFocusChange: (hasFocus) => setState(() => _isFocused = hasFocus),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: _isFocused ? Colors.white : const Color(0xFFF8F9FD),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isFocused ? widget.accentColor : Colors.grey.shade200,
                width: 2,
              ),
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: widget.accentColor.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: TextField(
              controller: widget.controller,
              keyboardType: widget.isNumber
                  ? TextInputType.number
                  : (widget.isTextArea ? TextInputType.multiline : TextInputType.text),
              maxLines: widget.isTextArea ? 4 : 1,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: widget.isMobile ? 14 : 15,
              ),
              decoration: InputDecoration(
                prefixIcon: widget.isTextArea
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 60, left: 12),
                        child: Icon(
                          widget.icon,
                          color: _isFocused ? widget.accentColor : Colors.grey[400],
                          size: 22,
                        ),
                      )
                    : Icon(
                        widget.icon,
                        color: _isFocused ? widget.accentColor : Colors.grey[400],
                        size: 22,
                      ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: widget.isTextArea ? 16 : 18,
                ),
                hintText: widget.hint,
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: widget.isMobile ? 13 : 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}