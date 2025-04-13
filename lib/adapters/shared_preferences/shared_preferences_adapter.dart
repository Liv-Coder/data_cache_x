import 'package:data_cache_x/adapters/cache_adapter.dart';
import 'package:data_cache_x/models/cache_item.dart';
import 'package:data_cache_x/models/encryption_options.dart';
import 'package:data_cache_x/utils/encryption.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPreferencesAdapter implements CacheAdapter {
  final String? boxName;
  @override
  final bool enableEncryption;
  SharedPreferences? _prefs;
  late final Encryption _encryption;
  late final EncryptionOptions? _encryptionOptions;

  @override
  EncryptionOptions? get encryptionOptions => _encryptionOptions;

  /// Creates a new instance of [SharedPreferencesAdapter].
  ///
  /// The [boxName] parameter is used to specify the prefix for keys in SharedPreferences.
  /// If no [boxName] is provided, a default prefix of 'data_cache_x' will be used.
  ///
  /// If [enableEncryption] is true, [encryptionOptions] must be provided.
  /// Throws an [ArgumentError] if encryption is enabled but no options are provided.
  SharedPreferencesAdapter({
    this.boxName,
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

  Future<SharedPreferences> get prefs async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  String _getKey(String key) => '${boxName ?? 'data_cache_x'}_$key';

  String _encrypt(String data) {
    return _encryption.encrypt(data);
  }

  String _decrypt(String encryptedData) {
    return _encryption.decrypt(encryptedData);
  }

  @override
  Future<void> clear() async {
    final p = await prefs;
    await p.clear();
  }

  @override
  Future<void> delete(String key) async {
    final p = await prefs;
    await p.remove(_getKey(key));
  }

  @override
  Future<CacheItem<dynamic>?> get(String key) async {
    final p = await prefs;
    final String? encryptedValue = p.getString(_getKey(key));
    if (encryptedValue == null) {
      return null;
    }
    dynamic value;
    if (enableEncryption) {
      final decryptedValue = _decrypt(encryptedValue);
      value = jsonDecode(decryptedValue);
    } else {
      final jsonString = encryptedValue;
      final Map<String, dynamic> map = jsonDecode(jsonString);
      value = map;
    }
    return CacheItem<dynamic>(
      value: value['value'],
      expiry: value['expiry'] != null
          ? DateTime.fromMillisecondsSinceEpoch(value['expiry'] as int)
          : null,
    );
  }

  @override
  Future<void> put(String key, CacheItem<dynamic> item) async {
    final p = await prefs;
    dynamic value = {
      'value': item.value,
      'expiry': item.expiry?.millisecondsSinceEpoch,
    };
    String jsonString = jsonEncode(value);
    if (enableEncryption) {
      jsonString = _encrypt(jsonEncode(value));
    }
    await p.setString(_getKey(key), jsonString);
  }

  @override
  Future<bool> containsKey(String key) async {
    final p = await prefs;
    return p.containsKey(_getKey(key));
  }

  @override
  Future<List<String>> getKeys({int? limit, int? offset}) async {
    final p = await prefs;
    final keys = p.getKeys();
    final filteredKeys = keys
        .where((key) => key.startsWith('${boxName ?? 'data_cache_x'}_'))
        .map((key) => key.substring('${boxName ?? 'data_cache_x'}_'.length))
        .toList();

    if (limit == null && offset == null) {
      return filteredKeys;
    }

    final startIndex = offset ?? 0;
    final endIndex = limit == null ? filteredKeys.length : startIndex + limit;

    return filteredKeys.skip(startIndex).take(endIndex - startIndex).toList();
  }

  @override
  Future<List<String>> getKeysByTag(String tag,
      {int? limit, int? offset}) async {
    final p = await prefs;
    final keys = p.getKeys();
    final prefixedKeys = keys
        .where((key) => key.startsWith('${boxName ?? 'data_cache_x'}_'))
        .toList();
    final result = <String>[];
    int count = 0;
    final startIndex = offset ?? 0;

    for (final prefixedKey in prefixedKeys) {
      final key = prefixedKey.substring('${boxName ?? 'data_cache_x'}_'.length);
      final String? jsonString = p.getString(prefixedKey);
      if (jsonString == null) continue;

      Map<String, dynamic> jsonMap;
      if (enableEncryption) {
        final decryptedValue = _decrypt(jsonString);
        jsonMap = jsonDecode(decryptedValue);
      } else {
        jsonMap = jsonDecode(jsonString);
      }

      final cacheItem = CacheItem<dynamic>(
        value: jsonMap['value'],
        expiry: jsonMap['expiry'] != null
            ? DateTime.fromMillisecondsSinceEpoch(jsonMap['expiry'] as int)
            : null,
      );

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

    return result;
  }

  @override
  Future<List<String>> getKeysByTags(List<String> tags,
      {int? limit, int? offset}) async {
    final p = await prefs;
    final keys = p.getKeys();
    final prefixedKeys = keys
        .where((key) => key.startsWith('${boxName ?? 'data_cache_x'}_'))
        .toList();
    final result = <String>[];
    int count = 0;
    final startIndex = offset ?? 0;

    for (final prefixedKey in prefixedKeys) {
      final key = prefixedKey.substring('${boxName ?? 'data_cache_x'}_'.length);
      final String? jsonString = p.getString(prefixedKey);
      if (jsonString == null) continue;

      Map<String, dynamic> jsonMap;
      if (enableEncryption) {
        final decryptedValue = _decrypt(jsonString);
        jsonMap = jsonDecode(decryptedValue);
      } else {
        jsonMap = jsonDecode(jsonString);
      }

      final cacheItem = CacheItem<dynamic>(
        value: jsonMap['value'],
        expiry: jsonMap['expiry'] != null
            ? DateTime.fromMillisecondsSinceEpoch(jsonMap['expiry'] as int)
            : null,
      );

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
    final p = await prefs;
    final Map<String, String> stringEntries = {};

    for (final entry in entries.entries) {
      final key = _getKey(entry.key);
      final item = entry.value;
      final Map<String, dynamic> jsonMap = {
        'value': item.value,
        'expiry': item.expiry?.millisecondsSinceEpoch,
      };

      String jsonString = jsonEncode(jsonMap);
      if (enableEncryption) {
        jsonString = _encrypt(jsonString);
      }

      stringEntries[key] = jsonString;
    }

    await p.setString(_getKey('batch_temp'), 'temp');
    for (final entry in stringEntries.entries) {
      await p.setString(entry.key, entry.value);
    }
    await p.remove(_getKey('batch_temp'));
  }

  @override
  Future<Map<String, CacheItem<dynamic>>> getAll(List<String> keys) async {
    final p = await prefs;
    final result = <String, CacheItem<dynamic>>{};

    for (final key in keys) {
      final prefKey = _getKey(key);
      if (p.containsKey(prefKey)) {
        final String? jsonString = p.getString(prefKey);
        if (jsonString == null) continue;

        Map<String, dynamic> jsonMap;
        if (enableEncryption) {
          final decryptedValue = _decrypt(jsonString);
          jsonMap = jsonDecode(decryptedValue);
        } else {
          jsonMap = jsonDecode(jsonString);
        }

        result[key] = CacheItem<dynamic>(
          value: jsonMap['value'],
          expiry: jsonMap['expiry'] != null
              ? DateTime.fromMillisecondsSinceEpoch(jsonMap['expiry'] as int)
              : null,
        );
      }
    }

    return result;
  }

  @override
  Future<void> deleteAll(List<String> keys) async {
    final p = await prefs;
    for (final key in keys) {
      await p.remove(_getKey(key));
    }
  }

  @override
  Future<Map<String, bool>> containsKeys(List<String> keys) async {
    final p = await prefs;
    final result = <String, bool>{};

    for (final key in keys) {
      result[key] = p.containsKey(_getKey(key));
    }

    return result;
  }
}
