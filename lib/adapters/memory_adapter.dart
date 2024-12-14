import 'package:data_cache_x/adapters/cache_adapter.dart';
import 'package:data_cache_x/models/cache_item.dart';

class MemoryAdapter implements CacheAdapter {
  final Map<String, CacheItem> _cache = {};

  @override
  Future<void> clear() async {
    _cache.clear();
  }

  @override
  Future<CacheItem?> get(String key) async {
    return _cache[key];
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
    _cache[key] = item;
  }
}
