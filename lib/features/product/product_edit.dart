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

class _ProductEditState extends State<ProductEdit> with SingleTickerProviderStateMixin {
  late TextEditingController nameCtrl;
  late TextEditingController priceCtrl;
  late TextEditingController stockCtrl;
  late TextEditingController categoryCtrl;
  late TextEditingController skuCtrl;
  late TextEditingController descCtrl;

  late String iName;
  late int iPrice;
  late int iStock;
  late String iCategory;
  late String iSku;
  late String iDesc;

  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  
  bool _isSaving = false;
  bool _isDeleting = false;

  bool get nameChanged => nameCtrl.text != iName;
  bool get priceChanged => (int.tryParse(priceCtrl.text) ?? 0) != iPrice;
  bool get stockChanged => (int.tryParse(stockCtrl.text) ?? 0) != iStock;
  bool get categoryChanged => categoryCtrl.text != iCategory;
  bool get skuChanged => skuCtrl.text != iSku;
  bool get descChanged => descCtrl.text != iDesc;

  bool get hasChange =>
      nameChanged || priceChanged || stockChanged || categoryChanged || skuChanged || descChanged;

  @override
  void initState() {
    super.initState();
    final p = widget.product;

    iName = p.name;
    iPrice = p.price;
    iStock = p.stock;
    iCategory = p.category;
    iSku = p.sku;
    iDesc = p.description;

    nameCtrl = TextEditingController(text: iName)..addListener(() => setState(() {}));
    priceCtrl = TextEditingController(text: iPrice.toString())..addListener(() => setState(() {}));
    stockCtrl = TextEditingController(text: iStock.toString())..addListener(() => setState(() {}));
    categoryCtrl = TextEditingController(text: iCategory)..addListener(() => setState(() {}));
    skuCtrl = TextEditingController(text: iSku)..addListener(() => setState(() {}));
    descCtrl = TextEditingController(text: iDesc)..addListener(() => setState(() {}));

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

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    nameCtrl.dispose();
    priceCtrl.dispose();
    stockCtrl.dispose();
    categoryCtrl.dispose();
    skuCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  Future<void> _deleteProduct() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFFF6B6B),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Hapus Produk?',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Produk ini akan dihapus permanen dari database.',
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tindakan ini tidak dapat dibatalkan',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.all(24),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              side: BorderSide(color: Colors.grey.shade300, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Batal',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B6B).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.delete_forever_rounded, size: 20),
              label: const Text(
                'Hapus',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isDeleting = true);
      await Future.delayed(const Duration(milliseconds: 500));
      
      await widget.product.delete();
      if (Hive.isBoxOpen('audit_logs')) {
        Hive.box<AuditLog>('audit_logs').add(
          AuditLog(
            action: 'DELETE',
            productName: iName,
            role: 'admin',
            time: DateTime.now(),
          ),
        );
      }
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 600));

    widget.product
      ..name = nameCtrl.text
      ..price = int.parse(priceCtrl.text)
      ..stock = int.parse(stockCtrl.text)
      ..category = categoryCtrl.text
      ..sku = skuCtrl.text
      ..description = descCtrl.text;

    await widget.product.save();

    final role = await SharedPrefService.getRole();
    if (Hive.isBoxOpen('audit_logs')) {
      Hive.box<AuditLog>('audit_logs').add(
        AuditLog(
          action: 'UPDATE',
          productName: widget.product.name,
          role: role,
          time: DateTime.now(),
        ),
      );
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 12),
              Text(
                '✨ Perubahan berhasil disimpan!',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF4ECDC4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      Navigator.pop(context);
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
                          colors: [Color(0xFFFF6B9D), Color(0xFFC44569)],
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
                              Icons.edit_rounded,
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
                                  'Edit Produk',
                                  style: TextStyle(
                                    fontSize: isMobile ? 18 : 22,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Perbarui informasi barang',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: isMobile ? 12 : 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _isDeleting ? null : _deleteProduct,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF6B6B).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFFF6B6B).withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: _isDeleting
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.delete_forever_rounded,
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
                            // Changed Items Counter
                            if (hasChange)
                              Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF4ECDC4).withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.edit_note_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '${_countChanges()} perubahan terdeteksi',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Nama Produk
                            _ModernEditField(
                              controller: nameCtrl,
                              label: 'Nama Produk',
                              icon: Icons.shopping_bag_rounded,
                              isChanged: nameChanged,
                              accentColor: const Color(0xFF667eea),
                              isMobile: isMobile,
                            ),
                            SizedBox(height: isMobile ? 16 : 20),

                            // Kategori & SKU
                            if (isMobile)
                              Column(
                                children: [
                                  _ModernEditField(
                                    controller: categoryCtrl,
                                    label: 'Kategori',
                                    icon: Icons.category_rounded,
                                    isChanged: categoryChanged,
                                    accentColor: const Color(0xFFFF6B9D),
                                    isMobile: isMobile,
                                  ),
                                  const SizedBox(height: 16),
                                  _ModernEditField(
                                    controller: skuCtrl,
                                    label: 'Kode SKU',
                                    icon: Icons.qr_code_2_rounded,
                                    isChanged: skuChanged,
                                    accentColor: const Color(0xFF4ECDC4),
                                    isMobile: isMobile,
                                  ),
                                ],
                              )
                            else
                              Row(
                                children: [
                                  Expanded(
                                    child: _ModernEditField(
                                      controller: categoryCtrl,
                                      label: 'Kategori',
                                      icon: Icons.category_rounded,
                                      isChanged: categoryChanged,
                                      accentColor: const Color(0xFFFF6B9D),
                                      isMobile: isMobile,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _ModernEditField(
                                      controller: skuCtrl,
                                      label: 'Kode SKU',
                                      icon: Icons.qr_code_2_rounded,
                                      isChanged: skuChanged,
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
                                  _ModernEditField(
                                    controller: priceCtrl,
                                    label: 'Harga (Rp)',
                                    icon: Icons.monetization_on_rounded,
                                    isNumber: true,
                                    isChanged: priceChanged,
                                    accentColor: const Color(0xFF95E1D3),
                                    isMobile: isMobile,
                                  ),
                                  const SizedBox(height: 16),
                                  _ModernEditField(
                                    controller: stockCtrl,
                                    label: 'Stok',
                                    icon: Icons.inventory_rounded,
                                    isNumber: true,
                                    isChanged: stockChanged,
                                    accentColor: const Color(0xFFFFBE76),
                                    isMobile: isMobile,
                                  ),
                                ],
                              )
                            else
                              Row(
                                children: [
                                  Expanded(
                                    child: _ModernEditField(
                                      controller: priceCtrl,
                                      label: 'Harga (Rp)',
                                      icon: Icons.monetization_on_rounded,
                                      isNumber: true,
                                      isChanged: priceChanged,
                                      accentColor: const Color(0xFF95E1D3),
                                      isMobile: isMobile,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _ModernEditField(
                                      controller: stockCtrl,
                                      label: 'Stok',
                                      icon: Icons.inventory_rounded,
                                      isNumber: true,
                                      isChanged: stockChanged,
                                      accentColor: const Color(0xFFFFBE76),
                                      isMobile: isMobile,
                                    ),
                                  ),
                                ],
                              ),
                            SizedBox(height: isMobile ? 16 : 20),

                            // Deskripsi
                            _ModernEditField(
                              controller: descCtrl,
                              label: 'Deskripsi',
                              icon: Icons.description_rounded,
                              isChanged: descChanged,
                              accentColor: const Color(0xFF764ba2),
                              isTextArea: true,
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
                                  side: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Batal',
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
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: hasChange
                                    ? const LinearGradient(
                                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                      )
                                    : LinearGradient(
                                        colors: [Colors.grey.shade300, Colors.grey.shade400],
                                      ),
                                boxShadow: hasChange
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF667eea).withOpacity(0.4),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: ElevatedButton(
                                onPressed: hasChange && !_isSaving ? _save : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  disabledBackgroundColor: Colors.transparent,
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
                                          Icon(
                                            hasChange
                                                ? Icons.check_circle_rounded
                                                : Icons.edit_off_rounded,
                                            color: hasChange ? Colors.white : Colors.grey[400],
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'SIMPAN',
                                            style: TextStyle(
                                              color: hasChange ? Colors.white : Colors.grey[400],
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
        );
      },
    );
  }

  int _countChanges() {
    int count = 0;
    if (nameChanged) count++;
    if (priceChanged) count++;
    if (stockChanged) count++;
    if (categoryChanged) count++;
    if (skuChanged) count++;
    if (descChanged) count++;
    return count;
  }
}

// ================= MODERN EDIT FIELD =================
class _ModernEditField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool isChanged;
  final bool isNumber;
  final bool isTextArea;
  final Color accentColor;
  final bool isMobile;

  const _ModernEditField({
    required this.label,
    required this.controller,
    required this.icon,
    required this.isChanged,
    this.isNumber = false,
    this.isTextArea = false,
    required this.accentColor,
    this.isMobile = false,
  });

  @override
  State<_ModernEditField> createState() => _ModernEditFieldState();
}

class _ModernEditFieldState extends State<_ModernEditField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.isChanged ? widget.accentColor : Colors.grey[400]!;
    final bgColor = widget.isChanged
        ? widget.accentColor.withOpacity(0.05)
        : (_isFocused ? Colors.white : const Color(0xFFF8F9FD));

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
                  color: activeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  widget.icon,
                  size: 14,
                  color: activeColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: widget.isChanged ? widget.accentColor : Colors.grey[600],
                  fontSize: widget.isMobile ? 12 : 13,
                ),
              ),
              if (widget.isChanged) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: widget.accentColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'EDITED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        Focus(
          onFocusChange: (focused) => setState(() => _isFocused = focused),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.isChanged
                    ? widget.accentColor
                    : (_isFocused ? widget.accentColor.withOpacity(0.5) : Colors.grey.shade200),
                width: 2,
              ),
              boxShadow: widget.isChanged || _isFocused
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
                color: widget.isChanged ? Colors.black87 : Colors.black54,
                fontSize: widget.isMobile ? 14 : 15,
              ),
              decoration: InputDecoration(
                prefixIcon: widget.isTextArea
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 60, left: 12),
                        child: Icon(
                          widget.icon,
                          color: activeColor,
                          size: 22,
                        ),
                      )
                    // Lanjutan dari logic prefixIcon...
                  : Icon(
                      widget.icon,
                      color: activeColor,
                      size: 22,
                    ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              hintText: 'Isi ${widget.label}...',
              hintStyle: TextStyle(
                color: widget.accentColor.withOpacity(0.4),
                fontSize: widget.isMobile ? 13 : 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    ],
  );
  }
}