# Cache Synchronization

## Overview

Cache synchronization allows you to keep multiple cache instances in sync, which is useful for:

- Synchronizing cache data between different parts of your application
- Implementing multi-instance caching with shared data
- Creating backup/restore mechanisms for cached data
- Implementing offline-first strategies with server synchronization

## Basic Usage

### Creating a Cache Synchronizer

```dart
import 'package:data_cache_x/data_cache_x.dart';

// Create two cache instances
final primaryCache = DataCacheX(...);
final remoteCache = DataCacheX(...);

// Create a synchronizer for the primary cache
final synchronizer = CacheSynchronizer(primaryCache);
```

### One-Way Synchronization

To synchronize data from a remote cache to the primary cache:

```dart
// Sync all data from remote to primary (one-way)
await synchronizer.syncWith(remoteCache);
```

This will:
1. Copy all items from the remote cache to the primary cache
2. Delete items from the primary cache that don't exist in the remote cache

### Bidirectional Synchronization

To synchronize data in both directions:

```dart
// Sync data bidirectionally
await synchronizer.syncWith(
  remoteCache,
  bidirectional: true,
);
```

This will:
1. Copy items from remote to primary
2. Copy items from primary to remote
3. Ensure both caches have the same items

### Selective Synchronization

To synchronize only specific keys:

```dart
// Sync only specific keys
await synchronizer.syncWith(
  remoteCache,
  keys: {'user_profile', 'settings', 'recent_items'},
);
```

## Advanced Usage

### Conflict Resolution

When the same key exists in both caches, you can specify how to resolve conflicts:

```dart
// Sync with conflict resolution
await synchronizer.syncWith(
  remoteCache,
  conflictResolution: ConflictResolution.newerWins,
);
```

Available conflict resolution strategies:

- `ConflictResolution.newerWins`: The newer item (based on last access time) wins
- `ConflictResolution.remoteWins`: The remote item always wins
- `ConflictResolution.localWins`: The local (primary) item always wins
- `ConflictResolution.mergePreferRemote`: Merge items, preferring remote values for conflicts
- `ConflictResolution.mergePreferLocal`: Merge items, preferring local values for conflicts

### Applying Policies During Synchronization

You can apply a cache policy to all synchronized items:

```dart
// Sync with a policy
await synchronizer.syncWith(
  remoteCache,
  policy: CachePolicy(
    expiry: Duration(days: 7),
    priority: CachePriority.high,
  ),
);
```

### Monitoring Synchronization Events

You can listen for synchronization events:

```dart
// Listen for sync events
synchronizer.syncEvents.listen((event) {
  switch (event.type) {
    case SyncEventType.syncStarted:
      print('Sync started');
      break;
    case SyncEventType.update:
      print('Updated key: ${event.key}');
      break;
    case SyncEventType.delete:
      print('Deleted key: ${event.key}');
      break;
    case SyncEventType.batchUpdate:
      print('Batch updated ${event.keys?.length} keys');
      break;
    case SyncEventType.batchDelete:
      print('Batch deleted ${event.keys?.length} keys');
      break;
    case SyncEventType.syncCompleted:
      print('Sync completed');
      break;
    case SyncEventType.error:
      print('Sync error: ${event.error}');
      break;
  }
});
```

## Implementation Details

### Synchronization Process

The synchronization process works as follows:

1. Get all keys from both caches
2. Determine which keys to synchronize (all keys or specified keys)
3. Process keys in batches to avoid memory issues
4. For each key:
   - If it exists in the remote cache but not in the primary cache, copy it to the primary cache
   - If it exists in both caches, apply the conflict resolution strategy
   - If it exists in the primary cache but not in the remote cache:
     - In one-way sync: delete it from the primary cache
     - In bidirectional sync: copy it to the remote cache
5. Emit events for each operation

### Performance Considerations

- Synchronization can be resource-intensive for large caches
- Keys are processed in batches to minimize memory usage
- Consider using selective synchronization for large caches
- For very large datasets, consider implementing a custom synchronization strategy

## Example: Offline-First Strategy

Here's an example of implementing an offline-first strategy:

```dart
class OfflineFirstRepository {
  final DataCacheX localCache;
  final DataCacheX serverCache;
  final CacheSynchronizer synchronizer;

  OfflineFirstRepository({
    required this.localCache,
    required this.serverCache,
  }) : synchronizer = CacheSynchronizer(localCache);

  // Sync with server when online
  Future<void> syncWithServer() async {
    try {
      await synchronizer.syncWith(
        serverCache,
        bidirectional: true,
        conflictResolution: ConflictResolution.newerWins,
      );
      print('Synchronized with server');
    } catch (e) {
      print('Failed to synchronize with server: $e');
    }
  }

  // Get data (always from local cache first)
  Future<T?> getData<T>(String key) async {
    return await localCache.get<T>(key);
  }

  // Save data (to local cache, sync later)
  Future<void> saveData<T>(String key, T value) async {
    await localCache.put(key, value);
  }
}
```

## Cleaning Up

Don't forget to dispose the synchronizer when you're done with it:

```dart
// Dispose the synchronizer
synchronizer.dispose();
```

This will cancel any active subscriptions and free up resources.
