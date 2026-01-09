import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'pos_controller.dart';

class ReceiptDialog extends StatelessWidget {
  final PosController cart;
  const ReceiptDialog({super.key, required this.cart});

  @override
  Widget build(BuildContext context) {
    final settings = Hive.box('settings');
    final storeName = settings.get('store_name', defaultValue: 'AGALLAGHER STORE');
    final storeAddress = settings.get('store_address', defaultValue: 'Indonesia');

    return Dialog(
      backgroundColor: Colors.transparent, elevation: 0,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 500), tween: Tween(begin: 0.8, end: 1), curve: Curves.easeOutBack,
        builder: (c, val, child) => Transform.scale(scale: val, child: child),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 32),
              ),
              ClipPath(
                clipper: const _ZigZagClipper(),
                child: Container(
                  width: 350, padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      Text(storeName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1)),
                      const SizedBox(height: 4),
                      Text(storeAddress, style: TextStyle(color: Colors.grey[600], fontSize: 12), textAlign: TextAlign.center),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(thickness: 2, height: 2, color: Colors.black12)),
                      
                      ...cart.lastItems.map((e) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [
                        Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(e.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), Text("${e.qty} x ${e.price}", style: const TextStyle(fontSize: 11, color: Colors.grey))])),
                        Text("Rp ${e.price * e.qty}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))
                      ]))),
                      
                      const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(thickness: 1, color: Colors.black12)),
                      _row("Subtotal", cart.lastSubtotal),
                      if(cart.lastTax > 0) _row("Pajak", cart.lastTax),
                      const SizedBox(height: 12),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("TOTAL", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)), Text("Rp ${cart.lastGrandTotal}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.blue))]),
                      const SizedBox(height: 8),
                      _row("Tunai", cart.lastPaid),
                      _row("Kembali", cart.lastChange),
                      
                      const SizedBox(height: 32),
                      Text("Terima Kasih!", style: TextStyle(fontFamily: 'Courier', letterSpacing: 2, color: Colors.grey[400], fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Tutup", style: TextStyle(color: Colors.white))),
                const SizedBox(width: 16),
                ElevatedButton.icon(onPressed: (){ if(kIsWeb) { try { (html.window as dynamic).print(); } catch(e){} } }, icon: const Icon(Icons.print), label: const Text("Cetak"), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black))
              ])
            ],
          ),
        ),
      ),
    );
  }
  Widget _row(String l, int v) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: const TextStyle(color: Colors.grey)), Text("Rp $v", style: const TextStyle(fontWeight: FontWeight.bold))]));
}

class _ZigZagClipper extends CustomClipper<Path> {
  const _ZigZagClipper();
  @override Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 20);
    double x = 0; double y = size.height - 20; double increment = size.width / 20;
    while (x < size.width) { x += increment; y = (y == size.height - 20) ? size.height : size.height - 20; path.lineTo(x, y); }
    path.lineTo(size.width, 0);
    return path;
  }
  @override bool shouldReclip(old) => false;
}