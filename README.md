<p align="center">
  <img src="https://i.postimg.cc/dQCB3rxM/fbc2d4a9-5805-4368-b160-cc9613eb0a0f.jpg"
       alt="data_cache_x logo"
       style="width: 100%; height: 150; object-fit: cover;" />
</p>

# DataCacheX

A versatile and extensible caching library for Dart and Flutter applications.

## Why This Package?

`DataCacheX` is designed to simplify data caching in your Dart and Flutter projects. It provides a flexible and efficient way to store and retrieve data, with support for various storage adapters. Whether you're building a small app or a large-scale application, `DataCacheX` helps you manage your data effectively, reduce network requests, and improve overall performance.

## Features

- **Multi-Adapter Support:** Choose from various storage adapters, including Hive, memory, SQLite, and shared preferences, to suit your specific needs.
- **Data Caching:** Store and retrieve data of any type with ease.
- **Dependency Injection:** Utilizes `get_it` for dependency injection, making it easy to swap out different cache adapters and manage dependencies.
- **Automatic Background Cleanup:** Automatically removes expired items from the cache, ensuring efficient use of storage space.
- **Customizable Expiry:** Set expiry durations for cached items, allowing fine-grained control over data freshness.
- **Error Handling:** Includes robust error handling with custom exceptions for various error conditions.
- **Extensible:** Designed with extensibility in mind, allowing developers to easily add support for other storage adapters and data serializers.
- **Data Serialization:** Supports custom data serializers, allowing you to store complex data types.

## Installation

Add `data_cache_x` to your `pubspec.yaml` file:

```yaml
dependencies:
  data_cache_x: ^latest_version
```

Then, run `flutter pub get` to install the package.

## Usage

### Basic Usage

1. **Initialize the package:**

   ```dart
   import 'package:data_cache_x/data_cache_x.dart';
   import 'package:data_cache_x/service_locator.dart';

   Future<void> main() async {
     // Initialize the service locator
     await setupDataCacheX();

     // Get the DataCacheX instance
     final dataCache = getIt<DataCacheX>();

     // ...
   }
   ```

2. **Store data:**

   ```dart
   // Store a string with an expiry time of 1 hour
   await dataCache.put('myKey', 'myValue', expiry: Duration(hours: 1));

   // Store an integer without an expiry time
   await dataCache.put('anotherKey', 42);
   ```

3. **Retrieve data:**

   ```dart
   // Retrieve the string value
   final myValue = await dataCache.get<String>('myKey');
   print(myValue); // Output: myValue (if not expired)

   // Retrieve the integer value
   final anotherValue = await dataCache.get<int>('anotherKey');
   print(anotherValue); // Output: 42
   ```

4. **Delete data:**

   ```dart
   await dataCache.delete('myKey');
   ```

5. **Clear the cache:**

   ```dart
   await dataCache.clear();
   ```

6. **Check if a key exists:**

   ```dart
   final exists = await dataCache.containsKey('myKey');
   print(exists); // Output: true or false
   ```

### Advanced Usage

1. **Initialize Background Cleanup:**

   ```dart
   import 'package:data_cache_x/utils/background_cleanup.dart';

   // ...

   // Initialize background cleanup (call this after setting up the service locator)
   // This is automatically done when you call setupDataCacheX()
   // But you can manually control it if needed:
   BackgroundCleanup.initializeBackgroundCleanup(
     adapter: cacheAdapter,
     frequency: Duration(hours: 1),
   );
   ```

   This will set up a periodic timer that runs every hour to remove expired items from the cache.

2. **Using a different cache adapter:**

You can choose between different cache adapters during initialization:

```dart
import 'package:data_cache_x/service_locator.dart';

// Using the memory adapter
await setupDataCacheX(adapterType: CacheAdapterType.memory);

// Using the SQLite adapter
await setupDataCacheX(adapterType: CacheAdapterType.sqlite);

// Using the shared preferences adapter
await setupDataCacheX(adapterType: CacheAdapterType.sharedPreferences);
```

3. **Custom Adapters and Serializers:**

You can register custom adapters and serializers to handle specific data types:

