import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/student_record.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('student_record.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    return await openDatabase(
      join(dbPath, filePath),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE student_record(id INTEGER PRIMARY KEY, name TEXT, age INTEGER, address TEXT, isFavorite INTEGER)',
        );
      },
      version: 1,
    );
  }

  Future<void> addRecord(Record record) async {
    final db = await instance.database;
    await db.insert('student_record', record.toMap());
  }

  Future<List<Record>> fetchRecords() async {
    final db = await instance.database;
    final maps = await db.query('student_record');
    return List.generate(maps.length, (i) => Record.fromMap(maps[i]));
  }

  Future<void> updateRecord(Record record) async {
    final db = await instance.database;
    await db.update('student_record', record.toMap(), where: 'id = ?', whereArgs: [record.id]);
  }

  Future<void> deleteRecord(int id) async {
    final db = await instance.database;
    await db.delete('student_record', where: 'id = ?', whereArgs: [id]);
  }
}