import 'package:Lucerna/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:Lucerna/main.dart';
import '../calculator/history_provider.dart';

class dashboard extends StatefulWidget {
  const dashboard({super.key});

  @override
  State<dashboard> createState() => _dashboardState();
}

class _dashboardState extends State<dashboard> {
  // Variable to track the selected timeframe
  String _footprint_selected = 'Monthly';
  String _offset_selected = 'Monthly';
  double totalCarbonFootprint = 0;

  // Image paths or widgets for each timeframe
  final Map<String, String> _footprint_Images = {
    'Daily': 'assets/daily_footprint.png', // Replace with actual asset path
    'Weekly': 'assets/weekly_footprint.png', // Replace with actual asset path
    'Monthly': 'assets/monthly_footprint.png', // Replace with actual asset path
  };

  final Map<String, String> _offset_Images = {
    'Daily': 'assets/daily_offset.png', // Replace with actual asset path
    'Weekly': 'assets/weekly_offset.png', // Replace with actual asset path
    'Monthly': 'assets/monthly_offset.png', // Replace with actual asset path
  };

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() {
    final historyProvider =
        Provider.of<HistoryProvider>(context, listen: false);
    for (var record in historyProvider.history) {
      totalCarbonFootprint +=
          double.tryParse(record['carbonFootprint'] ?? '0') ?? 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme,
      home: Scaffold(
        appBar: CommonAppBar(title: "Dashboard"),
        bottomNavigationBar:
            CommonBottomNavigationBar(selectedTab: BottomTab.dashboard),
      ),
    );
  }
}
