import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class WeeklyLineChart extends StatelessWidget {
  final Map<String, Map<String, double>> weeklyFootprint;
  final Map<String, Map<String, double>> weeklyOffset;

  const WeeklyLineChart({
    Key? key,
    required this.weeklyFootprint,
    required this.weeklyOffset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> days = _getLast7Days();
    List<double> footprintValues = _calculateDailyTotal(weeklyFootprint, days);
    List<double> offsetValues = _calculateDailyTotal(weeklyOffset, days);
    double totalFootprint = footprintValues.reduce((a, b) => a + b);
    double totalOffset = offsetValues.reduce((a, b) => a + b);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 25),
        Text(
          "Weekly's Carbon Activity",
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(color: Colors.black),
        ),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegend(
                context, Theme.of(context).colorScheme.tertiary, "Footprint"),
            const SizedBox(width: 10),
            _buildLegend(
                context, Theme.of(context).colorScheme.secondary, "Offset"),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: _buildLineChart(
              days, footprintValues, offsetValues, totalFootprint, context),
        ),
        const SizedBox(height: 25),
        Text(
          "Weekly Carbon Footprint: ${totalFootprint.toStringAsFixed(2)} kg",
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(color: Colors.black),
        ),
        Text(
          "Weekly Carbon Offset: ${totalOffset.toStringAsFixed(2)} kg",
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(color: Colors.black),
        ),
        const SizedBox(height: 25),
      ],
    );
  }

  Widget _buildLegend(BuildContext context, Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: Colors.black)),
      ],
    );
  }

  Widget _buildLineChart(List<String> days, List<double> footprint,
      List<double> offset, double totalFootprint, BuildContext context) {
    if (totalFootprint == 0) {
      return Text(
        "No record yet. Track your carbon activity now!",
        style: Theme.of(context)
            .textTheme
            .headlineLarge!
            .copyWith(color: Colors.white),
      );
    } else {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true, drawVerticalLine: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    int index = value.toInt();
                    if (index >= 0 && index < days.length) {
                      return Text(days[index],
                          style: const TextStyle(fontSize: 12));
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      _formatYAxis(value),
                      style: const TextStyle(fontSize: 12),
                    );
                  },
                ),
              ),
              topTitles: AxisTitles(
                // Disable top titles to remove numbers on top
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: AxisTitles(
                // Optionally hide right-side titles if needed
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: true),
            lineBarsData: [
              _buildLineChartBar(footprint,
                  Theme.of(context).colorScheme.tertiary, "Footprint"),
              _buildLineChartBar(
                  offset, Theme.of(context).colorScheme.secondary, "Offset"),
            ],
          ),
        ),
      );
    }
  }

  LineChartBarData _buildLineChartBar(
      List<double> data, Color color, String label) {
    return LineChartBarData(
      spots: List.generate(
          data.length, (index) => FlSpot(index.toDouble(), data[index])),
      isCurved: true,
      color: color,
      barWidth: 3,
      dotData: FlDotData(show: true),
      belowBarData: BarAreaData(show: false),
    );
  }

  List<String> _getLast7Days() {
    return List.generate(
        7,
        (i) => DateFormat('E')
            .format(DateTime.now().subtract(Duration(days: 6 - i))));
  }

  List<double> _calculateDailyTotal(
      Map<String, Map<String, double>> data, List<String> days) {
    return days.map((day) {
      if (data.containsKey(day)) {
        return data[day]!.values.reduce((a, b) => a + b);
      }
      return 0.0;
    }).toList();
  }

  String _formatYAxis(double value) {
    if (value >= 1000) {
      return "${(value / 1000).toStringAsFixed(1)}K"; // Convert large numbers to K format
    }
    return value.toStringAsFixed(0);
  }
}
