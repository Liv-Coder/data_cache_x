import '../../data/repositories/cache_repository.dart';

class CacheDataUseCase {
  final CacheRepository repository;

  CacheDataUseCase(this.repository);

  Future<void> call(
    String key,
    dynamic data,
    Duration expirationDuration,
    bool isCompressed,
  ) async {
    await repository.cacheData(
      key,
      data,
      expirationDuration,
      isCompressed,
    );
  }
}
