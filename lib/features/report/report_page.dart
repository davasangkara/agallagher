import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../core/services/export_service.dart';
import '../../data/models/transaction_model.dart';
import '../dashboard/dashboard_page.dart';
import 'sales_line_chart.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  bool _isExporting = false;

  Future<void> _handleExport() async {
    setState(() => _isExporting = true);
    
    try {
      await ExportService.exportTransactionToExcel();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Berhasil membuat Excel! Silakan pilih aplikasi untuk berbagi.',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF48BB78),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Gagal export: $e',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFFC8181),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionBox = Hive.box<TransactionModel>('transactions');
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 20 : 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= HEADER =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const DashboardPage()),
                    ),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF0FFF4), Color(0xFFE0F2FE)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF9AE6B4)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF43E97B).withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                        color: Color(0xFF48BB78),
                      ),
                    ),
                  ),
                  
                  // TOMBOL EXPORT EXCEL
                  InkWell(
                    onTap: _isExporting ? null : _handleExport,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 14 : 20,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF43E97B).withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: _isExporting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.file_download_rounded,
                                size: 20,
                                color: Colors.white,
                              ),
                              if (!isMobile) ...[
                                const SizedBox(width: 8),
                                const Text(
                                  "Export Excel",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ]
                            ],
                          ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 28),

              // TITLE SECTION
              Row(
                children: const [
                  Icon(Icons.assessment_rounded, color: Color(0xFF667EEA), size: 32),
                  SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      'Laporan Penjualan',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2D3748),
                        letterSpacing: -0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE0E7FF), Color(0xFFFCE7F3)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '✨ Ringkasan performa toko Anda',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF667EEA),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ================= SUMMARY CARDS =================
              ValueListenableBuilder(
                valueListenable: transactionBox.listenable(),
                builder: (context, Box<TransactionModel> box, _) {
                  final int totalRevenue = box.values.fold(0, (sum, item) => sum + item.total);
                  final int totalTransactions = box.length;
                  final formatter = NumberFormat.compactSimpleCurrency(locale: 'id_ID');

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      if (isMobile) {
                        return Column(
                          children: [
                            _GradientSummaryCard(
                              title: 'Pendapatan',
                              value: formatter.format(totalRevenue),
                              icon: Icons.paid_rounded,
                              colors: const [Color(0xFFFEAC5E), Color(0xFFC779D0)],
                            ),
                            const SizedBox(height: 16),
                            _GradientSummaryCard(
                              title: 'Total Transaksi',
                              value: '$totalTransactions',
                              icon: Icons.shopping_bag_rounded,
                              colors: const [Color(0xFF43E97B), Color(0xFF38F9D7)],
                            ),
                          ],
                        );
                      } else {
                        return Row(
                          children: [
                            Expanded(
                              child: _GradientSummaryCard(
                                title: 'Total Pendapatan',
                                value: formatter.format(totalRevenue),
                                icon: Icons.paid_rounded,
                                colors: const [Color(0xFFFEAC5E), Color(0xFFC779D0)],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _GradientSummaryCard(
                                title: 'Total Transaksi',
                                value: '$totalTransactions',
                                icon: Icons.shopping_bag_rounded,
                                colors: const [Color(0xFF43E97B), Color(0xFF38F9D7)],
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  );
                }
              ),

              const SizedBox(height: 32),

              // ================= CHART SECTION =================
              Container(
                padding: EdgeInsets.all(isMobile ? 24 : 32),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.white, Color(0xFFFAFBFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667EEA).withOpacity(0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(
                                    Icons.trending_up_rounded,
                                    color: Color(0xFF667EEA),
                                    size: 24,
                                  ),
                                  SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      "Analitik Grafik",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF2D3748),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0E7FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  "Data Realtime 7 Hari",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF667EEA),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isMobile)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF43E97B).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.fiber_manual_record,
                                  size: 10,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  "Live",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    SizedBox(
                      height: isMobile ? 250 : 350,
                      child: SalesLineChart(isMobile: isMobile),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientSummaryCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> colors;

  const _GradientSummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.colors,
  });

  @override
  State<_GradientSummaryCard> createState() => _GradientSummaryCardState();
}

class _GradientSummaryCardState extends State<_GradientSummaryCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(isHovered ? 1.03 : 1.0),
        constraints: const BoxConstraints(minHeight: 150),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.colors.first.withOpacity(isHovered ? 0.5 : 0.3),
              blurRadius: isHovered ? 20 : 15,
              offset: Offset(0, isHovered ? 12 : 8),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(-2, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // Dotted Pattern Background
              Positioned.fill(
                child: CustomPaint(
                  painter: _DottedPatternPainter(
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),

              // Large Watermark Icon
              Positioned(
                right: -20,
                top: -20,
                child: AnimatedRotation(
                  turns: isHovered ? 0.05 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    widget.icon,
                    size: 120,
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
              ),

              // Gradient Overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 80,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Icon Container
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.25),
                            Colors.white.withOpacity(0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.2),
                            blurRadius: isHovered ? 12 : 6,
                            spreadRadius: isHovered ? 2 : 0,
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.icon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Value
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.white.withOpacity(0.95),
                              ],
                            ).createShader(bounds),
                            child: Text(
                              widget.value,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -1,
                                height: 1.0,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Title Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.5),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  widget.title,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.95),
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Shine Effect
              if (isHovered)
                Positioned.fill(
                  child: AnimatedOpacity(
                    opacity: isHovered ? 1 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.15),
                            Colors.transparent,
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.3, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Painter for Dotted Pattern
class _DottedPatternPainter extends CustomPainter {
  final Color color;

  _DottedPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const spacing = 20.0;
    const dotRadius = 1.5;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}