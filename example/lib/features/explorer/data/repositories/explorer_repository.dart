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
          // Try to get tags for this key
          final tags = await _getTagsForKey(key);

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
              tags: tags,
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
          // Try to get tags for this key
          final tags = await _getTagsForKey(key);

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
              tags: tags,
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
          // Try to get tags for this key
          final tags = await _getTagsForKey(key);

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
              tags: tags,
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

  /// Helper method to get tags for a key
  Future<Set<String>> _getTagsForKey(String key) async {
    try {
      // This is a workaround since we don't have direct access to tags
      // In a real implementation, we would use the adapter's API to get tags

      // Try to find tags by checking if this key is returned by getKeysByTag
      // for each known tag
      final allTags = await getAllTags();
      final keyTags = <String>{};

      for (final tag in allTags) {
        final keys = await _cache.getKeysByTag(tag);
        if (keys.contains(key)) {
          keyTags.add(tag);
        }
      }

      return keyTags;
    } catch (e) {
      return {};
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

      // Get all tags
      final allTags = await getAllTags();
      final tagCount = allTags.length;

      // We don't have direct access to compression and encryption info
      // so we'll just return 0 for these values
      const compressedCount = 0;
      const encryptedCount = 0;

      return {
        'totalEntries': totalEntries,
        'totalSize': totalSize,
        'compressedCount': compressedCount,
        'encryptedCount': encryptedCount,
        'tagCount': tagCount,
      };
    } catch (e) {
      return {
        'totalEntries': 0,
        'totalSize': 0,
        'compressedCount': 0,
        'encryptedCount': 0,
        'tagCount': 0,
      };
    }
  }

  /// Gets all available tags in the cache
  Future<Set<String>> getAllTags() async {
    try {
      // This is a sample implementation with some common tags
      // In a real implementation, we would scan all cache items for their tags
      final sampleTags = <String>{
        'user',
        'settings',
        'profile',
        'data',
        'image',
        'temp',
        'config',
        'api',
        'response',
        'favorite'
      };

      // Check which tags actually have keys associated with them
      final validTags = <String>{};
      for (final tag in sampleTags) {
        final keys = await _cache.getKeysByTag(tag);
        if (keys.isNotEmpty) {
          validTags.add(tag);
        }
      }

      return validTags;
    } catch (e) {
      return {};
    }
  }

  /// Gets entries by tag
  Future<List<CacheEntry>> getEntriesByTag(String tag) async {
    try {
      final keys = await _cache.getKeysByTag(tag);
      final entries = <CacheEntry>[];

      for (final key in keys) {
        final value = await _cache.get(key);
        if (value != null) {
          // Get all tags for this key
          final tags = await _getTagsForKey(key);

          // Get size if available
          int size = 0;
          final largestItems = _cache.largestItems;
          for (final item in largestItems) {
            if (item.key == key) {
              size = item.value;
              break;
            }
          }

          entries.add(
            CacheEntry(
              key: key,
              size: size,
              createdAt: DateTime.now().subtract(const Duration(days: 1)),
              expiresAt: null,
              lastAccessedAt: DateTime.now(),
              accessCount: 1,
              priority: CachePriority.normal,
              isCompressed: false,
              isEncrypted: false,
              tags: tags,
            ),
          );
        }
      }

      return entries;
    } catch (e) {
      return [];
    }
  }

  /// Deletes entries by tag
  Future<bool> deleteByTag(String tag) async {
    try {
      await _cache.deleteByTag(tag);
      return true;
    } catch (e) {
      return false;
    }
  }
}
