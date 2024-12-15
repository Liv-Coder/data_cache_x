import 'package:data_cache_x/adapters/cache_adapter.dart';
import 'package:data_cache_x/models/cache_item.dart';
import 'dart:convert';
import 'package:encrypt/encrypt.dart';

/// A concrete implementation of [CacheAdapter] that uses an in-memory map for storage.
///
/// Example:
/// ```dart
/// // Initialize the memory adapter
/// final adapter = MemoryAdapter();
///
/// // Store a value
/// await adapter.put('myKey', CacheItem<String>(value: 'myValue', expiry: DateTime.now().add(Duration(days: 1))));
///
/// // Retrieve a value
/// final item = await adapter.get('myKey');
/// print(item?.value);
class MemoryAdapter implements CacheAdapter {
  final Map<String, dynamic> _cache = {};
  final String _encryptionKey;

  @override
  final bool enableEncryption;

  /// Creates a new instance of [MemoryAdapter].
  MemoryAdapter({this.enableEncryption = false, String? encryptionKey})
      : _encryptionKey = encryptionKey ?? 'default_secret_key';

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
    if (enableEncryption) {
      final encryptedValue = _aesEncrypt(jsonEncode(value.toJson()));
      _cache[key] = encryptedValue;
    } else {
      _cache[key] = value;
    }
  }

  @override
  Future<CacheItem<dynamic>?> get(String key) async {
    final dynamic storedValue = _cache[key];
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
    _cache.remove(key);
  }

  @override
  Future<void> clear() async {
    _cache.clear();
  }

  @override
  Future<bool> containsKey(String key) async {
    return _cache.containsKey(key);
  }

  @override
  Future<List<String>> getKeys({int? limit, int? offset}) async {
    final keys = _cache.keys.toList();
    if (limit == null && offset == null) {
      return keys;
    }

    final startIndex = offset ?? 0;
    final endIndex = limit == null ? keys.length : startIndex + limit;

    return keys.skip(startIndex).take(endIndex - startIndex).toList();
  }
}
