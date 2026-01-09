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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(item.product.name.isNotEmpty ? item.product.name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w900, fontSize: 20))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2D3436))),
                const SizedBox(height: 4),
                Text('Rp ${item.product.price}', style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Container(
            height: 36,
            decoration: BoxDecoration(color: const Color(0xFFF5F6FA), borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Btn(icon: Icons.remove, onTap: () => cart.decreaseQty(item)),
                Container(width: 30, alignment: Alignment.center, child: Text('${item.qty}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                _Btn(icon: Icons.add, onTap: () => cart.increaseQty(item), color: Colors.blue),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon; final VoidCallback onTap; final Color? color;
  const _Btn({required this.icon, required this.onTap, this.color});
  @override Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(8),
      child: SizedBox(width: 32, height: double.infinity, child: Icon(icon, size: 16, color: color ?? Colors.grey[600])),
    );
  }
}