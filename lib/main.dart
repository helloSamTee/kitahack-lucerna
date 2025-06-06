import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:Lucerna/login/login_page.dart';
import 'package:http/http.dart' as http;
//import 'package:Lucerna/login_page.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'calculator/history_provider.dart'; // Import the provider
import 'auth_provider.dart' as LucernaAuthProvider;
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Lock orientation to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  _bootServer();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => LucernaAuthProvider.AuthProvider()),
        ChangeNotifierProvider(create: (context) => HistoryProvider()),
      ],
      child: MyApp(),
    ),
  );
}
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   // Set Firebase session persistence
//   await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);

//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (context) => LucernaAuthProvider.AuthProvider()),
//         ChangeNotifierProvider(create: (context) => HistoryProvider()),
//       ],
//       child: const MyApp(),
//     ),
//   );
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lucerna',
      theme: appTheme,
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           // Show a loading screen while checking auth state
//           return const MaterialApp(
//             home: Scaffold(
//               body: Center(child: CircularProgressIndicator()),
//             ),
//           );
//         }

//         if (snapshot.hasData) {
//           // User is logged in, navigate to the dashboard
//           return MaterialApp(
//             title: 'Lucerna',
//             theme: appTheme,
//             home: const dashboard(),
//           );
//         } else {
//           // User is not logged in, navigate to the login page
//           return MaterialApp(
//             title: 'Lucerna',
//             theme: appTheme,
//             home: const LoginPage(),
//           );
//         }
//       },
//     );
//   }
// }

ThemeData appTheme = ThemeData(
  useMaterial3: false,

  // Define the default brightness and colors.
  colorScheme: const ColorScheme(
    primary: Color.fromRGBO(92, 128, 1, 1),
    onPrimary: Colors.white,
    secondary: Color.fromRGBO(124, 181, 24, 1),
    onSecondary: Colors.white,
    tertiary: Color.fromRGBO(251, 97, 7, 1),
    onTertiary: Colors.white,
    surface: Color.fromRGBO(251, 176, 45, 1),
    onSurface: Colors.white,
    surfaceBright: Color.fromRGBO(243, 222, 44, 1),
    error: Colors.redAccent,
    onError: Colors.white,
    brightness: Brightness.light,
  ),

  // Define the default `TextTheme`. Use this to specify the default
  // text styling for headlines, titles, bodies of text, and more.
  textTheme: TextTheme(
    // text styling for page title
    headlineLarge: GoogleFonts.ptSansCaption(
      fontSize: 25,
      fontWeight: FontWeight.bold,
      //height: 35,
      letterSpacing: 3.5,
    ),

    headlineMedium: GoogleFonts.ptSansCaption(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      //height: 35,
      letterSpacing: 3.5,
    ),

    // text styling for button
    displayLarge: GoogleFonts.ptSansCaption(
      fontSize: 15,
      fontWeight: FontWeight.bold,
    ),

    // text styling for text title
    titleLarge: GoogleFonts.ptSerif(
      fontSize: 17.5,
      fontWeight: FontWeight.bold,
    ),

    titleSmall: GoogleFonts.ptSerif(
      fontSize: 10,
      fontWeight: FontWeight.bold,
    ),

    bodyLarge: GoogleFonts.ptSans(
      fontSize: 12.5,
      fontWeight: FontWeight.bold,
    ),

    bodyMedium: GoogleFonts.ptSansNarrow(
      fontSize: 12.5,
      fontWeight: FontWeight.bold,
    ),

    bodySmall: GoogleFonts.ptSans(
      fontSize: 10,
    ),

    // TextField in Carbon Footprint Form
    labelSmall: GoogleFonts.ptSans(
      fontSize: 15,
      color: Color.fromRGBO(0, 0, 0, 0.5),
    ),
  ),
);

// boot up cloud run function to handle file upload
Future<void> _bootServer() async {
  try {
    final response = await http.post(Uri.parse(
        'https://food-detection-modelv2-193945562879.us-central1.run.app/predict'));
    print("Server boot-up request sent successfully.");
  } catch (e) {
    // Catch and ignore any errors
    print("server boot-up: $e");
  }
}
