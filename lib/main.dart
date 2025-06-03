import 'package:flutter/material.dart';
import 'package:log_system/Model/user_repository.dart';
import 'package:log_system/Model/database_helper.dart';
import 'View/register_screen.dart';
import 'View/home_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the database
  await DatabaseHelper().database; // Ensure the database is initialized.

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      theme: ThemeData(
        useMaterial3: false,
        primarySwatch: maroonSwatch,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter',
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}
const MaterialColor maroonSwatch = MaterialColor(
  0xFF800000, // Maroon base color
  <int, Color>{
    50: Color(0xFFF2E6E6),
    100: Color(0xFFDFC0C0),
    200: Color(0xFFCC9999),
    300: Color(0xFFB97373),
    400: Color(0xFFA64D4D),
    500: Color(0xFF800000), // Primary color
    600: Color(0xFF730000),
    700: Color(0xFF660000),
    800: Color(0xFF590000),
    900: Color(0xFF400000),
  },
);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  final UserRepository _userRepository = UserRepository();

  @override
  void initState() {
    super.initState();
  }


  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      String username = _usernameController.text;
      String password = _passwordController.text;

      try {
        bool isValid = await _userRepository.validateUser(username, password);

        if (!mounted) return; // ✅ Ensure widget is still in tree

        if (isValid) {
          _showMessage("Login Successful", Color(0xFF0E1B67));
          _formKey.currentState?.reset();
          _usernameController.clear();
          _passwordController.clear();
          //  Navigate to the home screen or next screen after successful login.
          //  For example:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(title: "Ahtisham")),
          );
        } else {
          _showMessage("Invalid Credentials", Color(0xFFC12222));
        }
      } catch (e) {
        _showMessage("An error occured $e", Color(0xFFC12222));
      }
    }
  }

  void _showMessage(String message, Color color) {
    OverlayEntry? overlayEntry; // To keep track of the overlay entry

    overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
        // Center the widget
        top: MediaQuery.of(context).size.height / 2 - 300,
        // Adjust 50 based on your card's approx height / 2
        left: MediaQuery.of(context).size.width / 2 - 130,
        // Adjust 150 based on your card's approx width / 2
        child: Material(
          // Material widget is needed for Card to have elevation and shape
          color: Colors.transparent,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: color, // Your custom color
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ), // Adjusted padding
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16, // Ensure font size is reasonable
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );

    // Add the OverlayEntry to the Overlay
    Overlay.of(context).insert(overlayEntry);

    // Remove the OverlayEntry after a duration
    Future.delayed(const Duration(seconds: 1), () {
      if (overlayEntry != null && overlayEntry!.mounted) {
        overlayEntry?.remove();
        overlayEntry = null; // Clear the reference
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // if (_loginMessage != null)
              //   Padding(
              //     padding: const EdgeInsets.only(bottom: 10.0),
              //     child: Text(
              //       _loginMessage!,
              //       style: TextStyle(color: _messageColor, fontSize: 16),
              //       textAlign: TextAlign.center,
              //     ),
              //   ),
              TextFormField(
                controller: _usernameController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  } else if (value.length < 3) {
                    return 'Username must be at least 3 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30.0),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text('Login', style: TextStyle(fontSize: 18.0)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterPage()),
                  );
                },
                child: const Text('Don\'t have an account? Register here'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
