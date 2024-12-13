# data_cache_x

A Dart package for caching data using Hive as a backend, with support for automatic background cleanup of expired items.

## Features

- **Data Caching:** Store and retrieve data of any type using Hive as the underlying storage.
- **Dependency Injection:** Utilizes `get_it` for dependency injection, making it easy to swap out different cache adapters.
- **Hive Integration:** Leverages Hive's NoSQL database capabilities for fast and efficient data storage.
- **Automatic Background Cleanup:** Automatically removes expired items from the cache using the `workmanager` package, ensuring efficient use of storage space.
- **Customizable Expiry:** Set expiry durations for cached items, allowing fine-grained control over data freshness.
- **Error Handling:** Includes robust error handling with custom exceptions for various error conditions.
- **Extensible:** Designed with extensibility in mind, allowing developers to easily add support for other storage adapters.

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
   initializeBackgroundCleanup();
   ```

   This will schedule a periodic task that runs every hour to remove expired items from the cache.

2. **Using a different cache adapter:**

   You can create your own cache adapter by implementing the `CacheAdapter` interface and then registering it with the service locator.

   ```dart
   // Example: Creating a custom cache adapter (not implemented in the provided code)
   class MyCustomAdapter implements CacheAdapter {
     // Implement the CacheAdapter methods
     // ...
   }

   // Registering the custom adapter with the service locator
   getIt.registerSingleton<CacheAdapter>(MyCustomAdapter());

   // Using the custom adapter
   getIt.registerSingleton<DataCacheX>(DataCacheX(getIt<CacheAdapter>()));
   ```

## API Reference

### `DataCacheX`

- `put<T>(String key, T value, {Duration? expiry})`: Stores a value in the cache with an optional expiry duration.
- `get<T>(String key)`: Retrieves a value from the cache. Returns `null` if the key doesn't exist or the item is expired.
- `delete(String key)`: Deletes a value from the cache.
- `clear()`: Clears the entire cache.
- `containsKey(String key)`: Checks if a key exists in the cache.

### `CacheItem`

- `value`: The actual value to be cached.
- `expiry`: An optional `DateTime` object representing the expiry date of the cached item.
- `isExpired`: Returns `true` if the item has expired.

## Exceptions

- `DataCacheXException`: A general exception related to data storage operations.
- `KeyNotFoundException`: Thrown when a specified key is not found in the cache.
- `DataTypeMismatchException`: Thrown when there is a mismatch between the expected data type and the actual data type.
- `StorageException`: Thrown when there is an error related to the underlying storage mechanism.
- `CacheException`: A general exception related to cache operations.
