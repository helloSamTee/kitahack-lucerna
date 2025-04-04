import 'package:Lucerna/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Lucerna/calculator/energy_record.dart';
import 'package:Lucerna/calculator/food_record.dart';
import 'package:Lucerna/calculator/journey_record.dart';
import 'package:provider/provider.dart';
import 'history_provider.dart'; // Import the provider
import 'package:Lucerna/auth_provider.dart'; // Import firebase provider

class CarbonFootprintTracker extends StatefulWidget {
  @override
  _CarbonFootprintTrackerState createState() => _CarbonFootprintTrackerState();
}

class _CarbonFootprintTrackerState extends State<CarbonFootprintTracker> {
  // // List to store history records dynamically.
  // List<Map<String, String>> _history = [];

  // // Method to add new record based on category type
  // void _addRecord(String category) {
  //   setState(() {
  //     _history.add({
  //       'title': 'Title',
  //       'category': category, // Example value
  //       'carbonFootprint': '10 kg', // Example value
  //     });
  //   });
  // }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final historyProvider =
          Provider.of<HistoryProvider>(context, listen: false);
      if (authProvider.user != null) {
        historyProvider.loadHistoryFromFirestore(authProvider.user!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final historyProvider = Provider.of<HistoryProvider>(context);

    return
        //   MaterialApp(
        // theme: appTheme,
        // home:
        Scaffold(
      backgroundColor: Color.fromRGBO(
          200, 200, 200, 1), // const Color.fromRGBO(173, 191, 127, 1),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            Text(
              'Add a record of the below categories:',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: Color.fromRGBO(0, 0, 0, 0.5)),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCategoryButton('Food',
                    Theme.of(context).colorScheme.tertiary, 'assets/food.png'),
                _buildCategoryButton(
                    'Journey',
                    Theme.of(context).colorScheme.surface,
                    'assets/journey.png'),
                _buildCategoryButton(
                    'Energy',
                    Theme.of(context).colorScheme.surfaceBright,
                    'assets/energy.png'),
              ],
            ),
            const SizedBox(height: 50),
            Expanded(
              child: _buildHistorySection(context, historyProvider),
            ),
          ],
        ),
      ),
      appBar: CommonAppBar(title: "Carbon Footprint"),
      bottomNavigationBar:
          CommonBottomNavigationBar(selectedTab: BottomTab.tracker),
    );
    // );
  }

  // Helper function to build category buttons
  Widget _buildCategoryButton(String label, Color color, String img) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          img,
          height: 75,
          width: 75,
        ),
        SizedBox(
          height: 15,
        ),
        Container(
          width: 90,
          child: ElevatedButton(
            onPressed: () {
              if (label == 'Journey') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => journeyRecord()),
                );
              } else if (label == 'Energy') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => energyRecord()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => foodRecord()),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .displayLarge!
                  .copyWith(color: Colors.white),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildHistorySection(
      BuildContext context, HistoryProvider historyProvider) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(50),
          topRight: Radius.circular(50),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 10,
                spreadRadius: 10,
                offset:
                    const Offset(0, -10), // Shadow at the top of the section
              ),
            ],
          ),
          constraints: const BoxConstraints(minHeight: 200),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 20, 30, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'History',
                  //textAlign: TextAlign.center,
                  style: GoogleFonts.ptSansCaption(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                // Text(
                //   'View your recent carbon footprint records here.',
                //   style: TextStyle(
                //     fontSize: 16,
                //     color: Colors.black54,
                //   ),
                //),
                Expanded(
                  child: _buildHistoryList(historyProvider),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

  // Widget to build the history list dynamically
  Widget _buildHistoryList(HistoryProvider historyProvider) {
    final history = historyProvider.history;

    return ListView.builder(
      itemCount: history.length,
      itemBuilder: (context, index) {
        final record = history[index];
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
        return Card.filled(
            elevation: 0,
            // margin: const EdgeInsets.symmetric(vertical: 5.0),
            child: Column(
              children: [
                ListTile(
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
                Divider(
                  color: Color.fromRGBO(
                      173, 191, 127, 1), // Sets the color of the line
                  thickness: 1.0, // Thickness of the line
                  height: 1.0, // Vertical space around the divider
                  indent: 0, // Spacing from the left
                  endIndent: 0, // Spacing from the right
                ),
                // Container(
                //   height: 1.0,
                //   width: MediaQuery.of(context).size.width,
                //   color: Color.fromRGBO(173, 191, 127, 1),
                // ),
              ],
            ));
      },
    );
  }
}

// SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       const Text(
//                         'History',
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.green,
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       Expanded(
//                         child: _buildHistoryList(),
//                       ),
//                     ],
//                   ),
//                 ),
