# Cache Policies

## Understanding Cache Policies

Cache policies define how items are stored, accessed, and managed in the cache. They control aspects such as expiration, priority, compression, and refresh behavior.

## Creating Cache Policies

You can create a custom cache policy using the `CachePolicy` class:

```dart
final myPolicy = CachePolicy(
  expiry: Duration(hours: 24),         // Fixed expiry time
  slidingExpiry: Duration(hours: 2),    // Extends on each access
  staleTime: Duration(minutes: 30),     // Time before refresh
  priority: CachePriority.high,         // Higher priority in eviction
  refreshStrategy: RefreshStrategy.backgroundRefresh,
  maxSize: 1024 * 10,                   // 10 KB max size
  encrypt: true,                        // Enable encryption
  compression: CompressionMode.auto,    // Auto-compress if beneficial
  compressionLevel: 6,                  // Compression level (1-9)
);
```

## Policy Parameters

### Expiration Control

- **expiry**: Sets a fixed expiration time for the cached item. After this duration, the item is considered expired and will be removed from the cache.

  ```dart
  expiry: Duration(hours: 24) // Item expires after 24 hours
  ```

- **slidingExpiry**: Extends the expiration time each time the item is accessed. This is useful for items that should remain in the cache as long as they're being used.

  ```dart
  slidingExpiry: Duration(hours: 2) // Expiry extends by 2 hours on each access
  ```

- **staleTime**: Defines how long an item is considered "fresh" before it becomes "stale". Stale items are still returned from the cache, but may trigger a background refresh.

  ```dart
  staleTime: Duration(minutes: 30) // Item becomes stale after 30 minutes
  ```

### Refresh Behavior

- **refreshStrategy**: Determines how stale items are handled:

  - `RefreshStrategy.never`: Never automatically refresh stale items
  - `RefreshStrategy.backgroundRefresh`: Refresh stale items in the background while returning the stale value
  - `RefreshStrategy.immediateRefresh`: Refresh stale items immediately, blocking until the refresh is complete

  ```dart
  refreshStrategy: RefreshStrategy.backgroundRefresh // Refresh in background
  ```

### Priority

- **priority**: Sets the priority of the item for eviction when the cache is full:

  - `CachePriority.low`: Evicted first
  - `CachePriority.normal`: Default priority
  - `CachePriority.high`: Higher retention priority
  - `CachePriority.critical`: Evicted last

  ```dart
  priority: CachePriority.high // Higher priority in eviction
  ```

### Size Control

- **maxSize**: Sets the maximum size (in bytes) for the cached item. Items exceeding this size will not be cached.

  ```dart
  maxSize: 1024 * 10 // 10 KB max size
  ```

### Security

- **encrypt**: Enables encryption for the cached item. This is useful for sensitive data.

  ```dart
  encrypt: true // Enable encryption
  ```

### Compression

- **compression**: Controls compression behavior:

  - `CompressionMode.auto`: Compress only if beneficial (based on data size and entropy)
  - `CompressionMode.always`: Always compress the data
  - `CompressionMode.never`: Never compress the data

  ```dart
  compression: CompressionMode.auto // Auto-compress if beneficial
  ```

- **compressionLevel**: Sets the compression level (1-9) when compression is enabled. Higher values provide better compression but are slower.

  ```dart
  compressionLevel: 6 // Balanced compression level
  ```

## Predefined Policies

data_cache_x comes with several predefined policies for common use cases:

### Default Policy

The default policy has no expiry, normal priority, and no automatic refresh.

```dart
// Default policy
await dataCache.put('data', value, policy: CachePolicy.defaultPolicy);
```

### Never Expire

Items with this policy never expire and have high priority, making them less likely to be evicted.

```dart
// Never expire
await dataCache.put('important_data', value, policy: CachePolicy.neverExpire);
```

### Temporary

Temporary items expire quickly (5 minutes by default) and have low priority, making them ideal for short-lived data.

```dart
// Temporary (5 minute expiry, low priority)
await dataCache.put('temp_data', value, policy: CachePolicy.temporary);
```

### Encrypted

Encrypted items have encryption enabled and high priority, making them suitable for sensitive data.

```dart
// Encrypted (high priority, encryption enabled)
await dataCache.put(
  'sensitive_data',
  value,
  policy: CachePolicy.encrypted(expiry: Duration(days: 7))
);
```

### Compressed

Compressed items always use compression, making them suitable for large data.

```dart
// Compressed (compression always enabled)
await dataCache.put(
  'large_data',
  value,
  policy: CachePolicy.compressed()
);
```

### Background Refresh

Items with background refresh are automatically refreshed in the background when they become stale.

```dart
// Background refresh (refresh in background when stale)
await dataCache.put(
  'api_data',
  value,
  policy: CachePolicy.backgroundRefresh(
    staleTime: Duration(minutes: 5),
    expiry: Duration(hours: 1),
  )
);
```

### Immediate Refresh

Items with immediate refresh are refreshed immediately when they become stale.

```dart
// Immediate refresh (refresh immediately when stale)
await dataCache.put(
  'critical_data',
  value,
  policy: CachePolicy.immediateRefresh(
    staleTime: Duration(minutes: 5),
    expiry: Duration(hours: 1),
  )
);
```

## Best Practices

- **Use appropriate expiry times**: Set expiry times based on how frequently the data changes.
- **Consider sliding expiry for frequently accessed items**: This keeps frequently used items in the cache longer.
- **Use stale-while-revalidate for API data**: This provides a good balance between freshness and performance.
- **Set appropriate priorities**: Use higher priorities for important data that should remain in the cache longer.
- **Enable compression for large data**: This can significantly reduce memory usage for large strings or binary data.
- **Enable encryption for sensitive data**: This protects sensitive information stored in the cache.
