import 'package:Lucerna/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Lucerna/calculator/cf_summary.dart';
import 'package:Lucerna/main.dart';
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

  // check carbon sutra api from user
  late GeminiAPIFootprint api;

  @override
  void initState() {
    super.initState();

    // Initialize the CarbonSutraAPI with the context
    api = GeminiAPIFootprint(context);
  }
  // JL

  // final CarbonSutraAPI api = CarbonSutraAPI();
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme,
      home: Scaffold(
        backgroundColor: const Color.fromRGBO(200, 200, 200, 1),
        appBar: CommonAppBar(title: "Track Carbon Footprint"),
        bottomNavigationBar:
            CommonBottomNavigationBar(selectedTab: BottomTab.tracker),
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
                                  .headlineMedium!
                                  .copyWith(
                                      color: Color.fromRGBO(0, 0, 0, 0.5)),
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
                  String carbonFootprint = await api.calcElectricity(
                      electricityValue: energyUsed,
                      countryName: selectedCountry);

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
}
