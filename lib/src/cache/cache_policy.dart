// lib/src/cache/cache_policy.dart

import '../models/cache_entry.dart';

/// An abstract class that defines the contract for cache policies.
abstract class CachePolicy {
  /// Determines whether a cache entry should be invalidated.
  ///
  /// Returns `true` if the entry should be invalidated, otherwise `false`.
  Future<bool> shouldInvalidate(String key, CacheEntry entry);

  /// Called when a new entry is added to the cache.
  Future<void> onEntryAdded(String key, CacheEntry entry);

  /// Called when an entry is removed from the cache.
  Future<void> onEntryRemoved(String key);

  /// Called when the entire cache is cleared.
  Future<void> onCacheCleared();
}

/// A cache policy that invalidates entries based on a fixed expiration duration.
class TimedExpirationCachePolicy implements CachePolicy {
  final Duration _expirationDuration;

  /// Creates a [TimedExpirationCachePolicy] with the given expiration duration.
  TimedExpirationCachePolicy(this._expirationDuration);

  @override
  Future<bool> shouldInvalidate(String key, CacheEntry entry) async {
    // Invalidate the entry if it is older than the expiration duration.
    return DateTime.now().difference(entry.timestamp) > _expirationDuration;
  }

  @override
  Future<void> onEntryAdded(String key, CacheEntry entry) async {
    // No additional actions needed when an entry is added.
  }

  @override
  Future<void> onEntryRemoved(String key) async {
    // No additional actions needed when an entry is removed.
  }

  @override
  Future<void> onCacheCleared() async {
    // No additional actions needed when the cache is cleared.
  }
}
