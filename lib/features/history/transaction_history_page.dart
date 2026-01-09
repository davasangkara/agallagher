import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart'; 
import '../../data/models/transaction_model.dart';
import '../dashboard/dashboard_page.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  Future<void> _sendReportToAdmin() async {
    final box = Hive.box<TransactionModel>('transactions');
    final today = DateTime.now();
    
    final todayTrans = box.values.where((t) {
      DateTime tDate = t.time is int ? DateTime.fromMillisecondsSinceEpoch(t.time as int) : t.time as DateTime;
      return tDate.day == today.day && tDate.month == today.month && tDate.year == today.year;
    }).toList();

    if (todayTrans.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Belum ada transaksi hari ini."),
          backgroundColor: Colors.orange[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    int totalOmzet = todayTrans.fold(0, (sum, t) => sum + t.total);
    int totalCash = todayTrans.where((t) => t.method == 'cash').fold(0, (sum, t) => sum + t.total);
    int totalQris = todayTrans.where((t) => t.method == 'qris').fold(0, (sum, t) => sum + t.total);
    String dateStr = DateFormat('dd MMM yyyy', 'id_ID').format(today);

    String message = 
      "*LAPORAN HARIAN POS*\n"
      "📅 $dateStr\n"
      "---------------------------\n"
      "💰 Omzet: Rp ${NumberFormat('#,###', 'id_ID').format(totalOmzet)}\n"
      "📝 Transaksi: ${todayTrans.length}\n"
      "---------------------------\n"
      "💵 Tunai: Rp ${NumberFormat('#,###', 'id_ID').format(totalCash)}\n"
      "💳 QRIS: Rp ${NumberFormat('#,###', 'id_ID').format(totalQris)}\n"
      "---------------------------\n"
      "Report from App.";

    String phoneNumber = "6289517705267"; 
    
    final Uri url = Uri.parse("whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}");

    try {
      if (await canLaunchUrl(url)) await launchUrl(url);
      else await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Gagal membuka WhatsApp"),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<TransactionModel>('transactions');
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER DENGAN GRADIENT MODERN
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF667EEA),
                    const Color(0xFF764BA2),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Container(
                padding: EdgeInsets.fromLTRB(24, isMobile ? 16 : 24, 24, 24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Tombol Back dengan efek glassmorphism
                        InkWell(
                          onTap: () => Navigator.pushReplacement(
                            context, 
                            MaterialPageRoute(builder: (_) => const DashboardPage())
                          ),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded, 
                              size: 20, 
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Riwayat Transaksi", 
                                style: TextStyle(
                                  fontSize: 24, 
                                  fontWeight: FontWeight.w900, 
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Semua aktivitas penjualan Anda",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.85),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // TOMBOL LAPOR BOS - WhatsApp Style
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF25D366).withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _sendReportToAdmin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF25D366),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 14 : 20, 
                                vertical: 14,
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.send_rounded, size: 18),
                                if (!isMobile) ...[
                                  const SizedBox(width: 10),
                                  const Text(
                                    "Lapor Bos", 
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // SEARCH BAR MODERN
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: "Cari ID Transaksi...",
                          hintStyle: TextStyle(
                            color: Colors.grey[400], 
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(12),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF667EEA).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.search_rounded, 
                              color: Color(0xFF667EEA),
                              size: 20,
                            ),
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 20),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                  color: Colors.grey[400],
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16, 
                            horizontal: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // LIST TRANSAKSI
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: box.listenable(),
                builder: (context, Box<TransactionModel> box, _) {
                  var transactions = box.values.toList().reversed.toList();

                  if (_searchQuery.isNotEmpty) {
                    transactions = transactions.where((t) {
                      final date = t.time is int 
                          ? DateTime.fromMillisecondsSinceEpoch(t.time as int) 
                          : t.time as DateTime;
                      return DateFormat('yyyyMMddHHmmss').format(date).contains(_searchQuery);
                    }).toList();
                  }

                  if (transactions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.receipt_long_rounded, 
                              size: 72, 
                              color: Colors.grey[300],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _searchQuery.isEmpty 
                                ? "Belum ada riwayat transaksi" 
                                : "Tidak ada hasil pencarian",
                            style: TextStyle(
                              color: Colors.grey[600], 
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchQuery.isEmpty
                                ? "Transaksi akan muncul di sini"
                                : "Coba kata kunci lain",
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: transactions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (ctx, i) => _ModernTransactionCard(
                      transaction: transactions[i],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernTransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  const _ModernTransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    DateTime date = transaction.time is int 
        ? DateTime.fromMillisecondsSinceEpoch(transaction.time as int) 
        : transaction.time as DateTime;
    
    final currency = NumberFormat.currency(
      locale: 'id_ID', 
      symbol: 'Rp ', 
      decimalDigits: 0,
    );
    final idTransaksi = DateFormat('HH:mm').format(date);
    final fullDate = DateFormat('d MMM yyyy', 'id_ID').format(date);

    final isCash = transaction.method == 'cash';
    final accentColor = isCash 
        ? const Color(0xFF10B981) 
        : const Color(0xFF3B82F6);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          leading: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accentColor,
                  accentColor.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              isCash ? Icons.payments_rounded : Icons.qr_code_2_rounded, 
              color: Colors.white, 
              size: 24,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  currency.format(transaction.total), 
                  style: const TextStyle(
                    fontWeight: FontWeight.w900, 
                    fontSize: 18, 
                    color: Color(0xFF1F2937),
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  idTransaksi, 
                  style: TextStyle(
                    fontSize: 12, 
                    fontWeight: FontWeight.bold, 
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded, 
                  size: 13, 
                  color: Colors.grey[400],
                ),
                const SizedBox(width: 6),
                Text(
                  fullDate, 
                  style: TextStyle(
                    color: Colors.grey[500], 
                    fontSize: 13, 
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          children: [
            const SizedBox(height: 8),
            Divider(height: 1, thickness: 1, color: Colors.grey[100]),
            const SizedBox(height: 16),
            
            // Item List dengan spacing lebih baik
            ...transaction.items.asMap().entries.map((entry) {
              final item = entry.value;
              final isLast = entry.key == transaction.items.length - 1;
              
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8, 
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${item.qty}x",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.productName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      currency.format(item.price * item.qty),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 20),
            
            // Payment Detail Box dengan design lebih elegan
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFF9FAFB),
                    const Color(0xFFF3F4F6),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  _detailRow("Dibayar", currency.format(transaction.paid)),
                  if (transaction.change > 0) ...[
                    const SizedBox(height: 8),
                    Divider(height: 1, color: Colors.grey[300]),
                    const SizedBox(height: 8),
                    _detailRow(
                      "Kembali", 
                      currency.format(transaction.change), 
                      isBold: true,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            fontSize: isBold ? 16 : 14,
            color: isBold ? const Color(0xFF10B981) : const Color(0xFF374151),
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}