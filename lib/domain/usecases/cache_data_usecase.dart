import '../../data/repositories/cache_repository.dart';

class CacheDataUseCase {
  final CacheRepository repository;

  CacheDataUseCase(this.repository);

  Future<void> call(String key, String data) async {
    await repository.cacheData(key, data);
  }
}
