import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../data/models/product_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/local/shared_pref_service.dart';
import '../../app.dart';
import 'dashboard_sidebar.dart';
import 'dashboard_card.dart';
import '../report/sales_line_chart.dart'; 
import '../product/smart_add_product_dialog.dart'; 
import '../history/transaction_history_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;
    
    final productBox = Hive.box<Product>('products');
    final transactionBox = Hive.box<TransactionModel>('transactions');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: isMobile ? const DashboardSidebar(isDrawer: true) : null,
      appBar: isMobile ? _buildMobileAppBar(context) : null,
      
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFD946EF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B5CF6).withOpacity(0.5),
              blurRadius: 24,
              offset: const Offset(0, 12),
              spreadRadius: -4,
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const SmartAddProductDialog(),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
          ),
          label: const Text(
            "Input AI", 
            style: TextStyle(
              color: Colors.white, 
              fontWeight: FontWeight.bold,
              fontSize: 15,
              letterSpacing: 0.8,
            )
          ),
        ),
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFF5F7FA),
              const Color(0xFFE8EEFF).withOpacity(0.3),
            ],
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMobile) const DashboardSidebar(),
            
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 20 : 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isMobile) _buildHeader(context),
                    
                    SizedBox(height: isMobile ? 24 : 32),

                    ValueListenableBuilder(
                      valueListenable: transactionBox.listenable(),
                      builder: (context, Box<TransactionModel> transBox, _) {
                        return ValueListenableBuilder(
                          valueListenable: productBox.listenable(),
                          builder: (context, Box<Product> prodBox, _) {
                            final totalProduk = prodBox.length;
                            final stokTipis = prodBox.values.where((p) => p.stock <= 5).length;
                            
                            int totalTerjual = 0;
                            for (var t in transBox.values) {
                              for (var item in t.items) totalTerjual += item.qty;
                            }

                            final totalPendapatan = transBox.values.fold(0, (sum, t) => sum + t.total);
                            final currencyFormat = NumberFormat.compactSimpleCurrency(locale: 'id_ID'); 
                            
                            final cards = [
                              _CardData("Total Produk", "$totalProduk", Icons.inventory_2_rounded, [const Color(0xFF6366F1), const Color(0xFF8B5CF6)]),
                              _CardData("Stok Menipis", "$stokTipis", Icons.warning_amber_rounded, [const Color(0xFFEC4899), const Color(0xFFF97316)]),
                              _CardData("Terjual", "$totalTerjual", Icons.shopping_bag_rounded, [const Color(0xFF10B981), const Color(0xFF14B8A6)]),
                              _CardData("Pendapatan", currencyFormat.format(totalPendapatan), Icons.paid_rounded, [const Color(0xFFF59E0B), const Color(0xFFEF4444)]),
                            ];

                            return LayoutBuilder(
                              builder: (context, constraints) {
                                int crossAxisCount = constraints.maxWidth > 1200 ? 4 : constraints.maxWidth > 700 ? 2 : 1;
                                double aspectRatio = constraints.maxWidth > 1200 ? 1.5 : constraints.maxWidth > 700 ? 1.7 : 2.0;

                                return GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount, 
                                    crossAxisSpacing: 20, 
                                    mainAxisSpacing: 20, 
                                    childAspectRatio: aspectRatio,
                                  ),
                                  itemCount: cards.length,
                                  itemBuilder: (context, index) {
                                    return DashboardCard(
                                      title: cards[index].title,
                                      value: cards[index].value,
                                      icon: cards[index].icon,
                                      colors: cards[index].colors,
                                      onTap: () {},
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                    
                    SizedBox(height: isMobile ? 28 : 32),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 1000) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 2, child: _buildChartSection(isMobile)),
                              const SizedBox(width: 24),
                              Expanded(
                                flex: 1, 
                                child: Column(
                                  children: [
                                    _buildRecentTransactions(transactionBox),
                                    const SizedBox(height: 24),
                                    _buildRecentProducts(productBox),
                                  ],
                                )
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              _buildChartSection(isMobile),
                              const SizedBox(height: 24),
                              _buildRecentTransactions(transactionBox),
                              const SizedBox(height: 24),
                              _buildRecentProducts(productBox),
                            ],
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildMobileAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFFAFBFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: const Text(
        "Dashboard", 
        style: TextStyle(
          color: Color(0xFF1E293B), 
          fontWeight: FontWeight.bold,
          fontSize: 20,
          letterSpacing: -0.5,
        )
      ),
      leading: Builder(
        builder: (context) => Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEEF2FF), Color(0xFFF5F3FF)],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.2)),
          ),
          child: IconButton(
            icon: const Icon(Icons.menu_rounded, color: Color(0xFF6366F1)),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        )
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFEF2F2), Color(0xFFFEE2E2)],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.2)),
          ),
          child: IconButton(
            onPressed: () => _showLogoutConfirmation(context),
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
          ),
        )
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFFAFBFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            blurRadius: 32,
            offset: const Offset(0, 8),
            spreadRadius: -8,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 16,
            offset: const Offset(-8, -8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FutureBuilder<String>(
            future: SharedPrefService.getName(),
            builder: (context, snapshot) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Text(
                          "👋", 
                          style: TextStyle(fontSize: 28),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Selamat Datang,",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            snapshot.data ?? 'Admin', 
                            style: const TextStyle(
                              fontSize: 28, 
                              fontWeight: FontWeight.w800, 
                              color: Color(0xFF1E293B),
                              letterSpacing: -0.5,
                            )
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFDDD6FE).withOpacity(0.5),
                          const Color(0xFFFAE8FF).withOpacity(0.5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFF8B5CF6).withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.auto_graph_rounded, 
                            size: 14, 
                            color: Color(0xFF8B5CF6),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Ringkasan toko Anda hari ini", 
                          style: TextStyle(
                            fontSize: 13, 
                            color: Color(0xFF7C3AED),
                            fontWeight: FontWeight.w700,
                          )
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
          ),
          
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFEF2F2), Color(0xFFFEE2E2)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFEF4444).withOpacity(0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEF4444).withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _showLogoutConfirmation(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  child: Row(
                    children: const [
                      Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
                      SizedBox(width: 10),
                      Text(
                        "Keluar", 
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          color: Color(0xFFEF4444),
                          fontSize: 15,
                        )
                      )
                    ]
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildChartSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFFAFBFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.08),
            blurRadius: 32,
            offset: const Offset(0, 8),
            spreadRadius: -8,
          ),
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.trending_up_rounded, 
                          color: Colors.white, 
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Analitik Penjualan", 
                        style: TextStyle(
                          fontSize: 22, 
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                          letterSpacing: -0.5,
                        )
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFDDD6FE).withOpacity(0.5),
                          const Color(0xFFFAE8FF).withOpacity(0.5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF8B5CF6).withOpacity(0.2),
                      ),
                    ),
                    child: const Text(
                      "📅 7 Hari Terakhir", 
                      style: TextStyle(
                        fontSize: 12, 
                        color: Color(0xFF7C3AED),
                        fontWeight: FontWeight.w700,
                      )
                    ),
                  ),
                ],
              ),
              if(!isMobile) 
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF14B8A6)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Realtime", 
                        style: TextStyle(
                          color: Colors.white, 
                          fontWeight: FontWeight.bold, 
                          fontSize: 13,
                          letterSpacing: 0.5,
                        )
                      ),
                    ],
                  ),
                )
            ],
          ),
          const SizedBox(height: 32),
          
          SizedBox(
            height: isMobile ? 220 : 320, 
            child: LayoutBuilder(
              builder: (ctx, constraints) => SalesLineChart(isMobile: isMobile)
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(Box<TransactionModel> box) {
    return ValueListenableBuilder(
      valueListenable: box.listenable(),
      builder: (context, Box<TransactionModel> box, _) {
        final recentTrans = box.values.toList().reversed.take(5).toList(); 

        return Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFFFFF), Color(0xFFFFFBF5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withOpacity(0.08),
                blurRadius: 32,
                offset: const Offset(0, 8),
                spreadRadius: -8,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF59E0B).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded, 
                          color: Colors.white, 
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Transaksi Terkini", 
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                          letterSpacing: -0.3,
                        )
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (_) => const TransactionHistoryPage())
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFDDD6FE).withOpacity(0.5),
                            const Color(0xFFFAE8FF).withOpacity(0.5),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF8B5CF6).withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: const [
                          Text(
                            "Lihat Semua", 
                            style: TextStyle(
                              color: Color(0xFF7C3AED), 
                              fontWeight: FontWeight.bold, 
                              fontSize: 12,
                            )
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward_rounded, color: Color(0xFF7C3AED), size: 14),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),
              
              if (recentTrans.isEmpty)
                 Container(
                   padding: const EdgeInsets.all(40),
                   decoration: BoxDecoration(
                     gradient: LinearGradient(
                       colors: [
                         const Color(0xFFF8FAFC),
                         const Color(0xFFF1F5F9).withOpacity(0.5),
                       ],
                     ),
                     borderRadius: BorderRadius.circular(20),
                     border: Border.all(
                       color: const Color(0xFFE2E8F0).withOpacity(0.5),
                       width: 2,
                     ),
                   ),
                   child: Center(
                     child: Column(
                       children: [
                         Container(
                           padding: const EdgeInsets.all(20),
                           decoration: BoxDecoration(
                             gradient: LinearGradient(
                               colors: [
                                 const Color(0xFFF1F5F9),
                                 const Color(0xFFE2E8F0).withOpacity(0.5),
                               ],
                             ),
                             shape: BoxShape.circle,
                           ),
                           child: const Icon(
                             Icons.receipt_outlined, 
                             color: Color(0xFFCBD5E0), 
                             size: 40,
                           ),
                         ),
                         const SizedBox(height: 16),
                         const Text(
                           "Belum ada transaksi", 
                           style: TextStyle(
                             color: Color(0xFF94A3B8),
                             fontWeight: FontWeight.w600,
                             fontSize: 15,
                           )
                         ),
                       ],
                     ),
                   ),
                 )
              else
                ...recentTrans.map((t) {
                  DateTime date = t.time is int 
                    ? DateTime.fromMillisecondsSinceEpoch(t.time as int) 
                    : t.time as DateTime;
                  final currency = NumberFormat.compactSimpleCurrency(locale: 'id_ID').format(t.total);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: t.method == 'cash' 
                          ? [const Color(0xFFECFDF5), const Color(0xFFD1FAE5)]
                          : [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: t.method == 'cash' 
                          ? const Color(0xFF10B981).withOpacity(0.3) 
                          : const Color(0xFF3B82F6).withOpacity(0.3), 
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (t.method == 'cash' 
                            ? const Color(0xFF10B981) 
                            : const Color(0xFF3B82F6)).withOpacity(0.1),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52, 
                          height: 52, 
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: t.method == 'cash'
                                ? [const Color(0xFF10B981), const Color(0xFF059669)]
                                : [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: (t.method == 'cash' 
                                  ? const Color(0xFF10B981) 
                                  : const Color(0xFF3B82F6)).withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ), 
                          child: Icon(
                            t.method == 'cash' ? Icons.payments_rounded : Icons.qr_code_rounded, 
                            color: Colors.white, 
                            size: 26,
                          )
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "ID #${DateFormat('mmss').format(date)}", 
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 15,
                                  color: Color(0xFF1E293B),
                                )
                              ),
                              const SizedBox(height: 6),
                                                            Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFF64748B).withOpacity(0.1),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded, 
                                      color: const Color(0xFF64748B), 
                                      size: 12,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat('HH:mm').format(date), 
                                      style: const TextStyle(
                                        color: Color(0xFF64748B), 
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      )
                                    ),
                                  ],
                                ),
                              ),
                            ]
                          )
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            currency, 
                            style: const TextStyle(
                              fontWeight: FontWeight.w900, 
                              fontSize: 14, 
                              color: Color(0xFF1E293B),
                            )
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      }
    );
  }

  Widget _buildRecentProducts(Box<Product> box) {
    return ValueListenableBuilder(
      valueListenable: box.listenable(),
      builder: (context, Box<Product> box, _) {
        final recentProducts = box.values.toList().reversed.take(4).toList(); 

        return Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFFFFF), Color(0xFFF5FAFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.08),
                blurRadius: 32,
                offset: const Offset(0, 8),
                spreadRadius: -8,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.shopping_basket_rounded, 
                      color: Colors.white, 
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Produk Terbaru", 
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.3,
                    )
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              if (recentProducts.isEmpty)
                 Container(
                   padding: const EdgeInsets.all(40),
                   decoration: BoxDecoration(
                     gradient: LinearGradient(
                       colors: [
                         const Color(0xFFF8FAFC),
                         const Color(0xFFF1F5F9).withOpacity(0.5),
                       ],
                     ),
                     borderRadius: BorderRadius.circular(20),
                     border: Border.all(
                       color: const Color(0xFFE2E8F0).withOpacity(0.5),
                       width: 2,
                     ),
                   ),
                   child: Center(
                     child: Column(
                       children: [
                         Container(
                           padding: const EdgeInsets.all(20),
                           decoration: BoxDecoration(
                             gradient: LinearGradient(
                               colors: [
                                 const Color(0xFFF1F5F9),
                                 const Color(0xFFE2E8F0).withOpacity(0.5),
                               ],
                             ),
                             shape: BoxShape.circle,
                           ),
                           child: const Icon(
                             Icons.inventory_2_outlined, 
                             color: Color(0xFFCBD5E0), 
                             size: 40,
                           ),
                         ),
                         const SizedBox(height: 16),
                         const Text(
                           "Belum ada produk", 
                           style: TextStyle(
                             color: Color(0xFF94A3B8),
                             fontWeight: FontWeight.w600,
                             fontSize: 15,
                           )
                         ),
                       ],
                     ),
                   ),
                 )
              else
                ...recentProducts.map((product) => Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFAFBFF), Color(0xFFF1F5F9)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF6366F1).withOpacity(0.2), 
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56, 
                        height: 56, 
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.inventory_2_rounded, 
                          color: Colors.white, 
                          size: 26,
                        )
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name, 
                              maxLines: 1, 
                              overflow: TextOverflow.ellipsis, 
                              style: const TextStyle(
                                fontWeight: FontWeight.bold, 
                                fontSize: 15,
                                color: Color(0xFF1E293B),
                              )
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: product.stock <= 5 
                                    ? [const Color(0xFFFEE2E2), const Color(0xFFFECDD3)]
                                    : [const Color(0xFFD1FAE5), const Color(0xFFA7F3D0)],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: product.stock <= 5 
                                    ? const Color(0xFFEF4444).withOpacity(0.3)
                                    : const Color(0xFF10B981).withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    product.stock <= 5 
                                      ? Icons.warning_amber_rounded 
                                      : Icons.check_circle_rounded,
                                    size: 14,
                                    color: product.stock <= 5 
                                      ? const Color(0xFFEF4444) 
                                      : const Color(0xFF10B981),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Stok: ${product.stock}", 
                                    style: TextStyle(
                                      color: product.stock <= 5 
                                        ? const Color(0xFFEF4444) 
                                        : const Color(0xFF10B981), 
                                      fontSize: 12, 
                                      fontWeight: FontWeight.bold,
                                    )
                                  ),
                                ],
                              ),
                            ),
                          ]
                        )
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          "Rp${product.price}", 
                          style: const TextStyle(
                            fontWeight: FontWeight.w900, 
                            fontSize: 13, 
                            color: Color(0xFF1E293B),
                          )
                        ),
                      ),
                    ],
                  ),
                )),
            ],
          ),
        );
      }
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFEE2E2), Color(0xFFFECDD3)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.logout_rounded, 
                  color: Color(0xFFEF4444), 
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              const Text(
                "Konfirmasi Logout",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: const Text(
              "Apakah anda yakin ingin keluar dari aplikasi?",
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.all(24),
          actions: [
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                ),
              ),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    "Batal", 
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    )
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)
                  ),
                  elevation: 0,
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await SharedPrefService.logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context, 
                      MaterialPageRoute(builder: (_) => const MyApp()), 
                      (_) => false
                    );
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    "Keluar", 
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    )
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CardData {
  final String title; 
  final String value; 
  final IconData icon; 
  final List<Color> colors;
  _CardData(this.title, this.value, this.icon, this.colors);
}