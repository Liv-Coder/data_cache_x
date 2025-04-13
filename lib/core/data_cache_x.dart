import 'package:data_cache_x/adapters/cache_adapter.dart';
import 'package:data_cache_x/analytics/cache_analytics.dart';
import 'package:data_cache_x/core/exception.dart';
import 'package:data_cache_x/models/cache_item.dart';
import 'package:data_cache_x/models/cache_policy.dart';
import 'package:data_cache_x/utils/cache_eviction.dart';
import 'package:data_cache_x/utils/compression.dart';
import 'package:data_cache_x/utils/size_estimator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';
import 'dart:async';

/// The main class for interacting with the cache.
///
/// `DataCacheX` provides methods for storing, retrieving, and deleting data.
/// It uses a [CacheAdapter] to handle the underlying storage.
///
/// Example:
/// ```dart
/// Assuming you have a HiveAdapter instance
/// final hiveAdapter = HiveAdapter(typeAdapterRegistry);
/// await hiveAdapter.init();
///
/// // Create a DataCacheX instance
/// final dataCache = DataCacheX(hiveAdapter);
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
class DataCacheX {
  final CacheAdapter _cacheAdapter;
  final CacheAnalytics _analytics;
  final CacheEviction? _eviction;
  final Compression? _compression;

  /// Creates a new instance of [DataCacheX].
  ///
  /// The [cacheAdapter] parameter is required to handle the underlying storage.
  /// The [analytics] parameter is optional and can be used to track cache performance.
  /// The [maxSize] parameter can be used to set a maximum size for the cache in bytes.
  /// The [maxItems] parameter can be used to set a maximum number of items in the cache.
  /// The [evictionStrategy] parameter can be used to set the eviction strategy to use when the cache is full.
  /// The [compressionLevel] parameter can be used to set the compression level (1-9) when compression is enabled.
  DataCacheX(
    this._cacheAdapter, {
    CacheAnalytics? analytics,
    int? maxSize,
    int? maxItems,
    EvictionStrategy evictionStrategy = EvictionStrategy.lru,
    int compressionLevel = 6,
  })  : _analytics = analytics ?? CacheAnalytics(),
        _eviction = (maxSize != null || maxItems != null)
            ? CacheEviction(
                _cacheAdapter,
                analytics ?? CacheAnalytics(),
                maxSize: maxSize,
                maxItems: maxItems,
                strategy: evictionStrategy,
              )
            : null,
        _compression = Compression(level: compressionLevel);

  final _log = Logger('DataCache');

  /// Gets the cache analytics instance.
  CacheAnalytics get analytics => _analytics;

  /// Gets the number of cache hits.
  int get hitCount => _analytics.hitCount;

  /// Gets the number of cache misses.
  int get missCount => _analytics.missCount;

  /// Gets the cache hit rate.
  double get hitRate => _analytics.hitRate;

  /// Gets the total size of all items in the cache (estimated).
  int get totalSize => _analytics.totalSize;

  /// Gets the average size of items in the cache.
  double get averageItemSize => _analytics.averageItemSize;

  /// Gets the most frequently accessed keys.
  List<MapEntry<String, int>> get mostFrequentlyAccessedKeys =>
      _analytics.mostFrequentlyAccessedKeys;

  /// Gets the most recently accessed keys.
  List<MapEntry<String, DateTime>> get mostRecentlyAccessedKeys =>
      _analytics.mostRecentlyAccessedKeys;

  /// Gets the largest items in the cache.
  List<MapEntry<String, int>> get largestItems => _analytics.largestItems;

  /// Resets the cache metrics.
  void resetMetrics() {
    _analytics.reset();
  }

  /// Gets a summary of the cache analytics.
  Map<String, dynamic> getAnalyticsSummary() {
    return _analytics.getSummary();
  }

