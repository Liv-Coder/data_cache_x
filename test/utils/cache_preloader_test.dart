import 'package:data_cache_x/adapters/memory_adapter.dart';
import 'package:data_cache_x/core/data_cache_x.dart';
import 'package:data_cache_x/models/cache_policy.dart';
import 'package:data_cache_x/utils/cache_preloader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DataCacheX cache;
  late CachePreloader preloader;

  setUp(() async {
    cache = DataCacheX(
      MemoryAdapter(),
      analytics: null,
    );

    preloader = CachePreloader(cache);
  });

  tearDown(() {
    preloader.dispose();
  });

  group('CachePreloader', () {
    test('preload loads data into the cache', () async {
      // Setup: Create data providers
      final dataProviders = <String, Future<String> Function()>{
        'key1': () async => 'value1',
        'key2': () async => 'value2',
        'key3': () async => 'value3',
      };

      // Act: Preload the data
      final operations = await preloader.preload(dataProviders: dataProviders);

      // Assert: Operations should be completed
      expect(operations.length, equals(3));
      for (final operation in operations.values) {
        expect(operation.status, equals(PreloadStatus.completed));
      }

      // Assert: Data should be in the cache
      expect(await cache.get<String>('key1'), equals('value1'));
      expect(await cache.get<String>('key2'), equals('value2'));
      expect(await cache.get<String>('key3'), equals('value3'));
    });

    test('preload with policy applies the policy to all items', () async {
      // Setup: Create data providers
      final dataProviders = <String, Future<String> Function()>{
        'key1': () async => 'value1',
      };

      // Create a policy with a short expiry
      final policy = CachePolicy(expiry: Duration(milliseconds: 100));

      // Act: Preload the data with the policy
      await preloader.preload(dataProviders: dataProviders, policy: policy);

      // Assert: Data should be in the cache
      expect(await cache.get<String>('key1'), equals('value1'));

      // Wait for the item to expire
      await Future.delayed(Duration(milliseconds: 150));

      // Assert: The item should be expired
      expect(await cache.get<String>('key1'), isNull);
    });

    test('preload with tags applies the tags to all items', () async {
      // Setup: Create data providers
      final dataProviders = <String, Future<String> Function()>{
        'key1': () async => 'value1',
        'key2': () async => 'value2',
      };

      // Act: Preload the data with tags
      await preloader.preload(
        dataProviders: dataProviders,
        tags: {'test_tag'},
      );

      // Assert: Data should be in the cache with the tag
      final keys = await cache.getKeysByTag('test_tag');
      expect(keys, containsAll(['key1', 'key2']));
    });

    test('preload handles errors gracefully', () async {
      // Setup: Create data providers with one that throws an error
      final dataProviders = <String, Future<String> Function()>{
        'key1': () async => 'value1',
        'key2': () async => throw Exception('Test error'),
        'key3': () async => 'value3',
      };

      // Act: Preload the data
      final operations = await preloader.preload(dataProviders: dataProviders);

      // Assert: Operations should have appropriate statuses
      expect(operations['key1']!.status, equals(PreloadStatus.completed));
      expect(operations['key2']!.status, equals(PreloadStatus.failed));
      expect(operations['key3']!.status, equals(PreloadStatus.completed));

      // Assert: Error should be recorded
      expect(operations['key2']!.error, isA<Exception>());
      expect((operations['key2']!.error as Exception).toString(),
          contains('Test error'));

      // Assert: Successful items should be in the cache
      expect(await cache.get<String>('key1'), equals('value1'));
      expect(await cache.get<String>('key2'), isNull);
      expect(await cache.get<String>('key3'), equals('value3'));
    });

    test('preloadInBackground returns a stream of operations', () async {
      // Setup: Create data providers
      final dataProviders = <String, Future<String> Function()>{
        'key1': () async {
          await Future.delayed(Duration(milliseconds: 50));
          return 'value1';
        },
        'key2': () async {
          await Future.delayed(Duration(milliseconds: 50));
          return 'value2';
        },
      };

      // Act: Preload the data in the background
      preloader.preloadInBackground(dataProviders: dataProviders);

      // Wait for preloading to complete
      await Future.delayed(Duration(milliseconds: 200));

      // Assert: Data should be in the cache
      expect(await cache.get<String>('key1'), equals('value1'));
      expect(await cache.get<String>('key2'), equals('value2'));
    });

    test('cancelPreload marks an operation as cancelled', () async {
      // Setup: Create a data provider that takes some time
      final dataProviders = <String, Future<String> Function()>{
        'key1': () async {
          await Future.delayed(Duration(milliseconds: 500));
          return 'value1';
        },
      };

      // Start preloading in the background
      preloader.preloadInBackground(dataProviders: dataProviders);

      // Wait a bit for the operation to start
      await Future.delayed(Duration(milliseconds: 50));

      // Act: Cancel the operation
      final cancelled = preloader.cancelPreload('key1');

      // Assert: Operation should be marked as cancelled
      expect(cancelled, isTrue);
      expect(preloader.operations['key1']!.status,
          equals(PreloadStatus.cancelled));

      // Note: In the current implementation, cancellation only marks the operation as cancelled
      // but doesn't actually prevent the data provider from completing its work.
      // This is a limitation that could be addressed in a future version.
    });

    test('clearCompletedOperations removes completed operations', () async {
      // Setup: Create data providers
      final dataProviders = <String, Future<String> Function()>{
        'key1': () async => 'value1',
        'key2': () async => 'value2',
      };

      // Preload the data
      await preloader.preload(dataProviders: dataProviders);

      // Act: Clear completed operations
      final cleared = preloader.clearCompletedOperations();

      // Assert: Operations should be cleared
      expect(cleared, equals(2));
      expect(preloader.operations, isEmpty);
    });
  });
}
