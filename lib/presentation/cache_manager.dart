// lib/presentation/cache_manager.dart
import 'package:data_cache_x/domain/usecases/print_cache_contents_usecase.dart';

import '../data/repositories/cache_repository.dart';
import '../domain/usecases/cache_data_usecase.dart';
import '../domain/usecases/clear_all_cache_data_usecase.dart';
import '../domain/usecases/clear_cache_data_usecase.dart';
import '../domain/usecases/get_cached_data_usecase.dart';

class CacheManager {
  final CacheDataUseCase cacheDataUseCase;
  final GetCachedDataUseCase getCachedDataUseCase;
  final ClearCacheDataUsecase clearCacheDataUsecase;
  final ClearAllCacheDataUsecase clearAllCacheDataUsecase;
  final PrintCacheContentsUsecase printCacheContentsUsecase;

  CacheManager(CacheRepository repository)
      : cacheDataUseCase = CacheDataUseCase(repository),
        getCachedDataUseCase = GetCachedDataUseCase(repository),
        clearCacheDataUsecase = ClearCacheDataUsecase(repository),
        clearAllCacheDataUsecase = ClearAllCacheDataUsecase(repository),
        printCacheContentsUsecase = PrintCacheContentsUsecase(repository);

  Future<void> cacheData(
    String key,
    dynamic data,
    Duration expirationDuration, {
    bool isCompressed = true,
  }) async {
    await cacheDataUseCase.call(
      key,
      data,
      expirationDuration,
      isCompressed,
    );
  }

  Future<dynamic> getCachedData(String key) async {
    return await getCachedDataUseCase.call(key);
  }

  Future<void> clearCache(String key) async {
    await clearCacheDataUsecase.call(key);
  }

  Future<void> clearAllCache() async {
    await clearAllCacheDataUsecase.call();
  }

  Future<void> printCacheContents() async {
    await printCacheContentsUsecase.call();
  }
}
