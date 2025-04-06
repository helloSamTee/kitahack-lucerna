import 'dart:math';
import 'package:Lucerna/common_widget.dart';
import 'package:Lucerna/home/visualisation_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:Lucerna/main.dart';
import '../calculator/history_provider.dart';
import 'package:Lucerna/auth_provider.dart' as LucernaAuthProvider;

class dashboard extends StatefulWidget {
  const dashboard({super.key});

  @override
  State<dashboard> createState() => _dashboardState();
}

class _dashboardState extends State<dashboard> {
  String username = "";
  // Variable to track the selected timeframe
  double totalCarbonFootprint = 0;
  double totalCarbonOffset = 0;
  Map<String, Map<String, double>> weeklyFootprint = {
    for (var i = 0; i < 7; i++)
      DateFormat('E').format(DateTime.now().subtract(Duration(days: i))): {
        'Journey': 0,
        'Food': 0,
        'Energy': 0,
      }
  };
  Map<String, Map<String, double>> weeklyOffset = {};

  Map<String, String?>? record;

  @override
  void initState() {
    super.initState();
    final authProvider =
        Provider.of<LucernaAuthProvider.AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      username = authProvider.user!.username;
    }
    _initializeRecord();
    _createWeeklyOffset();
  }

  void _initializeRecord() {
    final historyProvider =
        Provider.of<HistoryProvider>(context, listen: false);

    if (historyProvider.history.isEmpty) {
      print('No records found in history.');
      return; // Exit early to prevent errors
    }

    record = historyProvider.history[0];
    _createWeeklyFootprint(historyProvider);
  }

  void _createWeeklyFootprint(HistoryProvider historyProvider) {
    DateFormat inputFormat = DateFormat("MMMM d, yyyy 'at' hh:mm:ss a 'UTC'");

    for (var record in historyProvider.history) {
      String? dateStr = record['dateTime'];
      String? category = record['category'];
      double footprint = double.tryParse(record['carbonFootprint'] ?? '0') ?? 0;

      totalCarbonFootprint += footprint;

      if (dateStr != null && category != null) {
        try {
          DateTime parsedDate = inputFormat.parse(dateStr);
          String formattedDay = DateFormat('E').format(parsedDate);

          if (weeklyFootprint.containsKey(formattedDay)) {
            weeklyFootprint[formattedDay]?[category] =
                (weeklyFootprint[formattedDay]?[category] ?? 0) + footprint;
          }
        } catch (e) {
          print("Error parsing date: $dateStr, Error: $e");
        }
      }
    }
  }

  void _createWeeklyOffset() {
    weeklyFootprint.forEach((day, categories) {
      weeklyOffset[day] = categories.map((category, value) {
        double offsetValue = value * getRandomMultiplier();
        return MapEntry(category, offsetValue);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    totalCarbonOffset = totalCarbonFootprint * 0.75;
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: appTheme,
        home: Scaffold(
          appBar: CommonAppBar(title: "Dashboard"),
          bottomNavigationBar:
              CommonBottomNavigationBar(selectedTab: BottomTab.dashboard),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi $username 🤩',
                      // textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineMedium!.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                    ),
                    // Text(
                    //   "Start building a greener future with Lucerna today!",
                    //   // textAlign: TextAlign.center,
                    //   style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    //         color: Theme.of(context).colorScheme.primary,
                    //       ),
                    // ),
                    const SizedBox(height: 25),
                    CarbonVisualizationScreen(
                        weeklyFootprint: weeklyFootprint,
                        weeklyOffset: weeklyOffset),
                    const SizedBox(height: 25),
                    Center(
                        child: Text(
                      'Way to go! With Lucerna, you have tracked ${totalCarbonFootprint.toStringAsFixed(2)} kg of carbon footprint and offset ${totalCarbonOffset.toStringAsFixed(2)} kg. \nSmall steps, big impact!  🌍🌱',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Color.fromRGBO(100, 100, 100, 1),
                          ),
                      textAlign: TextAlign.center,
                    )),
                    const SizedBox(height: 25),
                    Center(
                      child: Text(
                        'Latest Carbon Activity',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 20),
                      ),
                    ),
                    const SizedBox(height: 10),

                    _buildLatestCarbonRecord(record, context),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  // Returns corresponding icon for each category
  Image _getCategoryImg(String category) {
    switch (category) {
      case 'Food':
        return Image.asset(
          'assets/food.png',
          height: 45,
          width: 45,
        );
      case 'Journey':
        return Image.asset(
          'assets/journey.png',
          height: 45,
          width: 45,
        );
      case 'Energy':
        return Image.asset(
          'assets/energy.png',
          height: 45,
          width: 45,
        );
      default:
        return Image.asset(
          'assets/temparature.png',
          height: 45,
          width: 45,
        );
    }
  }

// Widget to build the latest activity card dynamically
  Widget _buildLatestCarbonRecord(
      Map<String, String?>? record, BuildContext context) {
    // double cardWidth =
    //     MediaQuery.of(context).size.width * 0.9; // 80% of screen width

    if (record != null) {
      final String sub;
      switch (record['category']) {
        case 'Journey':
          sub =
              '${record['category']} - ${record['distance']}km (${record['vehicleType']})';
          break;
        case 'Energy':
          sub = '${record['category']} - ${record['energyUsed']}kWh';
          break;
        default:
          sub = '${record['category']}';
          break;
      }

      return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            // width: cardWidth,
            color: Theme.of(context).colorScheme.surface,
            child: ListTile(
              horizontalTitleGap: 30,
              leading: _getCategoryImg(record['category']!),
              title: Text(
                record['title']!,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Colors.black),
              ),
              subtitle: Text(
                sub,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: Colors.black),
              ),
              trailing: Text(
                '${record['carbonFootprint']!} kg',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Colors.black),
              ),
            ),
          ),
        ),
      );
    } else {
      return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            // width: cardWidth,
            color: Theme.of(context).colorScheme.surface,
            child: ListTile(
              horizontalTitleGap: 30,
              leading: Icon(
                Icons.question_mark_rounded,
                color: Theme.of(context).colorScheme.tertiary,
                size: 45,
              ),
              title: Text(
                "No Record Found",
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Colors.black),
              ),
              subtitle: Text(
                "Try adding a carbon footprint record now!",
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: Colors.black),
              ),
            ),
          ),
        ),
      );
    }
  }
}

// Function to generate random multiplier between 0.2 and 0.5
double getRandomMultiplier() {
  return Random().nextDouble() * (0.5 - 0.2) + 0.2;
}
