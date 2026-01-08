import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SalesLineChart extends StatefulWidget {
  const SalesLineChart({super.key});

  @override
  State<SalesLineChart> createState() => _SalesLineChartState();
}

class _SalesLineChartState extends State<SalesLineChart> {
  // Warna Gradasi Chart yang Aesthetic (Purple -> Blue)
  final List<Color> gradientColors = [
    const Color(0xFF6C63FF),
    const Color(0xFF4834D4),
  ];

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 10,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.15),
              strokeWidth: 1,
              dashArray: [6, 6],
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: 1,
              getTitlesWidget: bottomTitleWidgets,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 10,
              getTitlesWidget: leftTitleWidgets,
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 50,
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 15),
              FlSpot(1, 28),
              FlSpot(2, 22),
              FlSpot(3, 38),
              FlSpot(4, 30),
              FlSpot(5, 45),
              FlSpot(6, 40),
            ],
            isCurved: true,
            curveSmoothness: 0.35,
            gradient: LinearGradient(colors: gradientColors),
            barWidth: 4,
            isStrokeCapRound: true,
            
            // Dot Data
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 5,
                  color: Colors.white,
                  strokeWidth: 3,
                  strokeColor: const Color(0xFF6C63FF),
                );
              },
            ),
            
            // Area Bawah
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6C63FF).withOpacity(0.25),
                  const Color(0xFF6C63FF).withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        
        // --- PERBAIKAN DI SINI ---
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            // Ganti getTooltipColor menjadi tooltipBgColor
            tooltipBgColor: const Color(0xFF2D3436), 
            tooltipRoundedRadius: 12,
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            tooltipMargin: 16,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                return LineTooltipItem(
                  '${touchedSpot.y.toInt()} Sales',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Courier',
                    fontSize: 12
                  ),
                );
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
        ),
        // -------------------------
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 12,
      color: Colors.grey,
    );
    
    final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    Widget text = Text('');
    
    if (value.toInt() >= 0 && value.toInt() < days.length) {
      text = Text(days[value.toInt()], style: style);
    }

    return SideTitleWidget(axisSide: meta.axisSide, space: 10, child: text);
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 12,
      color: Colors.grey,
    );
    
    if (value == 0) return const SizedBox();
    
    return Text('${value.toInt()}', style: style, textAlign: TextAlign.left);
  }
}