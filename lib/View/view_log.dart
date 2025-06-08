import 'package:flutter/material.dart';
import 'package:log_system/Model/log.dart';
import 'package:log_system/Model/log_repository.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:excel/excel.dart';
import 'dart:convert';
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
              ? FloatingActionButton(
                onPressed: () => _exportLogsToExcel(_filteredLogs),
                backgroundColor: Colors.white,
                child: Icon(
                    Icons.share,
                    color: Color(0xFF97160A),
                    size: 26,
                ),
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
              Row(children: [
                const Spacer(),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey, size: 30),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                      // TODO: Implement edit functionality
                        break;
                      case 'delete':
                      // TODO: Implement delete functionality
                        break;
                    // Add more cases as needed
                      case 'share':
                        _exportSpecificLogs(log.id!);
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'share',
                      child: Text('Share'),
                    ),
                  ],
                )
              ],
              )
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

  Future<void> _exportSpecificLogs(int id) async {
    try {
      var specificLog = {};
      for (var log in _logs) {
        if (log.id == id) {
          specificLog['Id'] = log.id;
          specificLog['Name'] = log.name;
          specificLog['Date'] = log.date;
          specificLog['Purpose'] = log.purpose;
          specificLog['Detail'] = log.detail;
          specificLog['Time From'] = log.timeFrom;
          specificLog['Time To'] = log.timeTo;
          specificLog['Initial Meter Reading'] = log.initialMeterReading;
          specificLog['Final Meter Reading'] = log.finalMeterReading;
          specificLog['Kilometers Covered'] = log.kilometersCovered;
          specificLog['Remarks'] = log.remarks;
          break;
        }
      }
      if (specificLog.isNotEmpty) {
        String logString = jsonEncode(specificLog);
        logString = logString.replaceAll("\"", "");
        logString = logString.replaceAll(":", ": ");
        logString = logString.replaceAll("{", "");
        logString = logString.replaceAll("}", "");
        logString = logString.replaceAll(",", "\n");
        Share.share(logString);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Log not found.")),
          );
        }
      }
    } catch (e) {
      debugPrint("Error exporting log: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to export log.")),
        );
      }
    }
  }

  Future<void> _exportLogsToExcel(List<Log> logs) async {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    String rangeLabel = '';

    if (_selectedDateRange != null) {
      String start = formatter.format(_selectedDateRange!.start);
      String end = formatter.format(_selectedDateRange!.end);
      rangeLabel = '_$start-to-$end';
    }

    final excel = Excel.createExcel();
    final Sheet sheet = excel['Logs'];


    // Add a title row
    sheet.appendRow(["Log Export${rangeLabel.isNotEmpty ? ' ($rangeLabel)' : ''}"]);
    sheet.appendRow([]); // Empty row for spacing

    // Add header row
    sheet.appendRow([
      "ID",
      "Name",
      "Date",
      "Purpose",
      "Detail",
      "Time From",
      "Time To",
      "Initial Meter",
      "Final Meter",
      "Kilometers Covered",
      "Remarks",
    ]);

    // Add data rows
    for (var log in logs) {
      sheet.appendRow([
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

    try {
      final excelData = excel.encode();
      final tempDir = await getTemporaryDirectory();
      final fileName = 'logs_export${rangeLabel.isNotEmpty ? '_$rangeLabel' : ''}.xlsx';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(excelData!, flush: true);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Exported Logs${rangeLabel.isNotEmpty ? ' ($rangeLabel)' : ''}',
      );
    } catch (e) {
      debugPrint("Error exporting XLSX: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to export Excel file.")),
        );
      }
    }
  }
}
