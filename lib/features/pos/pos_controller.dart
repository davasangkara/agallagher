import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/product_model.dart';
import '../../data/models/transaction_model.dart';
import 'receipt_dialog.dart'; // Pastikan file ini ada

enum PaymentMethod { cash, qris, debit }

class CartItem {
  final Product product;
  int qty;

  CartItem(this.product, this.qty);

  int get subtotal => product.price * qty;
}

class PosController extends ChangeNotifier {
  final List<CartItem> _items = [];

  // Data untuk struk terakhir
  List<TransactionItem> lastItems = [];
  int lastTotal = 0;
  int lastPaid = 0;
  int lastChange = 0;

  PaymentMethod paymentMethod = PaymentMethod.cash;
  int paidAmount = 0;

  List<CartItem> get items => _items;

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

  int get total => _items.fold(0, (sum, item) => sum + item.subtotal);
  int get change => paidAmount - total;

  // ================= CHECKOUT FLOW (DIPERBAIKI) =================
  
  // PERBAIKAN: Sekarang menerima BuildContext context
  void checkout(BuildContext context) {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keranjang masih kosong')),
      );
      return;
    }

    // 1. Tampilkan Dialog Input Pembayaran
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _PaymentInputDialog(
        total: total,
        onPay: (nominal, method) {
          // 2. Set Data Pembayaran
          paidAmount = nominal;
          paymentMethod = method;
          
          // 3. Proses Transaksi
          _processTransaction();
          
          // 4. Tutup Dialog Input
          Navigator.pop(ctx); 

          // 5. Tampilkan Struk
          showDialog(
            context: context,
            builder: (_) => ReceiptDialog(cart: this),
          );
        },
      ),
    );
  }

  // Logika Internal
  void _processTransaction() {
    lastItems = _items.map((e) => TransactionItem(
      productName: e.product.name,
      price: e.product.price,
      qty: e.qty,
    )).toList();

    lastTotal = total;
    lastPaid = paidAmount;
    lastChange = change;

    // Simpan ke Hive
    Hive.box<TransactionModel>('transactions').add(
      TransactionModel(
        time: DateTime.now(),
        total: lastTotal,
        method: paymentMethod.name,
        paid: lastPaid,
        change: lastChange,
        items: lastItems,
      ),
    );

    // Kurangi Stok
    for (final item in _items) {
      item.product.stock -= item.qty;
      item.product.save(); 
    }

    _items.clear();
    paidAmount = 0;
    notifyListeners();
  }
}

// ================= WIDGET DIALOG PEMBAYARAN =================
class _PaymentInputDialog extends StatefulWidget {
  final int total;
  final Function(int, PaymentMethod) onPay;

  const _PaymentInputDialog({required this.total, required this.onPay});

  @override
  State<_PaymentInputDialog> createState() => _PaymentInputDialogState();
}

class _PaymentInputDialogState extends State<_PaymentInputDialog> {
  final _nominalCtrl = TextEditingController();
  PaymentMethod _method = PaymentMethod.cash;
  late List<int> _suggestions;

  @override
  void initState() {
    super.initState();
    // Suggestion uang pas / uang besar terdekat
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
    int? nominal = int.tryParse(_nominalCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''));
    
    if (_method == PaymentMethod.cash) {
      if (nominal == null || nominal < widget.total) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uang tunai kurang!'), backgroundColor: Colors.red),
        );
        return;
      }
    } else {
      nominal = widget.total;
    }

    widget.onPay(nominal, _method);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Pembayaran', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Tagihan: Rp ${widget.total}', style: const TextStyle(fontSize: 18, color: Color(0xFF6C63FF), fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),

            // Pilihan Metode
            Row(
              children: [
                _methodBtn('Tunai', PaymentMethod.cash, Icons.money),
                const SizedBox(width: 8),
                _methodBtn('QRIS', PaymentMethod.qris, Icons.qr_code),
                const SizedBox(width: 8),
                _methodBtn('Debit', PaymentMethod.debit, Icons.credit_card),
              ],
            ),
            
            const SizedBox(height: 24),

            if (_method == PaymentMethod.cash) ...[
              TextField(
                controller: _nominalCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Nominal Diterima',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: _suggestions.map((amount) {
                  if (amount < widget.total) return const SizedBox();
                  return ActionChip(
                    label: Text('Rp $amount'),
                    onPressed: () => _nominalCtrl.text = amount.toString(),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 32),
            
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
              onPressed: _submit,
              child: const Text('BAYAR SEKARANG', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _methodBtn(String label, PaymentMethod val, IconData icon) {
    final selected = _method == val;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() {
          _method = val;
          if (val != PaymentMethod.cash) {
            _nominalCtrl.text = widget.total.toString();
          } else {
            _nominalCtrl.clear();
          }
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF6C63FF) : Colors.transparent,
            border: Border.all(color: selected ? const Color(0xFF6C63FF) : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? Colors.white : Colors.grey),
              Text(label, style: TextStyle(color: selected ? Colors.white : Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}