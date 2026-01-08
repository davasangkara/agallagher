import 'package:flutter/material.dart';
import '../dashboard/dashboard_page.dart';
import 'sales_line_chart.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD), // Background soft grey-blue
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= HEADER =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const DashboardPage()),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black87),
                    ),
                  ),
                  // Tombol Download Opsional
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Icon(Icons.download_rounded, size: 20, color: Colors.black87),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              const Text(
                'Laporan Penjualan',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF2D3436), letterSpacing: -0.5),
              ),
              const SizedBox(height: 6),
              Text(
                'Ringkasan performa toko minggu ini',
                style: TextStyle(fontSize: 15, color: Colors.grey[500], fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 32),

              // ================= SUMMARY CARDS (GRADIENT) =================
              Row(
                children: [
                  Expanded(
                    child: _GradientSummaryCard(
                      title: 'Pendapatan', 
                      value: 'Rp 12.5 Jt', 
                      icon: Icons.auto_graph_rounded, 
                      colors: const [Color(0xFF00B894), Color(0xFF55EFC4)] // Green Gradient
                    )
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _GradientSummaryCard(
                      title: 'Transaksi', 
                      value: '142', 
                      icon: Icons.shopping_bag_rounded, 
                      colors: const [Color(0xFF0984E3), Color(0xFF74B9FF)] // Blue Gradient
                    )
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ================= CHART SECTION =================
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(color: Colors.blueGrey.withOpacity(0.08), blurRadius: 30, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Analitik Grafik", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF2D3436))),
                            const SizedBox(height: 4),
                            Text("Data Realtime", style: TextStyle(fontSize: 12, color: Colors.grey[400], fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C63FF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF6C63FF)),
                              SizedBox(width: 6),
                              Text("7 Hari", style: TextStyle(fontSize: 12, color: Color(0xFF6C63FF), fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 40),
                    const SizedBox(
                      height: 320, 
                      child: SalesLineChart(),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget Kartu Ringkasan dengan Gradien
class _GradientSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> colors;

  const _GradientSummaryCard({
    required this.title, 
    required this.value, 
    required this.icon, 
    required this.colors
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ]
      ),
      child: Stack(
        children: [
          // Watermark Icon Besar Transparan
          Positioned(
            right: -15,
            top: -15,
            child: Icon(icon, size: 100, color: Colors.white.withOpacity(0.15)),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(title, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500)),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}