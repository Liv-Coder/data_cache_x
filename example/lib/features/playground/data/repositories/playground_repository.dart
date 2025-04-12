import 'dart:math';

import 'package:data_cache_x/data_cache_x.dart';
import 'package:get_it/get_it.dart';

import '../models/adapter_benchmark.dart';
import '../models/benchmark_result.dart';

class PlaygroundRepository {
  final DataCacheX _mainCache;
  final Map<String, DataCacheX> _caches = {};

  PlaygroundRepository({DataCacheX? cache})
      : _mainCache = cache ?? GetIt.I<DataCacheX>() {
    _initializeCaches();
  }

  /// Initializes different cache adapters for comparison
  void _initializeCaches() {
    // Memory adapter
    final memoryAdapter = MemoryAdapter();
    _caches['memory'] = DataCacheX(
      memoryAdapter,
      maxItems: 1000,
      evictionStrategy: EvictionStrategy.lru,
    );

    // Hive adapter (already initialized in the main cache)
    _caches['hive'] = _mainCache;

    // Try to get other adapters from the service locator
    try {
      _caches['sqlite'] = GetIt.I<DataCacheX>(instanceName: 'sqlite_cache');
    } catch (e) {
      // SQLite adapter not available
    }

    try {
      _caches['shared_prefs'] =
          GetIt.I<DataCacheX>(instanceName: 'prefs_cache');
    } catch (e) {
      // SharedPreferences adapter not available
    }
  }

  /// Gets all available adapters
  List<String> getAvailableAdapters() {
    return _caches.keys.toList();
  }

  /// Runs a benchmark for a specific adapter
  Future<BenchmarkResult> runBenchmark(
      String adapter, AdapterBenchmark benchmark) async {
    if (!_caches.containsKey(adapter)) {
      throw Exception('Adapter $adapter not found');
    }

    final cache = _caches[adapter]!;
    final stopwatch = Stopwatch()..start();

    // Generate test data
    final random = Random();
    final testData = <String, String>{};
    for (int i = 0; i < benchmark.itemCount; i++) {
      final key = 'benchmark_${adapter}_$i';
      final value = List.generate(benchmark.itemSize,
          (_) => String.fromCharCode(random.nextInt(26) + 97)).join();
      testData[key] = value;
    }

    // Clear the cache before starting
    await _clearCache(cache);

    // Write benchmark
    stopwatch.reset();
    for (final entry in testData.entries) {
      await cache.put(
        entry.key,
        entry.value,
        policy: CachePolicy(
          expiry: benchmark.expiry,
          priority: benchmark.priority,
          compression: benchmark.compression,
        ),
      );
    }
    final writeTime = stopwatch.elapsedMilliseconds;

    // Read benchmark
    stopwatch.reset();
    for (final key in testData.keys) {
      await cache.get(key);
    }
    final readTime = stopwatch.elapsedMilliseconds;

    // Delete benchmark
    stopwatch.reset();
    for (final key in testData.keys) {
      await cache.delete(key);
    }
    final deleteTime = stopwatch.elapsedMilliseconds;

    // Calculate total time
    final totalTime = writeTime + readTime + deleteTime;

    // Get analytics
    final hitRate = cache.hitRate;
    final totalSize = cache.totalSize;

    return BenchmarkResult(
      adapterName: adapter,
      writeTime: writeTime,
      readTime: readTime,
      deleteTime: deleteTime,
      totalTime: totalTime,
      hitRate: hitRate,
      totalSize: totalSize,
      itemCount: benchmark.itemCount,
      itemSize: benchmark.itemSize,
      compression: benchmark.compression,
      priority: benchmark.priority,
      expiry: benchmark.expiry,
    );
  }

  /// Clears a specific cache
  Future<void> _clearCache(DataCacheX cache) async {
    try {
      // Get all keys from analytics
      final frequentKeys = cache.mostFrequentlyAccessedKeys;
      final largestKeys = cache.largestItems;
      final recentKeys = cache.mostRecentlyAccessedKeys;

      // Collect all keys
      final keys = <String>{};
      for (final entry in frequentKeys) {
        keys.add(entry.key);
      }
      for (final entry in largestKeys) {
        keys.add(entry.key);
      }
      for (final entry in recentKeys) {
        keys.add(entry.key);
      }

      // Delete all keys
      for (final key in keys) {
        await cache.delete(key);
      }
    } catch (e) {
      // Ignore errors
    }
  }

  /// Runs a comparison benchmark for all available adapters
  Future<List<BenchmarkResult>> runComparisonBenchmark(
      AdapterBenchmark benchmark) async {
    final results = <BenchmarkResult>[];

    for (final adapter in getAvailableAdapters()) {
      try {
        final result = await runBenchmark(adapter, benchmark);
        results.add(result);
      } catch (e) {
        // Skip adapters that fail
      }
    }

    // Sort by total time (fastest first)
    results.sort((a, b) => a.totalTime.compareTo(b.totalTime));

    return results;
  }
}
