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
      backgroundColor: const Color(0xFFF8F9FE), 
      drawer: isMobile ? const DashboardSidebar(isDrawer: true) : null,
      appBar: isMobile ? _buildMobileAppBar(context) : null,
      
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667EEA).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
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
          icon: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 24),
          label: const Text(
            "Input AI", 
            style: TextStyle(
              color: Colors.white, 
              fontWeight: FontWeight.bold,
              fontSize: 15,
              letterSpacing: 0.5,
            )
          ),
        ),
      ),

      body: Row(
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
                            _CardData("Total Produk", "$totalProduk", Icons.inventory_2_rounded, [const Color(0xFF667EEA), const Color(0xFF764BA2)]),
                            _CardData("Stok Menipis", "$stokTipis", Icons.warning_amber_rounded, [const Color(0xFFFA709A), const Color(0xFFFF6B9D)]),
                            _CardData("Terjual", "$totalTerjual", Icons.shopping_bag_rounded, [const Color(0xFF43E97B), const Color(0xFF38F9D7)]),
                            _CardData("Pendapatan", currencyFormat.format(totalPendapatan), Icons.paid_rounded, [const Color(0xFFFEAC5E), const Color(0xFFC779D0)]),
                          ];

                          return LayoutBuilder(
                            builder: (context, constraints) {
                              int crossAxisCount = constraints.maxWidth > 1200 ? 4 : constraints.maxWidth > 700 ? 2 : 1;
                              double aspectRatio = constraints.maxWidth > 1200 ? 1.6 : constraints.maxWidth > 700 ? 1.8 : 2.2;

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
    );
  }

  PreferredSizeWidget _buildMobileAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        "Dashboard", 
        style: TextStyle(
          color: Color(0xFF2D3748), 
          fontWeight: FontWeight.bold,
          fontSize: 20,
        )
      ),
      leading: Builder(
        builder: (context) => Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FE),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.menu_rounded, color: Color(0xFF667EEA)),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        )
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () => _showLogoutConfirmation(context),
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFFC8181)),
          ),
        )
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
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
                  Text(
                    "Halo, ${snapshot.data ?? 'Admin'}! 👋", 
                    style: const TextStyle(
                      fontSize: 32, 
                      fontWeight: FontWeight.w800, 
                      color: Color(0xFF2D3748),
                      letterSpacing: -0.5,
                      height: 1.2,
                    )
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE0E7FF), Color(0xFFFCE7F3)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "✨ Ringkasan toko Anda hari ini", 
                      style: TextStyle(
                        fontSize: 14, 
                        color: Color(0xFF667EEA),
                        fontWeight: FontWeight.w600,
                      )
                    ),
                  ),
                ],
              );
            }
          ),
          
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF5F5), Color(0xFFFED7D7)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFC8181).withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
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
                      Icon(Icons.logout_rounded, color: Color(0xFFFC8181), size: 20),
                      SizedBox(width: 10),
                      Text(
                        "Keluar", 
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          color: Color(0xFFFC8181),
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
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.trending_up_rounded, color: Color(0xFF667EEA), size: 24),
                      SizedBox(width: 8),
                      Text(
                        "Analitik Penjualan", 
                        style: TextStyle(
                          fontSize: 20, 
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        )
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E7FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "7 Hari Terakhir", 
                      style: TextStyle(
                        fontSize: 12, 
                        color: Color(0xFF667EEA),
                        fontWeight: FontWeight.w600,
                      )
                    ),
                  ),
                ],
              ),
              if(!isMobile) 
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                  child: Row(
                    children: const [
                      Icon(Icons.fiber_manual_record, color: Colors.white, size: 10),
                      SizedBox(width: 6),
                      Text(
                        "Realtime", 
                        style: TextStyle(
                          color: Colors.white, 
                          fontWeight: FontWeight.bold, 
                          fontSize: 12,
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
              colors: [Color(0xFFFFFFFF), Color(0xFFFFFAF5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFEAC5E).withOpacity(0.08),
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
                  Row(
                    children: const [
                      Icon(Icons.receipt_long_rounded, color: Color(0xFFFEAC5E), size: 22),
                      SizedBox(width: 8),
                      Text(
                        "Transaksi Terkini", 
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E7FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: const [
                          Text(
                            "Lihat Semua", 
                            style: TextStyle(
                              color: Color(0xFF667EEA), 
                              fontWeight: FontWeight.bold, 
                              fontSize: 12,
                            )
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, color: Color(0xFF667EEA), size: 14),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              
              if (recentTrans.isEmpty)
                 Container(
                   padding: const EdgeInsets.all(32),
                   decoration: BoxDecoration(
                     color: const Color(0xFFFAFBFF),
                     borderRadius: BorderRadius.circular(16),
                   ),
                   child: const Center(
                     child: Column(
                       children: [
                         Icon(Icons.receipt_outlined, color: Color(0xFFCBD5E0), size: 48),
                         SizedBox(height: 12),
                         Text(
                           "Belum ada transaksi", 
                           style: TextStyle(
                             color: Color(0xFFA0AEC0),
                             fontWeight: FontWeight.w500,
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
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: t.method == 'cash' 
                          ? [const Color(0xFFF0FFF4), const Color(0xFFC6F6D5)]
                          : [const Color(0xFFEBF8FF), const Color(0xFFBEE3F8)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: t.method == 'cash' 
                          ? const Color(0xFF9AE6B4) 
                          : const Color(0xFF90CDF4), 
                        width: 1.5
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48, 
                          height: 48, 
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: t.method == 'cash'
                                ? [const Color(0xFF48BB78), const Color(0xFF38A169)]
                                : [const Color(0xFF4299E1), const Color(0xFF3182CE)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: (t.method == 'cash' 
                                  ? const Color(0xFF48BB78) 
                                  : const Color(0xFF4299E1)).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ), 
                          child: Icon(
                            t.method == 'cash' ? Icons.payments_rounded : Icons.qr_code_rounded, 
                            color: Colors.white, 
                            size: 24
                          )
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "ID #${DateFormat('mmss').format(date)}", 
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 14,
                                  color: Color(0xFF2D3748),
                                )
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded, 
                                    color: Colors.grey[600], 
                                    size: 12
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat('HH:mm').format(date), 
                                    style: TextStyle(
                                      color: Colors.grey[600], 
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    )
                                  ),
                                ],
                              ),
                            ]
                          )
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            currency, 
                            style: const TextStyle(
                              fontWeight: FontWeight.w900, 
                              fontSize: 14, 
                              color: Color(0xFF2D3748),
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
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
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
                children: const [
                  Icon(Icons.shopping_basket_rounded, color: Color(0xFF667EEA), size: 22),
                  SizedBox(width: 8),
                  Text(
                    "Produk Terbaru", 
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    )
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              if (recentProducts.isEmpty)
                 Container(
                   padding: const EdgeInsets.all(32),
                   decoration: BoxDecoration(
                     color: const Color(0xFFFAFBFF),
                     borderRadius: BorderRadius.circular(16),
                   ),
                   child: const Center(
                     child: Column(
                       children: [
                         Icon(Icons.inventory_2_outlined, color: Color(0xFFCBD5E0), size: 48),
                         SizedBox(height: 12),
                         Text(
                           "Belum ada produk", 
                           style: TextStyle(
                             color: Color(0xFFA0AEC0),
                             fontWeight: FontWeight.w500,
                           )
                         ),
                       ],
                     ),
                   ),
                 )
              else
                ...recentProducts.map((product) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFAFBFF), Color(0xFFEDF2F7)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52, 
                        height: 52, 
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF667EEA).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.inventory_2_rounded, 
                          color: Colors.white, 
                          size: 24
                        )
                      ),
                      const SizedBox(width: 14),
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
                                fontSize: 14,
                                color: Color(0xFF2D3748),
                              )
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: product.stock <= 5 
                                  ? const Color(0xFFFED7D7) 
                                  : const Color(0xFFC6F6D5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    product.stock <= 5 
                                      ? Icons.warning_amber_rounded 
                                      : Icons.check_circle_rounded,
                                    size: 12,
                                    color: product.stock <= 5 
                                      ? const Color(0xFFFC8181) 
                                      : const Color(0xFF48BB78),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Stok: ${product.stock}", 
                                    style: TextStyle(
                                      color: product.stock <= 5 
                                        ? const Color(0xFFFC8181) 
                                        : const Color(0xFF48BB78), 
                                      fontSize: 11, 
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          "Rp${product.price}", 
                          style: const TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 13, 
                            color: Color(0xFF2D3748),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          title: Row(
            children: const [
              Icon(Icons.logout_rounded, color: Color(0xFFFC8181), size: 28),
              SizedBox(width: 12),
              Text(
                "Konfirmasi Logout",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: const Text(
              "Apakah anda yakin ingin keluar dari aplikasi?",
              style: TextStyle(
                color: Color(0xFF718096),
                fontSize: 15,
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.all(20),
          actions: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Text(
                    "Batal", 
                    style: TextStyle(
                      color: Color(0xFF718096),
                      fontWeight: FontWeight.w600,
                    )
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFC8181), Color(0xFFF56565)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFC8181).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)
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
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Text(
                    "Keluar", 
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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