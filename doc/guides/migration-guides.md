# Migration Guides

This guide provides instructions for migrating from other caching solutions to data_cache_x, as well as migrating between different versions of data_cache_x.

## Migrating from SharedPreferences

SharedPreferences is a simple key-value storage solution that's commonly used for small amounts of data. Here's how to migrate from SharedPreferences to data_cache_x:

### Step 1: Add data_cache_x to your project

```yaml
dependencies:
  data_cache_x: ^latest_version
```

### Step 2: Initialize data_cache_x

```dart
import 'package:data_cache_x/data_cache_x.dart';
import 'package:data_cache_x/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize with SharedPreferences adapter for compatibility
  await setupDataCacheX(adapterType: CacheAdapterType.sharedPreferences);
  
  runApp(MyApp());
}
```

### Step 3: Replace SharedPreferences calls with data_cache_x

**Before:**
```dart
final prefs = await SharedPreferences.getInstance();

// Writing data
await prefs.setString('name', 'John');
await prefs.setInt('age', 30);
await prefs.setBool('isLoggedIn', true);

// Reading data
final name = prefs.getString('name');
final age = prefs.getInt('age');
final isLoggedIn = prefs.getBool('isLoggedIn');

// Removing data
await prefs.remove('name');
await prefs.clear();
```

**After:**
```dart
final dataCache = getIt<DataCacheX>();

// Writing data
await dataCache.put('name', 'John');
await dataCache.put('age', 30);
await dataCache.put('isLoggedIn', true);

// Reading data
final name = await dataCache.get<String>('name');
final age = await dataCache.get<int>('age');
final isLoggedIn = await dataCache.get<bool>('isLoggedIn');

// Removing data
await dataCache.delete('name');
await dataCache.clear();
```

### Step 4: Migrate existing data (optional)

If you need to preserve existing data, you can migrate it during the transition:

```dart
Future<void> migrateFromSharedPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  final dataCache = getIt<DataCacheX>();
  
  // Get all keys from SharedPreferences
  final keys = prefs.getKeys();
  
  // Migrate each key
  for (final key in keys) {
    final value = prefs.get(key);
    if (value != null) {
      await dataCache.put(key, value);
    }
  }
  
  // Optionally clear SharedPreferences after migration
  // await prefs.clear();
}
```

## Migrating from Hive

Hive is a lightweight and fast key-value database. data_cache_x actually uses Hive internally as one of its adapters, so migration is straightforward:

### Step 1: Add data_cache_x to your project

```yaml
dependencies:
  data_cache_x: ^latest_version
```

### Step 2: Initialize data_cache_x

```dart
import 'package:data_cache_x/data_cache_x.dart';
import 'package:data_cache_x/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize with Hive adapter (default)
  await setupDataCacheX();
  
  runApp(MyApp());
}
```

### Step 3: Replace Hive calls with data_cache_x

**Before:**
```dart
await Hive.initFlutter();
final box = await Hive.openBox('myBox');

// Writing data
await box.put('name', 'John');
await box.put('user', user);

// Reading data
final name = box.get('name');
final user = box.get('user');

// Removing data
await box.delete('name');
await box.clear();
```

**After:**
```dart
final dataCache = getIt<DataCacheX>();

// Writing data
await dataCache.put('name', 'John');
await dataCache.put('user', user);

// Reading data
final name = await dataCache.get<String>('name');
final user = await dataCache.get<User>('user');

// Removing data
await dataCache.delete('name');
await dataCache.clear();
```

### Step 4: Migrate custom type adapters

If you're using custom type adapters with Hive, you'll need to register them with data_cache_x:

**Before:**
```dart
Hive.registerAdapter(UserAdapter());
```

**After:**
```dart
await setupDataCacheX(
  customAdapters: {
    User: UserAdapter(),
  },
);
```

## Migrating from SQLite

SQLite is a relational database that's commonly used for structured data. Here's how to migrate from SQLite to data_cache_x:

### Step 1: Add data_cache_x to your project

```yaml
dependencies:
  data_cache_x: ^latest_version
```

### Step 2: Initialize data_cache_x

```dart
import 'package:data_cache_x/data_cache_x.dart';
import 'package:data_cache_x/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize with SQLite adapter for compatibility
  await setupDataCacheX(adapterType: CacheAdapterType.sqlite);
  
  runApp(MyApp());
}
```

