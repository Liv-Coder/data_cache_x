import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDataSource {
  static final LocalDataSource _instance = LocalDataSource._internal();
  factory LocalDataSource() => _instance;
  LocalDataSource._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'cache.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE cache(key TEXT PRIMARY KEY, data TEXT)',
        );
      },
    );
  }

  Future<void> insertCache(String key, String data) async {
    final db = await database;
    await db.insert(
      'cache',
      {
        'key': key,
        'data': data,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getCache(String key) async {
    final db = await database;
    final result = await db.query(
      'cache',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (result.isNotEmpty) {
      return result.first['data'] as String?;
    }
    return null;
  }

  Future<void> deleteCache(String key) async {
    final db = await database;
    await db.delete(
      'cache',
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  Future<void> clearAllCache() async {
    final db = await database;
    await db.delete('cache');
  }
}
