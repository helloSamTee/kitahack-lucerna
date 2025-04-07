import 'package:Lucerna/home/donut_chart.dart';
import 'package:Lucerna/home/line_chart.dart';
import 'package:Lucerna/home/stackedBar_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CarbonVisualizationScreen extends StatelessWidget {
  Map<String, Map<String, double>> weeklyFootprint;
  Map<String, Map<String, double>> weeklyOffset;

  CarbonVisualizationScreen({super.key, 
    required this.weeklyFootprint,
    required this.weeklyOffset,
  });

  double _calculateTodayData(Map<String, Map<String, double>> weeklyData) {
    String today = DateFormat('E').format(DateTime.now());
    return (weeklyData[today]?['Journey'] ?? 0) +
        (weeklyData[today]?['Food'] ?? 0) +
        (weeklyData[today]?['Energy'] ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    PageController pageController = PageController();
    double todayFootprint = _calculateTodayData(weeklyFootprint);
    double todayOffset = _calculateTodayData(weeklyOffset);

    Widget donut = DailyDonutChart(
        todayFootprint: todayFootprint, todayOffset: todayOffset);
    Widget line = WeeklyLineChart(
        weeklyFootprint: weeklyFootprint, weeklyOffset: weeklyOffset);
    Widget stacked = WeeklyBarChart(weeklyFootprint: weeklyFootprint);

    return SizedBox(
      height: 350, // Adjust height to fit content
      child: PageView(
        controller: pageController,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _buildVisualizationCard(donut),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _buildVisualizationCard(line),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _buildVisualizationCard(stacked),
          ),
        ],
      ),
    );
  }

  Widget _buildVisualizationCard(Widget visualisation) {
    return SizedBox(
      height: 300,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Color(0xFFB7C49D), // Color.fromRGBO(200, 200, 200, 1),
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        child: visualisation,
      ),
    );
  }
}
