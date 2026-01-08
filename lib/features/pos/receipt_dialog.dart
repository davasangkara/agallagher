import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'pos_controller.dart';

class ReceiptDialog extends StatelessWidget {
  final PosController cart;

  const ReceiptDialog({super.key, required this.cart});

  @override
  Widget build(BuildContext context) {
    // Style text yang konsisten dan elegan
    const monoStyle = TextStyle(
      fontFamily: 'Courier',
      fontSize: 13,
      color: Color(0xFF2D3436),
      fontWeight: FontWeight.w600,
    );
    const labelStyle = TextStyle(
      fontSize: 11,
      color: Colors.grey,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    );
    const totalStyle = TextStyle(
      fontFamily: 'Courier',
      fontSize: 16,
      fontWeight: FontWeight.w900,
      color: Color(0xFF2563EB), // Blue Primary
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(20),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 600),
        tween: Tween(begin: 0, end: 1),
        curve: Curves.elasticOut,
        builder: (context, val, child) =>
            Transform.scale(scale: val, child: child),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Icon Sukses dengan Glow
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00B894).withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: const Color(0xFF00B894),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
              ),

              // 2. Kertas Struk (Ticket Shape)
              ClipPath(
                clipper: _TicketClipper(),
                child: Container(
                  width: 360,
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'PEMBAYARAN BERHASIL',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          letterSpacing: 1,
                          color: Color(0xFF00B894),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Terima kasih telah berbelanja',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),

                      const SizedBox(height: 24),

                      // Detail Toko
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.store_mall_directory_rounded,
                            size: 18,
                            color: Colors.grey[800],
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'AGALLAGHER STORE',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: Color(0xFF2D3436),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Jl. Raya POS No. 88, Purwakarta',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),

                      const SizedBox(height: 24),

                      // Garis Putus-putus
                      const _DashedLine(),
                      const SizedBox(height: 24),

                      // List Item
                      // PERBAIKAN ERROR DI SINI
                      ...cart.lastItems.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Ganti e.product.name -> e.productName
                                    Text(e.productName, style: monoStyle),
                                    // Ganti e.product.price -> e.price
                                    Text(
                                      '${e.qty} x ${e.price}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  // Ganti e.product.price -> e.price
                                  'Rp ${e.price * e.qty}',
                                  style: monoStyle,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      const _DashedLine(),
                      const SizedBox(height: 20),

                      // Total Section dengan Ikon
                      _receiptInfoRow(
                        'TOTAL TAGIHAN',
                        'Rp ${cart.lastTotal}',
                        Icons.receipt_long_rounded,
                        Colors.blueAccent,
                        labelStyle,
                        totalStyle,
                      ),
                      const SizedBox(height: 12),
                      _receiptInfoRow(
                        'TUNAI / BAYAR',
                        'Rp ${cart.lastPaid}',
                        Icons.payments_rounded,
                        Colors.green,
                        labelStyle,
                        monoStyle,
                      ),
                      const SizedBox(height: 12),
                      _receiptInfoRow(
                        'KEMBALIAN',
                        'Rp ${cart.lastChange}',
                        Icons.change_circle_rounded,
                        Colors.orange,
                        labelStyle,
                        monoStyle,
                      ),

                      const SizedBox(height: 32),

                      // Barcode Dummy
                      Opacity(
                        opacity: 0.7,
                        child: Container(
                          height: 45,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5d/UPC-A-036000291452.svg/1200px-UPC-A-036000291452.svg.png',
                              ),
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'TX-9921-8821',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[400],
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 3. Tombol Aksi (Floating style)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Tombol Tutup
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        foregroundColor: Colors.grey[800],
                      ),
                      icon: const Icon(Icons.close_rounded, size: 20),
                      label: const Text('Tutup'),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Tombol Cetak (Gradient)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF00C6FF)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        if (kIsWeb) {
                          try {
                            // ignore: avoid_dynamic_calls
                            (html.window as dynamic).print();
                          } catch (e) {
                            debugPrint('Print error: $e');
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Fitur cetak hanya tersedia di Web',
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.print_rounded, size: 20),
                      label: const Text(
                        'Cetak Struk',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Baris Info dengan Ikon
  Widget _receiptInfoRow(
    String label,
    String value,
    IconData icon,
    Color iconColor,
    TextStyle lStyle,
    TextStyle vStyle,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        const SizedBox(width: 8),
        Text(label, style: lStyle),
        const Spacer(),
        Text(value, style: vStyle),
      ],
    );
  }
}

// Widget Garis Putus-putus Custom (Warna lebih soft)
class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        final dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.grey[300]),
              ),
            );
          }),
        );
      },
    );
  }
}

// Custom Clipper untuk bentuk Tiket
class _TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);

    // Notch Kiri (Lengkungan Kertas)
    path.addOval(Rect.fromCircle(center: Offset(0, 150), radius: 12));
    // Notch Kanan (Lengkungan Kertas)
    path.addOval(Rect.fromCircle(center: Offset(size.width, 150), radius: 12));

    path.fillType = PathFillType.evenOdd;
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
