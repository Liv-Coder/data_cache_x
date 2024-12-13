import 'package:data_cache_x/adapters/cache_adapter.dart';
import 'package:data_cache_x/models/cache_item.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveAdapter implements CacheAdapter {
  static const String _boxName = 'data_cache_x';
  late Box<CacheItem> _box;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(CacheItemAdapter());
    _box = await Hive.openBox<CacheItem>(_boxName);
  }

  @override
  Future<void> put(String key, CacheItem value) async {
    await _box.put(key, value);
  }

  @override
  Future<CacheItem?> get(String key) async {
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

  List<String> keys() {
    return _box.keys.cast<String>().toList();
  }
}
