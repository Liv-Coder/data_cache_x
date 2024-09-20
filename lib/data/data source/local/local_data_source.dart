import 'dart:convert';
import 'dart:io';

import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../../domain/error/cache_execption.dart';
import '../../../presentation/cache_debug_printer.dart';

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
          'CREATE TABLE cache(key TEXT PRIMARY KEY, data BLOB, expirationDuration INTEGER, timestamp INTEGER, isCompressed INTEGER)',
        );
      },
    );
  }

  Future<void> insertCache(
    String key,
    String data,
    Duration expirationDuration,
    bool compress,
  ) async {
    try {
      final db = await database;
      List<int> compressedData;
      if (compress) {
        compressedData = gzip.encode(utf8.encode(data));
      } else {
        compressedData = utf8.encode(data);
      }
      await db.insert(
        'cache',
        {
          'key': key,
          'data': compressedData,
          'expirationDuration': expirationDuration.inMilliseconds,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'isCompressed': compress ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheException(message: 'Failed to insert cache: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>?> getCache(String key) async {
    try {
      final db = await database;
      final result = await db.query(
        'cache',
        where: 'key = ?',
        whereArgs: [key],
      );
      if (result.isNotEmpty) {
        final cacheEntry = Map<String, dynamic>.from(result.first);
        final compressedData = cacheEntry['data'] as List<int>;
        final isCompressed = cacheEntry['isCompressed'] == 1;

        String decompressedData;
        if (isCompressed) {
          decompressedData = utf8.decode(gzip.decode(compressedData));
        } else {
          decompressedData = utf8.decode(compressedData);
        }

        cacheEntry['data'] = decompressedData;
        cacheEntry['expirationDuration'] =
            Duration(milliseconds: cacheEntry['expirationDuration']);
        return cacheEntry;
      }
      return null;
    } catch (e) {
      throw CacheException(message: 'Failed to get cache: ${e.toString()}');
    }
  }

  Future<void> deleteCache(String key) async {
    try {
      final db = await database;
      await db.delete(
        'cache',
        where: 'key = ?',
        whereArgs: [key],
      );
    } catch (e) {
      throw CacheException(message: 'Failed to delete cache: ${e.toString()}');
    }
  }

  Future<void> clearAllCache() async {
    try {
      final db = await database;
      await db.delete('cache');
    } catch (e) {
      throw CacheException(
          message: 'Failed to clear all cache: ${e.toString()}');
    }
  }

  Future<void> printCacheContents() async {
    try {
      final db = await database;
      final cacheEntries = await db.query('cache');
      CacheDebugTablePrinter.printCacheContents(cacheEntries);
    } catch (e) {
      Logger().e('Failed to print cache contents: ${e.toString()}');
    }
  }

  bool _isValidJson(String jsonString) {
    try {
      jsonDecode(jsonString);
      return true;
    } catch (e) {
      return false;
    }
  }
}
