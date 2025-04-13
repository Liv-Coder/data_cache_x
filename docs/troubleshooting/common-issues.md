# Common Issues and Solutions

This guide covers common issues you might encounter when using data_cache_x and how to resolve them.

## Type Errors

### Issue: Type 'X' is not a subtype of type 'Y'

**Symptoms:**

- Error messages like `_CacheItemAdapter<List<String>> is not a subtype of TypeAdapter<List<String>>`
- Type casting errors when retrieving data from the cache

**Causes:**

- Using complex types (like Lists, Maps) without proper type adapters
- Retrieving data with the wrong type parameter

**Solutions:**

1. **Register custom type adapters for complex types:**

```dart
// Register a custom type adapter for List<String>
final typeAdapterRegistry = TypeAdapterRegistry();
typeAdapterRegistry.registerAdapter<List<String>>(
  ListStringAdapter(),
  typeId: 1,
);

await setupDataCacheX(
  customAdapters: {
    List<String>: ListStringAdapter(),
  },
);
```

2. **Use the correct type parameter when retrieving data:**

```dart
// Correct
final list = await dataCache.get<List<String>>('my_list');

// Incorrect
final list = await dataCache.get('my_list') as List<String>;
```

3. **For collections, consider storing as JSON strings:**

```dart
// Storing
final list = ['a', 'b', 'c'];
await dataCache.put('my_list', jsonEncode(list));

// Retrieving
final jsonString = await dataCache.get<String>('my_list');
final list = jsonDecode(jsonString) as List<dynamic>;
final stringList = list.cast<String>();
```

## Initialization Issues

### Issue: Cache not initialized

**Symptoms:**

- Error messages like `LateInitializationError: Field '_box' has not been initialized`
- `NoSuchMethodError` when trying to use the cache

**Causes:**

- Using the cache before it's fully initialized
- Not awaiting the `setupDataCacheX()` call

**Solutions:**

1. **Ensure proper initialization:**

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Always await the initialization
  await setupDataCacheX();

  runApp(MyApp());
}
```

2. **Check if the cache is initialized before using it:**

```dart
if (getIt.isRegistered<DataCacheX>()) {
  final dataCache = getIt<DataCacheX>();
  // Use the cache
}
```

## Performance Issues

### Issue: Slow cache operations

**Symptoms:**

- Cache operations taking longer than expected
- UI freezes when accessing the cache

**Causes:**

- Large data sets
- Inefficient compression settings
- Using the wrong adapter for your use case

**Solutions:**

1. **Choose the right adapter for your needs:**

   - Use Memory adapter for fastest performance (but non-persistent)
   - Use Hive adapter for a good balance of performance and persistence
   - Avoid SharedPreferences adapter for large data sets

2. **Optimize compression settings:**

```dart
// Only compress large items
await dataCache.put('large_data', largeData,
    policy: CachePolicy(
      compression: CompressionMode.auto,
      compressionLevel: 1, // Fastest compression
    ));

// Never compress small items
await dataCache.put('small_data', smallData,
    policy: CachePolicy(compression: CompressionMode.never));
```

3. **Use batch operations for multiple items:**

```dart
// More efficient than individual puts
await dataCache.putAll({
  'item1': value1,
  'item2': value2,
  'item3': value3,
});
```

4. **Consider using a background isolate for large operations:**

```dart
import 'dart:isolate';

Future<void> cacheInBackground(Map<String, dynamic> data) async {
  await Isolate.run(() async {
    final dataCache = getIt<DataCacheX>();
    await dataCache.putAll(data);
  });
}
```

## Memory Issues

### Issue: High memory usage

**Symptoms:**

- App using more memory than expected
- Out of memory errors

**Causes:**

- Cache size too large
- No eviction strategy set
- Storing large objects without compression

**Solutions:**

1. **Set appropriate cache size limits:**

```dart
final dataCache = DataCacheX(
  cacheAdapter,
  maxSize: 10 * 1024 * 1024, // 10 MB max
  maxItems: 1000, // 1000 items max
);
```

2. **Enable compression for large items:**

```dart
await dataCache.put('large_data', largeData,
    policy: CachePolicy(compression: CompressionMode.always));
```

3. **Choose an appropriate eviction strategy:**

```dart
final dataCache = DataCacheX(
  cacheAdapter,
  evictionStrategy: EvictionStrategy.lru,
);
```

4. **Manually clear unused items:**

```dart
// Clear specific items
await dataCache.deleteAll(['unused1', 'unused2']);

// Clear entire cache
await dataCache.clear();
```

## Persistence Issues

### Issue: Data not persisting between app launches

**Symptoms:**

- Cache is empty after restarting the app
- Unable to retrieve previously cached items

**Causes:**

- Using Memory adapter (which is non-persistent)
- Not initializing the cache properly
- Permission issues for file access

**Solutions:**

1. **Use a persistent adapter:**

```dart
await setupDataCacheX(adapterType: CacheAdapterType.hive);
// or
await setupDataCacheX(adapterType: CacheAdapterType.sqlite);
// or
await setupDataCacheX(adapterType: CacheAdapterType.sharedPreferences);
```

2. **Ensure proper initialization:**

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // For Hive adapter
  await Hive.initFlutter();

  await setupDataCacheX();

  runApp(MyApp());
}
```

3. **Check file permissions (Android):**

Ensure your app has the appropriate permissions in the `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

## Encryption Issues

### Issue: Encryption not working properly

**Symptoms:**

- Unable to retrieve encrypted items
- Error messages related to encryption/decryption

**Causes:**

- Inconsistent encryption settings
- Missing or invalid encryption key
- Using different keys for encryption and decryption

**Solutions:**

1. **Use consistent encryption settings:**

```dart
// During setup
await setupDataCacheX(
  enableEncryption: true,
  encryptionKey: 'my_secure_key',
);

// When storing data
await dataCache.put('sensitive_data', data,
    policy: CachePolicy(encrypt: true));
```

2. **Store your encryption key securely:**

Consider using a secure storage solution like `flutter_secure_storage` for the encryption key:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<String> getEncryptionKey() async {
  const storage = FlutterSecureStorage();
  String? key = await storage.read(key: 'cache_encryption_key');

  if (key == null) {
    // Generate a new key if none exists
    key = generateSecureRandomKey();
    await storage.write(key: 'cache_encryption_key', value: key);
  }

  return key;
}

// Then use it during setup
final key = await getEncryptionKey();
await setupDataCacheX(
  enableEncryption: true,
  encryptionKey: key,
);
```

## Still Having Issues?

If you're still experiencing problems after trying these solutions, please:

1. Check the [GitHub Issues](https://github.com/Liv-Coder/data_cache_x/issues) to see if others have reported the same problem
2. Create a new issue with detailed information about your problem, including:
   - data_cache_x version
   - Flutter/Dart version
   - Platform (iOS, Android, web, etc.)
   - Detailed error messages
   - Steps to reproduce the issue
   - Code samples demonstrating the issue
