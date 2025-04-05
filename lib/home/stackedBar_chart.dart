import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class WeeklyBarChart extends StatelessWidget {
  final Map<String, Map<String, double>> weeklyFootprint;

  const WeeklyBarChart({Key? key, required this.weeklyFootprint})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> days = weeklyFootprint.keys.toList().reversed.toList();

    // Total footprint per category
    double totalJourney = 0;
    double totalFood = 0;
    double totalEnergy = 0;
    double total = 0;

    List<ChartSampleData> chartData = days.map((day) {
      Map<String, double> categories =
          weeklyFootprint[day] ?? {'Journey': 0, 'Food': 0, 'Energy': 0};

      double journey = categories['Journey'] ?? 0;
      double food = categories['Food'] ?? 0;
      double energy = categories['Energy'] ?? 0;
      total += journey + food + energy;

      // Accumulate total footprint per category
      totalJourney += journey;
      totalFood += food;
      totalEnergy += energy;

      return ChartSampleData(
        x: day,
        y: journey,
        yValue: food,
        secondSeriesYValue: energy,
      );
    }).toList();

    return Column(
      children: [
        const SizedBox(height: 25),
        Text(
          "Weekly Carbon Footprint",
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(color: Colors.black),
        ),
        const SizedBox(height: 25),
        Expanded(
            child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: _buildStackedColumnChart(chartData, total, context),
        )),
        const SizedBox(height: 25),
        Text(
          "Energy Weekly Footprint: ${totalEnergy.toStringAsFixed(2)} kg",
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(color: Colors.black),
        ),
        Text(
          "Food Weekly Footprint: ${totalFood.toStringAsFixed(2)} kg",
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(color: Colors.black),
        ),
        Text(
          "Journey Weekly Footprint: ${totalJourney.toStringAsFixed(2)} kg",
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(color: Colors.black),
        ),
        const SizedBox(height: 25),
      ],
    );
  }

  Widget _buildStackedColumnChart(
      List<ChartSampleData> chartData, double total, BuildContext context) {
    if (total == 0) {
      return Text(
        "No record yet. \nTrack your carbon activity now!",
        style: Theme.of(context)
            .textTheme
            .headlineLarge!
            .copyWith(color: Colors.white),
        textAlign: TextAlign.center,
      );
    } else {
      return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SfCartesianChart(
            plotAreaBorderWidth: 0,
            // title: ChartTitle(text: 'Weekly Carbon Footprint'),
            legend: Legend(
                isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
            primaryXAxis:
                const CategoryAxis(majorGridLines: MajorGridLines(width: 0)),
            primaryYAxis: const NumericAxis(
              axisLine: AxisLine(width: 0),
              labelFormat: '{value} kg',
              majorTickLines: MajorTickLines(size: 0),
            ),
            series: <StackedColumnSeries<ChartSampleData, String>>[
              StackedColumnSeries<ChartSampleData, String>(
                dataSource: chartData,
                xValueMapper: (ChartSampleData data, _) => data.x,
                yValueMapper: (ChartSampleData data, _) => data.y,
                name: 'Journey',
                color: Theme.of(context).colorScheme.surface,
              ),
              StackedColumnSeries<ChartSampleData, String>(
                dataSource: chartData,
                xValueMapper: (ChartSampleData data, _) => data.x,
                yValueMapper: (ChartSampleData data, _) => data.yValue,
                name: 'Food',
                color: Theme.of(context).colorScheme.tertiary,
              ),
              StackedColumnSeries<ChartSampleData, String>(
                dataSource: chartData,
                xValueMapper: (ChartSampleData data, _) => data.x,
                yValueMapper: (ChartSampleData data, _) =>
                    data.secondSeriesYValue,
                name: 'Energy',
                color: Theme.of(context).colorScheme.surfaceBright,
              ),
            ],
            tooltipBehavior: TooltipBehavior(enable: true),
          ));
    }
  }
}

class ChartSampleData {
  final String x;
  final double y;
  final double yValue;
  final double secondSeriesYValue;

  ChartSampleData({
    required this.x,
    required this.y,
    required this.yValue,
    required this.secondSeriesYValue,
  });
}
