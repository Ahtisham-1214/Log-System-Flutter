// lib/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'; // Required for getApplicationDocumentsDirectory
import 'package:path/path.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Get the application documents directory
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'user_database.db');

    // Open the database (or create it if it doesn't exist)
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // Handle database upgrades if schema changes
    );
  }

  // Create the 'users' table
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
        role TEXT NOT NULL DEFAULT 'Driver'
      )
    ''');
    await db.execute('''
      CREATE TABLE logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        detail TEXT NOT NULL,
        purpose TEXT NOT NULL,
        date TEXT NOT NULL,
        timeFrom TEXT NOT NULL,
        timeTo TEXT NOT NULL,
        initialMeterReading REAL NOT NULL,
        finalMeterReading REAL NOT NULL,
        remarks TEXT,
        kilometersCovered REAL NOT NULL
      )
      ''');
  }

  // Handle database upgrades (e.g., adding new columns)
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Example: If you change your schema in a future version
    if (oldVersion < 2) {
      await db.execute('''
      CREATE TABLE logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        detail TEXT NOT NULL,
        purpose TEXT NOT NULL,
        date TEXT NOT NULL,
        timeFrom TEXT NOT NULL,
        timeTo TEXT NOT NULL,
        initialMeterReading REAL NOT NULL,
        finalMeterReading REAL NOT NULL,
        remarks TEXT,
        kilometersCovered REAL NOT NULL
      )
      ''');

    }
    if (oldVersion < 3) {
      await db.execute('''
      ALTER TABLE users ADD COLUMN role TEXT NOT NULL DEFAULT 'Driver';
      ''');
      await db.execute('''
      UPDATE users SET role = 'Admin' WHERE id = 1;
      ''');
    }
  }

  // Close the database (optional, often not strictly necessary for app lifecycle)
  Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null; // Clear the instance
    }
  }
}