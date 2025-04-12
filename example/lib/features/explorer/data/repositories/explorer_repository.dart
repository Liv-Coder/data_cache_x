import 'package:data_cache_x/data_cache_x.dart';
import 'package:get_it/get_it.dart';

import '../models/cache_entry.dart';

class ExplorerRepository {
  final DataCacheX _cache;

  ExplorerRepository({DataCacheX? cache})
      : _cache = cache ?? GetIt.I<DataCacheX>();

  /// Gets all cache entries
  Future<List<CacheEntry>> getAllEntries() async {
    try {
      // Use analytics to get information about cached items
      final entries = <CacheEntry>[];

      // Get most frequently accessed keys
      final frequentKeys = _cache.mostFrequentlyAccessedKeys;
      for (final entry in frequentKeys) {
        final key = entry.key;
        final accessCount = entry.value;

        // Try to get the value to check if it exists and isn't expired
        final value = await _cache.get(key);
        if (value != null) {
          entries.add(
            CacheEntry(
              key: key,
              size: 0, // We don't have direct access to size
              createdAt: DateTime.now()
                  .subtract(const Duration(days: 1)), // Placeholder
              expiresAt: null, // We don't have direct access to expiry
              lastAccessedAt: DateTime.now(), // Placeholder
              accessCount: accessCount,
              priority: CachePriority.normal, // Default
              isCompressed: false, // We don't know
              isEncrypted: false, // We don't know
            ),
          );
        }
      }

      // Get largest items
      final largestItems = _cache.largestItems;
      for (final entry in largestItems) {
        final key = entry.key;
        final size = entry.value;

        // Skip if already added
        if (entries.any((e) => e.key == key)) continue;

        // Try to get the value to check if it exists and isn't expired
        final value = await _cache.get(key);
        if (value != null) {
          entries.add(
            CacheEntry(
              key: key,
              size: size,
              createdAt: DateTime.now()
                  .subtract(const Duration(days: 1)), // Placeholder
              expiresAt: null, // We don't have direct access to expiry
              lastAccessedAt: DateTime.now(), // Placeholder
              accessCount: 1, // Default
              priority: CachePriority.normal, // Default
              isCompressed: false, // We don't know
              isEncrypted: false, // We don't know
            ),
          );
        }
      }

      // Get most recently accessed keys
      final recentKeys = _cache.mostRecentlyAccessedKeys;
      for (final entry in recentKeys) {
        final key = entry.key;
        final lastAccessedAt = entry.value;

        // Skip if already added
        if (entries.any((e) => e.key == key)) continue;

        // Try to get the value to check if it exists and isn't expired
        final value = await _cache.get(key);
        if (value != null) {
          entries.add(
            CacheEntry(
              key: key,
              size: 0, // We don't have direct access to size
              createdAt: DateTime.now()
                  .subtract(const Duration(days: 1)), // Placeholder
              expiresAt: null, // We don't have direct access to expiry
              lastAccessedAt: lastAccessedAt,
              accessCount: 1, // Default
              priority: CachePriority.normal, // Default
              isCompressed: false, // We don't know
              isEncrypted: false, // We don't know
            ),
          );
        }
      }

      // Sort by last accessed time (most recent first)
      entries.sort((a, b) => b.lastAccessedAt.compareTo(a.lastAccessedAt));

      return entries;
    } catch (e) {
      return [];
    }
  }

  /// Gets the value for a specific key
  Future<String?> getEntryValue(String key) async {
    try {
      final value = await _cache.get<dynamic>(key);
      if (value == null) {
        return null;
      }

      // Convert value to string representation
      if (value is String) {
        return value;
      } else if (value is Map || value is List) {
        return value.toString();
      } else {
        return value.toString();
      }
    } catch (e) {
      return null;
    }
  }

  /// Deletes a specific entry
  Future<bool> deleteEntry(String key) async {
    try {
      await _cache.delete(key);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Clears all entries
  Future<bool> clearAll() async {
    try {
      await _cache.clear();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Gets cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      // Get total size from analytics
      final totalSize = _cache.totalSize;

      // Count entries from our getAllEntries method
      final entries = await getAllEntries();
      final totalEntries = entries.length;

      // We don't have direct access to compression and encryption info
      // so we'll just return 0 for these values
      const compressedCount = 0;
      const encryptedCount = 0;

      return {
        'totalEntries': totalEntries,
        'totalSize': totalSize,
        'compressedCount': compressedCount,
        'encryptedCount': encryptedCount,
      };
    } catch (e) {
      return {
        'totalEntries': 0,
        'totalSize': 0,
        'compressedCount': 0,
        'encryptedCount': 0,
      };
    }
  }
}
