// lib/src/cache/cache_policy.dart

import '../models/cache_entry.dart';

abstract class CachePolicy {
  Future<bool> shouldInvalidate(String key, CacheEntry entry);
  Future<void> onEntryAdded(String key, CacheEntry entry);
  Future<void> onEntryRemoved(String key);
  Future<void> onCacheCleared();
}

class TimedExpirationCachePolicy implements CachePolicy {
  final Duration _expirationDuration;

  TimedExpirationCachePolicy(this._expirationDuration);

  @override
  Future<bool> shouldInvalidate(String key, CacheEntry entry) async {
    return DateTime.now().difference(entry.timestamp) > _expirationDuration;
  }

  @override
  Future<void> onEntryAdded(String key, CacheEntry entry) async {}

  @override
  Future<void> onEntryRemoved(String key) async {}

  @override
  Future<void> onCacheCleared() async {}
}
