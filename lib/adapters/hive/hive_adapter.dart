import 'package:data_cache_x/adapters/cache_adapter.dart';
import 'package:data_cache_x/models/cache_item.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// A concrete implementation of [CacheAdapter] that uses the Hive NoSQL database for storage.
///
/// The generic type parameter `T` represents the type of data that the adapter will store.
///
/// The `typeAdapter` parameter in the constructor is required to handle the serialization and deserialization of `CacheItem<T>` objects.
///
/// Example:
/// ```dart
/// // Create a type adapter for CacheItem<String>
/// class CacheItemStringAdapter extends TypeAdapter<CacheItem<String>> {
///   @override
///   final int typeId = 0;
///
///   @override
///   CacheItem<String> read(BinaryReader reader) {
///     final value = reader.readString();
///     final expiry = reader.readInt();
///     return CacheItem<String>(
///       value: value,
///       expiry: expiry == null ? null : DateTime.fromMillisecondsSinceEpoch(expiry),
///     );
///   }
///
///   @override
///   void write(BinaryWriter writer, CacheItem<String> obj) {
///     writer.writeString(obj.value);
///     writer.writeInt(obj.expiry?.millisecondsSinceEpoch ?? 0);
///   }
/// }
///
/// // Initialize the Hive adapter
/// final adapter = HiveAdapter<String>(CacheItemStringAdapter());
/// await adapter.init();
///
/// // Store a value
/// await adapter.put('myKey', CacheItem<String>(value: 'myValue', expiry: DateTime.now().add(Duration(days: 1))));
///
/// // Retrieve a value
/// final item = await adapter.get('myKey');
/// print(item?.value);
/// ```
class HiveAdapter<T> implements CacheAdapter<T> {
  static const String _boxName = 'data_cache_x';
  late Box<CacheItem<T>> _box;

  /// The type adapter used to serialize and deserialize `CacheItem<T>` objects.
  final TypeAdapter<CacheItem<T>> typeAdapter;

  /// Creates a new instance of [HiveAdapter].
  ///
  /// The [typeAdapter] parameter is required to handle the serialization and deserialization of `CacheItem<T>` objects.
  HiveAdapter(this.typeAdapter);

  /// Initializes the Hive database and registers the type adapter.
  ///
  /// This method must be called before using the adapter.
  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(typeAdapter);
    _box = await Hive.openBox<CacheItem<T>>(_boxName);
  }

  @override
  Future<void> put(String key, CacheItem<T> value) async {
    await _box.put(key, value);
  }

  @override
  Future<CacheItem<T>?> get(String key) async {
    return _box.get(key);
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
