import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pos_controller.dart';

class PosCartItem extends StatelessWidget {
  final CartItem item;

  const PosCartItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<PosController>();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          // 1. Image Placeholder / Initial
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              // PERBAIKAN DI SINI: gunakan item.product.name
              child: Text(
                item.product.name.isNotEmpty ? item.product.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Color(0xFF6C63FF),
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),

          // 2. Info Produk
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name, // PERBAIKAN DI SINI
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700, 
                    fontSize: 14, 
                    color: Color(0xFF2D3436)
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp ${item.product.price}',
                  style: const TextStyle(
                    fontSize: 13, 
                    color: Color(0xFF6C63FF), 
                    fontWeight: FontWeight.w600
                  ),
                ),
              ],
            ),
          ),

          // 3. QTY Stepper Modern
          Container(
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _QtyBtn(
                  icon: Icons.remove_rounded, 
                  onTap: () => cart.decreaseQty(item),
                  color: Colors.grey,
                ),
                Container(
                  width: 32,
                  alignment: Alignment.center,
                  child: Text(
                    '${item.qty}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
                _QtyBtn(
                  icon: Icons.add_rounded, 
                  onTap: () => cart.increaseQty(item),
                  color: const Color(0xFF6C63FF),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _QtyBtn({required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 34,
        height: double.infinity,
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}