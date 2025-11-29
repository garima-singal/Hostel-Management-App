import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AttendanceChart extends StatelessWidget {
  final List<BarChartGroupData> barChartData;

  const AttendanceChart({super.key, required this.barChartData});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          barGroups: barChartData,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.toInt()} days',
                  TextStyle(
                    color: Colors.white,
                    backgroundColor: Colors.indigo[400], // <-- Correct way
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