  /// Stores a [value] in the cache with the given [key].
  ///
  /// The [expiry] parameter can be used to set an optional expiry time for the data.
  /// The [slidingExpiry] parameter can be used to set an optional sliding expiry time for the data.
  /// The [policy] parameter can be used to set a cache policy for the data.
  /// The [tags] parameter can be used to associate tags with the data for easier retrieval and management.
  ///
  /// If both individual parameters (expiry, slidingExpiry) and a policy are provided,
  /// the individual parameters will take precedence over the policy.
  ///
  /// Throws a [CacheException] if there is an error storing the data.
  Future<void> put<T>(
    String key,
    T value, {
    Duration? expiry,
    Duration? slidingExpiry,
    CachePolicy? policy,
    Set<String>? tags,
  }) async {
    try {
      final effectivePolicy = policy ?? CachePolicy.defaultPolicy;
      final effectiveExpiry = expiry ?? effectivePolicy.expiry;
      final effectiveSlidingExpiry =
          slidingExpiry ?? effectivePolicy.slidingExpiry;

      // Initialize compression variables
      bool isCompressed = false;
      int? originalSize;
      double? compressionRatio;
      dynamic finalValue = value;

      // Check if compression should be applied
      if (effectivePolicy.compression != CompressionMode.never &&
          _compression != null &&
          value is String) {
        // For auto mode, check if compression is beneficial
        if (effectivePolicy.compression == CompressionMode.auto) {
          if (_compression.shouldCompress(value)) {
            // Compress the value
            originalSize =
                value.length * 2; // Rough estimate: 2 bytes per character
            final compressedValue = _compression.compressString(value);
            compressionRatio = originalSize / (compressedValue.length * 2);

            // Only use compression if it actually reduces the size
            if (compressionRatio > 1.1) {
              // At least 10% reduction
              finalValue = compressedValue;
              isCompressed = true;
              _log.fine(
                  'Compressed value for key $key with ratio $compressionRatio');
            }
          }
        } else if (effectivePolicy.compression == CompressionMode.always) {
          // Always compress
          originalSize = value.length * 2;
          final compressedValue = _compression.compressString(value);
          compressionRatio = originalSize / (compressedValue.length * 2);
          finalValue = compressedValue;
          isCompressed = true;
          _log.fine(
              'Compressed value for key $key with ratio $compressionRatio');
        }
      }

      final cacheItem = CacheItem<T>(
        value: finalValue as T,
        expiry: effectiveExpiry != null
            ? DateTime.now().add(effectiveExpiry)
            : null,
        slidingExpiry: effectiveSlidingExpiry,
        priority: effectivePolicy.priority,
        isCompressed: isCompressed,
        originalSize: originalSize,
        compressionRatio: compressionRatio,
        tags: tags,
      );

      // Use the SizeEstimator for more accurate size estimation
      final estimatedSize = SizeEstimator.estimateCacheItemSize(
        finalValue,
        hasExpiry: effectiveExpiry != null,
        hasSlidingExpiry: effectiveSlidingExpiry != null,
        isCompressed: isCompressed,
        originalSize: originalSize,
      );

      // Check if the item exceeds the maximum size (if specified)
      if (effectivePolicy.maxSize != null) {
        if (estimatedSize > effectivePolicy.maxSize!) {
          _log.warning(
              'Item exceeds maximum size: $estimatedSize > ${effectivePolicy.maxSize}');
          throw CacheException(
              'Item exceeds maximum size: $estimatedSize > ${effectivePolicy.maxSize}');
        }
      }

      // Record the put operation in analytics
      _analytics.recordPut(key, estimatedSize);

      await _cacheAdapter.put(key, cacheItem);

      // Check if we need to evict items
      if (_eviction != null) {
        await _eviction.checkAndEvict();
      }
    } on HiveError catch (e) {
      _log.severe('Failed to put data into cache (HiveError): $e');
      throw CacheException('Failed to put data into cache: ${e.message}');
    } catch (e) {
      _log.severe('Failed to put data into cache (Unknown Error): $e');
      throw CacheException('Failed to put data into cache: $e');
    }
  }

