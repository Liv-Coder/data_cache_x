# Cache Adapters

## Understanding Cache Adapters

Cache adapters are the backbone of data_cache_x, providing the actual storage mechanism for cached data. The package follows the adapter pattern, allowing you to switch between different storage backends without changing your application code.

## Available Adapters

data_cache_x comes with four built-in adapters:

### Memory Adapter

The Memory Adapter stores data in memory, making it extremely fast but volatile (data is lost when the app is closed).

**Best for:**
- Temporary data that doesn't need to persist
- High-performance caching with frequent reads/writes
- Testing and development

**Usage:**
```dart
await setupDataCacheX(adapterType: CacheAdapterType.memory);
```

**Characteristics:**
- Fastest performance
- Data is lost when the app is closed
- No size limitations other than available memory
- No setup required

### Hive Adapter

The Hive Adapter uses the [Hive](https://pub.dev/packages/hive) NoSQL database for storage, providing a good balance of performance and persistence.

**Best for:**
- General-purpose caching
- Structured data
- Default choice for most applications

**Usage:**
```dart
await setupDataCacheX(adapterType: CacheAdapterType.hive);
```

**Characteristics:**
- Good performance
- Persistent storage
- Type-safe with custom adapters
- Requires initialization with `Hive.initFlutter()`

### SQLite Adapter

The SQLite Adapter uses the [SQLite](https://pub.dev/packages/sqflite) database for storage, providing robust persistence for larger datasets.

**Best for:**
- Larger datasets
- Complex querying needs
- Applications that already use SQLite

**Usage:**
```dart
await setupDataCacheX(adapterType: CacheAdapterType.sqlite);
```

**Characteristics:**
- Moderate performance
- Robust persistent storage
- Good for larger datasets
- Requires no additional setup

### SharedPreferences Adapter

The SharedPreferences Adapter uses the [SharedPreferences](https://pub.dev/packages/shared_preferences) package for storage, providing simple key-value persistence.

**Best for:**
- Simple key-value data
- Applications that already use SharedPreferences
- Compatibility with existing code

**Usage:**
```dart
await setupDataCacheX(adapterType: CacheAdapterType.sharedPreferences);
```

**Characteristics:**
- Moderate performance
- Persistent storage
- Limited to simple data types
- Size limitations (varies by platform)

## Adapter Performance Comparison

| Adapter | Read Speed | Write Speed | Persistence | Size Limitations | Complexity Support |
|---------|------------|------------|-------------|------------------|-------------------|
| Memory | ★★★★★ | ★★★★★ | ❌ | Memory | ★★★★★ |
| Hive | ★★★★☆ | ★★★★☆ | ✅ | Disk | ★★★★☆ |
| SQLite | ★★★☆☆ | ★★★☆☆ | ✅ | Disk | ★★★★☆ |
| SharedPreferences | ★★★☆☆ | ★★☆☆☆ | ✅ | Platform-specific | ★★☆☆☆ |

## Creating Custom Adapters

You can create your own custom adapters by implementing the `CacheAdapter` interface:

```dart
class MyCustomAdapter implements CacheAdapter {
  @override
  final bool enableEncryption;

  MyCustomAdapter({this.enableEncryption = false});

  @override
  Future<void> put(String key, CacheItem<dynamic> value) async {
    // Implementation
  }

  @override
  Future<CacheItem<dynamic>?> get(String key) async {
    // Implementation
  }

  @override
  Future<void> delete(String key) async {
    // Implementation
  }

  @override
  Future<void> clear() async {
    // Implementation
  }

  @override
  Future<bool> containsKey(String key) async {
    // Implementation
  }

  @override
  Future<List<String>> getKeys({int? limit, int? offset}) async {
    // Implementation
  }
}
```

See [Creating Custom Adapters](../advanced-usage/custom-adapters.md) for more information.

## Best Practices

- **Choose the right adapter for your needs**: Consider the trade-offs between performance, persistence, and complexity support.
- **Use Memory adapter for testing**: The Memory adapter is ideal for testing as it doesn't require any setup and doesn't persist data between test runs.
- **Consider encryption for sensitive data**: All adapters support encryption for sensitive data.
- **Be aware of platform limitations**: Some adapters may have platform-specific limitations, especially on web.
