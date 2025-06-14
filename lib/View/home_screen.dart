import 'package:flutter/material.dart';
import 'package:log_system/Model/log.dart';
import 'package:log_system/Model/log_repository.dart';
import 'package:log_system/View/register_screen.dart';
import 'package:log_system/main.dart';
import 'add_log.dart';
import 'view_log.dart';
import 'package:log_system/Model/user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title, required this.user});

  final String title;
  final User user;

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  final LogRepository logRepository = LogRepository();

  double _totalKm = 0;
  double _targetKm = 10000;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    double total = await logRepository.getTotalKilometers();
    double target = total >= _targetKm ? total * 3 : _targetKm;
    setState(() {
      _totalKm = total;
      _targetKm = target;
      _isLoading = false;
    });
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
                if (widget.user.role == "Admin") {
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
        child:
            _isLoading
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
                                        onPressed: () {
                                          double input =
                                              double.tryParse(
                                                initialMeterReadingController.text,
                                              ) ??
                                              0.0;
                                          try {
                                            Log log = Log.pickLog(
                                              name: widget.user.userName,
                                              detail:
                                                  'Picked student for the university',
                                              purpose: "Picking",
                                              date:
                                                  "${DateTime.now().toLocal()}"
                                                      .split(' ')[0],
                                              timeFrom: TimeOfDay.now().format(
                                                context,
                                              ),
                                              remarks: '',
                                              initialMeterReading: input,
                                            );
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
            MaterialPageRoute(builder: (context) => const AddLogScreen()),
          ).then((_) => _loadData()); // Refresh after adding a log
        },
        tooltip: 'Add Log',
        child: const Icon(Icons.add),
      ),
    );
  }
}
