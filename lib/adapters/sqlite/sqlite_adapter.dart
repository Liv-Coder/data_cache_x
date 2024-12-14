import 'package:data_cache_x/adapters/cache_adapter.dart';
import 'package:data_cache_x/models/cache_item.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqliteAdapter implements CacheAdapter {
  final String? boxName;
  @override
  final bool enableEncryption;
  Database? _database;

  SqliteAdapter({this.boxName, this.enableEncryption = false});

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, '${boxName ?? 'data_cache_x'}.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cache (
        key TEXT PRIMARY KEY,
        value BLOB,
        expiry INTEGER
      )
    ''');
  }

  @override
  Future<void> clear() async {
    final db = await database;
    await db.delete('cache');
  }

  @override
  Future<void> delete(String key) async {
    final db = await database;
    await db.delete('cache', where: 'key = ?', whereArgs: [key]);
  }

  @override
  Future<CacheItem<dynamic>?> get(String key) async {
    final db = await database;
    final result = await db.query('cache', where: 'key = ?', whereArgs: [key]);
    if (result.isEmpty) {
      return null;
    }
    final item = result.first;
    return CacheItem<dynamic>(
      value: item['value'],
      expiry: item['expiry'] != null
          ? DateTime.fromMillisecondsSinceEpoch(item['expiry'] as int)
          : null,
    );
  }

  @override
  Future<void> put(String key, CacheItem<dynamic> item) async {
    final db = await database;
    await db.insert(
      'cache',
      {
        'key': key,
        'value': item.value,
        'expiry': item.expiry?.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<bool> containsKey(String key) async {
    final db = await database;
    final result = await db.query('cache', where: 'key = ?', whereArgs: [key]);
    return result.isNotEmpty;
  }

  @override
  Future<List<String>> getKeys() async {
    final db = await database;
    final result = await db.query('cache', columns: ['key']);
    return result.map((e) => e['key'] as String).toList();
  }
}
