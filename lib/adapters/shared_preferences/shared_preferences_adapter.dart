import 'package:data_cache_x/adapters/cache_adapter.dart';
import 'package:data_cache_x/models/cache_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPreferencesAdapter implements CacheAdapter {
  final String? boxName;
  @override
  final bool enableEncryption;
  SharedPreferences? _prefs;

  SharedPreferencesAdapter({this.boxName, this.enableEncryption = false});

  Future<SharedPreferences> get prefs async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  String _getKey(String key) => '${boxName ?? 'data_cache_x'}_$key';

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
    final jsonString = p.getString(_getKey(key));
    if (jsonString == null) {
      return null;
    }
    final Map<String, dynamic> map = jsonDecode(jsonString);
    return CacheItem<dynamic>(
      value: map['value'],
      expiry: map['expiry'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['expiry'] as int)
          : null,
    );
  }

  @override
  Future<void> put(String key, CacheItem<dynamic> item) async {
    final p = await prefs;
    final jsonString = jsonEncode({
      'value': item.value,
      'expiry': item.expiry?.millisecondsSinceEpoch,
    });
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
