// lib/src/cache/cache_manager.dart

import 'dart:async';
import '../models/cache_entry.dart';
import '../exceptions/cache_exceptions.dart';
import 'cache_policy.dart';

/// Manages caching of data with support for custom cache policies.
class CacheManager {
  final Map<String, CacheEntry> _cache = {};
  final CachePolicy _cachePolicy;

  /// Creates a [CacheManager] with the given [CachePolicy].
  CacheManager(this._cachePolicy);

  /// Caches the given [data] with the specified [key].
  Future<void> cacheData(String key, dynamic data) async {
    final entry = CacheEntry(data: data, timestamp: DateTime.now());
    _cache[key] = entry;
    await _cachePolicy.onEntryAdded(key, entry);
  }

  /// Retrieves cached data for the specified [key].
  ///
  /// Throws [CacheEntryNotFoundException] if no cache entry is found.
  /// Throws [CacheEntryExpiredException] if the cache entry has expired.
  Future<dynamic> getData(String key) async {
    final entry = _cache[key];
    if (entry == null) {
      throw CacheEntryNotFoundException('No cache entry found for key: $key');
    }

    if (await _cachePolicy.shouldInvalidate(key, entry)) {
      _cache.remove(key);
      throw CacheEntryExpiredException('Cache entry expired for key: $key');
    }

    return entry.data;
  }

  /// Invalidates the cache entry for the specified [key].
  Future<void> invalidate(String key) async {
    _cache.remove(key);
    await _cachePolicy.onEntryRemoved(key);
  }

  /// Clears all cache entries.
  Future<void> clear() async {
    _cache.clear();
    await _cachePolicy.onCacheCleared();
  }
}
