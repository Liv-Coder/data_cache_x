<p align="center">
  <img src="https://i.postimg.cc/dQCB3rxM/fbc2d4a9-5805-4368-b160-cc9613eb0a0f.jpg"
       alt="data_cache_x logo"
       style="width: 100%; height: 150; object-fit: cover;" />
</p>

<h1 align="center">DataCacheX</h1>
<p align="center">A versatile and extensible caching library for Dart and Flutter applications</p>

<p align="center">
  <a href="https://pub.dev/packages/data_cache_x">
    <img src="https://img.shields.io/pub/v/data_cache_x.svg" alt="Pub">
  </a>
  <a href="https://github.com/Liv-Coder/data_cache_x/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/Liv-Coder/data_cache_x" alt="License: MIT">
  </a>
</p>

---

## 📋 Overview

**DataCacheX** is a powerful caching solution designed to simplify data management in your Dart and Flutter applications. It provides a flexible and efficient way to store and retrieve data with support for multiple storage backends, advanced caching policies, and comprehensive analytics.

### Why Choose DataCacheX?

- **Multiple Storage Options**: Choose from memory, Hive, SQLite, or SharedPreferences adapters
- **Flexible Caching Policies**: Configure expiry, compression, encryption, and priority
- **Enhanced Security**: Multiple encryption algorithms (AES-256, ChaCha20, Salsa20) and secure key storage
- **Tag-Based Management**: Organize and selectively invalidate cache items using tags
- **Memory Management**: Automatic cleanup and multiple eviction strategies
- **Performance Analytics**: Track cache performance with built-in metrics
- **Type Safety**: Full support for generic types and complex data structures
- **Extensibility**: Easy to extend with custom adapters and serializers

## 🚀 Installation

Add `data_cache_x` to your `pubspec.yaml` file:

```yaml
dependencies:
  data_cache_x: ^latest_version
```

Then run:

```bash
flutter pub get
```

## 🔧 Quick Start

### Initialize the Package

```dart
import 'package:data_cache_x/data_cache_x.dart';
import 'package:data_cache_x/service_locator.dart';

Future<void> main() async {
  // Initialize with default settings (Hive adapter)
  await setupDataCacheX();

  // Get the DataCacheX instance
  final dataCache = getIt<DataCacheX>();

  // Start using the cache
  await dataCache.put('greeting', 'Hello, World!');
  final value = await dataCache.get<String>('greeting');
  print(value); // Output: Hello, World!
}
```

### Choose a Different Adapter

```dart
// Use memory adapter (volatile, but fast)
await setupDataCacheX(adapterType: CacheAdapterType.memory);

// Use SQLite adapter (persistent, good for larger datasets)
await setupDataCacheX(adapterType: CacheAdapterType.sqlite);

// Use SharedPreferences adapter (persistent, simple key-value storage)
await setupDataCacheX(adapterType: CacheAdapterType.sharedPreferences);
```

## 📚 Core Features

### Basic Cache Operations

```dart
// Store values with optional expiry
await dataCache.put('user_profile', userProfile,
    expiry: Duration(hours: 24));

// Retrieve values with type safety
final profile = await dataCache.get<UserProfile>('user_profile');

// Check if a key exists
final exists = await dataCache.containsKey('user_profile');

// Delete a value
await dataCache.delete('user_profile');

// Clear the entire cache
await dataCache.clear();
```

### Batch Operations

```dart
// Store multiple values at once
await dataCache.putAll({
  'user': currentUser,
  'settings': appSettings,
  'theme': currentTheme,
}, expiry: Duration(days: 7));

// Retrieve multiple values
final values = await dataCache.getAll<dynamic>([
  'user', 'settings', 'theme'
]);

// Delete multiple values
await dataCache.deleteAll(['user', 'settings', 'theme']);
```

### Advanced Caching Policies

