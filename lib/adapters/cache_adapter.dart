import 'package:data_cache_x/models/cache_item.dart';
import 'package:data_cache_x/models/encryption_options.dart';

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

  /// Stores multiple values in the cache with the given keys.
  ///
  /// Each value is wrapped in a [CacheItem] object, which allows for optional expiry.
  ///
  /// Throws a [CacheException] if there is an error storing the data.
  Future<void> putAll(Map<String, CacheItem<dynamic>> entries) async {
    // Default implementation that calls put for each entry
    // Subclasses should override this with a more efficient implementation if possible
    for (final entry in entries.entries) {
      await put(entry.key, entry.value);
    }
  }

  /// Retrieves the [CacheItem] associated with the given [key].
  ///
  /// Returns `null` if no value is found for the given [key].
  ///
  /// Throws a [CacheException] if there is an error retrieving the data.
  Future<CacheItem<dynamic>?> get(String key);

  /// Retrieves multiple [CacheItem]s associated with the given [keys].
  ///
  /// Returns a map where the keys are the original keys and the values are the retrieved [CacheItem]s.
  /// If a key is not found in the cache, it will not be included in the returned map.
  ///
  /// Throws a [CacheException] if there is an error retrieving the data.
  Future<Map<String, CacheItem<dynamic>>> getAll(List<String> keys) async {
    // Default implementation that calls get for each key
    // Subclasses should override this with a more efficient implementation if possible
    final result = <String, CacheItem<dynamic>>{};
    for (final key in keys) {
      final value = await get(key);
      if (value != null) {
        result[key] = value;
      }
    }
    return result;
  }

  /// Deletes the value associated with the given [key].
  ///
  /// Throws a [CacheException] if there is an error deleting the data.
  Future<void> delete(String key);

  /// Deletes multiple values associated with the given [keys].
  ///
  /// Throws a [CacheException] if there is an error deleting the data.
  Future<void> deleteAll(List<String> keys) async {
    // Default implementation that calls delete for each key
    // Subclasses should override this with a more efficient implementation if possible
    for (final key in keys) {
      await delete(key);
    }
  }

  /// Clears all data from the cache.
  ///
  /// Throws a [CacheException] if there is an error clearing the cache.
  Future<void> clear();

  /// Checks if the cache contains a value associated with the given [key].
  ///
  /// Returns `true` if the cache contains the key, `false` otherwise.
  Future<bool> containsKey(String key);

  /// Checks if the cache contains values associated with all the given [keys].
  ///
  /// Returns a map where the keys are the original keys and the values are booleans
  /// indicating whether the key exists in the cache.
  ///
  /// Throws a [CacheException] if there is an error checking the keys.
  Future<Map<String, bool>> containsKeys(List<String> keys) async {
    // Default implementation that calls containsKey for each key
    // Subclasses should override this with a more efficient implementation if possible
    final result = <String, bool>{};
    for (final key in keys) {
      result[key] = await containsKey(key);
    }
    return result;
  }

  /// Returns a list of all keys in the cache.
  ///
  /// Throws a [CacheException] if there is an error retrieving the keys.
  /// The [limit] and [offset] parameters can be used to paginate the results.
  Future<List<String>> getKeys({int? limit, int? offset});

  /// Returns a list of all keys in the cache that have the specified tag.
  ///
  /// Throws a [CacheException] if there is an error retrieving the keys.
  /// The [limit] and [offset] parameters can be used to paginate the results.
  Future<List<String>> getKeysByTag(String tag, {int? limit, int? offset});

  /// Returns a list of all keys in the cache that have all the specified tags.
  ///
  /// Throws a [CacheException] if there is an error retrieving the keys.
  /// The [limit] and [offset] parameters can be used to paginate the results.
  Future<List<String>> getKeysByTags(List<String> tags,
      {int? limit, int? offset});

  /// Deletes all items in the cache that have the specified tag.
  ///
  /// Throws a [CacheException] if there is an error deleting the items.
  Future<void> deleteByTag(String tag);

  /// Deletes all items in the cache that have all the specified tags.
  ///
  /// Throws a [CacheException] if there is an error deleting the items.
  Future<void> deleteByTags(List<String> tags);

  /// Indicates if encryption is enabled for this adapter.
  bool get enableEncryption;

  /// Returns the encryption options for this adapter.
  ///
  /// Returns `null` if encryption is not enabled.
  EncryptionOptions? get encryptionOptions;
}
