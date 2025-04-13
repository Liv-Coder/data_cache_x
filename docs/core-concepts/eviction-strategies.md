# Eviction Strategies

## Understanding Eviction Strategies

Eviction strategies determine which items are removed from the cache when it reaches its capacity limits. data_cache_x supports several eviction strategies, each with its own advantages and use cases.

## Available Eviction Strategies

### LRU (Least Recently Used)

The LRU strategy removes the least recently accessed items first. This is the default strategy and works well for most applications.

**Best for:**
- General-purpose caching
- Applications where recently accessed items are likely to be accessed again

**Usage:**
```dart
final cache = DataCacheX(
  cacheAdapter,
  maxSize: 10 * 1024 * 1024,  // 10 MB max size
  maxItems: 1000,             // 1000 items max
  evictionStrategy: EvictionStrategy.lru,
);
```

**How it works:**
1. The cache tracks when each item was last accessed
2. When the cache is full, the item that hasn't been accessed for the longest time is evicted first
3. Items with higher priority are less likely to be evicted

### LFU (Least Frequently Used)

The LFU strategy removes the least frequently accessed items first. This works well when access patterns are stable over time.

**Best for:**
- Applications where access frequency is more important than recency
- Caches with stable access patterns

**Usage:**
```dart
final cache = DataCacheX(
  cacheAdapter,
  maxSize: 10 * 1024 * 1024,
  maxItems: 1000,
  evictionStrategy: EvictionStrategy.lfu,
);
```

**How it works:**
1. The cache tracks how many times each item has been accessed
2. When the cache is full, the item with the lowest access count is evicted first
3. Items with higher priority are less likely to be evicted

### FIFO (First In, First Out)

The FIFO strategy removes the oldest items first, regardless of when they were last accessed or how frequently they've been accessed.

**Best for:**
- Time-ordered data where older items are less valuable
- Simple caching needs with predictable data lifecycles

**Usage:**
```dart
final cache = DataCacheX(
  cacheAdapter,
  maxSize: 10 * 1024 * 1024,
  maxItems: 1000,
  evictionStrategy: EvictionStrategy.fifo,
);
```

**How it works:**
1. The cache tracks when each item was added
2. When the cache is full, the oldest item is evicted first
3. Items with higher priority are less likely to be evicted

### TTL (Time To Live)

The TTL strategy removes items closest to expiration first. This works well when item expiry is the most important factor.

**Best for:**
- Applications where data freshness is critical
- Caches where items have varying expiry times

**Usage:**
```dart
final cache = DataCacheX(
  cacheAdapter,
  maxSize: 10 * 1024 * 1024,
  maxItems: 1000,
  evictionStrategy: EvictionStrategy.ttl,
);
```

**How it works:**
1. The cache tracks the expiry time of each item
2. When the cache is full, the item closest to expiration is evicted first
3. Items with higher priority are less likely to be evicted

## Eviction Triggers

Eviction can be triggered by several factors:

### Size-Based Eviction

When the total size of the cache exceeds the `maxSize` parameter, items are evicted until the cache size is reduced to approximately 80% of the maximum size.

```dart
final cache = DataCacheX(
  cacheAdapter,
  maxSize: 10 * 1024 * 1024,  // 10 MB max size
);
```

### Count-Based Eviction

When the number of items in the cache exceeds the `maxItems` parameter, items are evicted until the item count is reduced to approximately 80% of the maximum count.

```dart
final cache = DataCacheX(
  cacheAdapter,
  maxItems: 1000,  // 1000 items max
);
```

### Expiry-Based Cleanup

Expired items are automatically removed from the cache during background cleanup operations, which run periodically based on the `cleanupFrequency` parameter.

```dart
await setupDataCacheX(
  cleanupFrequency: Duration(hours: 1),  // Clean up every hour
);
```

## Priority Considerations

All eviction strategies respect item priorities. Items are evicted in the following order:

1. Low priority items
2. Normal priority items
3. High priority items
4. Critical priority items

Within each priority level, the specific eviction strategy (LRU, LFU, FIFO, TTL) determines which items are evicted first.

```dart
// Low priority item (evicted first)
await dataCache.put('temp_data', value, 
    policy: CachePolicy(priority: CachePriority.low));

// Critical priority item (evicted last)
await dataCache.put('important_data', value, 
    policy: CachePolicy(priority: CachePriority.critical));
```

## Best Practices

- **Choose the right strategy for your use case**: Consider your access patterns and data lifecycle when choosing an eviction strategy.
- **Set appropriate size limits**: Set `maxSize` and `maxItems` based on your application's memory constraints and expected cache usage.
- **Use priorities effectively**: Assign higher priorities to important items that should remain in the cache longer.
- **Consider TTL for time-sensitive data**: The TTL strategy works well for data with varying expiry times.
- **Monitor eviction rates**: High eviction rates may indicate that your cache size is too small or your eviction strategy is not optimal.
