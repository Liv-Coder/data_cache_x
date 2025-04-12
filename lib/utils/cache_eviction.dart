import 'package:data_cache_x/analytics/cache_analytics.dart';
import 'package:data_cache_x/adapters/cache_adapter.dart';
import 'package:data_cache_x/models/cache_item.dart';
import 'package:data_cache_x/models/cache_policy.dart';
import 'package:logging/logging.dart';

/// A class that handles cache eviction strategies.
class CacheEviction {
  /// The cache adapter to use for eviction.
  final CacheAdapter _cacheAdapter;

  /// The analytics instance to use for eviction decisions.
  final CacheAnalytics _analytics;

  /// The maximum size of the cache in bytes.
  final int? _maxSize;

  /// The maximum number of items in the cache.
  final int? _maxItems;

  /// The eviction strategy to use.
  final EvictionStrategy _strategy;

  /// The logger instance.
  final _log = Logger('CacheEviction');

  /// Creates a new instance of [CacheEviction].
  CacheEviction(
    this._cacheAdapter,
    this._analytics, {
    int? maxSize,
    int? maxItems,
    EvictionStrategy strategy = EvictionStrategy.lru,
  })  : _maxSize = maxSize,
        _maxItems = maxItems,
        _strategy = strategy;

  /// Checks if the cache needs eviction and performs it if necessary.
  ///
  /// Returns `true` if eviction was performed, `false` otherwise.
  Future<bool> checkAndEvict() async {
    if (_maxSize == null && _maxItems == null) {
      return false; // No limits set, no eviction needed
    }

    bool needsEviction = false;

    // Check if we're over the size limit
    if (_maxSize != null && _analytics.totalSize > _maxSize) {
      _log.info(
          'Cache size (${_analytics.totalSize}) exceeds maximum size ($_maxSize). Evicting items...');
      needsEviction = true;
    }

    // Check if we're over the item count limit
    if (_maxItems != null) {
      final keys = await _cacheAdapter.getKeys();
      if (keys.length > _maxItems) {
        _log.info(
            'Cache item count (${keys.length}) exceeds maximum count ($_maxItems). Evicting items...');
        needsEviction = true;
      }
    }

    if (needsEviction) {
      return await _evictItems();
    }

    return false;
  }

  /// Evicts items from the cache based on the eviction strategy.
  ///
  /// Returns `true` if eviction was performed, `false` otherwise.
  Future<bool> _evictItems() async {
    switch (_strategy) {
      case EvictionStrategy.lru:
        return await _evictLRU();
      case EvictionStrategy.lfu:
        return await _evictLFU();
      case EvictionStrategy.fifo:
        return await _evictFIFO();
      case EvictionStrategy.ttl:
        return await _evictTTL();
    }
  }

  /// Evicts items using the Least Recently Used (LRU) strategy.
  ///
  /// Returns `true` if eviction was performed, `false` otherwise.
  Future<bool> _evictLRU() async {
    // Get the least recently accessed keys from analytics
    final recentlyAccessedKeys =
        _analytics.mostRecentlyAccessedKeys.reversed.toList();

    if (recentlyAccessedKeys.isEmpty) {
      _log.warning(
          'No access data available for LRU eviction. Falling back to FIFO.');
      return await _evictFIFO();
    }

    // Start evicting from the least recently used
    bool evicted = false;
    for (final entry in recentlyAccessedKeys) {
      final key = entry.key;

      // Skip high priority items unless absolutely necessary
      final cacheItem = await _cacheAdapter.get(key);
      if (cacheItem != null && cacheItem.priority == CachePriority.critical) {
        continue; // Skip critical items
      }

      // Evict the item
      await _cacheAdapter.delete(key);
      _analytics.recordDelete(key);
      evicted = true;

      _log.info('Evicted item with key: $key (LRU strategy)');

      // Check if we've evicted enough
      if (_maxSize != null && _analytics.totalSize <= _maxSize * 0.8) {
        _log.info('Eviction complete. New cache size: ${_analytics.totalSize}');
        break;
      }

      if (_maxItems != null) {
        final keys = await _cacheAdapter.getKeys();
        if (keys.length <= _maxItems * 0.8) {
          _log.info('Eviction complete. New item count: ${keys.length}');
          break;
        }
      }
    }

    return evicted;
  }

