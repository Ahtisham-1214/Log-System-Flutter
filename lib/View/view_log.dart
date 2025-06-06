import 'package:flutter/material.dart';
import 'package:log_system/Model/log.dart';
import 'package:log_system/Model/log_repository.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

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
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View Logs')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _fetchLogs,
                child:
                    _filteredLogs.isEmpty
                        ? const Center(child: Text("No logs found."))
                        : Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: _pickDateRange,
                                    icon: const Icon(Icons.calendar_today),
                                    label: Text(
                                      _selectedDateRange != null
                                          ? "${_formatDate(_selectedDateRange!.start)} → ${_formatDate(_selectedDateRange!.end)}"
                                          : "Pick Date Range",
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black87,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  if (_selectedDateRange != null)
                                    IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        setState(() {
                                          _selectedDateRange = null;
                                          _filterLogs();
                                        });
                                      },
                                    ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.all(12),
                                itemCount: _filteredLogs.length,
                                itemBuilder: (context, index) {
                                  final log = _filteredLogs[index];
                                  return _buildLogCard(log);
                                },
                              ),
                            ),
                          ],
                        ),
              ),
      floatingActionButton:
      _filteredLogs.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: () => _exportLogsToCSV(_filteredLogs),
        icon: const Icon(Icons.share,),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF97160A),
        label: const Text('Export'),
      )
          : null,
    );
  }

  Widget _buildLogCard(Log log) {
    return Card(
      color: const Color(0xFF97160A),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: DefaultTextStyle(
        style: const TextStyle(color: Colors.white),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.person, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    log.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  const Icon(Icons.date_range, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    log.date,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(log.purpose),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(log.detail)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text("${log.timeFrom} | ${log.timeTo}"),
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
                  Text("${log.initialMeterReading} | ${log.finalMeterReading}"),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.flag, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text("${log.kilometersCovered} km"),
                ],
              ),
              if (log.remarks.isNotEmpty && log.remarks != 'null')
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
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
                          style: const TextStyle(color: Colors.grey),
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
  }

  Future<void> _fetchLogs() async {
    setState(() => _isLoading = true);
    try {
      List<Log> logs = await _logRepository.getAllLogs();
      logs.sort((a, b) => b.date.compareTo(a.date));
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

  void _filterLogs() {
    setState(() {
      _filteredLogs =
          _logs.where((log) {
            final logDate = DateTime.tryParse(log.date);
            final matchesDateRange =
                _selectedDateRange == null ||
                (logDate != null &&
                    logDate.isAfter(
                      _selectedDateRange!.start.subtract(
                        const Duration(days: 1),
                      ),
                    ) &&
                    logDate.isBefore(
                      _selectedDateRange!.end.add(const Duration(days: 1)),
                    ));
            return matchesDateRange;
          }).toList();
    });
  }

  Future<void> _pickDateRange() async {
    DateTime now = DateTime.now();
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: now,
      initialDateRange: _selectedDateRange,
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        _filterLogs();
      });
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _exportLogsToCSV(List<Log> logs) async {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    String rangeLabel = '';

    if (_selectedDateRange != null) {
      String start = formatter.format(_selectedDateRange!.start);
      String end = formatter.format(_selectedDateRange!.end);
      rangeLabel = '_$start-to-$end';
    }

    List<List<dynamic>> rows = [];

    // Header
    rows.add(["Log Export${rangeLabel.isNotEmpty ? ' ($rangeLabel)' : ''}"]);
    rows.add([]);

    rows.add([
      "ID", "Name", "Date", "Purpose", "Detail",
      "Time From", "Time To", "Initial Meter", "Final Meter",
      "Kilometers Covered", "Remarks"
    ]);

    for (var log in logs) {
      rows.add([
        log.id ?? '',
        log.name,
        log.date,
        log.purpose,
        log.detail,
        log.timeFrom,
        log.timeTo,
        log.initialMeterReading,
        log.finalMeterReading,
        log.kilometersCovered,
        log.remarks,
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);
    try {
      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final fileName = 'logs_export${rangeLabel.isNotEmpty ? '_$rangeLabel' : ''}.csv';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(csv);

      // Share directly
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Exported Logs${rangeLabel.isNotEmpty ? ' ($rangeLabel)' : ''}',
      );
    } catch (e) {
      debugPrint("Error exporting CSV: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to export logs.")),
      );
    }
  }
}
