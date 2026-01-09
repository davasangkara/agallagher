import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../core/services/export_service.dart'; // Import Service Baru
import '../../data/models/transaction_model.dart';
import '../dashboard/dashboard_page.dart';
import 'sales_line_chart.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  bool _isExporting = false; // Loading state

  Future<void> _handleExport() async {
    setState(() => _isExporting = true);
    
    try {
      await ExportService.exportTransactionToExcel();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil membuat Excel! Silakan pilih aplikasi untuk berbagi.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal export: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Intl.defaultLocale = 'id_ID';
    final transactionBox = Hive.box<TransactionModel>('transactions');

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
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
                    onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardPage())),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black87),
                    ),
                  ),
                  
                  // TOMBOL DOWNLOAD EXCEL (ACTIVE)
                  InkWell(
                    onTap: _isExporting ? null : _handleExport, // Panggil fungsi export
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00B894), // Warna Hijau Excel
                        borderRadius: BorderRadius.circular(14), 
                        boxShadow: [BoxShadow(color: const Color(0xFF00B894).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]
                      ),
                      child: _isExporting 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Row(
                            children: [
                              Icon(Icons.file_download_outlined, size: 20, color: Colors.white),
                              SizedBox(width: 8),
                              Text("Export Excel", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                            ],
                          ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              const Text('Laporan Penjualan', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF2D3436), letterSpacing: -0.5)),
              const SizedBox(height: 6),
              Text('Ringkasan performa toko Anda', style: TextStyle(fontSize: 15, color: Colors.grey[500], fontWeight: FontWeight.w500)),

              const SizedBox(height: 32),

              // ================= SUMMARY CARDS =================
              ValueListenableBuilder(
                valueListenable: transactionBox.listenable(),
                builder: (context, Box<TransactionModel> box, _) {
                  final int totalRevenue = box.values.fold(0, (sum, item) => sum + item.total);
                  final int totalTransactions = box.length;
                  final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

                  return Row(
                    children: [
                      Expanded(child: _GradientSummaryCard(title: 'Pendapatan', value: formatter.format(totalRevenue), icon: Icons.auto_graph_rounded, colors: const [Color(0xFF00B894), Color(0xFF55EFC4)])),
                      const SizedBox(width: 20),
                      Expanded(child: _GradientSummaryCard(title: 'Transaksi', value: '$totalTransactions', icon: Icons.shopping_bag_rounded, colors: const [Color(0xFF0984E3), Color(0xFF74B9FF)])),
                    ],
                  );
                }
              ),

              const SizedBox(height: 32),

              // ================= CHART SECTION =================
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: Colors.blueGrey.withOpacity(0.08), blurRadius: 30, offset: const Offset(0, 10))]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Analitik Grafik", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF2D3436))), SizedBox(height: 4), Text("Data Realtime 7 Hari", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold))]),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: const Color(0xFF6C63FF).withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: const Row(children: [Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF6C63FF)), SizedBox(width: 6), Text("Minggu Ini", style: TextStyle(fontSize: 12, color: Color(0xFF6C63FF), fontWeight: FontWeight.bold))]))
                      ],
                    ),
                    const SizedBox(height: 40),
                    const SizedBox(height: 320, child: SalesLineChart()),
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

class _GradientSummaryCard extends StatelessWidget {
  final String title; final String value; final IconData icon; final List<Color> colors;
  const _GradientSummaryCard({required this.title, required this.value, required this.icon, required this.colors});
  @override Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 140), 
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight), boxShadow: [BoxShadow(color: colors.first.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))]),
      child: Stack(children: [
        Positioned(right: -15, top: -15, child: Icon(icon, size: 100, color: Colors.white.withOpacity(0.15))),
        Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: Colors.white, size: 20)),
          const SizedBox(height: 24),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white))), const SizedBox(height: 4), Text(title, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500))])
        ]))
      ]),
    );
  }
}