```dart
// Create a custom policy
final myPolicy = CachePolicy(
  expiry: Duration(hours: 24),         // Fixed expiry time
  slidingExpiry: Duration(hours: 2),    // Extends on each access
  staleTime: Duration(minutes: 30),     // Time before refresh
  priority: CachePriority.high,         // Higher priority in eviction
  refreshStrategy: RefreshStrategy.backgroundRefresh,
  maxSize: 1024 * 10,                   // 10 KB max size
  encrypt: true,                        // Enable encryption
  encryptionAlgorithm: EncryptionAlgorithm.aes256, // Encryption algorithm
  compression: CompressionMode.auto,    // Auto-compress if beneficial
);

// Apply the policy
await dataCache.put('important_data', data, policy: myPolicy);

// Use predefined policies
await dataCache.put('sensitive_data', userData,
    policy: CachePolicy.encrypted(expiry: Duration(days: 7)));

await dataCache.put('temp_data', tempData,
    policy: CachePolicy.temporary);

await dataCache.put('large_data', largeData,
    policy: CachePolicy.compressed());
```

### Auto-Refresh with Callbacks

```dart
// Get data with auto-refresh when stale
final userData = await dataCache.get<UserData>('user_data',
  refreshCallback: () => fetchUserFromApi(),  // Called when data is stale/expired
  policy: CachePolicy(
    staleTime: Duration(minutes: 5),
    refreshStrategy: RefreshStrategy.backgroundRefresh,
  ),
);

// Multiple items with different refresh callbacks
final data = await dataCache.getAll<dynamic>(['users', 'posts', 'comments'],
  refreshCallbacks: {
    'users': () => fetchUsersFromApi(),
    'posts': () => fetchPostsFromApi(),
    'comments': () => fetchCommentsFromApi(),
  },
  policy: CachePolicy(staleTime: Duration(minutes: 10)),
);
```

### Enhanced Encryption

```dart
// Initialize with encryption options
import 'package:data_cache_x/utils/encryption.dart';
import 'package:data_cache_x/models/encryption_options.dart';

// Create encryption options with AES-256
final aesOptions = EncryptionOptions.aes256(
  key: 'your-secure-encryption-key-here',
);

// Generate a random secure key
final randomKeyOptions = EncryptionOptions.withRandomKey(
  algorithm: EncryptionAlgorithm.aes256,
);

// Derive a key from a password
final passwordOptions = EncryptionOptions.fromPassword(
  password: 'user-password',
  salt: 'random-salt-value',
  algorithm: EncryptionAlgorithm.aes256,
);

// Initialize cache with encryption
await setupDataCacheX(
  enableEncryption: true,
  encryptionOptions: aesOptions,
);
```

### Tag-Based Cache Management

```dart
// Store items with tags
await dataCache.put('user_1', userData1, tags: {'users', 'active'});
await dataCache.put('user_2', userData2, tags: {'users', 'inactive'});
await dataCache.put('product_1', product1, tags: {'products', 'featured'});

// Store multiple items with the same tags
await dataCache.putAll({
  'order_1': order1,
  'order_2': order2,
  'order_3': order3,
}, tags: {'orders', 'recent'});

// Get all keys with a specific tag
final userKeys = await dataCache.getKeysByTag('users');

// Get all keys with multiple tags
final activeUserKeys = await dataCache.getKeysByTags(['users', 'active']);

// Get all items with a specific tag
final allUsers = await dataCache.getByTag<UserData>('users');

// Delete all items with a specific tag
await dataCache.deleteByTag('inactive');

// Delete all items with multiple tags
await dataCache.deleteByTags(['orders', 'recent']);
```

## 🔍 Advanced Features

### Memory Management with Eviction Strategies

