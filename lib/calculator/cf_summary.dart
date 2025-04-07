import 'dart:typed_data';

import 'package:Lucerna/auth_provider.dart';
import 'package:Lucerna/class_models/carbon_record.dart';
import 'package:Lucerna/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Lucerna/calculator/carbon_footprint.dart';
import 'package:Lucerna/chat/chat.dart';
import 'package:Lucerna/calculator/history_provider.dart';
import 'package:Lucerna/firestore_service.dart';

class CFSummaryPage extends StatelessWidget {
  final String title;
  final String category;
  final String carbon_footprint;
  final String suggestion;
  final String? vehicleType;
  final String? distance;
  final String? energyUsed;
  final Uint8List? image; // food image

  // Constructor to receive the data
  CFSummaryPage({super.key, 
    required this.title,
    required this.category,
    required this.carbon_footprint,
    required this.suggestion,
    required this.vehicleType,
    required this.distance,
    required this.energyUsed,
    this.image,
  });

  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final historyProvider = Provider.of<HistoryProvider>(context);
    return
        //       MaterialApp(
        // theme: appTheme,
        // home:
        Scaffold(
      backgroundColor: Color.fromRGBO(200, 200, 200, 1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Review\nCarbon Footprint',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium!
                        .copyWith(color: Color.fromRGBO(0, 0, 0, 0.5)),
                  ),
                  const SizedBox(height: 50),
                  Center(
                    child: Container(
                      // padding: EdgeInsets.all(10.0),
                      // margin:
                      //     EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 25),
                          // Image section
                          image != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.memory(
                                    image!,
                                    height: 200,
                                    width: 300,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(),
                          const SizedBox(height: 25),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildRecordButton(context, 'Cancel',
                                  Theme.of(context).colorScheme.tertiary),
                              _buildRecordButton(context, 'Add Record',
                                  Theme.of(context).colorScheme.secondary),
                            ],
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Text(
                            'Carbon Footprint',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(color: Colors.black),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              '$carbon_footprint kg',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                            ),
                          ),
                          _buildCategoryLabel(context, category),
                          Divider(
                            color: Theme.of(context).colorScheme.primary,
                            thickness: 1.0,
                            height: 41.0,
                            indent: MediaQuery.of(context).size.width * 0.05,
                            endIndent: MediaQuery.of(context).size.width * 0.05,
                          ),
                          Text(
                            suggestion,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => chat(
                            carbonFootprint: carbon_footprint,
                            title: title,
                            category: category,
                            vehicleType: vehicleType,
                            suggestion: suggestion,
                            distance: distance,
                            energyUsed: energyUsed,
                            showAddRecordButton: true,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.primary, // Button color
                      padding: EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20), // Larger padding
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8), // Rounded corners
                      ),
                    ),
                    child: Text(
                      'Discuss with AI Chat',
                      style: Theme.of(context).textTheme.displayLarge!.copyWith(
                            color: Colors.white,
                            fontSize: 20, // Larger font size
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      appBar: CommonAppBar(title: "Track Carbon Footprint"),
      bottomNavigationBar:
          CommonBottomNavigationBar(selectedTab: BottomTab.tracker),
    );
    // );
  }

  Widget _buildRecordButton(
    BuildContext context,
    String label,
    Color color,
  ) {
    return Container(
      constraints: const BoxConstraints(minHeight: 35),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.3,
        child: ElevatedButton(
          onPressed: () async {
            if (label == 'Cancel') {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CarbonFootprintTracker()));
            }
            if (label == 'Add Record') {
              Provider.of<HistoryProvider>(context, listen: false).addRecord(
                  title,
                  category,
                  carbon_footprint,
                  suggestion,
                  vehicleType,
                  distance,
                  energyUsed);

              // Add record to Firestore
              final user =
                  Provider.of<AuthProvider>(context, listen: false).user;
              if (user != null) {
                print('user.uid: ${user.uid}');
                try {
                  await _firestoreService.addCarbonFootprint(
                    user.uid,
                    CarbonRecord(
                      title: title,
                      type: category,
                      value: carbon_footprint,
                      dateTime: DateTime.now(),
                      suggestion: suggestion,
                      vehicleType: vehicleType,
                      distance: distance,
                      energyUsed: energyUsed,
                    ),
                  );
                  print('Record added successfully to Firestore');
                } catch (e) {
                  print('Failed to add record to Firestore: $e');
                }
              } else {
                print('No user is currently signed in.');
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CarbonFootprintTracker()),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: EdgeInsets.symmetric(vertical: 8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .displayLarge!
                .copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryLabel(BuildContext context, String label) {
    Color color;
    switch (label) {
      case ('Food'):
        color = Theme.of(context).colorScheme.tertiary;
        break;

      case ('Journey'):
        color = Theme.of(context).colorScheme.surface;
        break;

      case ('Energy'):
        color = Theme.of(context).colorScheme.surfaceBright;
        break;

      default:
        color = Colors.black;
        break;
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: Container(
        width: 100,
        color: color,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .displayLarge!
              .copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
