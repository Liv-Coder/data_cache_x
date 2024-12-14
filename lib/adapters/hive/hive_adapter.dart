import 'package:data_cache_x/adapters/cache_adapter.dart';
import 'package:data_cache_x/models/cache_item.dart';
import 'package:data_cache_x/service_locator.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// A concrete implementation of [CacheAdapter] that uses the Hive NoSQL database for storage.
///
/// Example:
/// ```dart
/// // Initialize the Hive adapter
/// final adapter = HiveAdapter(typeAdapterRegistry);
/// await adapter.init();
///
/// // Store a value
/// await adapter.put('myKey', CacheItem<String>(value: 'myValue', expiry: DateTime.now().add(Duration(days: 1))));
///
/// // Retrieve a value
/// final item = await adapter.get('myKey');
/// print(item?.value);
class HiveAdapter implements CacheAdapter {
  final String _boxName;
  late Box _box;

  /// The type adapter registry used to get the correct adapter for a given type.
  final TypeAdapterRegistry typeAdapterRegistry;

  /// Creates a new instance of [HiveAdapter].
  ///
  /// The [typeAdapterRegistry] parameter is required to handle the serialization and deserialization of `CacheItem<T>` objects.
  /// The [boxName] parameter is optional and defaults to 'data_cache_x'.
  HiveAdapter(this.typeAdapterRegistry, {String? boxName})
      : _boxName = boxName ?? 'data_cache_x';

  /// Initializes the Hive database and registers the type adapter.
  ///
  /// This method must be called before using the adapter.
  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  @override
  Future<void> put(String key, CacheItem<dynamic> value) async {
    await _box.put(key, value);
  }

  @override
  Future<CacheItem<dynamic>?> get(String key) async {
    return _box.get(key) as CacheItem<dynamic>?;
  }

  @override
  Future<void> delete(String key) async {
    await _box.delete(key);
  }

  @override
  Future<void> clear() async {
    await _box.clear();
  }

  @override
  Future<bool> containsKey(String key) async {
    return _box.containsKey(key);
  }

  /// Returns a list of all keys in the cache.
  List<String> keys() {
    return _box.keys.cast<String>().toList();
  }
}
