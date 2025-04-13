# Benchmarking

data_cache_x includes a benchmarking tool that allows you to measure the performance of different cache operations and configurations. This guide explains how to use the benchmarking tool to optimize your cache usage.

## Basic Usage

To use the benchmarking tool, you need to create a `CacheBenchmark` instance with your `DataCacheX` instance:

```dart
import 'package:data_cache_x/data_cache_x.dart';
import 'package:data_cache_x/service_locator.dart';
import 'package:data_cache_x/utils/benchmark.dart';

// Initialize the cache
await setupDataCacheX();
final dataCache = getIt<DataCacheX>();

// Create a benchmark instance
final benchmark = CacheBenchmark(dataCache);
```

### Benchmarking Individual Operations

You can benchmark individual operations like put, get, and delete:

```dart
// Benchmark put operation
final putResult = await benchmark.benchmarkPut(
  keyPrefix: 'benchmark-put',
  value: 'test-value',
  iterations: 1000,
);
print('Put Result: $putResult');

// Benchmark get operation
final getResult = await benchmark.benchmarkGet(
  key: 'benchmark-get',
  iterations: 1000,
);
print('Get Result: $getResult');

// Benchmark delete operation
final deleteResult = await benchmark.benchmarkDelete(
  keyPrefix: 'benchmark-delete',
  iterations: 1000,
);
print('Delete Result: $deleteResult');
```

### Running Comprehensive Benchmarks

You can run a comprehensive benchmark that includes put, get, and delete operations:

```dart
final results = await benchmark.runComprehensiveBenchmark(
  iterations: 1000,
  valueSize: 1000,
);
for (final result in results) {
  print('Result: $result');
}
```

### Comparing Synchronous vs Asynchronous Performance

You can compare the performance of synchronous and asynchronous operations:

```dart
final comparison = await benchmark.compareAsyncVsSync(
  iterations: 1000,
  valueSize: 10000,
);
print(comparison);
```

This will output a detailed comparison of the performance of synchronous and asynchronous operations, including the percentage improvement of async over sync.

## Advanced Usage

### Benchmarking Different Compression Levels

You can benchmark different compression levels to find the optimal balance between compression ratio and performance:

```dart
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
```

### Benchmarking Different Adapter Types

You can benchmark different adapter types to find the one that best suits your needs:

```dart
// Memory adapter
await setupDataCacheX(adapterType: CacheAdapterType.memory);
final memoryCache = getIt<DataCacheX>();
final memoryBenchmark = CacheBenchmark(memoryCache);
final memoryResults = await memoryBenchmark.runComprehensiveBenchmark(
  iterations: 1000,
  valueSize: 1000,
);
for (final result in memoryResults) {
  print('Memory Adapter: $result');
}

// Hive adapter
await setupDataCacheX(adapterType: CacheAdapterType.hive);
final hiveCache = getIt<DataCacheX>();
final hiveBenchmark = CacheBenchmark(hiveCache);
final hiveResults = await hiveBenchmark.runComprehensiveBenchmark(
  iterations: 1000,
  valueSize: 1000,
);
for (final result in hiveResults) {
  print('Hive Adapter: $result');
}
```

### Custom Benchmarks

You can create custom benchmarks for specific scenarios:

```dart
final customResult = await benchmark.runBenchmark(
  operation: () async {
    // Your custom operation here
    await dataCache.put('custom-key', 'custom-value');
    await dataCache.get<String>('custom-key');
    await dataCache.delete('custom-key');
  },
  iterations: 1000,
  name: 'Custom Benchmark',
);
print('Custom Result: $customResult');
```

## Interpreting Results

The benchmark results include the following information:

- **Name**: The name of the benchmark
- **Iterations**: The number of times the operation was performed
- **Total Time**: The total time taken to perform all iterations (in milliseconds)
- **Average Time**: The average time per iteration (in milliseconds)

When comparing synchronous and asynchronous operations, the benchmark also calculates the percentage improvement of async over sync. A positive value means async is faster, a negative value means sync is faster.

## Best Practices

1. **Run benchmarks on the target device**: Performance can vary significantly between devices, so it's important to run benchmarks on the device where your app will be used.

2. **Use realistic data sizes**: Use data sizes that are representative of your actual usage to get meaningful results.

3. **Run multiple iterations**: Run a sufficient number of iterations to get statistically significant results.

4. **Benchmark different configurations**: Try different adapter types, compression levels, and other settings to find the optimal configuration for your use case.

5. **Consider the trade-offs**: Sometimes the fastest option isn't the best choice if it uses too much memory or doesn't provide the persistence you need.

## Example

Here's a complete example of how to use the benchmarking tool:

```dart
import 'package:data_cache_x/data_cache_x.dart';
import 'package:data_cache_x/service_locator.dart';
import 'package:data_cache_x/utils/benchmark.dart';
import 'package:data_cache_x/models/cache_policy.dart';
import 'package:logging/logging.dart';

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
}
```

This example compares the performance of synchronous and asynchronous operations for different value sizes, which can help you decide when to use the asynchronous methods.
