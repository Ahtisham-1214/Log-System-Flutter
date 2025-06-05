import 'package:flutter/material.dart';
import 'package:log_system/Model/log_repository.dart';
import 'add_log.dart';
import 'view_log.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  _HomeScreen createState() => _HomeScreen();
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
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
          children: [
            Card(
              elevation: 4,
              margin: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF97160A)),
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
                              style: TextStyle(fontSize: 16, color: Color(0xFF97160A)),
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
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ViewLogScreen()));
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddLogScreen()))
              .then((_) => _loadData()); // Refresh after adding a log
        },
        tooltip: 'Add Log',
        child: const Icon(Icons.add),
      ),
    );
  }
}
