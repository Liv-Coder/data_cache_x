import 'package:data_cache_x/models/cache_item.dart';

abstract class CacheAdapter {
  Future<void> put(String key, CacheItem value);
  Future<CacheItem?> get(String key);
  Future<void> delete(String key);
  Future<void> clear();
  Future<bool> containsKey(String key);
}
