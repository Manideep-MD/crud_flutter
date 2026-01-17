import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;
  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('users.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final DbPath = await getDatabasesPath();
    final path = join(DbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute(''' 
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        name TEXT, 
        email TEXT
      )
    ''');
  }

  Future<int> insetUser(Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert('users', data);
  }

  Future<List<Map<String, dynamic>>> getUser() async {
    final db = await instance.database;
    return await db.query('users');
  }

  Future<int> deleteUser(int id) async {
    final db = await instance.database;
    return await db.delete('users', where: 'id=?', whereArgs: [id]);
  }
}
