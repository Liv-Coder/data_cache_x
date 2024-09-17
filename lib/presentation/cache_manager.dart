// lib/presentation/cache_manager.dart
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

  CacheManager(CacheRepository repository)
      : cacheDataUseCase = CacheDataUseCase(repository),
        getCachedDataUseCase = GetCachedDataUseCase(repository),
        clearCacheDataUsecase = ClearCacheDataUsecase(repository),
        clearAllCacheDataUsecase = ClearAllCacheDataUsecase(repository);

  Future<void> cacheData(String key, String data) async {
    await cacheDataUseCase.call(key, data);
  }

  Future<String?> getCachedData(String key) async {
    return await getCachedDataUseCase.call(key);
  }

  Future<void> clearCache(String key) async {
    await clearCacheDataUsecase.call(key);
  }

  Future<void> clearAllCache() async {
    await clearAllCacheDataUsecase.call();
  }
}
