import 'package:data_cache_x/models/cache_item.dart';

/// Defines the priority level of a cached item.
///
/// Higher priority items are less likely to be evicted when the cache is full.
enum CachePriority {
  /// Lowest priority. These items will be evicted first when the cache is full.
  low,

  /// Normal priority. These items will be evicted after low priority items.
  normal,

  /// High priority. These items will be evicted after normal priority items.
  high,

  /// Critical priority. These items will only be evicted if absolutely necessary.
  critical,
}

/// Defines the strategy for refreshing cached data.
enum RefreshStrategy {
  /// Never refresh the data automatically. The data will only be refreshed when explicitly requested.
  never,

  /// Refresh the data in the background when it's accessed and is stale.
  backgroundRefresh,

  /// Refresh the data immediately when it's accessed and is stale, blocking the caller.
  immediateRefresh,
}

/// Defines the eviction strategy for the cache.
enum EvictionStrategy {
  /// Least Recently Used. Evicts items that haven't been accessed for the longest time.
  lru,

  /// Least Frequently Used. Evicts items that have been accessed the least number of times.
  lfu,

  /// First In, First Out. Evicts the oldest items first.
  fifo,

  /// Time To Live. Evicts items based on their expiry time.
  ttl,
}

/// Defines the compression mode for cached items.
enum CompressionMode {
  /// Automatically determine whether to compress based on data characteristics.
  auto,

  /// Always compress the data.
  always,

  /// Never compress the data.
  never,
}

/// A class that defines the caching policy for an item.
///
/// The policy includes settings such as expiry time, priority, refresh strategy, and more.
class CachePolicy {
  /// The time after which the cached item is considered stale.
  ///
  /// After this duration, the item may be refreshed according to the [refreshStrategy].
  final Duration? staleTime;

  /// The time after which the cached item is considered expired and will be removed from the cache.
  ///
  /// This is different from [staleTime] in that expired items are removed, while stale items may be refreshed.
  final Duration? expiry;

  /// The sliding expiry time for the cached item.
  ///
  /// If set, the expiry time will be extended by this duration each time the item is accessed.
  final Duration? slidingExpiry;

  /// The priority of the cached item.
  ///
  /// Higher priority items are less likely to be evicted when the cache is full.
  final CachePriority priority;

  /// The strategy for refreshing the cached item.
  final RefreshStrategy refreshStrategy;

  /// The maximum size of the cached item in bytes.
  ///
  /// If the item exceeds this size, it will not be cached.
  final int? maxSize;

  /// Whether the cached item should be encrypted.
  final bool encrypt;

  /// Whether the cached item should be compressed.
  ///
  /// If set to [CompressionMode.auto], the item will be compressed only if it's beneficial.
  /// If set to [CompressionMode.always], the item will always be compressed.
  /// If set to [CompressionMode.never], the item will never be compressed.
  final CompressionMode compression;

  /// The compression level to use if compression is enabled.
  ///
  /// Values range from 1 (fastest, least compression) to 9 (slowest, most compression).
  /// The default value is 6, which provides a good balance between speed and compression ratio.
  final int compressionLevel;

  /// Creates a new instance of [CachePolicy].
  const CachePolicy({
    this.staleTime,
    this.expiry,
    this.slidingExpiry,
    this.priority = CachePriority.normal,
    this.refreshStrategy = RefreshStrategy.never,
    this.maxSize,
    this.encrypt = false,
    this.compression = CompressionMode.auto,
    this.compressionLevel = 6,
  });

  /// Creates a [CacheItem] with this policy applied.
  CacheItem<T> createCacheItem<T>(T value) {
    return CacheItem<T>(
      value: value,
      expiry: expiry != null ? DateTime.now().add(expiry!) : null,
      slidingExpiry: slidingExpiry,
      priority: priority,
    );
  }

  /// Creates a copy of this policy with the specified fields replaced with new values.
  CachePolicy copyWith({
    Duration? staleTime,
    Duration? expiry,
    Duration? slidingExpiry,
    CachePriority? priority,
    RefreshStrategy? refreshStrategy,
    int? maxSize,
    bool? encrypt,
  }) {
    return CachePolicy(
      staleTime: staleTime ?? this.staleTime,
      expiry: expiry ?? this.expiry,
      slidingExpiry: slidingExpiry ?? this.slidingExpiry,
      priority: priority ?? this.priority,
      refreshStrategy: refreshStrategy ?? this.refreshStrategy,
      maxSize: maxSize ?? this.maxSize,
      encrypt: encrypt ?? this.encrypt,
    );
  }

  /// Default cache policy with normal priority and no automatic refresh.
  static const CachePolicy defaultPolicy = CachePolicy();

  /// Cache policy for items that should never expire.
  static const CachePolicy neverExpire = CachePolicy(
    priority: CachePriority.high,
  );

  /// Cache policy for items that should be refreshed in the background when stale.
  static CachePolicy backgroundRefresh({
    Duration staleTime = const Duration(minutes: 5),
    Duration expiry = const Duration(days: 1),
  }) {
    return CachePolicy(
      staleTime: staleTime,
      expiry: expiry,
      refreshStrategy: RefreshStrategy.backgroundRefresh,
    );
  }

  /// Cache policy for items that should be refreshed immediately when stale.
  static CachePolicy immediateRefresh({
    Duration staleTime = const Duration(minutes: 5),
    Duration expiry = const Duration(days: 1),
  }) {
    return CachePolicy(
      staleTime: staleTime,
      expiry: expiry,
      refreshStrategy: RefreshStrategy.immediateRefresh,
    );
  }

  /// Cache policy for sensitive data that should be encrypted.
  static CachePolicy encrypted({
    Duration? expiry,
    CachePriority priority = CachePriority.high,
    CompressionMode compression = CompressionMode.auto,
  }) {
    return CachePolicy(
      expiry: expiry,
      priority: priority,
      encrypt: true,
      compression: compression,
    );
  }

  /// Cache policy for large data that should be compressed.
  static CachePolicy compressed({
    Duration? expiry,
    CachePriority priority = CachePriority.normal,
    int compressionLevel = 6,
  }) {
    return CachePolicy(
      expiry: expiry,
      priority: priority,
      compression: CompressionMode.always,
      compressionLevel: compressionLevel,
    );
  }

  /// Cache policy for temporary data that should be evicted quickly.
  static const CachePolicy temporary = CachePolicy(
    expiry: Duration(minutes: 5),
    priority: CachePriority.low,
  );
}
