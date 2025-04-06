import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DailyDonutChart extends StatelessWidget {
  double todayFootprint;
  double todayOffset;

  DailyDonutChart({required this.todayFootprint, required this.todayOffset});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 25),
        Text(
          "Today's Carbon Activity",
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(color: Colors.black),
        ),
        const SizedBox(height: 25),
        Expanded(
            child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: _drawPieChart(todayFootprint, context),
        )),
        const SizedBox(height: 25),
        Text(
          "Today's Carbon Footprint: ${todayFootprint.toStringAsFixed(2)} kg",
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(color: Colors.black),
        ),
        Text(
          "Today's Carbon Offset: ${todayOffset.toStringAsFixed(2)} kg",
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(color: Colors.black),
        ),
        const SizedBox(height: 25),
      ],
    );
  }

  Widget _drawPieChart(double todayFootprint, BuildContext context) {
    if (todayFootprint == 0) {
      return Text(
        "No record yet. \nTrack your carbon activity now!",
        style: Theme.of(context)
            .textTheme
            .headlineLarge!
            .copyWith(color: Colors.white),
        textAlign: TextAlign.center,
      );
    } else {
      return PieChart(PieChartData(
        sections: [
          PieChartSectionData(
            value: todayFootprint,
            title: "Footprint",
            titleStyle: TextStyle(color: Colors.white),
            color: Theme.of(context).colorScheme.tertiary,
            radius: 60,
          ),
          PieChartSectionData(
            value: todayOffset,
            title: "Offset",
            titleStyle: TextStyle(color: Colors.white),
            color: Theme.of(context).colorScheme.secondary,
            radius: 60,
          ),
        ],
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ));
    }
  }
}
