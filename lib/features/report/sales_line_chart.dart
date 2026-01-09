import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/transaction_model.dart';

class SalesLineChart extends StatefulWidget {
  const SalesLineChart({super.key});

  @override
  State<SalesLineChart> createState() => _SalesLineChartState();
}

class _SalesLineChartState extends State<SalesLineChart> {
  final List<Color> gradientColors = [const Color(0xFF6C63FF), const Color(0xFF4834D4)];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<TransactionModel>('transactions').listenable(),
      builder: (context, Box<TransactionModel> box, _) {
        // --- LOGIKA MENGHITUNG DATA GRAFIK ---
        // 1. Siapkan 7 slot (0=Senin ... 6=Minggu)
        List<double> weeklySales = List.filled(7, 0.0);
        
        // 2. Loop semua transaksi
        for (var transaction in box.values) {
          // Ambil DateTime dari int timestamp
          final date = DateTime.fromMillisecondsSinceEpoch(transaction.time);
          
          // Cek apakah transaksi terjadi di minggu ini (opsional, saat ini kita ambil semua by day)
          // weekday: 1=Senin ... 7=Minggu. Kita butuh index 0-6.
          int dayIndex = date.weekday - 1; 
          
          // Tambahkan total penjualan ke hari tersebut
          weeklySales[dayIndex] += 1; // Opsional: Ganti += transaction.total untuk Grafik Nominal Rupiah
        }

        // 3. Konversi ke FlSpot
        List<FlSpot> spots = [];
        double maxY = 0;
        for (int i = 0; i < 7; i++) {
          spots.add(FlSpot(i.toDouble(), weeklySales[i]));
          if (weeklySales[i] > maxY) maxY = weeklySales[i];
        }
        // Tambahkan buffer untuk tampilan grafik agar tidak mentok atas
        maxY = maxY == 0 ? 10 : maxY * 1.2; 

        return LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true, drawVerticalLine: false, horizontalInterval: maxY / 5,
              getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.15), strokeWidth: 1, dashArray: [6, 6]),
            ),
            titlesData: FlTitlesData(
              show: true, rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32, interval: 1, getTitlesWidget: bottomTitleWidgets)),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: maxY / 5, getTitlesWidget: leftTitleWidgets, reservedSize: 40)),
            ),
            borderData: FlBorderData(show: false),
            minX: 0, maxX: 6, minY: 0, maxY: maxY,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true, curveSmoothness: 0.35,
                gradient: LinearGradient(colors: gradientColors),
                barWidth: 4, isStrokeCapRound: true,
                dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 5, color: Colors.white, strokeWidth: 3, strokeColor: const Color(0xFF6C63FF))),
                belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [const Color(0xFF6C63FF).withOpacity(0.25), const Color(0xFF6C63FF).withOpacity(0.0)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
              ),
            ],
            // TOOLTIP FIX
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                tooltipBgColor: const Color(0xFF2D3436),
                tooltipRoundedRadius: 12,
                tooltipPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                tooltipMargin: 16,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((LineBarSpot touchedSpot) {
                    return LineTooltipItem(
                      '${touchedSpot.y.toInt()} Trx',
                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Courier', fontSize: 12),
                    );
                  }).toList();
                },
              ),
              handleBuiltInTouches: true,
            ),
          ),
        );
      },
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey);
    final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    if (value.toInt() >= 0 && value.toInt() < days.length) {
      return SideTitleWidget(axisSide: meta.axisSide, space: 10, child: Text(days[value.toInt()], style: style));
    }
    return const SizedBox();
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey);
    if (value == 0) return const SizedBox();
    return Text('${value.toInt()}', style: style, textAlign: TextAlign.left);
  }
}