# Cache Preloading

## Overview

Cache preloading allows you to proactively load data into the cache before it's needed, which is useful for:

- Improving user experience by reducing wait times
- Implementing offline-first strategies
- Preparing data for high-demand periods
- Initializing the cache with default data

## Basic Usage

### Creating a Cache Preloader

```dart
import 'package:data_cache_x/data_cache_x.dart';

// Create a cache instance
final cache = DataCacheX(...);

// Create a preloader
final preloader = CachePreloader(cache);
```

### Preloading Data

To preload data into the cache:

```dart
// Define data providers
final dataProviders = <String, Future<dynamic> Function()>{
  'user_profile': () => fetchUserProfile(),
  'app_settings': () => fetchAppSettings(),
  'recent_items': () => fetchRecentItems(),
};

// Preload the data
final operations = await preloader.preload(dataProviders: dataProviders);

// Check the status of each operation
for (final entry in operations.entries) {
  print('${entry.key}: ${entry.value.status}');
}
```

### Preloading with a Cache Policy

You can apply a cache policy to all preloaded items:

```dart
// Preload with a policy
await preloader.preload(
  dataProviders: dataProviders,
  policy: CachePolicy(
    expiry: Duration(days: 1),
    priority: CachePriority.high,
  ),
);
```

### Preloading with Tags

You can associate tags with all preloaded items:

```dart
// Preload with tags
await preloader.preload(
  dataProviders: dataProviders,
  tags: {'preloaded', 'initial_data'},
);
```

## Advanced Usage

### Background Preloading

To preload data in the background without blocking the UI:

```dart
// Preload in the background
final stream = preloader.preloadInBackground(
  dataProviders: dataProviders,
);

// Listen for preload events
stream.listen((operation) {
  print('${operation.key}: ${operation.status}');
});
```

### Progress Tracking

You can track the progress of preloading operations:

```dart
// Preload with progress tracking
await preloader.preload(
  dataProviders: dataProviders,
  onProgress: (key, status, progress) {
    print('$key: $status - ${(progress * 100).toStringAsFixed(1)}%');
  },
);
```

### Controlling Parallelism

You can control how many items are preloaded in parallel:

```dart
// Preload with limited parallelism
await preloader.preload(
  dataProviders: dataProviders,
  parallelism: 3, // Load 3 items at a time
);
```

### Cancelling Preloading

You can cancel preloading operations:

```dart
// Cancel a specific preload operation
preloader.cancelPreload('user_profile');

// Cancel all preload operations
preloader.cancelAllPreloads();
```

## Implementation Details

### Preload Operation Lifecycle

Each preload operation goes through the following states:

1. `PreloadStatus.notStarted`: The operation has been created but not started
2. `PreloadStatus.inProgress`: The operation is currently running
3. `PreloadStatus.completed`: The operation completed successfully
4. `PreloadStatus.failed`: The operation failed with an error
5. `PreloadStatus.cancelled`: The operation was cancelled

### Error Handling

The preloader handles errors gracefully:

- If a data provider throws an error, the operation is marked as failed
- The error is recorded in the operation's `error` property
- Other operations continue to run
- Failed operations do not prevent successful operations from completing

### Memory Management

To prevent memory leaks, you can clear completed operations:

```dart
// Clear completed operations
final cleared = preloader.clearCompletedOperations();
print('Cleared $cleared completed operations');
```

## Example: App Initialization

Here's an example of using preloading for app initialization:

```dart
class AppInitializer {
  final DataCacheX cache;
  final CachePreloader preloader;
  final ValueNotifier<double> initProgress = ValueNotifier(0.0);

  AppInitializer({
    required this.cache,
  }) : preloader = CachePreloader(cache);

  // Initialize the app
  Future<void> initialize() async {
    // Define data providers for initialization
    final dataProviders = <String, Future<dynamic> Function()>{
      'user_profile': () => fetchUserProfile(),
      'app_settings': () => fetchAppSettings(),
      'categories': () => fetchCategories(),
      'featured_items': () => fetchFeaturedItems(),
      'notifications': () => fetchNotifications(),
    };

    // Preload with progress tracking
    await preloader.preload(
      dataProviders: dataProviders,
      policy: CachePolicy(
        expiry: Duration(days: 1),
        priority: CachePriority.high,
      ),
      tags: {'initialization'},
      onProgress: (key, status, progress) {
        initProgress.value = progress;
      },
    );

    // Clear completed operations to free up memory
    preloader.clearCompletedOperations();
  }
}
```

## Example: Prefetching for Offline Use

Here's an example of prefetching data for offline use:

```dart
class OfflineDataManager {
  final DataCacheX cache;
  final CachePreloader preloader;

  OfflineDataManager({
    required this.cache,
  }) : preloader = CachePreloader(cache);

  // Prefetch data for offline use
  Future<void> prefetchForOffline() async {
    // Define data providers for offline use
    final dataProviders = <String, Future<dynamic> Function()>{
      'articles': () => fetchArticles(),
      'images': () => fetchImages(),
      'videos': () => fetchVideoMetadata(),
    };

    // Preload with a long expiry and offline tag
    await preloader.preload(
      dataProviders: dataProviders,
      policy: CachePolicy(
        expiry: Duration(days: 7),
        priority: CachePriority.high,
        compression: CompressionMode.always,
      ),
      tags: {'offline'},
      onProgress: (key, status, progress) {
        print('Offline prefetch: ${(progress * 100).toStringAsFixed(1)}%');
      },
    );
  }

  // Check if offline data is available
  Future<bool> isOfflineDataAvailable() async {
    final keys = await cache.getKeysByTag('offline');
    return keys.isNotEmpty;
  }
}
```

## Cleaning Up

Don't forget to dispose the preloader when you're done with it:

```dart
// Dispose the preloader
preloader.dispose();
```

This will cancel any active operations and free up resources.
