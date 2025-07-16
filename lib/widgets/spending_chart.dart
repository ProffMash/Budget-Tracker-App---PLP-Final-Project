import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SpendingChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const SpendingChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(
          enabled: false,
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 4,
                    child: Text(
                      data[index]['name'],
                      style: const TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        barGroups: data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: item['spent'],
                color: Colors.blue,
                width: 16,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
