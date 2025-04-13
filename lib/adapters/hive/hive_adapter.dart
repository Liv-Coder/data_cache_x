import 'package:data_cache_x/adapters/cache_adapter.dart';
import 'package:data_cache_x/models/cache_item.dart';
import 'package:data_cache_x/models/encryption_options.dart';
import 'package:data_cache_x/utils/encryption.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'package:data_cache_x/service_locator.dart';

/// A concrete implementation of [CacheAdapter] that uses the Hive NoSQL database for storage.
///
/// Example:
/// ```dart
/// // Initialize the hive adapter
/// final adapter = HiveAdapter(boxName: 'myBox');
///
/// // Store a value
/// await adapter.put('myKey', CacheItem<String>(value: 'myValue', expiry: DateTime.now().add(Duration(days: 1))));
///
/// // Retrieve a value
/// final item = await adapter.get('myKey');
/// print(item?.value);
/// ```
class HiveAdapter implements CacheAdapter {
  late Box _box;
  late final Encryption _encryption;
  late final EncryptionOptions? _encryptionOptions;
  final String _boxName;

  @override
  final bool enableEncryption;
  bool _isInitialized = false;

  @override
  EncryptionOptions? get encryptionOptions => _encryptionOptions;

  /// Creates a new instance of [HiveAdapter].
  ///
  /// The [boxName] parameter is used to specify the name of the Hive box to use.
  /// If no [boxName] is provided, a default box name of 'data_cache_x' will be used.
  ///
  /// If [enableEncryption] is true, [encryptionOptions] must be provided.
  /// Throws an [ArgumentError] if encryption is enabled but no options are provided.
  HiveAdapter(
    this.typeAdapterRegistry, {
    String? boxName,
    this.enableEncryption = false,
    String? encryptionKey,
    EncryptionOptions? encryptionOptions,
  }) : _boxName = boxName ?? 'data_cache_x' {
    if (enableEncryption) {
      if (encryptionOptions != null) {
        _encryptionOptions = encryptionOptions;
      } else if (encryptionKey != null) {
        // For backward compatibility
        _encryptionOptions = EncryptionOptions(
          algorithm: EncryptionAlgorithm.aes256,
          key: encryptionKey,
        );
      } else {
        throw ArgumentError(
            'Encryption options or key must be provided when encryption is enabled');
      }
      _encryption = Encryption(
        algorithm: _encryptionOptions!.algorithm,
        encryptionKey: _encryptionOptions.key,
      );
    } else {
      _encryptionOptions = null;
    }
  }

  final TypeAdapterRegistry typeAdapterRegistry;

  /// Initializes the adapter by opening the Hive box.
  /// This method must be called before using any other methods of this adapter.
  Future<void> init() async {
    if (_isInitialized) return;

    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox(_boxName);
    } else {
      _box = Hive.box(_boxName);
    }

