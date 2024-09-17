import '../data source/local/local_data_source.dart';
import '../models/cache_model.dart';

class CacheRepository {
  final LocalDataSource localDataSource;

  CacheRepository(this.localDataSource);

  Future<void> cacheData(String key, String data) async {
    final cacheModel = CacheModel(key: key, data: data);
    await localDataSource.insertCache(cacheModel.key, cacheModel.data);
  }

  Future<String?> getCachedData(String key) async {
    return await localDataSource.getCache(key);
  }

  Future<void> clearCache(String key) async {
    await localDataSource.deleteCache(key);
  }

  Future<void> clearAllCache() async {
    await localDataSource.clearAllCache();
  }
}
