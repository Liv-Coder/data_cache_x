# Performance Optimization

This guide provides strategies and best practices for optimizing the performance of data_cache_x in your application.

## Choosing the Right Adapter

The choice of adapter has a significant impact on performance:

### Memory Adapter

The Memory adapter is the fastest option as it stores data directly in memory, but data is lost when the app is closed.

**Best for:**
- Temporary data that doesn't need to persist
- High-performance caching with frequent reads/writes
- Testing and development

```dart
await setupDataCacheX(adapterType: CacheAdapterType.memory);
```

### Hive Adapter

The Hive adapter provides a good balance of performance and persistence.

**Best for:**
- General-purpose caching
- Structured data
- Default choice for most applications

```dart
await setupDataCacheX(adapterType: CacheAdapterType.hive);
```

### SQLite Adapter

The SQLite adapter is slower but provides robust persistence for larger datasets.

**Best for:**
- Larger datasets
- Complex querying needs
- Applications that already use SQLite

```dart
await setupDataCacheX(adapterType: CacheAdapterType.sqlite);
```

### SharedPreferences Adapter

The SharedPreferences adapter is suitable for simple key-value data but has performance limitations.

**Best for:**
- Simple key-value data
- Applications that already use SharedPreferences
- Compatibility with existing code

```dart
await setupDataCacheX(adapterType: CacheAdapterType.sharedPreferences);
```

## Optimizing Compression

Compression can reduce memory usage but adds CPU overhead. Here's how to optimize it:

### Auto Compression

Use `CompressionMode.auto` to only compress data when it's beneficial:

```dart
await dataCache.put('large_text', largeText,
    policy: CachePolicy(compression: CompressionMode.auto));
```

### Compression Level

Adjust the compression level based on your needs:
- Lower levels (1-3): Faster but less compression
- Higher levels (7-9): Better compression but slower

```dart
// Fast compression
await dataCache.put('large_text', largeText,
    policy: CachePolicy(
      compression: CompressionMode.always,
      compressionLevel: 1,
    ));

// Balanced compression
await dataCache.put('large_text', largeText,
    policy: CachePolicy(
      compression: CompressionMode.always,
      compressionLevel: 6,
    ));

// Maximum compression
await dataCache.put('large_text', largeText,
    policy: CachePolicy(
      compression: CompressionMode.always,
      compressionLevel: 9,
    ));
```

### Selective Compression

Only compress large data that benefits from compression:

```dart
// For small data
await dataCache.put('small_data', smallData,
    policy: CachePolicy(compression: CompressionMode.never));

// For large data
await dataCache.put('large_data', largeData,
    policy: CachePolicy(compression: CompressionMode.auto));
```

## Batch Operations

Use batch operations to improve performance when working with multiple items:

```dart
// More efficient than individual puts
await dataCache.putAll({
  'item1': value1,
  'item2': value2,
  'item3': value3,
});

// More efficient than individual gets
final values = await dataCache.getAll<dynamic>(['item1', 'item2', 'item3']);

// More efficient than individual deletes
await dataCache.deleteAll(['item1', 'item2', 'item3']);
```

## Asynchronous Operations

Leverage asynchronous operations to avoid blocking the UI thread:

```dart
// Use async/await for all cache operations
Future<void> loadData() async {
  final data = await dataCache.get<String>('data');
  // Use the data
}

// For large operations, consider using a compute function or isolate
import 'dart:isolate';

Future<void> cacheInBackground(Map<String, dynamic> data) async {
  await Isolate.run(() async {
    final dataCache = getIt<DataCacheX>();
    await dataCache.putAll(data);
  });
}
```

## Optimizing Size Estimation

The default size estimation is a rough approximation. For more accurate size estimation, you can implement a custom size calculator:

```dart
int calculateItemSize(dynamic value) {
  if (value is String) {
    return value.length * 2; // UTF-16 encoding
  } else if (value is num) {
    return 8; // Approximate size of a number
  } else if (value is bool) {
    return 1;
  } else if (value is List) {
    return value.fold<int>(0, (sum, item) => sum + calculateItemSize(item));
  } else if (value is Map) {
    return value.entries.fold<int>(
      0, 
      (sum, entry) => sum + calculateItemSize(entry.key) + calculateItemSize(entry.value)
    );
  } else {
    // For complex objects, serialize to JSON and measure
    return jsonEncode(value).length * 2;
  }
}

// Use this function when putting items in the cache
final size = calculateItemSize(value);
print('Estimated size: $size bytes');
```

## Optimizing Eviction Strategies