    _isInitialized = true;
  }

  String _encrypt(String data) {
    return _encryption.encrypt(data);
  }

  String _decrypt(String encryptedData) {
    return _encryption.decrypt(encryptedData);
  }

  @override
  Future<void> put(String key, CacheItem<dynamic> value) async {
    if (!_isInitialized) await init();

    if (enableEncryption) {
      final encryptedValue = _encrypt(jsonEncode(value.toJson()));
      await _box.put(key, encryptedValue);
    } else {
      await _box.put(key, value);
    }
  }

  @override
  Future<CacheItem<dynamic>?> get(String key) async {
    if (!_isInitialized) await init();

    final dynamic storedValue = _box.get(key);
    if (storedValue == null) {
      return null;
    }
    if (enableEncryption) {
      final decryptedValue = _decrypt(storedValue);
      return CacheItem.fromJson(jsonDecode(decryptedValue));
    } else {
      return storedValue as CacheItem<dynamic>?;
    }
  }

  @override
  Future<void> delete(String key) async {
    if (!_isInitialized) await init();
    await _box.delete(key);
  }

  @override
  Future<void> clear() async {
    if (!_isInitialized) await init();
    await _box.clear();
  }

  @override
  Future<bool> containsKey(String key) async {
    if (!_isInitialized) await init();
    return _box.containsKey(key);
  }

  @override
  Future<List<String>> getKeys({int? limit, int? offset}) async {
    if (!_isInitialized) await init();

    final keys = _box.keys.toList().cast<String>();
    if (limit == null && offset == null) {
      return keys;
    }

    final startIndex = offset ?? 0;
    final endIndex = limit == null ? keys.length : startIndex + limit;

    return keys.skip(startIndex).take(endIndex - startIndex).toList();
  }

  @override
  Future<List<String>> getKeysByTag(String tag,
      {int? limit, int? offset}) async {
    if (!_isInitialized) await init();

    final result = <String>[];
    final startIndex = offset ?? 0;
    int count = 0;

    for (final key in _box.keys) {
      final dynamic storedValue = _box.get(key);
      if (storedValue == null) continue;

      CacheItem<dynamic> cacheItem;
      if (enableEncryption) {
        final decryptedValue = _decrypt(storedValue as String);
        cacheItem = CacheItem.fromJson(jsonDecode(decryptedValue));
      } else {
        cacheItem = storedValue as CacheItem<dynamic>;
      }

      if (cacheItem.tags.contains(tag)) {
        if (count >= startIndex) {
          result.add(key as String);
          if (limit != null && result.length >= limit) {
            break;
          }
        }
        count++;
      }
    }

    return result;
  }

  @override
  Future<List<String>> getKeysByTags(List<String> tags,
      {int? limit, int? offset}) async {
    if (!_isInitialized) await init();

    final result = <String>[];
    final startIndex = offset ?? 0;
    int count = 0;

    for (final key in _box.keys) {
      final dynamic storedValue = _box.get(key);
      if (storedValue == null) continue;

      CacheItem<dynamic> cacheItem;
      if (enableEncryption) {
        final decryptedValue = _decrypt(storedValue as String);
        cacheItem = CacheItem.fromJson(jsonDecode(decryptedValue));
      } else {
        cacheItem = storedValue as CacheItem<dynamic>;
      }

      if (tags.every((tag) => cacheItem.tags.contains(tag))) {
        if (count >= startIndex) {
          result.add(key as String);
          if (limit != null && result.length >= limit) {
            break;
          }
        }
        count++;
      }
    }

    return result;
  }

  @override
  Future<void> deleteByTag(String tag) async {
    if (!_isInitialized) await init();
    final keysToDelete = await getKeysByTag(tag);
    await deleteAll(keysToDelete);
  }

  @override
  Future<void> deleteByTags(List<String> tags) async {
    if (!_isInitialized) await init();
    final keysToDelete = await getKeysByTags(tags);
    await deleteAll(keysToDelete);
  }

  @override
  Future<void> putAll(Map<String, CacheItem<dynamic>> entries) async {
    if (!_isInitialized) await init();

    final Map<String, dynamic> boxEntries = {};

    for (final entry in entries.entries) {
      if (enableEncryption) {
        boxEntries[entry.key] = _encrypt(jsonEncode(entry.value.toJson()));
      } else {
        boxEntries[entry.key] = entry.value;
      }
    }

    await _box.putAll(boxEntries);
  }

  @override
  Future<Map<String, CacheItem<dynamic>>> getAll(List<String> keys) async {
    if (!_isInitialized) await init();

    final result = <String, CacheItem<dynamic>>{};

    // Hive doesn't have a native getAll method, so we need to get each key individually
    // but we can optimize by doing it in a single transaction
    for (final key in keys) {
      if (_box.containsKey(key)) {
        final dynamic storedValue = _box.get(key);

        if (storedValue == null) continue;

        if (enableEncryption) {
          final decryptedValue = _decrypt(storedValue);
          result[key] = CacheItem.fromJson(jsonDecode(decryptedValue));
        } else {
          result[key] = storedValue as CacheItem<dynamic>;
        }
      }
    }

    return result;
  }

  @override
  Future<void> deleteAll(List<String> keys) async {
    if (!_isInitialized) await init();

    // Hive doesn't have a native deleteAll method, so we need to delete each key individually
    for (final key in keys) {
      await _box.delete(key);
    }
  }

  @override
  Future<Map<String, bool>> containsKeys(List<String> keys) async {
    if (!_isInitialized) await init();

    final result = <String, bool>{};
    for (final key in keys) {
      result[key] = _box.containsKey(key);
    }

    return result;
  }
}
