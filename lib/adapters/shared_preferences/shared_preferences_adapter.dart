import 'package:data_cache_x/adapters/cache_adapter.dart';
import 'package:data_cache_x/models/cache_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:encrypt/encrypt.dart';

class SharedPreferencesAdapter implements CacheAdapter {
  final String? boxName;
  @override
  final bool enableEncryption;
  SharedPreferences? _prefs;
  final String _encryptionKey;

  SharedPreferencesAdapter(
      {this.boxName, this.enableEncryption = false, String? encryptionKey})
      : _encryptionKey = encryptionKey ?? 'default_secret_key';

  Future<SharedPreferences> get prefs async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  String _getKey(String key) => '${boxName ?? 'data_cache_x'}_$key';

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
      final decryptedValue = _aesDecrypt(encryptedValue);
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
      jsonString = _aesEncrypt(jsonEncode(value));
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
}
