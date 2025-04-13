# Installation

## Adding data_cache_x to Your Project

Add `data_cache_x` to your `pubspec.yaml` file:

```yaml
dependencies:
  data_cache_x: ^latest_version
```

Then run:

```bash
flutter pub get
```

## Import the Package

```dart
import 'package:data_cache_x/data_cache_x.dart';
import 'package:data_cache_x/service_locator.dart';
```

## Initialize the Package

Before using data_cache_x, you need to initialize it. This is typically done in your `main.dart` file:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize with default settings (Hive adapter)
  await setupDataCacheX();
  
  // Get the DataCacheX instance
  final dataCache = getIt<DataCacheX>();
  
  runApp(MyApp());
}
```

## Choosing a Different Adapter

data_cache_x supports multiple storage adapters. You can choose the one that best fits your needs:

```dart
// Use memory adapter (volatile, but fast)
await setupDataCacheX(adapterType: CacheAdapterType.memory);

// Use SQLite adapter (persistent, good for larger datasets)
await setupDataCacheX(adapterType: CacheAdapterType.sqlite);

// Use SharedPreferences adapter (persistent, simple key-value storage)
await setupDataCacheX(adapterType: CacheAdapterType.sharedPreferences);
```

## Additional Configuration Options

The `setupDataCacheX` function accepts several optional parameters for customizing the behavior of the cache:

```dart
await setupDataCacheX(
  boxName: 'my_cache', // Custom name for the storage container
  cleanupFrequency: Duration(hours: 2), // How often to clean up expired items
  enableEncryption: true, // Enable encryption for sensitive data
  encryptionKey: 'my_secret_key', // Custom encryption key
  customSerializers: { // Custom serializers for complex types
    UserProfile: UserProfileSerializer(),
  },
);
```

## Next Steps

Now that you have installed and initialized data_cache_x, you can start using it to cache data in your application. See the [Basic Usage](basic-usage.md) guide for more information.