  /// Evicts items using the Least Frequently Used (LFU) strategy.
  ///
  /// Returns `true` if eviction was performed, `false` otherwise.
  Future<bool> _evictLFU() async {
    // Get the least frequently accessed keys from analytics
    final frequentlyAccessedKeys =
        _analytics.mostFrequentlyAccessedKeys.reversed.toList();

    if (frequentlyAccessedKeys.isEmpty) {
      _log.warning(
          'No access data available for LFU eviction. Falling back to FIFO.');
      return await _evictFIFO();
    }

    // Start evicting from the least frequently used
    bool evicted = false;
    for (final entry in frequentlyAccessedKeys) {
      final key = entry.key;

      // Skip high priority items unless absolutely necessary
      final cacheItem = await _cacheAdapter.get(key);
      if (cacheItem != null && cacheItem.priority == CachePriority.critical) {
        continue; // Skip critical items
      }

      // Evict the item
      await _cacheAdapter.delete(key);
      _analytics.recordDelete(key);
      evicted = true;

      _log.info('Evicted item with key: $key (LFU strategy)');

      // Check if we've evicted enough
      if (_maxSize != null && _analytics.totalSize <= _maxSize * 0.8) {
        _log.info('Eviction complete. New cache size: ${_analytics.totalSize}');
        break;
      }

      if (_maxItems != null) {
        final keys = await _cacheAdapter.getKeys();
        if (keys.length <= _maxItems * 0.8) {
          _log.info('Eviction complete. New item count: ${keys.length}');
          break;
        }
      }
    }

    return evicted;
  }

  /// Evicts items using the First In, First Out (FIFO) strategy.
  ///
  /// Returns `true` if eviction was performed, `false` otherwise.
  Future<bool> _evictFIFO() async {
    // Get all keys
    final keys = await _cacheAdapter.getKeys();

    if (keys.isEmpty) {
      _log.warning('No items available for FIFO eviction.');
      return false;
    }

    // Get all items to sort by creation time
    final items = <String, CacheItem<dynamic>>{};
    for (final key in keys) {
      final item = await _cacheAdapter.get(key);
      if (item != null) {
        items[key] = item;
      }
    }

    // Sort by creation time (oldest first)
    final sortedKeys = items.entries.toList()
      ..sort((a, b) => a.value.createdAt.compareTo(b.value.createdAt));

    // Start evicting from the oldest
    bool evicted = false;
    for (final entry in sortedKeys) {
      final key = entry.key;
      final item = entry.value;

      // Skip high priority items unless absolutely necessary
      if (item.priority == CachePriority.critical) {
        continue; // Skip critical items
      }

      // Evict the item
      await _cacheAdapter.delete(key);
      _analytics.recordDelete(key);
      evicted = true;

      _log.info('Evicted item with key: $key (FIFO strategy)');

      // Check if we've evicted enough
      if (_maxSize != null && _analytics.totalSize <= _maxSize * 0.8) {
        _log.info('Eviction complete. New cache size: ${_analytics.totalSize}');
        break;
      }

      if (_maxItems != null) {
        final remainingKeys = await _cacheAdapter.getKeys();
        if (remainingKeys.length <= _maxItems * 0.8) {
          _log.info(
              'Eviction complete. New item count: ${remainingKeys.length}');
          break;
        }
      }
    }

    return evicted;
  }