```dart
// Create a cache with LRU (Least Recently Used) eviction
final lruCache = DataCacheX(
  cacheAdapter,
  maxSize: 10 * 1024 * 1024,  // 10 MB max size
  maxItems: 1000,             // 1000 items max
  evictionStrategy: EvictionStrategy.lru,
);

// Other available strategies
// LFU (Least Frequently Used)
final lfuCache = DataCacheX(
  cacheAdapter,
  evictionStrategy: EvictionStrategy.lfu,
);

// FIFO (First In, First Out)
final fifoCache = DataCacheX(
  cacheAdapter,
  evictionStrategy: EvictionStrategy.fifo,
);

// TTL (Time To Live - prioritizes items closest to expiration)
final ttlCache = DataCacheX(
  cacheAdapter,
  evictionStrategy: EvictionStrategy.ttl,
);
```

### Data Compression

```dart
// Create a cache with compression support
final compressedCache = DataCacheX(
  cacheAdapter,
  compressionLevel: 6,  // 1 (fastest) to 9 (most compression)
);

// Auto compression (only compresses if beneficial)
await dataCache.put('large_text', largeString,
    policy: CachePolicy(compression: CompressionMode.auto));

// Always compress
await dataCache.put('always_compressed', value,
    policy: CachePolicy(compression: CompressionMode.always));

// Never compress
await dataCache.put('never_compressed', value,
    policy: CachePolicy(compression: CompressionMode.never));
```

### Cache Analytics

```dart
// Get basic metrics
print('Hit rate: ${dataCache.hitRate}%');
print('Total size: ${dataCache.totalSize} bytes');
print('Average item size: ${dataCache.averageItemSize} bytes');

// Get most frequently accessed keys
final topKeys = dataCache.mostFrequentlyAccessedKeys;
for (final entry in topKeys) {
  print('${entry.key}: ${entry.value} accesses');
}

// Get largest items
final largestItems = dataCache.largestItems;
for (final entry in largestItems) {
  print('${entry.key}: ${entry.value} bytes');
}

// Get complete analytics summary
final summary = dataCache.getAnalyticsSummary();
print(summary);

// Reset metrics
dataCache.resetMetrics();
```

### Background Cleanup

```dart
import 'package:data_cache_x/utils/background_cleanup.dart';

// Initialize background cleanup (automatically done by setupDataCacheX)
// But you can manually control it if needed:
BackgroundCleanup.initializeBackgroundCleanup(
  adapter: cacheAdapter,
  frequency: Duration(hours: 1),
);

// Stop background cleanup
BackgroundCleanup.stopBackgroundCleanup();

// Manually trigger cleanup
BackgroundCleanup.performCleanup(cacheAdapter);
```

### Custom Adapters and Serializers

```dart
import 'package:data_cache_x/serializers/data_serializer.dart';
import 'dart:convert';

// Define a custom data type
class UserProfile {
  final String name;
  final int age;

  UserProfile({required this.name, required this.age});
}

// Create a serializer for the custom type
class UserProfileSerializer implements DataSerializer<UserProfile> {
  @override
  UserProfile fromJson(String json) {
    final map = jsonDecode(json);
    return UserProfile(name: map['name'], age: map['age']);
  }

  @override
  String toJson(UserProfile value) {
    return jsonEncode({'name': value.name, 'age': value.age});
  }
}

// Register the custom serializer
await setupDataCacheX(
  customSerializers: {
    UserProfile: UserProfileSerializer(),
  },
);
```

## 🧪 Example App

The package includes a comprehensive example app (CacheHub) that demonstrates all features:

- **News Feed**: API caching with different policies
- **Image Gallery**: Binary data caching for images
- **Analytics**: Cache performance visualization
- **Explorer**: Browse and manipulate cached data
- **Adapter Playground**: Benchmark different adapters
- **Settings**: Configure cache behavior

To run the example app:

```bash
cd example
flutter pub get
flutter run
```

## 📘 API Reference

### DataCacheX Class

