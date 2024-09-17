import '../../data/repositories/cache_repository.dart';

class GetCachedDataUseCase {
  final CacheRepository repository;

  GetCachedDataUseCase(this.repository);

  Future<String?> call(String key) async {
    return await repository.getCachedData(key);
  }
}
