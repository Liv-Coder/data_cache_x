import 'package:data_cache_x/adapters/cache_adapter.dart';
import 'package:data_cache_x/models/cache_item.dart';
import 'dart:convert';

class MemoryAdapter implements CacheAdapter {
  final Map<String, CacheItem> _cache = {};

  @override
  final bool enableEncryption;

  MemoryAdapter({this.enableEncryption = false});

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
  Future<void> clear() async {
    _cache.clear();
  }

  @override
  Future<CacheItem?> get(String key) async {
    final storedValue = _cache[key];
    if (storedValue == null) {
      return null;
    }
    if (enableEncryption) {
      final decryptedValue =
          _xorDecrypt(storedValue.toJson().toString(), 'my_secret_key');
      return CacheItem.fromJson(jsonDecode(decryptedValue));
    } else {
      return storedValue;
    }
  }

  @override
  Future<void> delete(String key) async {
    _cache.remove(key);
  }

  @override
  Future<bool> containsKey(String key) async {
    return _cache.containsKey(key);
  }

  @override
  Future<void> put(String key, CacheItem item) async {
    if (enableEncryption) {
      final encryptedValue =
          _xorEncrypt(jsonEncode(item.toJson()), 'my_secret_key');
      _cache[key] = CacheItem.fromJson(jsonDecode(encryptedValue));
    } else {
      _cache[key] = item;
    }
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
