import '../../data/repositories/cache_repository.dart';

class ClearCacheDataUsecase {
  final CacheRepository cacheRepository;

  ClearCacheDataUsecase(this.cacheRepository);

  Future<void> call(String key) async {
    return cacheRepository.clearCache(key);
  }
}
