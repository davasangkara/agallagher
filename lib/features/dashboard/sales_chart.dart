import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SalesChart extends StatelessWidget {
  final List<FlSpot> spots;
  final bool isMobile; // Tambahkan parameter ini untuk penyesuaian font size

  const SalesChart({super.key, required this.spots, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    // Warna tema grafik
    const Color chartColor = Color(0xFF6C63FF);

    // Tentukan Gradient Area di bawah garis
    final gradientColors = [
      chartColor.withOpacity(0.3),
      chartColor.withOpacity(0.0),
    ];

    return AspectRatio(
      aspectRatio: isMobile ? 1.5 : 2.5, // Lebih lebar di Desktop
      child: LineChart(
        LineChartData(
          // Grid Tipis Horizontal saja
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.1),
                strokeWidth: 1,
              );
            },
          ),

          // Sembunyikan Border Kotak Luar
          borderData: FlBorderData(show: false),

          // Judul / Label Sumbu
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  // Contoh label hari (Sen, Sel, Rab...)
                  // Anda bisa sesuaikan ini dengan data real nanti
                  const days = [
                    'Min',
                    'Sen',
                    'Sel',
                    'Rab',
                    'Kam',
                    'Jum',
                    'Sab',
                  ];
                  final index = value.toInt();
                  if (index >= 0 && index < days.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        days[index],
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ), // Hide Y Axis for cleaner look
          ),

          // Interaksi Sentuh / Hover
          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => Colors.blueGrey.withOpacity(0.9),
              tooltipRoundedRadius: 8,
              tooltipPadding: const EdgeInsets.all(8),
              tooltipMargin: 8,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    '${spot.y.toInt()} Transaksi',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),

          // Data Grafik
          lineBarsData: [
            LineChartBarData(
              spots: spots.isEmpty
                  ? [const FlSpot(0, 0)]
                  : spots, // Prevent crash if empty
              isCurved: true,
              color: chartColor,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false), // Hide dots for cleaner look
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

          // Rentang Data (Opsional, agar grafik tidak mentok atas/bawah)
          minY: 0,
        ),
      ),
    );
  }
}
