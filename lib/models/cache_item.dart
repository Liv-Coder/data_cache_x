import 'package:data_cache_x/models/cache_policy.dart';

/// A class that represents a single item in the cache.
///
/// Each cache item contains a value, optional expiry time, and other metadata.
class CacheItem<T> {
  /// The value stored in the cache.
  final T value;

  /// The time at which the item expires and should be removed from the cache.
  final DateTime? expiry;

  /// The sliding expiry duration. If set, the expiry time will be extended by this duration each time the item is accessed.
  final Duration? slidingExpiry;

  /// The priority of the item. Higher priority items are less likely to be evicted when the cache is full.
  final CachePriority priority;

  /// The time at which the item was created.
  final DateTime createdAt;

  /// The time at which the item was last accessed.
  DateTime lastAccessedAt;

  /// The number of times the item has been accessed.
  int accessCount;

  /// Whether the item is compressed.
  final bool isCompressed;

  /// The original size of the item before compression, in bytes.
  /// This is only set if the item is compressed.
  final int? originalSize;

  /// The compression ratio achieved (original size / compressed size).
  /// This is only set if the item is compressed.
  final double? compressionRatio;

  /// Creates a new instance of [CacheItem].
  CacheItem({
    required this.value,
    this.expiry,
    this.slidingExpiry,
    this.priority = CachePriority.normal,
    DateTime? createdAt,
    DateTime? lastAccessedAt,
    this.accessCount = 0,
    this.isCompressed = false,
    this.originalSize,
    this.compressionRatio,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastAccessedAt = lastAccessedAt ?? DateTime.now();

  bool get isExpired => expiry != null && DateTime.now().isAfter(expiry!);

  /// Updates the expiry time of the item based on the sliding expiry duration.
  ///
  /// If the item has a sliding expiry duration, the expiry time will be extended by that duration.
  /// Also updates the last accessed time and increments the access count.
  CacheItem<T> updateExpiry() {
    final now = DateTime.now();
    lastAccessedAt = now;
    accessCount++;

    if (slidingExpiry == null) {
      return this;
    }

    return CacheItem(
      value: value,
      expiry: now.add(slidingExpiry!),
      slidingExpiry: slidingExpiry,
      priority: priority,
      createdAt: createdAt,
      lastAccessedAt: now,
      accessCount: accessCount,
      isCompressed: isCompressed,
      originalSize: originalSize,
      compressionRatio: compressionRatio,
    );
  }

  /// Converts the cache item to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'expiry': expiry?.toIso8601String(),
      'slidingExpiry': slidingExpiry?.inSeconds,
      'priority': priority.index,
      'createdAt': createdAt.toIso8601String(),
      'lastAccessedAt': lastAccessedAt.toIso8601String(),
      'accessCount': accessCount,
      'isCompressed': isCompressed,
      'originalSize': originalSize,
      'compressionRatio': compressionRatio,
    };
  }

  /// Creates a cache item from a JSON map.
  factory CacheItem.fromJson(Map<String, dynamic> json) {
    return CacheItem<T>(
      value: json['value'] as T,
      expiry: json['expiry'] != null ? DateTime.parse(json['expiry']) : null,
      slidingExpiry: json['slidingExpiry'] != null
          ? Duration(seconds: json['slidingExpiry'])
          : null,
      priority: json['priority'] != null
          ? CachePriority.values[json['priority']]
          : CachePriority.normal,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      lastAccessedAt: json['lastAccessedAt'] != null
          ? DateTime.parse(json['lastAccessedAt'])
          : null,
      accessCount: json['accessCount'] as int? ?? 0,
      isCompressed: json['isCompressed'] as bool? ?? false,
      originalSize: json['originalSize'] as int?,
      compressionRatio: json['compressionRatio'] as double?,
    );
  }

  /// Checks if the item is stale based on the provided stale time.
  bool isStale(Duration staleTime) {
    final now = DateTime.now();
    return now.difference(lastAccessedAt) > staleTime;
  }
}
