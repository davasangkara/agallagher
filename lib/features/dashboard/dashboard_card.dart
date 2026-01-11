import 'package:flutter/material.dart';
import 'dart:math' as math;

class DashboardCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback? onTap;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.colors,
    this.onTap,
  });

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> with TickerProviderStateMixin {
  bool isHovered = false;
  late AnimationController _hoverController;
  late AnimationController _pulseController;
  late AnimationController _shineController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    // Hover Animation Controller
    _hoverController = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 400),
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );
    
    _elevationAnimation = Tween<double>(begin: 0.2, end: 0.5).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );
    
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );

    // Pulse Animation (Continuous)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Shine Effect Controller
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _pulseController.dispose();
    _shineController.dispose();
    super.dispose();
  }

  void _onHover(bool hover) {
    setState(() => isHovered = hover);
    if (hover) {
      _hoverController.forward();
      _shineController.forward(from: 0);
    } else {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      cursor: SystemMouseCursors.click,
      child: AnimatedBuilder(
        animation: Listenable.merge([_hoverController, _pulseController]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value * math.pi / 180,
              child: GestureDetector(
                onTap: widget.onTap,
                
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: LinearGradient(
                      colors: widget.colors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      // Main Shadow
                      BoxShadow(
                        color: widget.colors.last.withOpacity(_elevationAnimation.value),
                        blurRadius: isHovered ? 32 : 20,
                        offset: Offset(0, isHovered ? 16 : 10),
                        spreadRadius: isHovered ? -4 : -6,
                      ),
                      // Glow Effect
                      BoxShadow(
                        color: widget.colors.first.withOpacity(0.3 + (_glowAnimation.value * 0.2)),
                        blurRadius: 24,
                        offset: const Offset(0, 0),
                        spreadRadius: isHovered ? 2 : 0,
                      ),
                      // Top Light
                      BoxShadow(
                        color: Colors.white.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(-4, -4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Stack(
                      children: [
                        // Animated Gradient Background
                        Positioned.fill(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  widget.colors[0],
                                  widget.colors[1],
                                  widget.colors[0],
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                        ),

                        // Mesh Gradient Pattern
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _MeshGradientPainter(
                              color: Colors.white.withOpacity(0.03),
                            ),
                          ),
                        ),
                        
                        // Animated Circles Pattern
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _CirclePatternPainter(
                              color: Colors.white.withOpacity(0.08),
                              animation: _glowAnimation.value,
                            ),
                          ),
                        ),
                        
                        // Decorative Watermark Icon
                        Positioned(
                          right: -30,
                          top: -30,
                          child: AnimatedRotation(
                            turns: isHovered ? 0.1 : 0,
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOutCubic,
                            child: Icon(
                              widget.icon,
                              size: 140,
                              color: Colors.white.withOpacity(0.12),
                            ),
                          ),
                        ),
                        
                        // Gradient Overlay for depth
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 120,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.15),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Icon Container with Glow Effect
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOutCubic,
                                padding: EdgeInsets.all(isHovered ? 14 : 12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.3),
                                      Colors.white.withOpacity(0.15),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.4),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.25),
                                      blurRadius: isHovered ? 16 : 8,
                                      spreadRadius: isHovered ? 4 : 0,
                                    ),
                                    BoxShadow(
                                      color: widget.colors.last.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  widget.icon, 
                                  color: Colors.white, 
                                  size: isHovered ? 28 : 26,
                                ),
                              ),
                              
                              const Spacer(),
                              
                              // Value with Enhanced Typography
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: [
                                      Colors.white,
                                      Colors.white.withOpacity(0.9),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(bounds),
                                  child: Text(
                                    widget.value,
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: -1.5,
                                      height: 1.0,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.3),
                                          offset: const Offset(0, 3),
                                          blurRadius: 8,
                                        ),
                                        Shadow(
                                          color: widget.colors.last.withOpacity(0.5),
                                          offset: const Offset(0, 0),
                                          blurRadius: 12,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 12),
                              
                              // Title with Modern Badge
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                padding: EdgeInsets.symmetric(
                                  horizontal: isHovered ? 14 : 12,
                                  vertical: isHovered ? 8 : 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.25),
                                      Colors.white.withOpacity(0.15),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.4),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 400),
                                      width: isHovered ? 8 : 6,
                                      height: isHovered ? 8 : 6,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white.withOpacity(0.6),
                                            blurRadius: isHovered ? 8 : 4,
                                            spreadRadius: isHovered ? 3 : 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Flexible(
                                      child: Text(
                                        widget.title,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white.withOpacity(0.95),
                                          letterSpacing: 0.5,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withOpacity(0.2),
                                              offset: const Offset(0, 1),
                                              blurRadius: 2,
                                            ),
                                          ],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Animated Shine Effect
                        AnimatedBuilder(
                          animation: _shineController,
                          builder: (context, child) {
                            return Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: Transform.translate(
                                  offset: Offset(
                                    -200 + (_shineController.value * 400),
                                    -200 + (_shineController.value * 400),
                                  ),
                                  child: Transform.rotate(
                                    angle: 0.5,
                                    child: Container(
                                      width: 100,
                                      height: 300,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            Colors.white.withOpacity(0.2),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        
                        // Hover Overlay
                        if (isHovered)
                          Positioned.fill(
                            child: AnimatedOpacity(
                              opacity: isHovered ? 1 : 0,
                              duration: const Duration(milliseconds: 400),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28),
                                  gradient: RadialGradient(
                                    center: Alignment.topLeft,
                                    radius: 1.5,
                                    colors: [
                                      Colors.white.withOpacity(0.15),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
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
      ),
    );
  }
}

// Mesh Gradient Pattern Painter
class _MeshGradientPainter extends CustomPainter {
  final Color color;

  _MeshGradientPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const spacing = 30.0;

    // Horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Animated Circle Pattern Painter
class _CirclePatternPainter extends CustomPainter {
  final Color color;
  final double animation;

  _CirclePatternPainter({required this.color, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const spacing = 40.0;
    final baseRadius = 2.0 + (animation * 1.5);

    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        final radius = baseRadius + (math.sin(x / 20 + animation * math.pi) * 0.5);
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}