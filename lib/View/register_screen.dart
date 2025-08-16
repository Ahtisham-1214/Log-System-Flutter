import 'package:flutter/material.dart';
import '../model/user_repository.dart';
import '../model/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  // final UserRepository _userRepository = UserRepository();
  final List<String> _roles = ['Admin', 'Driver'];
  String? _selectedRole = "Driver";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final userDatabase = FirebaseDatabase.instance.ref('users');


  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final userName = _userNameController.text;
      final email = _emailController.text;
      final password = _passwordController.text;
      // final role = _selectedRole ?? 'user'; // Keep if you use it with your custom user repository

      // Optional: Show a loading indicator
      // _showMessage("Registering...", Colors.blue); // Or use a dedicated loading state
      setState(() {
        _isLoading = true;
      });
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Registration Successful with Firebase Auth
        // Now you might want to store additional user info (like role) in your own database
        // For example, if you were using Firestore or your UserRepository:

        if (userCredential.user != null) {
          //   Example: Storing additional user data in Firestore
          await userDatabase.child(userCredential.user!.uid).set({
            'user_name': userName,
            'email': email,
            'role': _selectedRole,
          });

          // Or using your UserRepository (ensure it's adapted for Firebase UID)
          // await _userRepository.insertUser(User(
          //   uid: userCredential.user!.uid, // Assuming User model has uid
          //   email: email,
          //   role: role
          // ));
        }


        if (!mounted) {
          setState(() {
            _isLoading = false;
          });
          return;
        } // Check if the widget is still in the tree

        _showMessage("Registration Successful!", const Color(0xFF0E1B67));

        // Optionally clear form and navigate
        _formKey.currentState?.reset();
        _emailController.clear();
        _passwordController.clear();
        setState(() {
          _selectedRole = "Driver"; // Reset dropdown if needed
          _isLoading = false;
        });

        // Navigate back to login or to home screen after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          Navigator.pop(context); // Or Navigator.pushReplacement to a home screen
        });

      } on FirebaseAuthException catch (e) {
        if (!mounted) return; // Check mounted before showing message

        String errorMessage;
        switch (e.code) {
          case 'weak-password':
            errorMessage = 'The password provided is too weak.';
            break;
          case 'email-already-in-use':
            errorMessage = 'An account already exists for that email.';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is not valid.';
            break;
        // Add other Firebase Auth error codes as needed
        // See: https://firebase.google.com/docs/auth/admin/errors
          default:
            errorMessage = 'Registration failed. Please try again.';
        // print('Firebase Auth Error: ${e.code} - ${e.message}');
        }
        setState(() {
          _isLoading = false;
        });
        _showMessage(errorMessage, const Color(0xFFC12222));
      } catch (e) {
        // Catch any other non-FirebaseAuth errors
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        _showMessage("An unexpected error occurred: ${e.toString()}", const Color(0xFFC12222));
      }
    }
  }


  void _showMessage(String message, Color color) {
    OverlayEntry? overlayEntry; // To keep track of the overlay entry

    overlayEntry = OverlayEntry(
      builder: (context) => SafeArea(
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _userNameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }else if (!RegExp(r"^[a-zA-Z0-9]+$").hasMatch(value)) {
                    return 'Please enter a valid username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a Email';
                  }else if (!RegExp(r"^[a-zA-Z0-9_!#$%&'*+/=?`{|}~^.-]+@[a-zA-Z0-9.-]+$").hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedRole, // The currently selected value
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                hint: const Text('Select a role'), // Placeholder text
                items: _roles.map((String role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRole = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a user role';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                child: _isLoading
                    ? const SizedBox(
                  width: 24, // Adjust size as needed
                  height: 24, // Adjust size as needed
                  child: CircularProgressIndicator(
                    color: Colors.white, // Color of the spinner
                    strokeWidth: 2.5, // Thickness of the spinner
                  ),
                )
                    : const Text('Register', style: TextStyle(fontSize: 18.0)),
              ),
            ],
          ),
        ),
      ),
      )
    );
  }
}
