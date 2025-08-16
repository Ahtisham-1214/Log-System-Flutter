import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:log_system/View/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:log_system/Model/user.dart';

import 'home_screen.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final userDatabase = FirebaseDatabase.instance.ref('users');

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message, Color color) {
    OverlayEntry? overlayEntry; // To keep track of the overlay entry
    overlayEntry = OverlayEntry(
      builder:
          (context) => SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 80.0), // Distance from top
            child: Material(
              color: Colors.transparent,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: color,
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
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

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text;
      String password = _passwordController.text;
      setState(() {
        _isLoading = true;
      });

      try {
        // Using async/await for cleaner error handling
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        DatabaseEvent snapshot = await userDatabase.child(userCredential.user!.uid).once();

        // Login Successful
        if (!mounted) {
          _isLoading = false;
          return;
        } // Check mounted before using context or setState

        if(snapshot.snapshot.exists && snapshot.snapshot.value != null){
          Map<dynamic, dynamic> userData = snapshot.snapshot.value as Map<dynamic, dynamic>;
          String id = snapshot.snapshot.key!;
          String role = userData['role'];
          String userName = userData['user_name'];
          // Cache role for offline startup
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_role', role);
          setState(() {
            _showMessage('Login Successful!', Colors.green);
          });

          _formKey.currentState?.reset();
          _emailController.clear();
          _passwordController.clear();

          UserDTO userDTO = UserDTO(
            id: id,
            userName: userName,
            email: email,
            role: role,
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(title: 'Dashboard', userDTO: userDTO)),
          );
        }else{
          setState(() {
            _isLoading = false;
            _showMessage('User data not found.', Color(0xFFC12222));
          });
        }


      } on FirebaseAuthException catch (e) {
        if (!mounted) return; // Check mounted before using context or setState

        String errorMessage;
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found for that email.';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is not valid';
            break;
          case 'user-disabled':
            errorMessage = 'This user account has been disabled';
            break;
          case 'invalid-credential': // This is a common one for wrong email/password
            errorMessage = 'Invalid credentials';
            break;
        // Add more cases as needed based on Firebase Auth error codes
        // See: https://firebase.google.com/docs/auth/admin/errors
          default:
            errorMessage = 'An unexpected error occurred. Please try again.';
        // You might want to log the original error for debugging:
        // print('Firebase Auth Error: ${e.code} - ${e.message}');
        }
        setState(() {
          _isLoading = false;
          _showMessage(errorMessage, Color(0xFFC12222));
        });
      } catch (e) {
        // Catch any other non-FirebaseAuth errors
        if (!mounted) return;

        setState(() {
          _isLoading = false;
          _showMessage('An error occurred: ${e.toString()}', Color(0xFFC12222));
        });
      }
    }
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
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }else if (!RegExp(r"^[a-zA-Z0-9_!#$%&'*+/=?`{|}~^.-]+@[a-zA-Z0-9.-]+$").hasMatch(value)) {
                    return 'Please enter a valid email';
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
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                  width: 24, // Adjust size as needed
                  height: 24, // Adjust size as needed
                  child: CircularProgressIndicator(
                    color: Colors.white, // Color of the spinner
                    strokeWidth: 2.5, // Thickness of the spinner
                  ),
                )
                    : const Text('Login', style: TextStyle(fontSize: 18.0)),
              ),
            ],
          ),
        ),
      ),
    );
  }


}