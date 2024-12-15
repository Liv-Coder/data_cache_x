import 'package:data_cache_x/adapters/cache_adapter.dart';
import 'package:data_cache_x/models/cache_item.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:encrypt/encrypt.dart';

class SqliteAdapter implements CacheAdapter {
  final String? boxName;
  @override
  final bool enableEncryption;
  Database? _database;
  final String _encryptionKey;

  SqliteAdapter(
      {this.boxName, this.enableEncryption = false, String? encryptionKey})
      : _encryptionKey = encryptionKey ?? 'default_secret_key';

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

  String _aesEncrypt(String data) {
    final key = Key.fromUtf8(_encryptionKey.padRight(32, '0').substring(0, 32));
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(data, iv: iv);
    return encrypted.base64;
  }

  String _aesDecrypt(String encryptedData) {
    final key = Key.fromUtf8(_encryptionKey.padRight(32, '0').substring(0, 32));
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));
    final decrypted =
        encrypter.decrypt(Encrypted.fromBase64(encryptedData), iv: iv);
    return decrypted;
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
    dynamic value = item['value'];
    if (enableEncryption) {
      final decryptedValue = _aesDecrypt(value);
      value = jsonDecode(decryptedValue);
    }
    return CacheItem<dynamic>(
      value: value,
      expiry: item['expiry'] != null
          ? DateTime.fromMillisecondsSinceEpoch(item['expiry'] as int)
          : null,
    );
  }

  @override
  Future<void> put(String key, CacheItem<dynamic> item) async {
    final db = await database;
    dynamic value = item.value;
    if (enableEncryption) {
      value = _aesEncrypt(jsonEncode(item.toJson()));
    }
    await db.insert(
      'cache',
      {
        'key': key,
        'value': value,
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
  Future<List<String>> getKeys({int? limit, int? offset}) async {
    final db = await database;
    final result = await db.query(
      'cache',
      columns: ['key'],
      limit: limit,
      offset: offset,
    );
    return result.map((e) => e['key'] as String).toList();
  }
}
