import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/product_model.dart';
import 'pos_controller.dart';

class PosCartItem extends StatefulWidget {
  final CartItem item;
  const PosCartItem({super.key, required this.item});

  @override
  State<PosCartItem> createState() => _PosCartItemState();
}

class _PosCartItemState extends State<PosCartItem> with SingleTickerProviderStateMixin {
  bool isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Warna gradient berdasarkan index produk
  List<Color> _getGradientColors(String productName) {
    final gradients = [
      [const Color(0xFF667EEA), const Color(0xFF764BA2)], // Purple
      [const Color(0xFFf093fb), const Color(0xFFF5576C)], // Pink
      [const Color(0xFF4facfe), const Color(0xFF00f2fe)], // Blue
      [const Color(0xFF43e97b), const Color(0xFF38f9d7)], // Green
      [const Color(0xFFfa709a), const Color(0xFFfee140)], // Orange
      [const Color(0xFF30cfd0), const Color(0xFF330867)], // Teal
    ];
    
    final index = productName.hashCode.abs() % gradients.length;
    return gradients[index];
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.read<PosController>();
    final gradientColors = _getGradientColors(widget.item.product.name);
    final totalPrice = widget.item.product.price * widget.item.qty;

    return MouseRegion(
      onEnter: (_) {
        setState(() => isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => isHovered = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isHovered 
                    ? gradientColors[0].withOpacity(0.2)
                    : Colors.grey.withOpacity(0.08),
                blurRadius: isHovered ? 20 : 12,
                offset: Offset(0, isHovered ? 8 : 4),
                spreadRadius: isHovered ? 2 : 0,
              ),
            ],
            border: isHovered
                ? Border.all(
                    color: gradientColors[0].withOpacity(0.3),
                    width: 2,
                  )
                : null,
          ),
          child: Row(
            children: [
              // AVATAR PRODUK DENGAN GRADIENT
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors[0].withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.item.product.name.isNotEmpty
                        ? widget.item.product.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // INFO PRODUK
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF1F2937),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                gradientColors[0].withOpacity(0.15),
                                gradientColors[1].withOpacity(0.15),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Rp ${NumberFormat('#,###').format(widget.item.product.price)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: gradientColors[0],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '× ${widget.item.qty}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // TOTAL HARGA
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: gradientColors,
                      ).createShader(bounds),
                      child: Text(
                        'Total: Rp ${NumberFormat('#,###').format(totalPrice)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // TOMBOL KONTROL QTY
              Container(
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFF8F9FE),
                      Colors.grey[50]!,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.grey[200]!,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ModernButton(
                      icon: Icons.remove_rounded,
                      onTap: () {
                        cart.decreaseQty(widget.item);
                        // Haptic feedback bisa ditambahkan di sini
                      },
                      gradient: LinearGradient(
                        colors: [Colors.red[400]!, Colors.red[600]!],
                      ),
                    ),
                    Container(
                      width: 42,
                      alignment: Alignment.center,
                      child: Text(
                        '${widget.item.qty}',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: gradientColors[0],
                        ),
                      ),
                    ),
                    _ModernButton(
                      icon: Icons.add_rounded,
                      onTap: () {
                        cart.increaseQty(widget.item);
                      },
                      gradient: LinearGradient(
                        colors: gradientColors,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// TOMBOL MODERN DENGAN GRADIENT
class _ModernButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final LinearGradient gradient;

  const _ModernButton({
    required this.icon,
    required this.onTap,
    required this.gradient,
  });

  @override
  State<_ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<_ModernButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) {
        setState(() => isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 40,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: widget.gradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isPressed
              ? []
              : [
                  BoxShadow(
                    color: widget.gradient.colors[0].withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        transform: isPressed
            ? (Matrix4.identity()..scale(0.95))
            : Matrix4.identity(),
        child: Icon(
          widget.icon,
          size: 20,
          color: Colors.white,
        ),
      ),
    );
  }
}