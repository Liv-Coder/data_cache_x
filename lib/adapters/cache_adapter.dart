import 'package:data_cache_x/models/cache_item.dart';

/// An abstract class that defines the interface for cache adapters.
///
/// Cache adapters are responsible for storing and retrieving data from a specific storage mechanism.
/// This abstract class provides a common interface for all cache adapters, allowing them to be used interchangeably.
abstract class CacheAdapter {
  /// Stores a [value] in the cache with the given [key].
  ///
  /// The [value] is wrapped in a [CacheItem] object, which allows for optional expiry.
  ///
  /// Throws a [CacheException] if there is an error storing the data.
  Future<void> put(String key, CacheItem<dynamic> value);

  /// Retrieves the [CacheItem] associated with the given [key].
  ///
  /// Returns `null` if no value is found for the given [key].
  ///
  /// Throws a [CacheException] if there is an error retrieving the data.
  Future<CacheItem<dynamic>?> get(String key);

  /// Deletes the value associated with the given [key].
  ///
  /// Throws a [CacheException] if there is an error deleting the data.
  Future<void> delete(String key);

  /// Clears all data from the cache.
  ///
  /// Throws a [CacheException] if there is an error clearing the cache.
  Future<void> clear();

  /// Checks if the cache contains a value associated with the given [key].
  ///
  /// Returns `true` if the cache contains the key, `false` otherwise.
  Future<bool> containsKey(String key);
}
