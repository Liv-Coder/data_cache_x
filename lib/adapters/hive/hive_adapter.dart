import 'package:data_cache_x/adapters/cache_adapter.dart';
import 'package:data_cache_x/models/cache_item.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'package:encrypt/encrypt.dart';
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
  final String _encryptionKey;
  final String _boxName;

  @override
  final bool enableEncryption;
  bool _isInitialized = false;

  /// Creates a new instance of [HiveAdapter].
  ///
  /// The [boxName] parameter is used to specify the name of the Hive box to use.
  /// If no [boxName] is provided, a default box name of 'data_cache_x' will be used.
  HiveAdapter(
    this.typeAdapterRegistry, {
    String? boxName,
    this.enableEncryption = false,
    String? encryptionKey,
  })  : _encryptionKey = encryptionKey ?? 'default_secret_key',
        _boxName = boxName ?? 'data_cache_x';

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

  String _aesEncrypt(String data) {
    final key = Key.fromUtf8(_encryptionKey.padRight(32, '0').substring(0, 32));
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(data, iv: iv);
    return encrypted.base64;
  }

  String _aesDecrypt(String encryptedData) {
    final key = Key.fromUtf8(_encryptionKey.padRight(32, '0').substring(0, 32));
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));
    final decrypted =
        encrypter.decrypt(Encrypted.fromBase64(encryptedData), iv: iv);
    return decrypted;
  }

  @override
  Future<void> put(String key, CacheItem<dynamic> value) async {
    if (!_isInitialized) await init();

    if (enableEncryption) {
      final encryptedValue = _aesEncrypt(jsonEncode(value.toJson()));
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
      final decryptedValue = _aesDecrypt(storedValue);
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
  Future<void> putAll(Map<String, CacheItem<dynamic>> entries) async {
    if (!_isInitialized) await init();

    final Map<String, dynamic> boxEntries = {};

    for (final entry in entries.entries) {
      if (enableEncryption) {
        boxEntries[entry.key] = _aesEncrypt(jsonEncode(entry.value.toJson()));
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
          final decryptedValue = _aesDecrypt(storedValue);
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
