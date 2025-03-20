import 'package:Lucerna/profile/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Lucerna/calculator/cf_summary.dart';
import 'package:Lucerna/chat/chat.dart';
import 'package:Lucerna/home/dashboard.dart';
import 'package:Lucerna/ecolight/lamp_stat.dart';
import 'package:Lucerna/main.dart';
import 'package:Lucerna/calculator/carbon_footprint.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../API_KEY_Config.dart';
import 'common_widget.dart';
import 'carbon_sutra.dart';

class journeyRecord extends StatefulWidget {
  @override
  _JourneyRecordState createState() => _JourneyRecordState();
}

class _JourneyRecordState extends State<journeyRecord> {
  final _formKey = GlobalKey<FormState>(); // Key to manage form state
  final TextEditingController _titleController = TextEditingController();
  // Controllers for flight fields
  final TextEditingController airportFromController = TextEditingController();
  final TextEditingController airportToController = TextEditingController();
  String roundTripValue = "Y"; // Default value
  final TextEditingController numPassengersController =
      TextEditingController(text: "1");

  // Controllers for ground travel fields
  final TextEditingController distanceValueController = TextEditingController();

  final List<String> _vehicleTypes = [
    'Bus',
    'Car',
    'Flight',
    'Motorbike',
    'Taxi-Local',
    'Train'
  ];
  String selectedVehicle = "Flight";

  final List<String> _carTypes = [
    'Car-Type-Mini',
    'Car-Type-Supermini',
    'Car-Type-LowerMedium',
    'Car-Type-UpperMedium',
    'Car-Type-Executive',
    'Car-Type-Luxury',
    'Car-Type-Sports',
    'Car-Type-4x4',
    'Car-Type-MPV',
    'Car-Size-Small',
    'Car-Size-Medium',
    'Car-Size-Large',
    'Car-Size-Average'
  ];
  String selectedCar = 'Car-Type-Mini';

  final List<String> _motorbikeTypes = [
    'Motorbike-Size-Small',
    'Motorbike-Size-Medium',
    'Motorbike-Size-Large',
    'Motorbike-Size-Average'
  ];
  String selectedMotorbike = 'Motorbike-Size-Small';

  final List<String> _busTypes = ['Bus-LocalAverage', 'Bus-Coach'];
  String selectedBus = 'Bus-LocalAverage';

  final List<String> _trainTypes = [
    'Train-National',
    'Train-Local',
    'Train-Tram'
  ];
  String selectedTrain = 'Train-National';

  final List<String> _fuelTypes = ['Diesel', 'Petrol', 'Unknown'];
  String selectedFuel = 'Unknown';

  final List<String> _flightClasses = [
    'Economy',
    'Premium',
    'Business',
    'First',
    'Average'
  ];
  String selectedFlightClass = "Average";
  // final CarbonSutraAPI api = CarbonSutraAPI();

  // check carbon sutra api from user
  late CarbonSutraAPI api;

  @override
  void initState() {
    super.initState();

    // Initialize the CarbonSutraAPI with the context
    api = CarbonSutraAPI(context);
  }
  // JL

  Future<String> calculateCarbonFootprintFromFlight(
      String flightFrom,
      String flightTo,
      String flightClass,
      String roundTrip,
      String numPassenger) async {
    final response = await api.calcFlight(
        flightFrom: flightFrom,
        flightTo: flightTo,
        flightClass: selectedFlightClass,
        roundTrip: roundTrip,
        numPassenger: numPassenger);

    if (response != null) {
      return response['data']['co2e_kg'].toString();
    } else {
      return "0";
    }
  }

  Future<String> calculateCarbonFootprintFromVehicle(
      String vehicleType, String distanceKM, String fuelType) async {
    final response = await api.calcVehicleByType(
        vehicleType: vehicleType, distanceKM: distanceKM, fuelType: fuelType);

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
                              'Add Journey Record',
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
                                items: _vehicleTypes,
                                label: "Vehicle Type",
                                defaultValue: selectedVehicle,
                                onChanged: (value) {
                                  setState(() {
                                    selectedVehicle = value;
                                  });
                                }),
                            const SizedBox(height: 25),

