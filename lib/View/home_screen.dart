import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:log_system/Model/log.dart';
import 'package:log_system/Model/log_repository.dart';
import 'package:log_system/View/register_screen.dart';
import 'package:log_system/View/user_profile.dart';
import 'package:log_system/main.dart';
import 'add_log.dart';
import 'view_log.dart';
import 'package:log_system/Model/user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title, required this.userDTO});

  final String title;
  final UserDTO userDTO;

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  // final LogRepository logRepository = LogRepository();

  double _totalKm = 0;
  double _targetKm = 10000;
  bool _isLoading = true;
  // Firebase Database Reference
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<double> _getTotalKilometersFromFirebase() async {
    double totalKilometers = 0;
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      print("No user logged in. Cannot fetch logs.");
      return 0.0;
    }

    try {
      // Path to user-specific logs
      final DataSnapshot snapshot = await _databaseRef.child('users').child(currentUser.uid).child('logs').get();

      if (snapshot.exists && snapshot.value != null) {
        final Map<dynamic, dynamic>? logsMap = snapshot.value as Map<dynamic, dynamic>?;

        if (logsMap != null) {
          logsMap.forEach((key, value) {
            if (value is Map<dynamic, dynamic>) {
              // Ensure 'kilometersCovered' field exists and is a number
              if (value.containsKey('kilometersCovered')) {
                final dynamic kilometers = value['kilometersCovered'];
                if (kilometers is num) {
                  totalKilometers += kilometers.toDouble();
                } else {
                  print("Warning: 'kilometersCovered' is not a number for log entry $key");
                }
              }
            }
          });
        }
      }
    } catch (e) {
      print("Failed to fetch total kilometers from Firebase: $e");
      rethrow; // Re-throw to be caught by _loadData's try-catch
    }
    return totalKilometers;
  }

  Future<void> _loadData() async {
    // double total = await logRepository.getTotalKilometers();
    setState(() {
      _isLoading = true; // Set to true at the start of loading
    });
    try {
      double total = await _getTotalKilometersFromFirebase();
      // Ensure _targetKm has a sensible initial value or is also fetched if dynamic
      double target = total >= _targetKm ? total * 3 : _targetKm;
      setState(() {
        _totalKm = total;
        _targetKm = target;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading data from Firebase: $e");
      setState(() {
        _isLoading = false; // Stop loading even on error
      });
      // Optionally show an error message to the user, e.g., using a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load total kilometers: $e')),
      );
    }
  }

  String formatKilometers(double km) {
    if (km >= 1000000) {
      return '${(km / 1000000).toStringAsFixed(1)}M km';
    } else if (km >= 1000) {
      return '${(km / 1000).toStringAsFixed(1)}k km';
    } else {
      return '${km.toStringAsFixed(1)} km';
    }
  }

  @override
  Widget build(BuildContext context) {
    double progress = (_totalKm / _targetKm).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF97160A)),
              child: const Text(
                'Navigation Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Register'),
              onTap: () {
                if (widget.userDTO.role == "Admin") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterPage(),
                    ),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Permission Denied'),
                          content: const Text(
                            'Only admins can access this feature',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MyApp()),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                  children: [
                    Card(
                      elevation: 4,
                      margin: const EdgeInsets.all(20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 150,
                                  height: 150,
                                  child: CircularProgressIndicator(
                                    value: progress,
                                    strokeWidth: 12,
                                    backgroundColor: Colors.grey[300],
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          Color(0xFF97160A),
                                        ),
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      formatKilometers(_totalKm),
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF97160A),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Total Covered',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF97160A),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.grid_view),
                      label: const Text("View Log"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ViewLogScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.bus_alert_rounded),
                            label: const Text("Pick"),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  final TextEditingController initialMeterReadingController =
                                      TextEditingController();
                                  return AlertDialog(
                                    title: const Text("Enter Pick Details"),
                                    content: TextField(
                                      controller: initialMeterReadingController,
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      decoration: const InputDecoration(
                                        hintText: "Enter Meter Reading",
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        child: const Text("Cancel"),
                                        onPressed: () {
                                          Navigator.of(
                                            context,
                                          ).pop(); // Close the popup
                                        },
                                      ),
                                      ElevatedButton(
                                        child: const Text("Submit"),
                                        onPressed: () async {
                                          double input =
                                              double.tryParse(
                                                initialMeterReadingController.text,
                                              ) ??
                                              0.0;
                                          try {
                                            Log log = Log.pickLog(
                                              name: 'Ahtisham',
                                              detail:
                                                  'Picked student for the university',
                                              purpose: "Picking",
                                              date:
                                                  "${DateTime.now().toLocal()}"
                                                      .split(' ')[0],
                                              timeFrom: TimeOfDay.now().format(
                                                context,
                                              ),
                                              remarks: 'null',
                                              initialMeterReading: input,
                                            );
                                            final User? currentUser = FirebaseAuth.instance.currentUser;
                                            final DatabaseReference logDatabase = FirebaseDatabase.instance.ref('users').child(currentUser!.uid).child('logs');
                                            await logDatabase.push().set({
                                              'id': currentUser.uid,
                                              'name': log.name,
                                              'detail': log.detail,
                                              'purpose': log.purpose,
                                              'date': log.date,
                                              'timeFrom': log.timeFrom,
                                              // 'timeTo': log.timeTo,
                                              'remarks': log.remarks,
                                              'initialMeterReading': log.initialMeterReading,
                                              // 'finalMeterReading': log.finalMeterReading,
                                              // 'kilometersCovered': log.kilometersCovered,
                                            });
                                            Navigator.pop(
                                              context,
                                            ); // Close the popup
                                          } catch (e) {
                                            showDialog(
                                              context: context,
                                              builder:
                                                  (context) => AlertDialog(
                                                    title: const Text('Error'),
                                                    content: Text(e.toString()),
                                                    actions: [
                                                      TextButton(
                                                        onPressed:
                                                            () => Navigator.pop(
                                                              context,
                                                            ),
                                                        child: const Text('OK'),
                                                      ),
                                                    ],
                                                  ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.bus_alert_rounded),
                            label: const Text("Drop"),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  final TextEditingController finalMeterReadingController =
                                      TextEditingController();
                                  return AlertDialog(
                                    title: const Text("Enter Drop Details"),
                                    content: TextField(
                                      controller: finalMeterReadingController,
                                      decoration: const InputDecoration(
                                        hintText: "Enter Meter Reading",
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        child: const Text("Cancel"),
                                        onPressed: () {
                                          Navigator.of(
                                            context,
                                          ).pop(); // Close the popup
                                        },
                                      ),
                                      ElevatedButton(
                                        child: const Text("Submit"),
                                        onPressed: () {
                                          String input = finalMeterReadingController.text;
                                          // You can handle the input here (e.g. save, validate, etc.)

                                          Navigator.of(
                                            context,
                                          ).pop(); // Close the popup
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddLogScreen(userDTO: widget.userDTO)),
          ).then((_) => _loadData()); // Refresh after adding a log
        },
        tooltip: 'Add Log',
        child: const Icon(Icons.add),
      ),
    );
  }
}
