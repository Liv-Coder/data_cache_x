import 'dart:developer';

import 'package:data_cache_x/data/repositories/cache_repository.dart';
import 'package:data_cache_x/domain/usecases/cache_data_usecase.dart';
import 'package:data_cache_x/domain/usecases/clear_all_cache_data_usecase.dart';
import 'package:data_cache_x/domain/usecases/clear_cache_data_usecase.dart';
import 'package:data_cache_x/domain/usecases/get_cached_data_usecase.dart';
import 'package:data_cache_x/domain/usecases/print_cache_contents_usecase.dart';
import 'package:data_cache_x/presentation/cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'local_data_source_test.mocks.dart';

@GenerateMocks([
  CacheRepository,
  CacheDataUseCase,
  GetCachedDataUseCase,
  ClearCacheDataUsecase,
  ClearAllCacheDataUsecase,
  PrintCacheContentsUsecase,
])
void main() {
  late MockCacheRepository mockCacheRepository;
  late CacheManager cacheManager;

  setUp(() {
    mockCacheRepository = MockCacheRepository();
    cacheManager = CacheManager(mockCacheRepository);
  });

  test('should retrieve cache data', () async {
    log('Test Started: should retrieve cache data');
    const key = 'test_key';
    const data = 'test_data';

    when(mockCacheRepository.getCachedData(key)).thenAnswer((_) async => data);

    final cacheEntry = await cacheManager.getCachedData(key);

    expect(cacheEntry, isNotNull);
    expect(cacheEntry, data);
    log('Test Passed: should retrieve cache data: $cacheEntry');
  });

  test('should return null if cache data does not exist', () async {
    log('Test Started: should return null if cache data does not exist');
    const key = 'non_existent_key';

    when(mockCacheRepository.getCachedData(key)).thenAnswer((_) async => null);

    final cacheEntry = await cacheManager.getCachedData(key);

    expect(cacheEntry, isNull);
    log('Test Passed: should return null if cache data does not exist: $cacheEntry');
  });
}
