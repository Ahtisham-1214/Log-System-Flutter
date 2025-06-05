import 'package:flutter/material.dart';
import 'package:log_system/Model/log.dart';
import 'package:log_system/Model/log_repository.dart';

class ViewLogScreen extends StatefulWidget {
  const ViewLogScreen({super.key});

  @override
  ViewLogScreenState createState() => ViewLogScreenState();
}

class ViewLogScreenState extends State<ViewLogScreen> {
  final LogRepository _logRepository = LogRepository();
  List<Log> _logs = [];
  List<Log> _filteredLogs = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    setState(() => _isLoading = true);
    try {
      List<Log> logs = await _logRepository.getAllLogs();
      logs.sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending
      setState(() {
        _logs = logs;
        _filteredLogs = logs;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading logs: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterLogs(String query) {
    query = query.toLowerCase();
    setState(() {
      _searchQuery = query;
      _filteredLogs =
          _logs.where((log) {
            return log.name.toLowerCase().contains(query) ||
                log.purpose.toLowerCase().contains(query);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Logs'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _filterLogs,
              decoration: InputDecoration(
                hintText: 'Search by name or purpose',
                prefixIcon: const Icon(Icons.search),
                fillColor: Colors.white,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _fetchLogs,
                child:
                    _filteredLogs.isEmpty
                        ? const Center(child: Text("No logs found."))
                        : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _filteredLogs.length,
                          itemBuilder: (context, index) {
                            final log = _filteredLogs[index];
                            return Card(
                              color: const Color(0xFF97160A),
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: DefaultTextStyle(
                                style: const TextStyle(color: Colors.white),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.person,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            log.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Spacer(),
                                          const Icon(
                                            Icons.date_range,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            log.date,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(log.purpose),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.info_outline,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(child: Text(log.detail)),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.access_time,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "${log.timeFrom} | ${log.timeTo}",
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.directions_car,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "${log.initialMeterReading} | ${log.finalMeterReading}",
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.flag,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Text("${log.kilometersCovered} km"),
                                        ],
                                      ),
                                      if (log.remarks.isNotEmpty &&
                                          log.remarks != 'null')
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 6.0,
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.comment,
                                                color: Colors.white70,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  log.remarks,
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
              ),
    );
  }
}