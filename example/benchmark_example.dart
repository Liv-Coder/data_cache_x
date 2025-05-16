// ignore_for_file: avoid_print

import 'package:data_cache_x/data_cache_x.dart';
import 'package:data_cache_x/service_locator.dart';
import 'package:data_cache_x/utils/benchmark.dart';
import 'package:logging/logging.dart';

/// This example demonstrates how to use the benchmarking tool to measure
/// the performance of the cache.
Future<void> main() async {
  // Configure logging
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  // Initialize the cache
  await setupDataCacheX(adapterType: CacheAdapterType.memory);
  final dataCache = getIt<DataCacheX>();

  // Create a benchmark instance
  final benchmark = CacheBenchmark(dataCache);

  // Run a simple benchmark
  print('Running simple benchmark...');
  final putResult = await benchmark.benchmarkPut(
    keyPrefix: 'simple-benchmark',
    value: 'test-value',
    iterations: 1000,
  );
  print('Put Result: $putResult');

  // Run a comprehensive benchmark
  print('\nRunning comprehensive benchmark...');
  final results = await benchmark.runComprehensiveBenchmark(
    iterations: 1000,
    valueSize: 1000,
  );
  for (final result in results) {
    print('Result: $result');
  }

  // Compare sync vs async performance for different value sizes
  print('\nComparing sync vs async performance...');

  // Small values (100 characters)
  print('\nSmall values (100 characters):');
  final smallComparison = await benchmark.compareAsyncVsSync(
    iterations: 1000,
    valueSize: 100,
  );
  print(smallComparison);

  // Medium values (10,000 characters)
  print('\nMedium values (10,000 characters):');
  final mediumComparison = await benchmark.compareAsyncVsSync(
    iterations: 100,
    valueSize: 10000,
  );
  print(mediumComparison);

  // Large values (100,000 characters)
  print('\nLarge values (100,000 characters):');
  final largeComparison = await benchmark.compareAsyncVsSync(
    iterations: 10,
    valueSize: 100000,
  );
  print(largeComparison);

  // Benchmark different compression levels
  print('\nBenchmarking different compression levels...');
  for (int level = 1; level <= 9; level += 2) {
    final policy = CachePolicy(
      compression: CompressionMode.always,
      compressionLevel: level,
    );

    final result = await benchmark.benchmarkPut(
      keyPrefix: 'compression-benchmark-$level',
      value: 'A' * 10000,
      iterations: 100,
      policy: policy,
    );

    print('Compression Level $level: $result');
  }

  // Benchmark different adapter types
  print('\nBenchmarking different adapter types...');

  // Memory adapter (already initialized)
  print('\nMemory Adapter:');
  final memoryResults = await benchmark.runComprehensiveBenchmark(
    iterations: 1000,
    valueSize: 1000,
  );
  for (final result in memoryResults) {
    print('Result: $result');
  }

  // Clean up
  await getIt.reset();

  // Hive adapter
  print('\nHive Adapter:');
  await setupDataCacheX(adapterType: CacheAdapterType.hive);
  final hiveCache = getIt<DataCacheX>();
  final hiveBenchmark = CacheBenchmark(hiveCache);
  final hiveResults = await hiveBenchmark.runComprehensiveBenchmark(
    iterations: 1000,
    valueSize: 1000,
  );
  for (final result in hiveResults) {
    print('Result: $result');
  }

  // Clean up
  await getIt.reset();

  // SQLite adapter
  print('\nSQLite Adapter:');
  await setupDataCacheX(adapterType: CacheAdapterType.sqlite);
  final sqliteCache = getIt<DataCacheX>();
  final sqliteBenchmark = CacheBenchmark(sqliteCache);
  final sqliteResults = await sqliteBenchmark.runComprehensiveBenchmark(
    iterations: 1000,
    valueSize: 1000,
  );
  for (final result in sqliteResults) {
    print('Result: $result');
  }

  // Clean up
  await getIt.reset();

  // SharedPreferences adapter
  print('\nSharedPreferences Adapter:');
  await setupDataCacheX(adapterType: CacheAdapterType.sharedPreferences);
  final sharedPrefsCache = getIt<DataCacheX>();
  final sharedPrefsBenchmark = CacheBenchmark(sharedPrefsCache);
  final sharedPrefsResults =
      await sharedPrefsBenchmark.runComprehensiveBenchmark(
    iterations: 1000,
    valueSize: 1000,
  );
  for (final result in sharedPrefsResults) {
    print('Result: $result');
  }

  print('\nBenchmarking complete!');
}
