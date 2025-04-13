import 'package:data_cache_x/adapters/cache_adapter.dart';
import 'package:data_cache_x/models/cache_item.dart';
import 'package:data_cache_x/models/encryption_options.dart';
import 'package:data_cache_x/utils/encryption.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class SqliteAdapter implements CacheAdapter {
  final String? boxName;
  @override
  final bool enableEncryption;
  Database? _database;
  late final Encryption _encryption;
  late final EncryptionOptions? _encryptionOptions;

  @override
  EncryptionOptions? get encryptionOptions => _encryptionOptions;

  /// Creates a new instance of [SqliteAdapter].
  ///
  /// The [boxName] parameter is used to specify the name of the SQLite database to use.
  /// If no [boxName] is provided, a default name of 'data_cache_x' will be used.
  ///
  /// If [enableEncryption] is true, [encryptionOptions] must be provided.
  /// Throws an [ArgumentError] if encryption is enabled but no options are provided.
  SqliteAdapter({
    this.boxName,
    this.enableEncryption = false,
    String? encryptionKey,
    EncryptionOptions? encryptionOptions,
  }) {
    if (enableEncryption) {
      if (encryptionOptions != null) {
        _encryptionOptions = encryptionOptions;
      } else if (encryptionKey != null) {
        // For backward compatibility
        _encryptionOptions = EncryptionOptions(
          algorithm: EncryptionAlgorithm.aes256,
          key: encryptionKey,
        );
      } else {
        throw ArgumentError(
            'Encryption options or key must be provided when encryption is enabled');
      }
      _encryption = Encryption(
        algorithm: _encryptionOptions!.algorithm,
        encryptionKey: _encryptionOptions.key,
      );
    } else {
      _encryptionOptions = null;
    }
  }

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

  String _encrypt(String data) {
    return _encryption.encrypt(data);
  }

  String _decrypt(String encryptedData) {
    return _encryption.decrypt(encryptedData);
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
      final decryptedValue = _decrypt(value);
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
      value = _encrypt(jsonEncode(item.toJson()));
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

  @override
  Future<List<String>> getKeysByTag(String tag,
      {int? limit, int? offset}) async {
    final db = await database;
    final allItems = await db.query('cache');
    final result = <String>[];
    int count = 0;
    final startIndex = offset ?? 0;

    for (final item in allItems) {
      final key = item['key'] as String;
      final dynamic value = item['value'];

      if (value == null) continue;

      CacheItem<dynamic> cacheItem;
      if (enableEncryption) {
        final decryptedValue = _decrypt(value as String);
        cacheItem = CacheItem.fromJson(jsonDecode(decryptedValue));
      } else {
        final Map<String, dynamic> map = jsonDecode(value as String);
        cacheItem = CacheItem<dynamic>(
          value: map['value'],
          expiry: map['expiry'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['expiry'] as int)
              : null,
        );
      }

      if (cacheItem.tags.contains(tag)) {
        if (count >= startIndex) {
          result.add(key);
          if (limit != null && result.length >= limit) {
            break;
          }
        }
        count++;
      }
    }

    return result;
  }

  @override
  Future<List<String>> getKeysByTags(List<String> tags,
      {int? limit, int? offset}) async {
    final db = await database;
    final allItems = await db.query('cache');
    final result = <String>[];
    int count = 0;
    final startIndex = offset ?? 0;

    for (final item in allItems) {
      final key = item['key'] as String;
      final dynamic value = item['value'];

      if (value == null) continue;

      CacheItem<dynamic> cacheItem;
      if (enableEncryption) {
        final decryptedValue = _decrypt(value as String);
        cacheItem = CacheItem.fromJson(jsonDecode(decryptedValue));
      } else {
        final Map<String, dynamic> map = jsonDecode(value as String);
        cacheItem = CacheItem<dynamic>(
          value: map['value'],
          expiry: map['expiry'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['expiry'] as int)
              : null,
        );
      }

      if (tags.every((tag) => cacheItem.tags.contains(tag))) {
        if (count >= startIndex) {
          result.add(key);
          if (limit != null && result.length >= limit) {
            break;
          }
        }
        count++;
      }
    }

    return result;
  }

  @override
  Future<void> deleteByTag(String tag) async {
    final keysToDelete = await getKeysByTag(tag);
    await deleteAll(keysToDelete);
  }

  @override
  Future<void> deleteByTags(List<String> tags) async {
    final keysToDelete = await getKeysByTags(tags);
    await deleteAll(keysToDelete);
  }

  @override
  Future<void> putAll(Map<String, CacheItem<dynamic>> entries) async {
    final db = await database;
    final batch = db.batch();

    for (final entry in entries.entries) {
      final key = entry.key;
      final item = entry.value;
      dynamic value = item.value;

      if (enableEncryption) {
        value = _encrypt(jsonEncode(item.toJson()));
      }

      batch.insert(
        'cache',
        {
          'key': key,
          'value': value,
          'expiry': item.expiry?.millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  @override
  Future<Map<String, CacheItem<dynamic>>> getAll(List<String> keys) async {
    if (keys.isEmpty) return {};

    final db = await database;
    final placeholders = List.filled(keys.length, '?').join(',');
    final result = await db.query(
      'cache',
      where: 'key IN ($placeholders)',
      whereArgs: keys,
    );

    final Map<String, CacheItem<dynamic>> cacheItems = {};

    for (final row in result) {
      final key = row['key'] as String;
      final dynamic value = row['value'];
      final int? expiryMillis = row['expiry'] as int?;

      if (value == null) continue;

      if (enableEncryption) {
        final decryptedValue = _decrypt(value as String);
        cacheItems[key] = CacheItem.fromJson(jsonDecode(decryptedValue));
      } else {
        cacheItems[key] = CacheItem<dynamic>(
          value: value,
          expiry: expiryMillis != null
              ? DateTime.fromMillisecondsSinceEpoch(expiryMillis)
              : null,
        );
      }
    }

    return cacheItems;
  }

  @override
  Future<void> deleteAll(List<String> keys) async {
    if (keys.isEmpty) return;

    final db = await database;
    final placeholders = List.filled(keys.length, '?').join(',');
    await db.delete(
      'cache',
      where: 'key IN ($placeholders)',
      whereArgs: keys,
    );
  }

  @override
  Future<Map<String, bool>> containsKeys(List<String> keys) async {
    if (keys.isEmpty) return {};

    final db = await database;
    final placeholders = List.filled(keys.length, '?').join(',');
    final result = await db.query(
      'cache',
      columns: ['key'],
      where: 'key IN ($placeholders)',
      whereArgs: keys,
    );

    final foundKeys = result.map((e) => e['key'] as String).toSet();
    final Map<String, bool> containsMap = {};

    for (final key in keys) {
      containsMap[key] = foundKeys.contains(key);
    }

    return containsMap;
  }
}