  /// Stores a value in the cache with the given [key] asynchronously.
  ///
  /// This method is similar to [put], but uses asynchronous compression for large strings,
  /// which can improve performance by avoiding blocking the main thread.
  ///
  /// The [expiry] parameter can be used to set an optional expiry time for the data.
  /// The [slidingExpiry] parameter can be used to set an optional sliding expiry time for the data.
  /// The [policy] parameter can be used to set a cache policy for the data.
  ///
  /// If both individual parameters (expiry, slidingExpiry) and a policy are provided,
  /// the individual parameters will take precedence over the policy.
  ///
  /// Throws an [ArgumentError] if the key is empty.
  /// Throws a [CacheException] if there is an error storing the data.
  Future<void> putAsync<T>(String key, T value,
      {Duration? expiry, Duration? slidingExpiry, CachePolicy? policy}) async {
    if (key.isEmpty) {
      throw ArgumentError('Key cannot be empty');
    }
    try {
      final effectivePolicy = policy ?? CachePolicy.defaultPolicy;
      final effectiveExpiry = expiry ?? effectivePolicy.expiry;
      final effectiveSlidingExpiry =
          slidingExpiry ?? effectivePolicy.slidingExpiry;

      // Apply encryption if needed
      if (effectivePolicy.encrypt && !_cacheAdapter.enableEncryption) {
        _log.warning(
            'Encryption requested but not supported by the adapter. Data will be stored unencrypted.');
      }

      // Apply compression if needed
      dynamic finalValue = value;
      bool isCompressed = false;
      int? originalSize;
      double? compressionRatio;

      if (effectivePolicy.compression != CompressionMode.never &&
          _compression != null &&
          value is String) {
        // For auto mode, check if compression is beneficial
        if (effectivePolicy.compression == CompressionMode.auto) {
          if (_compression.shouldCompress(value)) {
            // Compress the value asynchronously
            originalSize = value.length * 2;
            final compressedValue =
                await _compression.compressStringAsync(value);
            compressionRatio = originalSize / (compressedValue.length * 2);

            // Only use compression if it actually reduces the size
            if (compressionRatio > 1.1) {
              // At least 10% reduction
              finalValue = compressedValue;
              isCompressed = true;
              _log.fine(
                  'Compressed value for key $key with ratio $compressionRatio');
            }
          }
        } else if (effectivePolicy.compression == CompressionMode.always) {
          // Always compress
          originalSize = value.length * 2;
          final compressedValue = await _compression.compressStringAsync(value);
          compressionRatio = originalSize / (compressedValue.length * 2);
          finalValue = compressedValue;
          isCompressed = true;
          _log.fine(
              'Compressed value for key $key with ratio $compressionRatio');
        }
      }

      final cacheItem = CacheItem<T>(
        value: finalValue as T,
        expiry: effectiveExpiry != null
            ? DateTime.now().add(effectiveExpiry)
            : null,
        slidingExpiry: effectiveSlidingExpiry,
        priority: effectivePolicy.priority,
        isCompressed: isCompressed,
        originalSize: originalSize,
        compressionRatio: compressionRatio,
      );

      // Use the SizeEstimator for more accurate size estimation
      final estimatedSize = SizeEstimator.estimateCacheItemSize(
        finalValue,
        hasExpiry: effectiveExpiry != null,
        hasSlidingExpiry: effectiveSlidingExpiry != null,
        isCompressed: isCompressed,
        originalSize: originalSize,
      );

      // Check if the item exceeds the maximum size (if specified)
      if (effectivePolicy.maxSize != null) {
        if (estimatedSize > effectivePolicy.maxSize!) {
          _log.warning(
              'Item exceeds maximum size: $estimatedSize > ${effectivePolicy.maxSize}');
          throw CacheException(
              'Item exceeds maximum size: $estimatedSize > ${effectivePolicy.maxSize}');
        }
      }

      // Record the put operation in analytics
      _analytics.recordPut(key, estimatedSize);

      await _cacheAdapter.put(key, cacheItem);

      // Check if we need to evict items
      if (_eviction != null) {
        await _eviction.checkAndEvict();
      }
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
  /// If [refreshCallback] is provided and the item is stale according to its policy,
  /// the callback will be used to refresh the data based on the refresh strategy.
  ///
  /// Throws an [ArgumentError] if the key is empty.
  /// Throws a [CacheException] if there is an error retrieving the data.
  Future<T?> get<T>(String key,
      {Future<T> Function()? refreshCallback, CachePolicy? policy}) async {
    if (key.isEmpty) {
      throw ArgumentError('Key cannot be empty');
    }
    try {
      final cacheItem = await _cacheAdapter.get(key);
      if (cacheItem == null) {
        // Record cache miss in analytics
        _analytics.recordMiss(key);

        // If a refresh callback is provided, use it to get fresh data
        if (refreshCallback != null) {
          final freshValue = await refreshCallback();
          await put(key, freshValue, policy: policy);
          return freshValue;
        }

        return null;
      }

      if (cacheItem.isExpired) {
        // Record cache miss in analytics
        _analytics.recordMiss(key);
        await delete(key);

        // If a refresh callback is provided, use it to get fresh data
        if (refreshCallback != null) {
          final freshValue = await refreshCallback();
          await put(key, freshValue, policy: policy);
          return freshValue;
        }

        return null;
      }

      // Check if the item is stale and needs refreshing
      final effectivePolicy = policy ?? CachePolicy.defaultPolicy;
      if (refreshCallback != null &&
          effectivePolicy.staleTime != null &&
          cacheItem.isStale(effectivePolicy.staleTime!)) {
        // Handle different refresh strategies
        switch (effectivePolicy.refreshStrategy) {
          case RefreshStrategy.backgroundRefresh:
            // Update in the background without blocking
            _refreshInBackground(key, refreshCallback, effectivePolicy);
            break;
          case RefreshStrategy.immediateRefresh:
            // Refresh immediately and return the fresh value
            final freshValue = await refreshCallback();
            await put(key, freshValue, policy: effectivePolicy);
            return freshValue;
          case RefreshStrategy.never:
            // Do nothing, just use the cached value
            break;
        }
      }

      // Update sliding expiry if needed
      // Decompress the value if it's compressed
      T? resultValue;
      if (cacheItem.isCompressed &&
          _compression != null &&
          cacheItem.value is String) {
        try {
          final decompressedValue =
              _compression.decompressString(cacheItem.value as String);
          resultValue = decompressedValue as T?;
          _log.fine('Decompressed value for key $key');
        } catch (e) {
          _log.warning('Failed to decompress value for key $key: $e');
          resultValue = cacheItem.value as T?;
        }
      } else {
        resultValue = cacheItem.value as T?;
      }

      if (cacheItem.slidingExpiry != null) {
        final updatedCacheItem = cacheItem.updateExpiry();
        await _cacheAdapter.put(key, updatedCacheItem);
        // Record cache hit in analytics
        _analytics.recordHit(key);
        return resultValue;
      }

      // Update access metadata
      final updatedCacheItem = cacheItem.updateExpiry();
      if (updatedCacheItem != cacheItem) {
        await _cacheAdapter.put(key, updatedCacheItem);
      }

      // Record cache hit in analytics
      _analytics.recordHit(key);
      return resultValue;
    } on HiveError catch (e) {
      _log.severe('Failed to get data from cache (HiveError): $e');
      throw CacheException('Failed to get data from cache: ${e.message}');
    } catch (e) {
      _log.severe('Failed to get data from cache (Unknown Error): $e');
      throw CacheException('Failed to get data from cache: $e');
    }
  }

  /// Retrieves the value associated with the given [key] asynchronously.
  ///
  /// This method is similar to [get], but uses asynchronous decompression for large strings,
  /// which can improve performance by avoiding blocking the main thread.
  ///
  /// Returns `null` if no value is found for the given [key] or if the value is expired.
  ///
  /// If [refreshCallback] is provided and the item is stale according to its policy,
  /// the callback will be used to refresh the data based on the refresh strategy.
  ///
  /// Throws an [ArgumentError] if the key is empty.
  /// Throws a [CacheException] if there is an error retrieving the data.
  Future<T?> getAsync<T>(String key,
      {Future<T> Function()? refreshCallback, CachePolicy? policy}) async {
    if (key.isEmpty) {
      throw ArgumentError('Key cannot be empty');
    }
    try {
      final cacheItem = await _cacheAdapter.get(key);
      if (cacheItem == null) {
        // Record cache miss in analytics
        _analytics.recordMiss(key);

        // If a refresh callback is provided, use it to get fresh data
        if (refreshCallback != null) {
          final freshValue = await refreshCallback();
          await putAsync(key, freshValue, policy: policy);
          return freshValue;
        }

        return null;
      }

      if (cacheItem.isExpired) {
        // Record cache miss in analytics
        _analytics.recordMiss(key);
        await delete(key);

        // If a refresh callback is provided, use it to get fresh data
        if (refreshCallback != null) {
          final freshValue = await refreshCallback();
          await putAsync(key, freshValue, policy: policy);
          return freshValue;
        }

        return null;
      }

      // Check if the item is stale and needs refreshing
      final effectivePolicy = policy ?? CachePolicy.defaultPolicy;
      if (refreshCallback != null &&
          effectivePolicy.staleTime != null &&
          cacheItem.isStale(effectivePolicy.staleTime!)) {
        // Handle different refresh strategies
        switch (effectivePolicy.refreshStrategy) {
          case RefreshStrategy.backgroundRefresh:
            // Update in the background without blocking
            _refreshInBackgroundAsync(key, refreshCallback, effectivePolicy);
            break;
          case RefreshStrategy.immediateRefresh:
            // Refresh immediately and return the fresh value
            final freshValue = await refreshCallback();
            await putAsync(key, freshValue, policy: effectivePolicy);
            return freshValue;
          case RefreshStrategy.never:
            // Do nothing, just use the cached value
            break;
        }
      }

      // Update sliding expiry if needed
      // Decompress the value if it's compressed
      T? resultValue;
      if (cacheItem.isCompressed &&
          _compression != null &&
          cacheItem.value is String) {
        try {
          final decompressedValue = await _compression
              .decompressStringAsync(cacheItem.value as String);
          resultValue = decompressedValue as T?;
          _log.fine('Decompressed value for key $key');
        } catch (e) {
          _log.warning('Failed to decompress value for key $key: $e');
          resultValue = cacheItem.value as T?;
        }
      } else {
        resultValue = cacheItem.value as T?;
      }

      if (cacheItem.slidingExpiry != null) {
        final updatedCacheItem = cacheItem.updateExpiry();
        await _cacheAdapter.put(key, updatedCacheItem);
        // Record cache hit in analytics
        _analytics.recordHit(key);
        return resultValue;
      }

      // Update access metadata
      final updatedCacheItem = cacheItem.updateExpiry();
      if (updatedCacheItem != cacheItem) {
        await _cacheAdapter.put(key, updatedCacheItem);
      }

      // Record cache hit in analytics
      _analytics.recordHit(key);
      return resultValue;
    } on HiveError catch (e) {
      _log.severe('Failed to get data from cache (HiveError): $e');
      throw CacheException('Failed to get data from cache: ${e.message}');
    } catch (e) {
      _log.severe('Failed to get data from cache (Unknown Error): $e');
      throw CacheException('Failed to get data from cache: $e');
    }
  }

  /// Refreshes a cache item in the background without blocking the caller.
  Future<void> _refreshInBackground<T>(String key,
      Future<T> Function() refreshCallback, CachePolicy policy) async {
    try {
      final freshValue = await refreshCallback();
      await put(key, freshValue, policy: policy);
      _log.info('Background refresh completed for key: $key');
    } catch (e) {
      _log.warning('Background refresh failed for key: $key - $e');
    }
  }

  /// Refreshes a cache item in the background without blocking the caller using async methods.
  Future<void> _refreshInBackgroundAsync<T>(String key,
      Future<T> Function() refreshCallback, CachePolicy policy) async {
    try {
      final freshValue = await refreshCallback();
      await putAsync(key, freshValue, policy: policy);
      _log.info('Background refresh completed for key: $key (async)');
    } catch (e) {
      _log.warning('Background refresh failed for key: $key - $e (async)');
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
      // Record delete operation in analytics
      _analytics.recordDelete(key);
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
      // Record clear operation in analytics
      _analytics.recordClear();
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

  /// Invalidates the cache entry associated with the given [key].
  ///
  /// This method removes the entry from the cache.
  Future<void> invalidate(String key) async {
    await delete(key);
  }

  /// Invalidates cache entries that match the given [test] condition.
  ///
  /// The [test] function is applied to each key-value pair in the cache.
  /// If the test returns true, the entry is removed from the cache.
  Future<void> invalidateWhere(
      bool Function(String key, dynamic value) test) async {
    try {
      final keys = await _cacheAdapter.getKeys();
      for (final key in keys) {
        final value = await _cacheAdapter.get(key);
        if (value != null && test(key, value.value)) {
          await delete(key);
        }
      }
    } catch (e) {
      _log.severe('Failed to invalidate cache entries (Unknown Error): $e');
      throw CacheException('Failed to invalidate cache entries: $e');
    }
  }

  /// Stores multiple values in the cache with the given keys.
  ///
  /// The [entries] parameter is a map where the keys are the cache keys and the values are the values to store.
  /// The [expiry] parameter can be used to set an optional expiry time for all the data.
  /// The [slidingExpiry] parameter can be used to set an optional sliding expiry time for all the data.
  /// The [policy] parameter can be used to set a cache policy for all the data.
  /// The [tags] parameter can be used to associate tags with all the data for easier retrieval and management.
  ///
  /// If both individual parameters (expiry, slidingExpiry) and a policy are provided,
  /// the individual parameters will take precedence over the policy.
  ///
  /// Throws a [CacheException] if there is an error storing the data.
  Future<void> putAll<T>(
    Map<String, T> entries, {
    Duration? expiry,
    Duration? slidingExpiry,
    CachePolicy? policy,
    Set<String>? tags,
  }) async {
    try {
      final effectivePolicy = policy ?? CachePolicy.defaultPolicy;
      final effectiveExpiry = expiry ?? effectivePolicy.expiry;
      final effectiveSlidingExpiry =
          slidingExpiry ?? effectivePolicy.slidingExpiry;

      final cacheItems = <String, CacheItem<dynamic>>{};
      final now = DateTime.now();
      final expiryTime =
          effectiveExpiry != null ? now.add(effectiveExpiry) : null;

      for (final entry in entries.entries) {
        final key = entry.key;
        final value = entry.value;

        // Initialize compression variables
        bool isCompressed = false;
        int? originalSize;
        double? compressionRatio;
        dynamic finalValue = value;

        // Check if compression should be applied
        if (effectivePolicy.compression != CompressionMode.never &&
            _compression != null &&
            value is String) {
          // For auto mode, check if compression is beneficial
          if (effectivePolicy.compression == CompressionMode.auto) {
            if (_compression.shouldCompress(value)) {
              // Compress the value
              originalSize =
                  value.length * 2; // Rough estimate: 2 bytes per character
              final compressedValue = _compression.compressString(value);
              compressionRatio = originalSize / (compressedValue.length * 2);

              // Only use compression if it actually reduces the size
              if (compressionRatio > 1.1) {
                // At least 10% reduction
                finalValue = compressedValue;
                isCompressed = true;
                _log.fine(
                    'Compressed value for key $key with ratio $compressionRatio');
              }
            }
          } else if (effectivePolicy.compression == CompressionMode.always) {
            // Always compress
            originalSize = value.length * 2;
            final compressedValue = _compression.compressString(value);
            compressionRatio = originalSize / (compressedValue.length * 2);
            finalValue = compressedValue;
            isCompressed = true;
            _log.fine(
                'Compressed value for key $key with ratio $compressionRatio');
          }
        }

        final cacheItem = CacheItem<T>(
          value: finalValue as T,
          expiry: expiryTime,
          slidingExpiry: effectiveSlidingExpiry,
          priority: effectivePolicy.priority,
          isCompressed: isCompressed,
          originalSize: originalSize,
          compressionRatio: compressionRatio,
          tags: tags,
        );

        // Check if the item exceeds the maximum size (if specified)
        if (effectivePolicy.maxSize != null) {
          // Use the SizeEstimator for more accurate size estimation
          final estimatedSize = SizeEstimator.estimateCacheItemSize(
            finalValue,
            hasExpiry: expiryTime != null,
            hasSlidingExpiry: effectiveSlidingExpiry != null,
            isCompressed: isCompressed,
            originalSize: originalSize,
          );

          if (estimatedSize > effectivePolicy.maxSize!) {
            _log.warning(
                'Item exceeds maximum size: $estimatedSize > ${effectivePolicy.maxSize}');
            // Skip this item but continue with others
            continue;
          }
        }

        cacheItems[key] = cacheItem;
      }

      if (cacheItems.isEmpty) {
        _log.warning('No items to cache after size filtering');
        return;
      }

      await _cacheAdapter.putAll(cacheItems);

      // Check if we need to evict items
      if (_eviction != null) {
        await _eviction.checkAndEvict();
      }
    } on HiveError catch (e) {
      _log.severe('Failed to put data into cache (HiveError): $e');
      throw CacheException('Failed to put data into cache: ${e.message}');
    } catch (e) {
      _log.severe('Failed to put data into cache (Unknown Error): $e');
      throw CacheException('Failed to put data into cache: $e');
    }
  }

  /// Retrieves multiple values associated with the given [keys].
  ///
  /// Returns a map where the keys are the original keys and the values are the retrieved values.
  /// If a key is not found in the cache or its value is expired, it will not be included in the returned map.
  ///
  /// If [refreshCallbacks] is provided and an item is stale according to its policy,
  /// the callback for that key will be used to refresh the data based on the refresh strategy.
  ///
  /// Throws a [CacheException] if there is an error retrieving the data.
  Future<Map<String, T>> getAll<T>(
    List<String> keys, {
    Map<String, Future<T> Function()>? refreshCallbacks,
    CachePolicy? policy,
  }) async {
    try {
      if (keys.isEmpty) {
        return {};
      }

      // Check for empty keys
      for (final key in keys) {
        if (key.isEmpty) {
          throw ArgumentError('Keys cannot be empty');
        }
      }

      final result = <String, T>{};
      final cacheItems = await _cacheAdapter.getAll(keys);
      final keysToDelete = <String>[];
      final effectivePolicy = policy ?? CachePolicy.defaultPolicy;

      // Process cache hits
      for (final entry in cacheItems.entries) {
        final key = entry.key;
        final cacheItem = entry.value;

        if (cacheItem.isExpired) {
          // Record cache miss in analytics
          _analytics.recordMiss(key);
          keysToDelete.add(key);

          // If a refresh callback is provided for this key, use it to get fresh data
          if (refreshCallbacks != null && refreshCallbacks.containsKey(key)) {
            final freshValue = await refreshCallbacks[key]!();
            await put(key, freshValue, policy: policy);
            result[key] = freshValue;
          }

          continue;
        }

        // Check if the item is stale and needs refreshing
        if (refreshCallbacks != null &&
            refreshCallbacks.containsKey(key) &&
            effectivePolicy.staleTime != null &&
            cacheItem.isStale(effectivePolicy.staleTime!)) {
          // Handle different refresh strategies
          switch (effectivePolicy.refreshStrategy) {
            case RefreshStrategy.backgroundRefresh:
              // Update in the background without blocking
              _refreshInBackground(
                  key, refreshCallbacks[key]!, effectivePolicy);
              break;
            case RefreshStrategy.immediateRefresh:
              // Refresh immediately and return the fresh value
              final freshValue = await refreshCallbacks[key]!();
              await put(key, freshValue, policy: effectivePolicy);
              result[key] = freshValue;
              continue; // Skip the rest of the loop for this item
            case RefreshStrategy.never:
              // Do nothing, just use the cached value
              break;
          }
        }

        // Decompress the value if it's compressed
        T? resultValue;
        if (cacheItem.isCompressed &&
            _compression != null &&
            cacheItem.value is String) {
          try {
            final decompressedValue =
                _compression.decompressString(cacheItem.value as String);
            resultValue = decompressedValue as T?;
            _log.fine('Decompressed value for key $key');
          } catch (e) {
            _log.warning('Failed to decompress value for key $key: $e');
            resultValue = cacheItem.value as T?;
          }
        } else {
          resultValue = cacheItem.value as T?;
        }

        // Update sliding expiry if needed
        if (cacheItem.slidingExpiry != null) {
          final updatedCacheItem = cacheItem.updateExpiry();
          await _cacheAdapter.put(key, updatedCacheItem);
          // Record cache hit in analytics
          _analytics.recordHit(key);
          result[key] = resultValue as T;
        } else {
          // Update access metadata
          final updatedCacheItem = cacheItem.updateExpiry();
          if (updatedCacheItem != cacheItem) {
            await _cacheAdapter.put(key, updatedCacheItem);
          }

          // Record cache hit in analytics
          _analytics.recordHit(key);
          result[key] = resultValue as T;
        }
      }

      // Process cache misses with refresh callbacks
      if (refreshCallbacks != null) {
        final missingKeys = keys.where((key) =>
            !result.containsKey(key) &&
            !keysToDelete.contains(key) &&
            refreshCallbacks.containsKey(key));

        for (final key in missingKeys) {
          // Record cache miss in analytics
          _analytics.recordMiss(key);
          final freshValue = await refreshCallbacks[key]!();
          await put(key, freshValue, policy: policy);
          result[key] = freshValue;
        }
      }

      // Delete expired items in batch
      if (keysToDelete.isNotEmpty) {
        await _cacheAdapter.deleteAll(keysToDelete);
      }

      return result;
    } on HiveError catch (e) {
      _log.severe('Failed to get data from cache (HiveError): $e');
      throw CacheException('Failed to get data from cache: ${e.message}');
    } catch (e) {
      _log.severe('Failed to get data from cache (Unknown Error): $e');
      throw CacheException('Failed to get data from cache: $e');
    }
  }

  /// Deletes multiple values associated with the given [keys].
  ///
  /// Throws an [ArgumentError] if any key is empty.
  /// Throws a [CacheException] if there is an error deleting the data.
  Future<void> deleteAll(List<String> keys) async {
    try {
      if (keys.isEmpty) {
        return;
      }

      // Check for empty keys
      for (final key in keys) {
        if (key.isEmpty) {
          throw ArgumentError('Keys cannot be empty');
        }
      }

      await _cacheAdapter.deleteAll(keys);
    } on HiveError catch (e) {
      _log.severe('Failed to delete data from cache (HiveError): $e');
      throw CacheException('Failed to delete data from cache: ${e.message}');
    } catch (e) {
      _log.severe('Failed to delete data from cache (Unknown Error): $e');
      throw CacheException('Failed to delete data from cache: $e');
    }
  }

  /// Returns a list of all keys in the cache that have the specified tag.
  ///
  /// The [limit] and [offset] parameters can be used to paginate the results.
  /// Throws a [CacheException] if there is an error retrieving the keys.
  Future<List<String>> getKeysByTag(String tag,
      {int? limit, int? offset}) async {
    try {
      if (tag.isEmpty) {
        throw ArgumentError('Tag cannot be empty');
      }

      return await _cacheAdapter.getKeysByTag(tag,
          limit: limit, offset: offset);
    } on HiveError catch (e) {
      _log.severe('Failed to get keys by tag from cache (HiveError): $e');
      throw CacheException(
          'Failed to get keys by tag from cache: ${e.message}');
    } catch (e) {
      _log.severe('Failed to get keys by tag from cache (Unknown Error): $e');
      throw CacheException('Failed to get keys by tag from cache: $e');
    }
  }

  /// Returns a list of all keys in the cache that have all the specified tags.
  ///
  /// The [limit] and [offset] parameters can be used to paginate the results.
  /// Throws a [CacheException] if there is an error retrieving the keys.
  Future<List<String>> getKeysByTags(List<String> tags,
      {int? limit, int? offset}) async {
    try {
      if (tags.isEmpty) {
        throw ArgumentError('Tags list cannot be empty');
      }

      for (final tag in tags) {
        if (tag.isEmpty) {
          throw ArgumentError('Tags cannot be empty');
        }
      }

      return await _cacheAdapter.getKeysByTags(tags,
          limit: limit, offset: offset);
    } on HiveError catch (e) {
      _log.severe('Failed to get keys by tags from cache (HiveError): $e');
      throw CacheException(
          'Failed to get keys by tags from cache: ${e.message}');
    } catch (e) {
      _log.severe('Failed to get keys by tags from cache (Unknown Error): $e');
      throw CacheException('Failed to get keys by tags from cache: $e');
    }
  }

  /// Deletes all items in the cache that have the specified tag.
  ///
  /// Throws an [ArgumentError] if the tag is empty.
  /// Throws a [CacheException] if there is an error deleting the items.
  Future<void> deleteByTag(String tag) async {
    try {
      if (tag.isEmpty) {
        throw ArgumentError('Tag cannot be empty');
      }

      await _cacheAdapter.deleteByTag(tag);
    } on HiveError catch (e) {
      _log.severe('Failed to delete data by tag from cache (HiveError): $e');
      throw CacheException(
          'Failed to delete data by tag from cache: ${e.message}');
    } catch (e) {
      _log.severe(
          'Failed to delete data by tag from cache (Unknown Error): $e');
      throw CacheException('Failed to delete data by tag from cache: $e');
    }
  }

  /// Deletes all items in the cache that have all the specified tags.
  ///
  /// Throws an [ArgumentError] if the tags list is empty or contains empty tags.
  /// Throws a [CacheException] if there is an error deleting the items.
  Future<void> deleteByTags(List<String> tags) async {
    try {
      if (tags.isEmpty) {
        throw ArgumentError('Tags list cannot be empty');
      }

      for (final tag in tags) {
        if (tag.isEmpty) {
          throw ArgumentError('Tags cannot be empty');
        }
      }

      await _cacheAdapter.deleteByTags(tags);
    } on HiveError catch (e) {
      _log.severe('Failed to delete data by tags from cache (HiveError): $e');
      throw CacheException(
          'Failed to delete data by tags from cache: ${e.message}');
    } catch (e) {
      _log.severe(
          'Failed to delete data by tags from cache (Unknown Error): $e');
      throw CacheException('Failed to delete data by tags from cache: $e');
    }
  }

  /// Retrieves all values associated with the given tag.
  ///
  /// Returns a map where the keys are the original keys and the values are the retrieved values.
  /// If a key is not found in the cache, it will not be included in the returned map.
  ///
  /// The [policy] parameter can be used to specify a cache policy for the operation.
  /// Throws an [ArgumentError] if the tag is empty.
  /// Throws a [CacheException] if there is an error retrieving the data.
  Future<Map<String, T>> getByTag<T>(String tag, {CachePolicy? policy}) async {
    try {
      if (tag.isEmpty) {
        throw ArgumentError('Tag cannot be empty');
      }

      final keys = await getKeysByTag(tag);
      return await getAll<T>(keys, policy: policy);
    } on HiveError catch (e) {
      _log.severe('Failed to get data by tag from cache (HiveError): $e');
      throw CacheException(
          'Failed to get data by tag from cache: ${e.message}');
    } catch (e) {
      _log.severe('Failed to get data by tag from cache (Unknown Error): $e');
      throw CacheException('Failed to get data by tag from cache: $e');
    }
  }

  /// Retrieves all values associated with all the given tags.
  ///
  /// Returns a map where the keys are the original keys and the values are the retrieved values.
  /// If a key is not found in the cache, it will not be included in the returned map.
  ///
  /// The [policy] parameter can be used to specify a cache policy for the operation.
  /// Throws an [ArgumentError] if the tags list is empty or contains empty tags.
  /// Throws a [CacheException] if there is an error retrieving the data.
  Future<Map<String, T>> getByTags<T>(List<String> tags,
      {CachePolicy? policy}) async {
    try {
      if (tags.isEmpty) {
        throw ArgumentError('Tags list cannot be empty');
      }

      for (final tag in tags) {
        if (tag.isEmpty) {
          throw ArgumentError('Tags cannot be empty');
        }
      }

      final keys = await getKeysByTags(tags);
      return await getAll<T>(keys, policy: policy);
    } on HiveError catch (e) {
      _log.severe('Failed to get data by tags from cache (HiveError): $e');
      throw CacheException(
          'Failed to get data by tags from cache: ${e.message}');
    } catch (e) {
      _log.severe('Failed to get data by tags from cache (Unknown Error): $e');
      throw CacheException('Failed to get data by tags from cache: $e');
    }
  }
}
