import '../data source/local_data_source.dart';
import '../models/cache_model.dart';

class CacheRepository {
  final LocalDataSource localDataSource;

  CacheRepository(this.localDataSource);

  Future<void> cacheData(String key, String data) async {
    final cacheModel = CacheModel(key: key, data: data);
    await localDataSource.cacheData(cacheModel);
  }

  Future<String?> getCachedData(String key) async {
    return await localDataSource.getCachedData(key);
  }

  Future<void> clearCache(String key) async {
    await localDataSource.clearCache(key);
  }
}
