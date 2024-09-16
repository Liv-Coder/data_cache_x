// lib/src/cache/cache_manager.dart

import 'dart:async';
import '../models/cache_entry.dart';
import '../exceptions/cache_exceptions.dart';
import 'cache_policy.dart';

class CacheManager {
  final Map<String, CacheEntry> _cache = {};
  final CachePolicy _cachePolicy;

  CacheManager(this._cachePolicy);

  Future<void> cacheData(String key, dynamic data) async {
    final entry = CacheEntry(data: data, timestamp: DateTime.now());
    _cache[key] = entry;
    await _cachePolicy.onEntryAdded(key, entry);
  }

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

  Future<void> invalidate(String key) async {
    _cache.remove(key);
    await _cachePolicy.onEntryRemoved(key);
  }

  Future<void> clear() async {
    _cache.clear();
    await _cachePolicy.onCacheCleared();
  }
}
