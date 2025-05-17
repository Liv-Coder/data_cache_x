import 'package:data_cache_x/adapters/memory_adapter.dart';
import 'package:data_cache_x/core/data_cache_x.dart';
import 'package:data_cache_x/models/cache_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DataCacheX cache;

  setUp(() async {
    cache = DataCacheX(
      MemoryAdapter(),
      analytics: null,
    );
  });

  group('DataCacheX Batch Operations', () {
    test('putAll stores multiple items correctly', () async {
      // Create a large batch of items
      final entries = <String, String>{};
      for (int i = 0; i < 100; i++) {
        entries['key$i'] = 'value$i';
      }

      // Store the items
      await cache.putAll(entries);

      // Verify all items were stored
      for (int i = 0; i < 100; i++) {
        final value = await cache.get<String>('key$i');
        expect(value, equals('value$i'));
      }
    });

    test('putAll with compression stores and retrieves correctly', () async {
      // Create a policy with compression
      final policy = CachePolicy.compressed();

      // Create a batch of compressible items (repeated text)
      final entries = <String, String>{};
      for (int i = 0; i < 100; i++) {
        entries['key$i'] =
            'value$i' * 100; // Make it large enough to benefit from compression
      }

      // Store the items with compression
      await cache.putAll(entries, policy: policy);

      // Verify all items can be retrieved and decompressed
      for (int i = 0; i < 100; i++) {
        final value = await cache.get<String>('key$i');
        expect(value, equals('value$i' * 100));
      }
    });

    test('getAll retrieves multiple items correctly', () async {
      // Store individual items
      for (int i = 0; i < 100; i++) {
        await cache.put('key$i', 'value$i');
      }

      // Retrieve all items at once
      final keys = List.generate(100, (i) => 'key$i');
      final results = await cache.getAll<String>(keys);

      // Verify all items were retrieved
      expect(results.length, equals(100));
      for (int i = 0; i < 100; i++) {
        expect(results['key$i'], equals('value$i'));
      }
    });

    test('getAll with missing keys returns only found items', () async {
      // Store some items
      for (int i = 0; i < 50; i++) {
        await cache.put('key$i', 'value$i');
      }

      // Try to retrieve more items than exist
      final keys = List.generate(100, (i) => 'key$i');
      final results = await cache.getAll<String>(keys);

      // Verify only existing items were retrieved
      expect(results.length, equals(50));
      for (int i = 0; i < 50; i++) {
        expect(results['key$i'], equals('value$i'));
      }
      for (int i = 50; i < 100; i++) {
        expect(results.containsKey('key$i'), isFalse);
      }
    });

    test('getAll with refresh callbacks fetches missing items', () async {
      // Store some items
      for (int i = 0; i < 50; i++) {
        await cache.put('key$i', 'value$i');
      }

      // Create refresh callbacks for missing items
      final refreshCallbacks = <String, Future<String> Function()>{};
      for (int i = 50; i < 100; i++) {
        refreshCallbacks['key$i'] = () async => 'fresh_value$i';
      }

      // Try to retrieve all items with refresh callbacks
      final keys = List.generate(100, (i) => 'key$i');
      final results =
          await cache.getAll<String>(keys, refreshCallbacks: refreshCallbacks);

      // Verify all items were retrieved, with fresh values for missing ones
      expect(results.length, equals(100));
      for (int i = 0; i < 50; i++) {
        expect(results['key$i'], equals('value$i'));
      }
      for (int i = 50; i < 100; i++) {
        expect(results['key$i'], equals('fresh_value$i'));
      }

      // Verify the fresh values were cached
      for (int i = 50; i < 100; i++) {
        final value = await cache.get<String>('key$i');
        expect(value, equals('fresh_value$i'));
      }
    });

    test('deleteAll removes multiple items correctly', () async {
      // Store items
      for (int i = 0; i < 100; i++) {
        await cache.put('key$i', 'value$i');
      }

      // Delete a subset of items
      final keysToDelete = List.generate(50, (i) => 'key$i');
      await cache.deleteAll(keysToDelete);

      // Verify deleted items are gone
      for (int i = 0; i < 50; i++) {
        final exists = await cache.containsKey('key$i');
        expect(exists, isFalse);
      }

      // Verify remaining items still exist
      for (int i = 50; i < 100; i++) {
        final exists = await cache.containsKey('key$i');
        expect(exists, isTrue);
      }
    });

    test('putAll with empty map does nothing', () async {
      // This should not throw an exception
      await cache.putAll(<String, String>{});

      // Verify the cache is empty by checking a known key
      await cache.put('test_key', 'test_value');
      await cache.delete('test_key');
      final exists = await cache.containsKey('test_key');
      expect(exists, isFalse);
    });

    test('getAll with empty keys returns empty map', () async {
      // Store some items
      await cache.put('key1', 'value1');
      await cache.put('key2', 'value2');

      // Call getAll with empty keys
      final results = await cache.getAll<String>([]);

      // Verify an empty map is returned
      expect(results, isEmpty);
    });

    test('deleteAll with empty keys does nothing', () async {
      // Store some items
      await cache.put('key1', 'value1');
      await cache.put('key2', 'value2');

      // Call deleteAll with empty keys
      await cache.deleteAll([]);

      // Verify items still exist
      expect(await cache.containsKey('key1'), isTrue);
      expect(await cache.containsKey('key2'), isTrue);
    });
  });
}