Choose the right eviction strategy based on your access patterns:

```dart
// For frequently accessed items
final cache = DataCacheX(
  cacheAdapter,
  evictionStrategy: EvictionStrategy.lfu,
);

// For recently accessed items
final cache = DataCacheX(
  cacheAdapter,
  evictionStrategy: EvictionStrategy.lru,
);

// For time-sensitive data
final cache = DataCacheX(
  cacheAdapter,
  evictionStrategy: EvictionStrategy.ttl,
);
```

## Caching Strategies

Implement effective caching strategies to maximize performance:

### Stale-While-Revalidate

Return stale data immediately while refreshing in the background:

```dart
final data = await dataCache.get<Data>(
  'api_data',
  refreshCallback: () => fetchDataFromApi(),
  policy: CachePolicy(
    staleTime: Duration(minutes: 5),
    refreshStrategy: RefreshStrategy.backgroundRefresh,
  ),
);
```

### Preloading

Preload frequently accessed data during app startup:

```dart
Future<void> preloadCache() async {
  final dataCache = getIt<DataCacheX>();
  
  // Preload common data
  final commonData = await fetchCommonData();
  await dataCache.put('common_data', commonData);
  
  // Preload user data
  final userData = await fetchUserData();
  await dataCache.put('user_data', userData);
}
```

### Prioritization

Prioritize important data to keep it in the cache longer:

```dart
// Critical data (evicted last)
await dataCache.put(
  'critical_data', 
  value, 
  policy: CachePolicy(priority: CachePriority.critical)
);

// High priority data
await dataCache.put(
  'important_data', 
  value, 
  policy: CachePolicy(priority: CachePriority.high)
);

// Low priority data (evicted first)
await dataCache.put(
  'temporary_data', 
  value, 
  policy: CachePolicy(priority: CachePriority.low)
);
```

## Memory Management

Implement effective memory management to avoid excessive memory usage:

### Set Size Limits

Set appropriate size limits for your cache:

```dart
final dataCache = DataCacheX(
  cacheAdapter,
  maxSize: 10 * 1024 * 1024, // 10 MB max
  maxItems: 1000, // 1000 items max
);
```

### Regular Cleanup

Perform regular cleanup to remove expired items:

```dart
// Set cleanup frequency during initialization
await setupDataCacheX(
  cleanupFrequency: Duration(hours: 1),
);

// Manually trigger cleanup
import 'package:data_cache_x/utils/background_cleanup.dart';

await BackgroundCleanup.performCleanup(cacheAdapter);
```

### Monitor Cache Size

Monitor the cache size to detect potential issues:

```dart
final dataCache = getIt<DataCacheX>();
final totalSize = dataCache.totalSize;
final itemCount = dataCache.getAnalyticsSummary()['itemCount'];

print('Cache size: $totalSize bytes');
print('Item count: $itemCount');

// If size is too large, clear some items
if (totalSize > 50 * 1024 * 1024) { // 50 MB
  await dataCache.clear();
}
```

## Performance Benchmarking

Benchmark your cache performance to identify bottlenecks:

```dart
Future<void> benchmarkCache() async {
  final dataCache = getIt<DataCacheX>();
  final stopwatch = Stopwatch()..start();
  
  // Benchmark put operation
  stopwatch.reset();
  for (int i = 0; i < 1000; i++) {
    await dataCache.put('key_$i', 'value_$i');
  }
  print('Put 1000 items: ${stopwatch.elapsedMilliseconds}ms');
  
  // Benchmark get operation
  stopwatch.reset();
  for (int i = 0; i < 1000; i++) {
    await dataCache.get<String>('key_$i');
  }
  print('Get 1000 items: ${stopwatch.elapsedMilliseconds}ms');
  
  // Benchmark delete operation
  stopwatch.reset();
  for (int i = 0; i < 1000; i++) {
    await dataCache.delete('key_$i');
  }
  print('Delete 1000 items: ${stopwatch.elapsedMilliseconds}ms');
}
```

## Best Practices

1. **Choose the right adapter** for your use case
2. **Use batch operations** for multiple items
3. **Optimize compression settings** based on your data
4. **Set appropriate size limits** for your cache
5. **Choose the right eviction strategy** for your access patterns
6. **Implement effective caching strategies** like stale-while-revalidate
7. **Monitor cache performance** to identify bottlenecks
8. **Perform regular cleanup** to remove expired items
9. **Use asynchronous operations** to avoid blocking the UI thread
10. **Benchmark your cache performance** to identify areas for improvement
