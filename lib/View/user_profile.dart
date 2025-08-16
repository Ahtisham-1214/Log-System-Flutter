import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  _UserProfileScreen createState() => _UserProfileScreen();
}

class _UserProfileScreen extends State<UserProfileScreen> {
  final _emailController = TextEditingController();
  final _userNameController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _userId = '';

  @override
  void dispose() {
    _emailController.dispose();
    _userNameController.dispose();
    _oldPasswordController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_role');
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false, // Remove all previous routes
    );
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text.trim();
      String userName = _userNameController.text.trim();
      String oldPassword = _oldPasswordController.text; // The old password entered by the user
      String newPassword = _passwordController.text; // The new password entered by the user

      try {
        final user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          // 1. Re-authenticate the user with their old password
          // This is crucial for security when updating email or password
          AuthCredential credential = EmailAuthProvider.credential(
            email: user.email!, // Use the user's current email
            password: oldPassword,
          );

          await user.reauthenticateWithCredential(credential);

          // 2. If re-authentication is successful, proceed with updates

          // Update email if it has changed
          if (user.email != email) {
            await user.updateEmail(email);
          }

          // Update password if it has changed and a new password is provided
          if (newPassword.isNotEmpty) {
            await user.updatePassword(newPassword);
          }

          // Update Firebase Realtime Database (username and potentially email if updated)
          final DatabaseReference userRef = FirebaseDatabase.instance
              .ref()
              .child('users')
              .child(user.uid);

          await userRef.update({'email': email, 'user_name': userName});

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User info updated successfully')),
          );
          _logout();
        }
      } on FirebaseAuthException catch (e) {
        debugPrint('FirebaseAuthException: ${e.message}');
        if (!mounted) return;
        String errorMessage;
        if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
          errorMessage = 'Invalid old password. Please try again.';
        } else if (e.code == 'requires-recent-login') {
          errorMessage = 'This operation is sensitive and requires recent authentication. Please log in again.';
        } else {
          errorMessage = 'Authentication error: ${e.message}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        debugPrint('Error: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating user: $e')),
        );
      }
    }
  }
  Future<void> _loadUserInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Set email from FirebaseAuth
        _emailController.text = user.email ?? '';

        final DatabaseReference userRef = FirebaseDatabase.instance
            .ref()
            .child('users')
            .child(user.uid);

        final DataSnapshot snapshot = await userRef.get();

        if (snapshot.exists) {
          final data = snapshot.value as Map<dynamic, dynamic>;

          String role = data['role'] ?? '';
          String userID = data['userID'] ?? user.uid;
          String userName = data['user_name'];

          setState(() {
            _userId = userID;
            _userNameController.text = userName;
            // You could store role here too if needed
          });
        } else {
          // Fallback: just set Firebase UID
          setState(() {
            _userId = user.uid;
          });
        }
      }
    } catch (e) {
      print('Error loading user info: $e');
      // You could show a snackbar or dialog here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Info'), centerTitle: true),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 16.0,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _userId.isNotEmpty ? _userId : 'Loading...',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: _userNameController,
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
                    } else if (!RegExp(r"^[a-zA-Z0-9]+$").hasMatch(value)) {
                      return 'Please enter a valid username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
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
                    } else if (!RegExp(
                      r"^[a-zA-Z0-9_!#$%&'*+/=?`{|}~^.-]+@[a-zA-Z0-9.-]+$",
                    ).hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: _oldPasswordController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Old Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return null;
                    } else if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return null;
                    } else if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text('Save', style: TextStyle(fontSize: 18.0)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
