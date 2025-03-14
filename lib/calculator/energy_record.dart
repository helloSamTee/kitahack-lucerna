import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Lucerna/calculator/cf_summary.dart';
import 'package:Lucerna/chat/chat.dart';
import 'package:Lucerna/home/dashboard.dart';
import 'package:Lucerna/ecolight/lamp_stat.dart';
import 'package:Lucerna/main.dart';
import 'package:Lucerna/calculator/carbon_footprint.dart';
import 'common_widget.dart';
import 'carbon_sutra.dart';

class energyRecord extends StatefulWidget {
  @override
  _EnergyRecordState createState() => _EnergyRecordState();
}

class _EnergyRecordState extends State<energyRecord> {
  final _formKey = GlobalKey<FormState>(); // Key to manage form state
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _energyUsedController = TextEditingController();

  final List<String> countries = [
    "Australia",
    "Austria",
    "Bangladesh",
    "Belgium",
    "Bhutan",
    "Brunei",
    "Bulgaria",
    "Cambodia",
    "Canada",
    "China",
    "Croatia",
    "Cyprus",
    "Czechia",
    "Denmark",
    "Estonia",
    "EU-27",
    "Finland",
    "France",
    "Germany",
    "Greece",
    "Hong Kong",
    "Hungary",
    "Iceland",
    "India",
    "Indonesia",
    "Ireland",
    "Italy",
    "Japan",
    "Laos",
    "Latvia",
    "Lithuania",
    "Luxembourg",
    "Macao",
    "Malaysia",
    "Maldives",
    "Malta",
    "Mongolia",
    "Myanmar",
    "Nepal",
    "Netherlands",
    "New Zealand",
    "North Korea",
    "Norway",
    "Pakistan",
    "Papua New Guinea",
    "Philippines",
    "Poland",
    "Portugal",
    "Qatar",
    "Romania",
    "Singapore",
    "Slovakia",
    "Slovenia",
    "South Korea",
    "Spain",
    "Sri Lanka",
    "Sweden",
    "Taiwan",
    "Thailand",
    "Turkey",
    "UK",
    "USA",
    "Vietnam"
  ];

  String selectedCountry = "Malaysia";

  final CarbonSutraAPI api = CarbonSutraAPI();
  // Future<String> calculateCarbonFootprintFromEnergy(
  //     String country, String energyUsed) async {
  //   double kwh = double.tryParse(energyUsed) ?? 0;

  //   final data = await api.getElectricityUsage(country, kwh);
  //   if (data != null) {
  //     return data['co2e_kg'];
  //   } else {
  //     return "0";
  //   }
  // }

  Future<String> calculateCarbonFootprintFromEnergy(
      String country, String energyUsed) async {
    final response = await api.calcElectricity(
      electricityValue: energyUsed,
      countryName: country,
    );

    if (response != null) {
      return response['data']['co2e_kg'].toString();
    } else {
      return "0";
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme,
      home: Scaffold(
        backgroundColor: const Color.fromRGBO(173, 191, 127, 1),
        bottomNavigationBar: _buildBottomNavigationBar(context),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
            child: Form(
              key: _formKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Add Electricity Consumption Record',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge!
                                  .copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 50),
                            buildTextField(context, _titleController, 'Title'),
                            const SizedBox(height: 25),
                            buildDropdown(
                                items: countries,
                                label: "Country",
                                defaultValue: selectedCountry,
                                onChanged: (value) {
                                  setState(() {
                                    selectedCountry =
                                        value; // ✅ Updates selected value correctly
                                  });
                                }),
                            const SizedBox(height: 25),
                            buildTextField(context, _energyUsedController,
                                'Electricity Consumption (in kWh)',
                                isNumeric: true),
                            // const SizedBox(height: 20),
                            // _buildAttachmentSection(),
                            // const SizedBox(height: 40),,))],
                          ],
                        ),
                      ),
                    ),
                    _buildSubmitButton(),
                  ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        constraints: const BoxConstraints(minHeight: 50),
        child: SizedBox(
          width: 175,
          child: ElevatedButton(
              onPressed: () async {
                // Validate the form
                if (_formKey.currentState!.validate()) {
                  // If the form is valid, navigate to the next page
                  // Get input values
                  String title = _titleController.text;
                  String energyUsed = _energyUsedController.text;

                  /*
                Gemini API call here!!
                Pass the carbon footprint and suggestion to CFSummaryPage constructor
                */
                  String carbonFootprint =
                      await calculateCarbonFootprintFromEnergy(
                          selectedCountry, energyUsed);

                  // Navigate to the new page with the inputs
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CFSummaryPage(
                                title: title,
                                category: 'Energy',
                                carbon_footprint: carbonFootprint,
                                suggestion: '',
                                vehicleType: null,
                                distance: null,
                                energyUsed: energyUsed,
                              )));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 5.0),
              ),
              child: Text(
                'Submit',
                style: GoogleFonts.ptSansCaption(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomAppBar(
      color: Color.fromRGBO(173, 191, 127, 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
              icon: const Icon(
                Icons.pie_chart,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => dashboard()),
                );
              }),
          IconButton(
              icon: const Icon(
                Icons.lightbulb,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ecolight_stat()),
                );
              }),
          IconButton(
              icon: const Icon(
                Icons.edit,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CarbonFootprintTracker()));
              }),
          IconButton(
              icon: Image.asset('assets/chat-w.png'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => chat(
                          carbonFootprint: '10', showAddRecordButton: false)),
                );
              }),
        ],
      ),
    );
  }
}