```dart
import 'package:data_cache_x/service_locator.dart';
import 'package:data_cache_x/models/cache_item.dart';
import 'package:hive/hive.dart';
import 'package:data_cache_x/serializers/data_serializer.dart';
import 'dart:convert';

class MyCustomType {
  final String name;
  final int age;

  MyCustomType({required this.name, required this.age});
}

class MyCustomTypeAdapter extends TypeAdapter<CacheItem<MyCustomType>> {
  @override
  final int typeId = 1;

  @override
  CacheItem<MyCustomType> read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CacheItem<MyCustomType>(
      value: fields[0] as MyCustomType,
      expiry: fields[1] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, CacheItem<MyCustomType> obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.value)
      ..writeByte(1)
      ..write(obj.expiry);
  }
}

class MyCustomTypeSerializer implements DataSerializer<MyCustomType> {
  @override
  MyCustomType fromJson(String json) {
    final map = jsonDecode(json);
    return MyCustomType(name: map['name'], age: map['age']);
  }

  @override
  String toJson(MyCustomType value) {
    return jsonEncode({'name': value.name, 'age': value.age});
  }
}

Future<void> main() async {
  await setupDataCacheX(
    customAdapters: {
      MyCustomType: MyCustomTypeAdapter(),
    },
    customSerializers: {
      MyCustomType: MyCustomTypeSerializer(),
    },
  );
}
```

## API Reference

### `DataCacheX`

#### Storage Operations

- `Future<void> put<T>(String key, T value, {Duration? expiry, Duration? slidingExpiry})`:
  Stores a value in the cache with an optional expiry duration or sliding expiry.

  - `key`: Unique identifier for the cached item
  - `value`: The data to cache
  - `expiry`: Optional fixed expiration duration after which the item is considered expired
  - `slidingExpiry`: Optional sliding expiration that extends each time the item is accessed

- `Future<T?> get<T>(String key)`:
  Retrieves a value from the cache. Returns `null` if the key doesn't exist or the item is expired.

  - If using sliding expiry, each access extends the expiration time

- `Future<void> delete(String key)`:
  Deletes a value from the cache.

- `Future<void> clear()`:
  Clears the entire cache.

- `Future<bool> containsKey(String key)`:
  Checks if a key exists in the cache and hasn't expired.

#### Cache Invalidation

- `Future<void> invalidate(String key)`:
  Explicitly invalidates the cache entry with the specified key.

- `Future<void> invalidateWhere(bool Function(String key, dynamic value) test)`:
  Invalidates cache entries that match the given condition.
  - `test`: Function that takes a key and value, returning true for items to be invalidated

#### Cache Metrics

- `int get hitCount`:
  Returns the number of cache hits since the last reset.

- `int get missCount`:
  Returns the number of cache misses since the last reset.

- `double get hitRate`:
  Returns the ratio of hits to total requests (hits + misses).

- `void resetMetrics()`:
  Resets all cache metrics counters to zero.

### `CacheItem`

- `dynamic value`: The actual value to be cached.
- `DateTime? expiry`: An optional `DateTime` object representing the expiry date of the cached item.
- `Duration? slidingExpiry`: Optional sliding expiration duration that extends on each access.
- `bool get isExpired`: Returns `true` if the item has expired.

### Cache Adapters

- `CacheAdapterType.hive`: Uses Hive NoSQL database for persistent storage.
- `CacheAdapterType.memory`: Uses in-memory storage (volatile).
- `CacheAdapterType.sqlite`: Uses SQLite database for persistent storage.
- `CacheAdapterType.sharedPreferences`: Uses SharedPreferences for key-value storage.

### Background Cleanup

- `BackgroundCleanup.initializeBackgroundCleanup({required CacheAdapter adapter, Duration? frequency})`:
  Starts a periodic timer to clean up expired cache items.

  - `adapter`: The cache adapter to use for cleanup
  - `frequency`: Optional cleanup interval (defaults to 1 hour)

- `BackgroundCleanup.stopBackgroundCleanup()`:
  Stops the background cleanup process.

- `BackgroundCleanup.performCleanup(CacheAdapter cacheAdapter)`:
  Manually triggers a cleanup operation.

### Exceptions

- `DataCacheXException`: A general exception related to data storage operations.
- `KeyNotFoundException`: Thrown when a specified key is not found in the cache.
- `DataTypeMismatchException`: Thrown when there is a mismatch between the expected data type and the actual data type.
- `StorageException`: Thrown when there is an error related to the underlying storage mechanism.
- `CacheException`: A general exception related to cache operations.
- `AdapterNotFoundException`: Thrown when no adapter is registered for a given type.
- `SerializerNotFoundException`: Thrown when no serializer is registered for a given type.
