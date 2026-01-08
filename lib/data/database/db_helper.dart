import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  // ===============================
  // GET DATABASE
  // ===============================
  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  // ===============================
  // INIT DATABASE
  // ===============================
  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'inventory.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        // ===============================
        // USERS TABLE
        // ===============================
        await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT UNIQUE,
          password TEXT,
          role TEXT
        )
        ''');

        // ===============================
        // DEFAULT USERS
        // ===============================
        await db.insert('users', {
          'username': 'admin',
          'password': '123',
          'role': 'admin',
        });

        await db.insert('users', {
          'username': 'kasir',
          'password': '123',
          'role': 'kasir',
        });
      },
    );
  }

  // ===============================
  // OPTIONAL: RESET DB (DEV ONLY)
  // ===============================
  static Future<void> resetDatabase() async {
    final path = join(await getDatabasesPath(), 'inventory.db');
    await deleteDatabase(path);
    _db = null;
  }
}
