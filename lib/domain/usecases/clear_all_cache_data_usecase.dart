import 'package:data_cache_x/data_cache_x.dart';

class ClearAllCacheDataUsecase {
  final CacheRepository cacheRepository;

  ClearAllCacheDataUsecase(this.cacheRepository);

  Future<void> call() async {
    await cacheRepository.clearAllCache();
  }
}
