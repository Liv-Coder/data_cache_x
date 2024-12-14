import 'package:data_cache_x/adapters/cache_adapter.dart';
import 'package:data_cache_x/core/exception.dart';
import 'package:data_cache_x/models/cache_item.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';

/// The main class for interacting with the cache.
///
/// `DataCacheX` provides methods for storing, retrieving, and deleting data.
/// It uses a [CacheAdapter] to handle the underlying storage.
///
/// The generic type parameter `T` represents the type of data that the cache will store.
///
/// Example:
/// ```dart
/// // Assuming you have a HiveAdapter instance
/// final hiveAdapter = HiveAdapter<String>(CacheItemStringAdapter());
/// await hiveAdapter.init();
///
/// // Create a DataCacheX instance
/// final dataCache = DataCacheX<String>(hiveAdapter);
///
/// // Store a value
/// await dataCache.put('name', 'John Doe', expiry: Duration(seconds: 30));
///
/// // Retrieve a value
/// final name = await dataCache.get('name');
/// print(name); // Output: John Doe
///
/// // Delete a value
/// await dataCache.delete('name');
///
/// // Clear the cache
/// await dataCache.clear();
/// ```
class DataCacheX<T> {
  final CacheAdapter<T> _cacheAdapter;

  /// Creates a new instance of [DataCacheX].
  ///
  /// The [cacheAdapter] parameter is required to handle the underlying storage.
  DataCacheX(this._cacheAdapter);

  final _log = Logger('DataCache');

  /// Stores a [value] in the cache with the given [key].
  ///
  /// The [expiry] parameter can be used to set an optional expiry time for the data.
  ///
  /// Throws a [CacheException] if there is an error storing the data.
  Future<void> put(String key, T value, {Duration? expiry}) async {
    try {
      final cacheItem = CacheItem<T>(
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

  /// Retrieves the value associated with the given [key].
  ///
  /// Returns `null` if no value is found for the given [key] or if the value is expired.
  ///
  /// Throws an [ArgumentError] if the key is empty.
  /// Throws a [CacheException] if there is an error retrieving the data.
  Future<T?> get(String key) async {
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

      return cacheItem.value;
    } on HiveError catch (e) {
      _log.severe('Failed to get data from cache (HiveError): $e');
      throw CacheException('Failed to get data from cache: ${e.message}');
    } catch (e) {
      _log.severe('Failed to get data from cache (Unknown Error): $e');
      throw CacheException('Failed to get data from cache: $e');
    }
  }

  /// Deletes the value associated with the given [key].
  ///
  /// Throws an [ArgumentError] if the key is empty.
  /// Throws a [CacheException] if there is an error deleting the data.
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

  /// Clears all data from the cache.
  ///
  /// Throws a [CacheException] if there is an error clearing the cache.
  Future<void> clear() async {
    try {
      await _cacheAdapter.clear();
    } catch (e) {
      throw CacheException('Failed to clear cache: $e');
    }
  }

  /// Checks if the cache contains a value associated with the given [key].
  ///
  /// Throws an [ArgumentError] if the key is empty.
  /// Throws a [CacheException] if there is an error checking the key.
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