### Step 3: Replace SQLite calls with data_cache_x

**Before:**
```dart
final db = await openDatabase('my_db.db');

// Writing data
await db.insert('users', {
  'id': 1,
  'name': 'John',
  'age': 30,
});

// Reading data
final users = await db.query('users', where: 'id = ?', whereArgs: [1]);
final user = users.first;

// Removing data
await db.delete('users', where: 'id = ?', whereArgs: [1]);
await db.delete('users');
```

**After:**
```dart
final dataCache = getIt<DataCacheX>();

// Writing data
final user = {
  'id': 1,
  'name': 'John',
  'age': 30,
};
await dataCache.put('user_1', user);

// Reading data
final user = await dataCache.get<Map<String, dynamic>>('user_1');

// Removing data
await dataCache.delete('user_1');
await dataCache.clear();
```

### Step 4: Handling relationships and queries

SQLite supports complex queries and relationships, which don't directly map to a key-value store. You'll need to rethink your data model:

1. **Flatten relationships**: Store related data together or use prefixed keys
   ```dart
   // Store a user with their posts
   await dataCache.put('user_1', {
     'id': 1,
     'name': 'John',
     'posts': [
       {'id': 1, 'title': 'Post 1'},
       {'id': 2, 'title': 'Post 2'},
     ],
   });
   
   // Or use prefixed keys
   await dataCache.put('user_1', {'id': 1, 'name': 'John'});
   await dataCache.put('user_1_post_1', {'id': 1, 'title': 'Post 1'});
   await dataCache.put('user_1_post_2', {'id': 2, 'title': 'Post 2'});
   ```

2. **Implement query logic in your code**: For filtering, sorting, etc.
   ```dart
   Future<List<Map<String, dynamic>>> getUserPosts(int userId) async {
     final keys = await dataCache.getKeys();
     final postKeys = keys.where((key) => key.startsWith('user_${userId}_post_'));
     
     final posts = <Map<String, dynamic>>[];
     for (final key in postKeys) {
       final post = await dataCache.get<Map<String, dynamic>>(key);
       if (post != null) {
         posts.add(post);
       }
     }
     
     return posts;
   }
   ```

## Migrating Between data_cache_x Versions

### Migrating from 0.x to 1.x

If you're upgrading from an earlier version of data_cache_x to the latest version, here are the key changes and migration steps:

#### Key Changes

1. **Service Locator**: The service locator pattern is now used for dependency injection
2. **Adapter Types**: Adapter types are now specified using an enum
3. **Cache Policies**: Cache policies have been enhanced with new options
4. **Analytics**: Cache analytics are now built-in

#### Migration Steps

1. **Update your imports**:
   ```dart
   // Add the service locator import
   import 'package:data_cache_x/service_locator.dart';
   ```

2. **Update initialization**:

   **Before:**
   ```dart
   final memoryAdapter = MemoryAdapter();
   final dataCache = DataCacheX(memoryAdapter);
   ```

   **After:**
   ```dart
   await setupDataCacheX(adapterType: CacheAdapterType.memory);
   final dataCache = getIt<DataCacheX>();
   ```

3. **Update cache policies**:

   **Before:**
   ```dart
   await dataCache.put('key', value, expiry: Duration(hours: 1));
   ```

   **After:**
   ```dart
   await dataCache.put('key', value, policy: CachePolicy(expiry: Duration(hours: 1)));
   ```

4. **Update custom adapters**:

   **Before:**
   ```dart
   Hive.registerAdapter(UserAdapter());
   final hiveAdapter = HiveAdapter();
   final dataCache = DataCacheX(hiveAdapter);
   ```

   **After:**
   ```dart
   await setupDataCacheX(
     customAdapters: {
       User: UserAdapter(),
     },
   );
   final dataCache = getIt<DataCacheX>();
   ```

## Best Practices for Migration

1. **Gradual Migration**: Consider migrating one feature or module at a time
2. **Test Thoroughly**: Test each migrated component to ensure it works as expected
3. **Backup Data**: Always backup important data before migration
4. **Maintain Compatibility**: Consider maintaining compatibility with the old system during the transition
5. **Update Documentation**: Update your documentation to reflect the new caching solution
6. **Monitor Performance**: Monitor performance after migration to ensure it meets your expectations