  /// Evicts items using the Time To Live (TTL) strategy, which evicts items closest to expiration.
  ///
  /// Returns `true` if eviction was performed, `false` otherwise.
  Future<bool> _evictTTL() async {
    // Get all keys
    final keys = await _cacheAdapter.getKeys();

    if (keys.isEmpty) {
      _log.warning('No items available for TTL eviction.');
      return false;
    }

    // Get all items to sort by expiry time
    final items = <String, CacheItem<dynamic>>{};
    for (final key in keys) {
      final item = await _cacheAdapter.get(key);
      if (item != null && item.expiry != null) {
        items[key] = item;
      }
    }

    if (items.isEmpty) {
      _log.warning(
          'No items with expiry available for TTL eviction. Falling back to LRU.');
      return await _evictLRU();
    }

    // Sort by expiry time (closest to expiry first)
    final now = DateTime.now();
    final sortedKeys = items.entries.toList()
      ..sort((a, b) {
        final aTimeLeft = a.value.expiry!.difference(now);
        final bTimeLeft = b.value.expiry!.difference(now);
        return aTimeLeft.compareTo(bTimeLeft);
      });

    // Start evicting from the closest to expiry
    bool evicted = false;
    for (final entry in sortedKeys) {
      final key = entry.key;
      final item = entry.value;

      // Skip high priority items unless absolutely necessary
      if (item.priority == CachePriority.critical) {
        continue; // Skip critical items
      }

      // Evict the item
      await _cacheAdapter.delete(key);
      _analytics.recordDelete(key);
      evicted = true;

      _log.info('Evicted item with key: $key (TTL strategy)');

      // Check if we've evicted enough
      if (_maxSize != null && _analytics.totalSize <= _maxSize * 0.8) {
        _log.info('Eviction complete. New cache size: ${_analytics.totalSize}');
        break;
      }

      if (_maxItems != null) {
        final remainingKeys = await _cacheAdapter.getKeys();
        if (remainingKeys.length <= _maxItems * 0.8) {
          _log.info(
              'Eviction complete. New item count: ${remainingKeys.length}');
          break;
        }
      }
    }

    return evicted;
  }

  /// Evicts items based on priority, starting with the lowest priority.
  ///
  /// This method is used as a fallback when other strategies don't have enough data.
  /// Returns `true` if eviction was performed, `false` otherwise.
  Future<bool> evictByPriority() async {
    // Get all keys
    final keys = await _cacheAdapter.getKeys();

    if (keys.isEmpty) {
      _log.warning('No items available for priority-based eviction.');
      return false;
    }

    // Get all items to group by priority
    final itemsByPriority = <CachePriority, List<String>>{};
    for (final key in keys) {
      final item = await _cacheAdapter.get(key);
      if (item != null) {
        final priority = item.priority;
        itemsByPriority.putIfAbsent(priority, () => []).add(key);
      }
    }

    // Evict items in priority order (low to high)
    final priorities = [
      CachePriority.low,
      CachePriority.normal,
      CachePriority.high,
      CachePriority.critical,
    ];

    bool evicted = false;
    for (final priority in priorities) {
      final priorityKeys = itemsByPriority[priority] ?? [];

      for (final key in priorityKeys) {
        // Evict the item
        await _cacheAdapter.delete(key);
        _analytics.recordDelete(key);
        evicted = true;

        _log.info(
            'Evicted item with key: $key (Priority strategy, priority: $priority)');

        // Check if we've evicted enough
        if (_maxSize != null && _analytics.totalSize <= _maxSize * 0.8) {
          _log.info(
              'Eviction complete. New cache size: ${_analytics.totalSize}');
          return true;
        }

        if (_maxItems != null) {
          final remainingKeys = await _cacheAdapter.getKeys();
          if (remainingKeys.length <= _maxItems * 0.8) {
            _log.info(
                'Eviction complete. New item count: ${remainingKeys.length}');
            return true;
          }
        }
      }

      // If we've evicted all items of this priority and still need more,
      // move on to the next priority level
    }

    return evicted;
  }
}
