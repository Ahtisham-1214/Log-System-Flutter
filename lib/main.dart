import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'View/login_screen.dart';
import 'firebase_options.dart';
import '/View/splash_router.dart';
import 'Model/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the database
  await DatabaseHelper().database; // Ensure the database is initialized.

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      home: const SplashRouter(),
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


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  final double _radius = 120;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _controller.repeat();

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildCurvedText(String text, double angle) {
    // Split text into characters to position them individually
    final characters = text.split('');
    final characterCount = characters.length;
    final double charAngle = pi / (characterCount / 2);

    return Transform.rotate(
      angle: angle,
      child: SizedBox(
        width: _radius * 2,
        height: _radius * 2,
        child: Stack(
          alignment: Alignment.center,
          children: List.generate(characterCount, (index) {
            final charAngle = -pi/2 + (pi / characterCount) * index;
            return Positioned(
              left: _radius + _radius * cos(charAngle) - 6,
              top: _radius + _radius * sin(charAngle) - 8,
              child: Transform.rotate(
                angle: charAngle + pi/2,
                child: Text(
                  characters[index],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFC12222),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Central Aror text
                const Text(
                  'Aror',
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFC12222),
                  ),
                ),

                // Curved text
                Transform.translate(
                  offset: Offset.zero,
                  child: Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: _buildCurvedText(
                      'Aror University Driver',
                      0,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