                            // Dynamically Display Relevant Fields
                            if (selectedVehicle == "Flight")
                              _buildFlightFields(),
                            if ([
                              "Car",
                              "Motorbike",
                              "Bus",
                              "Taxi",
                              "Train",
                              "Taxi-Local"
                            ].contains(selectedVehicle))
                              _buildGroundTransportFields(),
                            const SizedBox(height: 25),

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

  Widget _buildFlightFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildTextField(
            context, airportFromController, "IATA Airport From (e.g., LHR)"),
        const SizedBox(height: 25),
        buildTextField(
            context, airportToController, "IATA Airport To (e.g., JFK)"),
        const SizedBox(height: 25),
        buildDropdown(
            items: _flightClasses,
            label: "Flight Class",
            defaultValue: selectedFlightClass,
            onChanged: (value) {
              setState(() {
                selectedFlightClass = value;
              });
            }),
        const SizedBox(height: 25),
        buildTextField(
            context, numPassengersController, "Number of Passengers"),
        const SizedBox(height: 25),
        buildCheckbox(
          label: 'Round Trip',
          onChanged: (value) {
            setState(() {
              roundTripValue = value;
            });
          },
        ),
      ],
    );
  }

  // ✅ Ground Transport Fields
  Widget _buildGroundTransportFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (selectedVehicle == "Car") ...[
          buildDropdown(
              items: _carTypes,
              label: "Car Type",
              defaultValue: selectedCar,
              onChanged: (value) {
                setState(() {
                  selectedCar = value;
                });
              }),
          const SizedBox(height: 25),
        ],
        if (selectedVehicle == "Motorbike") ...[
          buildDropdown(
              items: _motorbikeTypes,
              label: "Motorbike Type",
              defaultValue: selectedMotorbike,
              onChanged: (value) {
                setState(() {
                  selectedMotorbike = value;
                });
              }),
          const SizedBox(height: 25),
        ],
        if (selectedVehicle == "Bus") ...[
          buildDropdown(
              items: _busTypes,
              label: "Bus Type",
              defaultValue: selectedBus,
              onChanged: (value) {
                setState(() {
                  selectedBus = value;
                });
              }),
          const SizedBox(height: 25),
        ],
        if (selectedVehicle == "Train") ...[
          buildDropdown(
              items: _trainTypes,
              label: "Train Type",
              defaultValue: selectedTrain,
              onChanged: (value) {
                setState(() {
                  selectedTrain = value;
                });
              }),
          const SizedBox(height: 25),
        ],
        buildTextField(
            context, distanceValueController, "Distance Travelled (km)",
            isNumeric: true),
        const SizedBox(height: 25),
        buildDropdown(
            items: _fuelTypes,
            label: "Fuel Type",
            defaultValue: selectedFuel,
            onChanged: (value) {
              setState(() {
                selectedFuel = value;
              });
            }),
      ],
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
                  String carbonFootprint;
                  String finalVehicle;
                  if (selectedVehicle == 'Flight') {
                    carbonFootprint = await calculateCarbonFootprintFromFlight(
                        airportFromController.text,
                        airportToController.text,
                        selectedFlightClass,
                        roundTripValue,
                        numPassengersController.text);
                    finalVehicle = "Flight ($selectedFlightClass)";
                  } else {
                    switch (selectedVehicle) {
                      case 'Car':
                        finalVehicle = selectedCar;
                        break;
                      case 'Motorbike':
                        finalVehicle = selectedMotorbike;
                        break;
                      case 'Bus':
                        finalVehicle = selectedBus;
                        break;
                      case 'Train':
                        finalVehicle = selectedTrain;
                        break;
                      default:
                        finalVehicle = selectedVehicle;
                        break;
                    }
                    carbonFootprint = await calculateCarbonFootprintFromVehicle(
                        finalVehicle,
                        distanceValueController.text,
                        selectedFuel);
                  }

                  // Navigate to the new page with the inputs
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CFSummaryPage(
                                title: _titleController.text,
                                category: 'Journey',
                                carbon_footprint: carbonFootprint,
                                suggestion: '',
                                vehicleType: finalVehicle,
                                distance: distanceValueController.text,
                                energyUsed: null,
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
          IconButton(
            icon: const Icon(
              Icons.person,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserProfile()),
              );
            },
          ),
        ],
      ),
    );
  }
}
