import 'package:data_cache_x/adapters/cache_adapter.dart';
import 'package:data_cache_x/models/cache_item.dart';
import 'package:data_cache_x/service_locator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';

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

  @override
  final bool enableEncryption;

  /// The type adapter registry used to get the correct adapter for a given type.
  final TypeAdapterRegistry typeAdapterRegistry;

  /// Creates a new instance of [HiveAdapter].
  ///
  /// The [typeAdapterRegistry] parameter is required to handle the serialization and deserialization of `CacheItem<T>` objects.
  /// The [boxName] parameter is optional and defaults to 'data_cache_x'.
  HiveAdapter(this.typeAdapterRegistry,
      {String? boxName, this.enableEncryption = false})
      : _boxName = boxName ?? 'data_cache_x';

  /// Initializes the Hive database and registers the type adapter.
  ///
  /// This method must be called before using the adapter.
  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  String _xorEncrypt(String data, String key) {
    final keyBytes = utf8.encode(key);
    final dataBytes = utf8.encode(data);
    final encryptedBytes = List<int>.generate(
        dataBytes.length, (i) => dataBytes[i] ^ keyBytes[i % keyBytes.length]);
    return base64.encode(encryptedBytes);
  }

  String _xorDecrypt(String encryptedData, String key) {
    final keyBytes = utf8.encode(key);
    final encryptedBytes = base64.decode(encryptedData);
    final decryptedBytes = List<int>.generate(encryptedBytes.length,
        (i) => encryptedBytes[i] ^ keyBytes[i % keyBytes.length]);
    return utf8.decode(decryptedBytes);
  }

  @override
  Future<void> put(String key, CacheItem<dynamic> value) async {
    if (enableEncryption) {
      final encryptedValue =
          _xorEncrypt(jsonEncode(value.toJson()), 'my_secret_key');
      await _box.put(key, encryptedValue);
    } else {
      await _box.put(key, value);
    }
  }

  @override
  Future<CacheItem<dynamic>?> get(String key) async {
    final dynamic storedValue = _box.get(key);
    if (storedValue == null) {
      return null;
    }
    if (enableEncryption) {
      final decryptedValue = _xorDecrypt(storedValue, 'my_secret_key');
      return CacheItem.fromJson(jsonDecode(decryptedValue));
    } else {
      return storedValue as CacheItem<dynamic>?;
    }
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

  @override
  Future<List<String>> getKeys({int? limit, int? offset}) async {
    final keys = _box.keys.cast<String>();
    if (limit == null && offset == null) {
      return keys.toList();
    }

    final startIndex = offset ?? 0;
    final endIndex = limit == null ? keys.length : startIndex + limit;

    return keys.skip(startIndex).take(endIndex - startIndex).toList();
  }
}
