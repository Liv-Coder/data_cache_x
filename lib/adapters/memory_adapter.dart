import 'package:data_cache_x/adapters/cache_adapter.dart';
import 'package:data_cache_x/models/cache_item.dart';
import 'package:data_cache_x/models/encryption_options.dart';
import 'package:data_cache_x/utils/encryption.dart';
import 'dart:convert';

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
  late final Encryption _encryption;
  late final EncryptionOptions? _encryptionOptions;

  @override
  final bool enableEncryption;

  @override
  EncryptionOptions? get encryptionOptions => _encryptionOptions;

  /// Creates a new instance of [MemoryAdapter].
  ///
  /// If [enableEncryption] is true, [encryptionOptions] must be provided.
  /// Throws an [ArgumentError] if encryption is enabled but no options are provided.
  MemoryAdapter({
    this.enableEncryption = false,
    String? encryptionKey,
    EncryptionOptions? encryptionOptions,
  }) {
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

  String _encrypt(String data) {
    return _encryption.encrypt(data);
  }

  String _decrypt(String encryptedData) {
    return _encryption.decrypt(encryptedData);
  }

  @override
  Future<void> put(String key, CacheItem<dynamic> value) async {
    if (enableEncryption) {
      final encryptedValue = _encrypt(jsonEncode(value.toJson()));
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
      final decryptedValue = _decrypt(storedValue);
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

  @override
  Future<List<String>> getKeysByTag(String tag,
      {int? limit, int? offset}) async {
    final result = <String>[];
    final startIndex = offset ?? 0;
    int count = 0;

    for (final entry in _cache.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is CacheItem) {
        if (value.tags.contains(tag)) {
          if (count >= startIndex) {
            result.add(key);
            if (limit != null && result.length >= limit) {
              break;
            }
          }
          count++;
        }
      } else if (enableEncryption) {
        // For encrypted items, we need to decrypt and check the tags
        final decryptedValue = _decrypt(value as String);
        final cacheItem = CacheItem.fromJson(jsonDecode(decryptedValue));
        if (cacheItem.tags.contains(tag)) {
          if (count >= startIndex) {
            result.add(key);
            if (limit != null && result.length >= limit) {
              break;
            }
          }
          count++;
        }
      }
    }

    return result;
  }

  @override
  Future<List<String>> getKeysByTags(List<String> tags,
      {int? limit, int? offset}) async {
    final result = <String>[];
    final startIndex = offset ?? 0;
    int count = 0;

    for (final entry in _cache.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is CacheItem) {
        if (tags.every((tag) => value.tags.contains(tag))) {
          if (count >= startIndex) {
            result.add(key);
            if (limit != null && result.length >= limit) {
              break;
            }
          }
          count++;
        }
      } else if (enableEncryption) {
        // For encrypted items, we need to decrypt and check the tags
        final decryptedValue = _decrypt(value as String);
        final cacheItem = CacheItem.fromJson(jsonDecode(decryptedValue));
        if (tags.every((tag) => cacheItem.tags.contains(tag))) {
          if (count >= startIndex) {
            result.add(key);
            if (limit != null && result.length >= limit) {
              break;
            }
          }
          count++;
        }
      }
    }

    return result;
  }

  @override
  Future<void> deleteByTag(String tag) async {
    final keysToDelete = await getKeysByTag(tag);
    await deleteAll(keysToDelete);
  }

  @override
  Future<void> deleteByTags(List<String> tags) async {
    final keysToDelete = await getKeysByTags(tags);
    await deleteAll(keysToDelete);
  }

  @override
  Future<void> putAll(Map<String, CacheItem<dynamic>> entries) async {
    for (final entry in entries.entries) {
      if (enableEncryption) {
        final encryptedValue = _encrypt(jsonEncode(entry.value.toJson()));
        _cache[entry.key] = encryptedValue;
      } else {
        _cache[entry.key] = entry.value;
      }
    }
  }

  @override
  Future<Map<String, CacheItem<dynamic>>> getAll(List<String> keys) async {
    final result = <String, CacheItem<dynamic>>{};

    for (final key in keys) {
      if (_cache.containsKey(key)) {
        final dynamic storedValue = _cache[key];

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
    for (final key in keys) {
      _cache.remove(key);
    }
  }

  @override
  Future<Map<String, bool>> containsKeys(List<String> keys) async {
    final result = <String, bool>{};

    for (final key in keys) {
      result[key] = _cache.containsKey(key);
    }

    return result;
  }
}
