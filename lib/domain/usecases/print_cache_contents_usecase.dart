import '../../data_cache_x.dart';

class PrintCacheContentsUsecase {
  final CacheRepository repository;

  PrintCacheContentsUsecase(this.repository);

  Future<void> call() async {
    await repository.printCacheContents();
  }
}
