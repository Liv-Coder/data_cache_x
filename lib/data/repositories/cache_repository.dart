import 'dart:convert';

import '../data source/local/local_data_source.dart';
import '../models/cache_model.dart';

class CacheRepository {
  final LocalDataSource localDataSource;

  CacheRepository(this.localDataSource);

  Future<void> cacheData(
    String key,
    dynamic data,
    Duration expirationDuration,
    bool isCompressed,
  ) async {
    final cacheModel = CacheModel(
      key: key,
      data: data,
      expirationDuration: expirationDuration,
      isCompressed: isCompressed,
    );
    await localDataSource.insertCache(
      cacheModel.key,
      jsonEncode(cacheModel.data),
      Duration(milliseconds: cacheModel.expirationDuration.inMilliseconds),
      cacheModel.isCompressed,
    );
  }

  Future<dynamic> getCachedData(String key) async {
    final cacheEntry = await localDataSource.getCache(key);
    if (cacheEntry != null) {
      final expirationDuration = cacheEntry['expirationDuration'] as Duration;
      final timestamp = cacheEntry['timestamp'] as int;
      final expirationDate = DateTime.fromMillisecondsSinceEpoch(
          timestamp + expirationDuration.inMilliseconds);
      if (DateTime.now().isAfter(expirationDate)) {
        await localDataSource.deleteCache(key);
        return null;
      }
      return jsonDecode(cacheEntry['data'] as String);
    }
    return null;
  }

  Future<void> clearCache(String key) async {
    await localDataSource.deleteCache(key);
  }

  Future<void> clearAllCache() async {
    await localDataSource.clearAllCache();
  }

  Future<void> printCacheContents() async {
    await localDataSource.printCacheContents();
  }
}
