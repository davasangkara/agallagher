import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../data/models/transaction_model.dart';

class SalesLineChart extends StatelessWidget {
  final bool isMobile;

  const SalesLineChart({super.key, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<TransactionModel>('transactions').listenable(),
      builder: (context, Box<TransactionModel> box, _) {
        
        // 1. Generate Data 7 Hari Terakhir
        List<FlSpot> spots = _generateLast7DaysData(box);

        const Color chartColor = Color(0xFF6C63FF);
        final gradientColors = [
          chartColor.withOpacity(0.3),
          chartColor.withOpacity(0.0),
        ];

        return AspectRatio(
          aspectRatio: isMobile ? 1.7 : 2.5,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1000000, 
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.withOpacity(0.1),
                  strokeWidth: 1,
                ),
              ),
              
              borderData: FlBorderData(show: false),
              
              titlesData: FlTitlesData(
                show: true,
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final date = DateTime.now().subtract(Duration(days: 6 - value.toInt()));
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          DateFormat('E', 'id_ID').format(date),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // === PERBAIKAN 1: SINTAKS TOOLTIP VERSI LAMA ===
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: Colors.blueGrey.withOpacity(0.9), // Ganti getTooltipColor jadi ini
                  tooltipRoundedRadius: 8,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final val = NumberFormat.compactSimpleCurrency(locale: 'id_ID').format(spot.y);
                      return LineTooltipItem(
                        val,
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    }).toList();
                  },
                ),
              ),

              lineBarsData: [
                LineChartBarData(
                  spots: spots.isEmpty ? [const FlSpot(0, 0)] : spots,
                  isCurved: true,
                  color: chartColor,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(radius: 4, color: Colors.white, strokeWidth: 2, strokeColor: chartColor);
                  }),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
              
              minY: 0,
            ),
          ),
        );
      }
    );
  }

  // --- LOGIKA HITUNG DATA (7 HARI TERAKHIR) ---
  List<FlSpot> _generateLast7DaysData(Box<TransactionModel> box) {
    List<FlSpot> spots = [];
    final today = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final targetDate = today.subtract(Duration(days: 6 - i));
      
      // Filter transaksi pada tanggal tersebut
      final transactions = box.values.where((t) {
        // === PERBAIKAN 2: KONVERSI INT KE DATETIME ===
        // Karena t.time adalah int (timestamp), kita ubah dulu jadi DateTime
        // Jika t.time ternyata DateTime, hapus .fromMillisecondsSinceEpoch
        // Tapi berdasarkan error log Kakak, t.time itu int.
        
        DateTime date;
        if (t.time is int) {
           date = DateTime.fromMillisecondsSinceEpoch(t.time as int);
        } else if (t.time is DateTime) {
           date = t.time as DateTime;
        } else {
           return false; // Tipe data tidak dikenali
        }

        return date.year == targetDate.year && 
               date.month == targetDate.month && 
               date.day == targetDate.day;
      });

      double totalDay = transactions.fold(0.0, (sum, t) => sum + t.total);
      spots.add(FlSpot(i.toDouble(), totalDay));
    }
    return spots;
  }
}