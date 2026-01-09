import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/product_model.dart';
import '../../data/models/transaction_model.dart';
import 'receipt_dialog.dart'; 
import 'package:qr_flutter/qr_flutter.dart';
enum PaymentMethod { cash, qris, debit }

class CartItem {
  final Product product;
  int qty;

  CartItem(this.product, this.qty);

  int get subtotal => product.price * qty;
}

class PosController extends ChangeNotifier {
  final List<CartItem> _items = [];

  // Data Transaksi Terakhir (Untuk Struk)
  List<TransactionItem> lastItems = [];
  int lastSubtotal = 0;
  int lastTax = 0;
  int lastGrandTotal = 0;
  int lastPaid = 0;
  int lastChange = 0;

  PaymentMethod paymentMethod = PaymentMethod.cash;
  int paidAmount = 0;

  List<CartItem> get items => _items;

  // ================= CALCULATIONS =================
  int get subtotal => _items.fold(0, (sum, item) => sum + item.subtotal);

  int get taxAmount {
    if (!Hive.isBoxOpen('settings')) return 0;
    final settings = Hive.box('settings');
    final int taxRate = settings.get('tax_rate', defaultValue: 0);
    return (subtotal * (taxRate / 100)).toInt();
  }

  int get grandTotal => subtotal + taxAmount;
  int get change => paidAmount - grandTotal;

  // ================= CART LOGIC =================
  void addProduct(Product product) {
    if (product.stock <= 0) return;
    final index = _items.indexWhere((e) => e.product.key == product.key);
    if (index >= 0) {
      if (_items[index].qty < product.stock) {
        _items[index].qty++;
      }
    } else {
      _items.add(CartItem(product, 1));
    }
    notifyListeners();
  }

  void increaseQty(CartItem item) {
    if (item.qty < item.product.stock) {
      item.qty++;
      notifyListeners();
    }
  }

  void decreaseQty(CartItem item) {
    if (item.qty > 1) {
      item.qty--;
    } else {
      _items.remove(item);
    }
    notifyListeners();
  }

  // Fungsi untuk membersihkan keranjang manual
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // ================= HOLD ORDER FEATURE (BARU) =================

  // 1. Simpan Pesanan Sementara
  Future<void> holdOrder(BuildContext context, String note) async {
    if (_items.isEmpty) return;

    // Buka box khusus untuk pesanan yang di-hold
    final box = await Hive.openBox('held_orders');
    
    // Simpan Key Produk & Qty (Serialization)
    List<Map<String, dynamic>> itemsData = _items.map((e) => {
      'key': e.product.key,
      'qty': e.qty,
      'name': e.product.name, // Backup nama
      'price': e.product.price // Backup harga
    }).toList();

    final heldOrder = {
      'time': DateTime.now().toIso8601String(),
      'note': note.isEmpty ? 'Pelanggan #${box.length + 1}' : note,
      'items': itemsData,
      'total': grandTotal
    };

    await box.add(heldOrder);
    
    _items.clear(); // Kosongkan keranjang aktif
    notifyListeners();

    if(context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Pesanan berhasil disimpan (Hold)"), 
        backgroundColor: Colors.orange
      ));
    }
  }

  // 2. Kembalikan Pesanan (Restore)
  Future<void> restoreOrder(BuildContext context, int index) async {
    final box = await Hive.openBox('held_orders');
    final productBox = Hive.box<Product>('products');
    
    final data = box.getAt(index) as Map;
    final List<dynamic> itemsData = data['items'];

    // Timpa keranjang saat ini
    _items.clear();

    for (var item in itemsData) {
      final productKey = item['key'];
      final qty = item['qty'] as int;

      // Coba cari produk di database berdasarkan Key
      // Ini menjaga agar stok tetap sinkron
      try {
        final product = productBox.get(productKey);
        if (product != null) {
          _items.add(CartItem(product, qty));
        } else {
          // Jika produk sudah dihapus dari database, skip atau handle error
          debugPrint("Produk dengan key $productKey tidak ditemukan.");
        }
      } catch (e) {
        debugPrint("Error restore product: $e");
      }
    }

    // Hapus dari daftar hold setelah diambil
    await box.deleteAt(index);
    notifyListeners();
    
    if(context.mounted) {
      Navigator.pop(context); // Tutup dialog
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Pesanan dikembalikan ke keranjang"), 
        backgroundColor: Colors.green
      ));
    }
  }

  // 3. Hapus Permanen Hold Order
  Future<void> deleteHeldOrder(int index) async {
    final box = await Hive.openBox('held_orders');
    await box.deleteAt(index);
    notifyListeners(); // Update UI jika ada listener yang memantau box ini (opsional)
  }

  // ================= SCAN BARCODE LOGIC =================
  bool handleBarcode(String code) {
    if (code.isEmpty) return false;

    final box = Hive.box<Product>('products');
    
    try {
      final product = box.values.firstWhere(
        (p) => p.sku == code,
      );
      addProduct(product);
      return true; 
    } catch (e) {
      return false; 
    }
  }

  // ================= CHECKOUT FLOW =================
  void checkout(BuildContext context) {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Keranjang kosong')));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _PaymentInputDialog(
        total: grandTotal, 
        onPay: (nominal, method) {
          paidAmount = nominal;
          paymentMethod = method;
          
          _processTransaction();
          
          Navigator.pop(ctx); 
          showDialog(context: context, builder: (_) => ReceiptDialog(cart: this));
        },
      ),
    );
  }

  void _processTransaction() {
    lastItems = _items.map((e) => TransactionItem(
      productName: e.product.name,
      price: e.product.price,
      qty: e.qty,
    )).toList();

    lastSubtotal = subtotal;
    lastTax = taxAmount;
    lastGrandTotal = grandTotal;
    lastPaid = paidAmount;
    lastChange = change;

    Hive.box<TransactionModel>('transactions').add(
      TransactionModel(
        time: DateTime.now(),
        total: lastGrandTotal,
        method: paymentMethod.name,
        paid: lastPaid,
        change: lastChange,
        items: lastItems,
      ),
    );

    for (final item in _items) {
      item.product.stock -= item.qty;
      item.product.save(); 
    }

    _items.clear();
    paidAmount = 0;
    notifyListeners();
  }
}

