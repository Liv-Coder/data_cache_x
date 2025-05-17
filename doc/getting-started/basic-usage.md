# Basic Usage

## Getting Started with data_cache_x

After [installing and initializing](installation.md) data_cache_x, you can start using it to cache data in your application.

## Basic Operations

### Storing Data

To store a value in the cache:

```dart
// Get the DataCacheX instance
final dataCache = getIt<DataCacheX>();

// Store a simple value
await dataCache.put('greeting', 'Hello, World!');

// Store a value with expiry
await dataCache.put(
  'user_profile', 
  userProfile,
  expiry: Duration(hours: 24)
);

// Store a value with a custom policy
final myPolicy = CachePolicy(
  expiry: Duration(hours: 1),
  priority: CachePriority.high,
  compression: CompressionMode.auto,
);

await dataCache.put('important_data', data, policy: myPolicy);
```

### Retrieving Data

To retrieve a value from the cache:

```dart
// Get a value
final greeting = await dataCache.get<String>('greeting');
print(greeting); // Output: Hello, World!

// Get a value with a type
final userProfile = await dataCache.get<UserProfile>('user_profile');

// Get a value with a refresh callback (called when the value is not in the cache or expired)
final userData = await dataCache.get<UserData>(
  'user_data',
  refreshCallback: () => fetchUserFromApi(),
);
```

### Deleting Data

To delete a value from the cache:

```dart
// Delete a single value
await dataCache.delete('greeting');

// Delete multiple values
await dataCache.deleteAll(['user', 'settings', 'theme']);

// Clear the entire cache
await dataCache.clear();
```

## Working with Multiple Items

### Storing Multiple Items

To store multiple values in the cache at once:

```dart
// Store multiple values
await dataCache.putAll({
  'user': user,
  'settings': settings,
  'theme': theme,
});

// Store multiple values with a custom policy
await dataCache.putAll(
  {
    'user': user,
    'settings': settings,
    'theme': theme,
  },
  policy: myPolicy,
);
```

### Retrieving Multiple Items

To retrieve multiple values from the cache at once:

```dart
// Get multiple values
final values = await dataCache.getAll<dynamic>(['user', 'settings', 'theme']);

// Get multiple values with refresh callbacks
final data = await dataCache.getAll<dynamic>(
  ['users', 'posts', 'comments'],
  refreshCallbacks: {
    'users': () => fetchUsersFromApi(),
    'posts': () => fetchPostsFromApi(),
    'comments': () => fetchCommentsFromApi(),
  },
);
```

## Using Predefined Policies

data_cache_x comes with several predefined policies for common use cases:

```dart
// Default policy (no expiry, normal priority)
await dataCache.put('data', value, policy: CachePolicy.defaultPolicy);

// Never expire (no expiry, high priority)
await dataCache.put('important_data', value, policy: CachePolicy.neverExpire);

// Temporary (5 minute expiry, low priority)
await dataCache.put('temp_data', value, policy: CachePolicy.temporary);

// Encrypted (high priority, encryption enabled)
await dataCache.put(
  'sensitive_data', 
  value, 
  policy: CachePolicy.encrypted(expiry: Duration(days: 7))
);

// Compressed (compression always enabled)
await dataCache.put(
  'large_data', 
  value, 
  policy: CachePolicy.compressed()
);

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

## Next Steps

Now that you understand the basics of using data_cache_x, you can explore more advanced features:

- [Cache Policies](../core-concepts/cache-policies.md)
- [Eviction Strategies](../core-concepts/eviction-strategies.md)
- [Working with Complex Types](../advanced-usage/complex-types.md)
- [Performance Optimization](../advanced-usage/performance-optimization.md)