| Method                                                                                                                 | Description                               |
| ---------------------------------------------------------------------------------------------------------------------- | ----------------------------------------- |
| `Future<void> put<T>(String key, T value, {CachePolicy? policy})`                                                      | Stores a value in the cache               |
| `Future<T?> get<T>(String key, {Function? refreshCallback, CachePolicy? policy})`                                      | Retrieves a value from the cache          |
| `Future<void> delete(String key)`                                                                                      | Deletes a value from the cache            |
| `Future<void> clear()`                                                                                                 | Clears the entire cache                   |
| `Future<bool> containsKey(String key)`                                                                                 | Checks if a key exists and hasn't expired |
| `Future<void> putAll(Map<String, dynamic> entries, {CachePolicy? policy})`                                             | Stores multiple values at once            |
| `Future<Map<String, T?>> getAll<T>(List<String> keys, {Map<String, Function>? refreshCallbacks, CachePolicy? policy})` | Retrieves multiple values at once         |
| `Future<void> deleteAll(List<String> keys)`                                                                            | Deletes multiple values at once           |
| `Future<void> invalidate(String key)`                                                                                  | Explicitly invalidates a cache entry      |
| `Future<void> invalidateWhere(bool Function(String, dynamic) test)`                                                    | Invalidates entries matching a condition  |

### Cache Adapters

- `CacheAdapterType.hive`: Hive NoSQL database (persistent)
- `CacheAdapterType.memory`: In-memory storage (volatile)
- `CacheAdapterType.sqlite`: SQLite database (persistent)
- `CacheAdapterType.sharedPreferences`: SharedPreferences (persistent)

### Eviction Strategies

- `EvictionStrategy.lru`: Least Recently Used
- `EvictionStrategy.lfu`: Least Frequently Used
- `EvictionStrategy.fifo`: First In, First Out
- `EvictionStrategy.ttl`: Time To Live (expiry-based)

### Cache Priorities

- `CachePriority.low`: Evicted first
- `CachePriority.normal`: Default priority
- `CachePriority.high`: Higher retention priority
- `CachePriority.critical`: Evicted last

### Compression Modes

- `CompressionMode.auto`: Compress only if beneficial
- `CompressionMode.always`: Always compress
- `CompressionMode.never`: Never compress

### Encryption Algorithms

- `EncryptionAlgorithm.aes256`: AES-256 encryption (default)

### Tag-Based Cache API Reference

| Method                                                                             | Description                               |
| ---------------------------------------------------------------------------------- | ----------------------------------------- |
| `Future<List<String>> getKeysByTag(String tag, {int? limit, int? offset})`         | Gets keys with a specific tag             |
| `Future<List<String>> getKeysByTags(List<String> tags, {int? limit, int? offset})` | Gets keys with all specified tags         |
| `Future<void> deleteByTag(String tag)`                                             | Deletes all items with a specific tag     |
| `Future<void> deleteByTags(List<String> tags)`                                     | Deletes all items with all specified tags |
| `Future<Map<String, T>> getByTag<T>(String tag, {CachePolicy? policy})`            | Gets all items with a specific tag        |
| `Future<Map<String, T>> getByTags<T>(List<String> tags, {CachePolicy? policy})`    | Gets all items with all specified tags    |

### Secure Key Storage

```dart
import 'package:data_cache_x/utils/secure_storage.dart';

// Create a secure storage instance
final secureStorage = SecureStorage();

// Generate and store a random encryption key
final encryptionOptions = await secureStorage.generateAndStoreKey(
  algorithm: EncryptionAlgorithm.aes256,
);

// Derive a key from a password
final encryptionOptions = await secureStorage.deriveAndStoreKey(
  password: 'my-secure-password',
  salt: 'random-salt-value',
  algorithm: EncryptionAlgorithm.chacha20,
  iterations: 10000,
);

// Retrieve stored encryption options
final encryptionOptions = await secureStorage.getEncryptionOptions();

// Initialize cache with encryption
await setupDataCacheX(
  enableEncryption: true,
  encryptionOptions: encryptionOptions,
);
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