// ================= PAYMENT DIALOG (KEEP EXISTING) =================
// (Bagian _PaymentInputDialog SAMA PERSIS dengan kode Anda sebelumnya.
//  Saya sertakan ulang agar tidak hilang saat copy-paste).

class _PaymentInputDialog extends StatefulWidget {
  final int total;
  final Function(int, PaymentMethod) onPay;
  const _PaymentInputDialog({required this.total, required this.onPay});
  @override State<_PaymentInputDialog> createState() => _PaymentInputDialogState();
}

class _PaymentInputDialogState extends State<_PaymentInputDialog> {
  final _nominalCtrl = TextEditingController();
  PaymentMethod _method = PaymentMethod.cash;
  late List<int> _suggestions;
  String? _qrisData;

  @override
  void initState() {
    super.initState();
    final settings = Hive.box('settings');
    const myStaticQris = "00020101021126610015COM.EIDUPAY.WWW011893600824000000099502090000009950303UMI51440014ID.CO.QRIS.WWW0215ID10243301369600303UMI5204481253033605802ID5915MBL-DAFFAXSTORE6010PURWAKARTA61054111162070703A0163044E17";
    _qrisData = settings.get('qris_data', defaultValue: myStaticQris);

    _suggestions = [
      widget.total,
      _roundUp(widget.total, 5000),
      _roundUp(widget.total, 10000),
      _roundUp(widget.total, 50000),
      100000,
    ].toSet().toList()..sort();
  }

  int _roundUp(int number, int multiple) {
    if (multiple == 0) return number;
    int remainder = number % multiple;
    if (remainder == 0) return number;
    return number + multiple - remainder;
  }

  void _submit() {
    int nominal = widget.total;
    if (_method == PaymentMethod.cash) {
      int? input = int.tryParse(_nominalCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''));
      if (input == null || input < widget.total) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uang tunai kurang!'), backgroundColor: Colors.redAccent));
        return;
      }
      nominal = input;
    }
    widget.onPay(nominal, _method);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 420, padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Pembayaran', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                _methodBtn('Tunai', PaymentMethod.cash, Icons.money), 
                _methodBtn('QRIS', PaymentMethod.qris, Icons.qr_code), 
                _methodBtn('Debit', PaymentMethod.debit, Icons.credit_card)
              ]),
            ),
            const SizedBox(height: 24),
            if (_method == PaymentMethod.cash) ...[
              Text('Total Tagihan', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              Text('Rp ${widget.total}', style: const TextStyle(fontSize: 32, color: Color(0xFF2563EB), fontWeight: FontWeight.w900)),
              const SizedBox(height: 20),
              TextField(
                controller: _nominalCtrl, 
                keyboardType: TextInputType.number, 
                autofocus: true,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                decoration: InputDecoration(labelText: 'Uang Diterima', prefixText: 'Rp ', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white)
              ),
              const SizedBox(height: 12),
              Wrap(spacing: 8, children: _suggestions.map((amt) { 
                if(amt < widget.total) return const SizedBox(); 
                return ActionChip(
                  label: Text('Rp $amt'), 
                  onPressed: () => _nominalCtrl.text = amt.toString(),
                  backgroundColor: Colors.blue[50],
                  labelStyle: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
                ); 
              }).toList()),
            ] else if (_method == PaymentMethod.qris) ...[
               // QRIS UI (Simplified for brevity as requested)
               if (_qrisData == null || _qrisData!.isEmpty)
                const Text("QRIS belum diatur")
               else
                SizedBox(height: 200, width: 200, child: QrImageView(data: _qrisData!, version: QrVersions.auto)),
               const SizedBox(height: 20),
               Text("Scan & Bayar: Rp ${widget.total}", style: const TextStyle(fontWeight: FontWeight.bold))
            ] else ...[
              const Icon(Icons.credit_card, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text("Gesek kartu di mesin EDC", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              Text("Rp ${widget.total}", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.black87)),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 52, 
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 4), 
                onPressed: _submit, 
                child: Text(_method == PaymentMethod.cash ? 'BAYAR SEKARANG' : 'SUDAH DIBAYAR (LUNAS)', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16))
              )
            )
          ],
        ),
      ),
    );
  }
  
  Widget _methodBtn(String l, PaymentMethod v, IconData i) {
    bool sel = _method == v;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() { _method = v; if(v != PaymentMethod.cash) _nominalCtrl.text = widget.total.toString(); else _nominalCtrl.clear(); }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(vertical: 10), 
          decoration: BoxDecoration(color: sel ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(10), boxShadow: sel ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)] : []),
          child: Column(children: [Icon(i, color: sel ? const Color(0xFF2563EB) : Colors.grey, size: 20), const SizedBox(height: 4), Text(l, style: TextStyle(color: sel ? const Color(0xFF2563EB) : Colors.grey, fontWeight: FontWeight.bold, fontSize: 11))]),
        ),
      ),
    );
  }
}