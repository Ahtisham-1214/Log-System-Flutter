import 'database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'log.dart';

class LogRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> insertLog(Log log) async {
    final db = await _databaseHelper.database;
    return await db.insert(
      'logs',
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Log>> getAllLogs() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('logs');

    return List.generate(maps.length, (i) {
      return Log(
        id: maps[i]['id'],
        name: maps[i]['name'],
        detail: maps[i]['detail'],
        purpose: maps[i]['purpose'],
        date: maps[i]['date'],
        timeFrom: maps[i]['timeFrom'],
        timeTo: maps[i]['timeTo'],
        remarks: maps[i]['remarks'],
        initialMeterReading: maps[i]['initialMeterReading'],
        finalMeterReading: maps[i]['finalMeterReading'],
        kilometersCovered: maps[i]['kilometersCovered'],
      );
    });
  }
}
