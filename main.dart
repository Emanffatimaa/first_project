import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'login-screen.dart';

// Main entry point of the app
void main() {
  runApp(MyApp());
}

// Database Helper Class to manage SQLite database operations
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Getter for database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('users.db');
    return _database!;
  }

  // Initialize database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Create the database schema (users table)
  Future _createDB(Database db, int version) async {
    await db.execute(''' 
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE,
        password TEXT
      )
    ''');
  }

  // Insert a new user into the database
  Future<int> insertUser(String email, String password) async {
    final db = await instance.database;
    return await db.insert(
      'users',
      {'email': email, 'password': password},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch a user by email and password
  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }
}

// Main App Widget (entry point for the UI)
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Signup & Login with SQLite',
      debugShowCheckedModeBanner: false,
      home: SignUpScreen(),
    );
  }
}
// SignUp Screen widget


// Home Screen widget to display welcome message
class HomeScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  HomeScreen({required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Screen')),
      body: Center(
        child: Text(
          'Welcome, ${userData['email']}!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
