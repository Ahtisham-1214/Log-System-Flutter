import 'database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'log.dart';

class LogRepository{
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> insertLog(Log log) async {
    final db = await _databaseHelper.database;
    return await db.insert(
      'logs',
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }



}