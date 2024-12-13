import 'package:data_cache_x/adapters/cache_adapter.dart';
import 'package:data_cache_x/core/exception.dart';
import 'package:data_cache_x/models/cache_item.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';

class DataCacheX {
  final CacheAdapter _cacheAdapter;

  DataCacheX(this._cacheAdapter);

  final _log = Logger('DataCache');

  Future<void> put<T>(String key, T value, {Duration? expiry}) async {
    try {
      final cacheItem = CacheItem(
        value: value,
        expiry: expiry != null ? DateTime.now().add(expiry) : null,
      );
      await _cacheAdapter.put(key, cacheItem);
    } on HiveError catch (e) {
      _log.severe('Failed to put data into cache (HiveError): $e');
      throw CacheException('Failed to put data into cache: ${e.message}');
    } catch (e) {
      _log.severe('Failed to put data into cache (Unknown Error): $e');
      throw CacheException('Failed to put data into cache: $e');
    }
  }

  Future<T?> get<T>(String key) async {
    if (key.isEmpty) {
      throw ArgumentError('Key cannot be empty');
    }
    try {
      final cacheItem = await _cacheAdapter.get(key);
      if (cacheItem == null) {
        return null;
      }

      if (cacheItem.isExpired) {
        await delete(key);
        return null;
      }

      return cacheItem.value as T;
    } on HiveError catch (e) {
      _log.severe('Failed to get data from cache (HiveError): $e');
      throw CacheException('Failed to get data from cache: ${e.message}');
    } catch (e) {
      _log.severe('Failed to get data from cache (Unknown Error): $e');
      throw CacheException('Failed to get data from cache: $e');
    }
  }

  Future<void> delete(String key) async {
    if (key.isEmpty) {
      throw ArgumentError('Key cannot be empty');
    }
    try {
      await _cacheAdapter.delete(key);
    } on HiveError catch (e) {
      _log.severe('Failed to delete data from cache (HiveError): $e');
      throw CacheException('Failed to delete data from cache: ${e.message}');
    } catch (e) {
      _log.severe('Failed to delete data from cache (Unknown Error): $e');
      throw CacheException('Failed to delete data from cache: $e');
    }
  }

  Future<void> clear() async {
    try {
      await _cacheAdapter.clear();
    } catch (e) {
      throw CacheException('Failed to clear cache: $e');
    }
  }

  Future<bool> containsKey(String key) async {
    try {
      if (key.isEmpty) {
        throw ArgumentError('Key cannot be empty');
      }
      return await _cacheAdapter.containsKey(key);
    } on HiveError catch (e) {
      _log.severe('Failed to check if key exists in cache (HiveError): $e');
      throw CacheException(
          'Failed to check if key exists in cache: ${e.message}');
    } catch (e) {
      _log.severe('Failed to check if key exists in cache (Unknown Error): $e');
      throw CacheException('Failed to check if key exists in cache: $e');
    }
  }
}
