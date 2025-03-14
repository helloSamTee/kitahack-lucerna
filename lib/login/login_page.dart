import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Lucerna/home/dashboard.dart';
import 'package:video_player/video_player.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:pure_dart_ui/pure_dart_ui.dart' as ui;
// import 'dart:html';
import 'package:Lucerna/main.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage; // Variable to store error message

  // late  WebViewController controller;
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  Future<void> _login() async {
    setState(() {
      _errorMessage = null; // Reset error message on each login attempt
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Navigate to dashboard on successful login
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => dashboard()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage =
            "Wrong Email or Password"; // Set error message from Firebase exception
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Wrong Email or Password"; // Set general error message
      });
    }
  }

  @override
  void initState() {
    _controller = VideoPlayerController.asset("videos/login.mp4");
    _initializeVideoPlayerFuture =
        _controller.initialize().then((value) => _controller.play());
    _controller.setLooping(true);
    _controller.setVolume(0.0);
    _controller.setPlaybackSpeed(0.5);
    super.initState();
    // controller = WebViewController()
    //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
    //   ..setNavigationDelegate(
    //     NavigationDelegate(
    //       onPageFinished: (String url) async {
    //         // Inject JavaScript to scroll to center
    //         await controller.runJavaScript('''
    //           document.body.style.overflow = 'hidden';
    //           window.scrollTo(window.innerWidth / 2, window.innerHeight / 2);
    //         ''');
    //       },
    //     ),
    //   )
    //   ..loadRequest(Uri.parse('https://my.spline.design/cabinwoodscopy-b6bf6e8498ac797fa2b801392b03c330/'));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: appTheme,
        home: Scaffold(
            body: SafeArea(
                child: Center(
          // Centers everything
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              // Enables scrolling to prevent overflow
              child: Column(
                mainAxisSize: MainAxisSize.min, // Prevents taking full height
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment
                    .center, // Centers all components vertically
                children: [
                  // Video
                  FutureBuilder(
                    future: _initializeVideoPlayerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return SizedBox(
                          width:
                              double.infinity, // Stretch to full screen width
                          child: AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller),
                          ),
                        );
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                  // Input Form
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 80, vertical: 75),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Keeps it compact
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTextField(_emailController, 'Email'),
                        const SizedBox(height: 20),
                        _buildTextField(_passwordController, 'Password',
                            hide: true),
                        const SizedBox(height: 20),
                        if (_errorMessage != null)
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red, fontSize: 14),
                          ),
                        const SizedBox(height: 20),
                        _buildLoginButton(),
                        const SizedBox(height: 15),
                        _buildRegisterButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ))));
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool hide = false}) {
    return TextFormField(
      controller: controller,
      obscureText: hide,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: label,
        labelStyle: Theme.of(context).textTheme.labelSmall,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.surface, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.surface, width: 1.5),
        ),
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label cannot be empty. Please enter a valid value.';
        }
        if (label == 'Email' && !_isValidEmail(value.trim())) {
          return 'Please enter a valid email address.';
        }
        return null;
      },
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  Widget _buildLoginButton() {
    return SizedBox(
      height: 50, // Set fixed height
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _login();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: Text(
          'Login',
          style: Theme.of(context).textTheme.displayLarge,
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      height: 50, // Set fixed height
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RegisterPage()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: Text(
          'Register',
          style: Theme.of(context).textTheme.displayLarge,
        ),
      ),
    );
  }

  Widget _buildButtonRow() {
    return Row(
      children: [
        _buildLoginButton(),
        const SizedBox(width: 10), // Space between buttons
        _buildRegisterButton(),
      ],
    );
  }
}
