import 'dart:async';
import 'package:data_cache_x/core/data_cache_x.dart';
import 'package:data_cache_x/models/cache_policy.dart';
import 'package:logging/logging.dart';

/// A utility class for benchmarking cache operations.
class CacheBenchmark {
  final DataCacheX _cache;
  final Logger _log = Logger('CacheBenchmark');

  /// Creates a new instance of [CacheBenchmark].
  CacheBenchmark(this._cache);

  /// Runs a benchmark for the given operation.
  ///
  /// The [operation] parameter is the operation to benchmark.
  /// The [iterations] parameter is the number of times to run the operation.
  /// The [name] parameter is the name of the benchmark.
  ///
  /// Returns the benchmark result.
  Future<BenchmarkResult> runBenchmark({
    required Future<void> Function() operation,
    required int iterations,
    required String name,
  }) async {
    _log.info('Starting benchmark: $name');
    
    final stopwatch = Stopwatch()..start();
    
    for (int i = 0; i < iterations; i++) {
      await operation();
    }
    
    stopwatch.stop();
    
    final result = BenchmarkResult(
      name: name,
      iterations: iterations,
      totalTimeMs: stopwatch.elapsedMilliseconds,
      averageTimeMs: stopwatch.elapsedMilliseconds / iterations,
    );
    
    _log.info('Benchmark completed: $name');
    _log.info('Result: $result');
    
    return result;
  }

  /// Runs a benchmark for put operations.
  ///
  /// The [keyPrefix] parameter is the prefix for the keys.
  /// The [value] parameter is the value to store.
  /// The [iterations] parameter is the number of times to run the operation.
  /// The [policy] parameter is the cache policy to use.
  /// The [useAsync] parameter determines whether to use the asynchronous put method.
  ///
  /// Returns the benchmark result.
  Future<BenchmarkResult> benchmarkPut({
    required String keyPrefix,
    required dynamic value,
    required int iterations,
    CachePolicy? policy,
    bool useAsync = false,
  }) async {
    return runBenchmark(
      operation: () async {
        final key = '$keyPrefix-${DateTime.now().microsecondsSinceEpoch}';
        if (useAsync) {
          await _cache.putAsync(key, value, policy: policy);
        } else {
          await _cache.put(key, value, policy: policy);
        }
      },
      iterations: iterations,
      name: useAsync ? 'Put (Async)' : 'Put',
    );
  }

  /// Runs a benchmark for get operations.
  ///
  /// The [key] parameter is the key to retrieve.
  /// The [iterations] parameter is the number of times to run the operation.
  /// The [useAsync] parameter determines whether to use the asynchronous get method.
  ///
  /// Returns the benchmark result.
  Future<BenchmarkResult> benchmarkGet({
    required String key,
    required int iterations,
    bool useAsync = false,
  }) async {
    // First, make sure the key exists
    if (!await _cache.containsKey(key)) {
      await _cache.put(key, 'benchmark-value');
    }
    
    return runBenchmark(
      operation: () async {
        if (useAsync) {
          await _cache.getAsync<dynamic>(key);
        } else {
          await _cache.get<dynamic>(key);
        }
      },
      iterations: iterations,
      name: useAsync ? 'Get (Async)' : 'Get',
    );
  }

  /// Runs a benchmark for delete operations.
  ///
  /// The [keyPrefix] parameter is the prefix for the keys.
  /// The [iterations] parameter is the number of times to run the operation.
  ///
  /// Returns the benchmark result.
  Future<BenchmarkResult> benchmarkDelete({
    required String keyPrefix,
    required int iterations,
  }) async {
    // First, create the keys
    for (int i = 0; i < iterations; i++) {
      final key = '$keyPrefix-$i';
      await _cache.put(key, 'benchmark-value');
    }
    
    return runBenchmark(
      operation: () async {
        final key = '$keyPrefix-${_deleteCounter++}';
        await _cache.delete(key);
      },
      iterations: iterations,
      name: 'Delete',
    );
  }
  
  int _deleteCounter = 0;

  /// Runs a comprehensive benchmark suite.
  ///
  /// The [iterations] parameter is the number of times to run each operation.
  /// The [valueSize] parameter is the size of the value to use (in characters).
  /// The [useAsync] parameter determines whether to use the asynchronous methods.
  ///
  /// Returns a list of benchmark results.
  Future<List<BenchmarkResult>> runComprehensiveBenchmark({
    required int iterations,
    required int valueSize,
    bool useAsync = false,
  }) async {
    final results = <BenchmarkResult>[];
    
    // Generate a test value of the specified size
    final value = 'A' * valueSize;
    
    // Benchmark put operations
    results.add(await benchmarkPut(
      keyPrefix: 'benchmark-put',
      value: value,
      iterations: iterations,
      useAsync: useAsync,
    ));
    
    // Benchmark get operations
    final getKey = 'benchmark-get';
    await _cache.put(getKey, value);
    results.add(await benchmarkGet(
      key: getKey,
      iterations: iterations,
      useAsync: useAsync,
    ));
    
    // Benchmark delete operations
    results.add(await benchmarkDelete(
      keyPrefix: 'benchmark-delete',
      iterations: iterations,
    ));
    
    return results;
  }

  /// Compares the performance of synchronous and asynchronous operations.
  ///
  /// The [iterations] parameter is the number of times to run each operation.
  /// The [valueSize] parameter is the size of the value to use (in characters).
  ///
  /// Returns a comparison of the benchmark results.
  Future<BenchmarkComparison> compareAsyncVsSync({
    required int iterations,
    required int valueSize,
  }) async {
    // Run synchronous benchmarks
    final syncResults = await runComprehensiveBenchmark(
      iterations: iterations,
      valueSize: valueSize,
      useAsync: false,
    );
    
    // Run asynchronous benchmarks
    final asyncResults = await runComprehensiveBenchmark(
      iterations: iterations,
      valueSize: valueSize,
      useAsync: true,
    );
    
    return BenchmarkComparison(
      syncResults: syncResults,
      asyncResults: asyncResults,
      valueSize: valueSize,
      iterations: iterations,
    );
  }
}

/// A class that represents the result of a benchmark.
class BenchmarkResult {
  final String name;
  final int iterations;
  final int totalTimeMs;
  final double averageTimeMs;

  BenchmarkResult({
    required this.name,
    required this.iterations,
    required this.totalTimeMs,
    required this.averageTimeMs,
  });

  @override
  String toString() {
    return '$name: $iterations iterations, $totalTimeMs ms total, ${averageTimeMs.toStringAsFixed(2)} ms average';
  }
}

/// A class that represents a comparison of benchmark results.
class BenchmarkComparison {
  final List<BenchmarkResult> syncResults;
  final List<BenchmarkResult> asyncResults;
  final int valueSize;
  final int iterations;

  BenchmarkComparison({
    required this.syncResults,
    required this.asyncResults,
    required this.valueSize,
    required this.iterations,
  });

  /// Gets the performance improvement of async over sync as a percentage.
  ///
  /// A positive value means async is faster, a negative value means sync is faster.
  Map<String, double> getImprovementPercentages() {
    final result = <String, double>{};
    
    for (int i = 0; i < syncResults.length; i++) {
      final syncResult = syncResults[i];
      final asyncResult = asyncResults[i];
      
      if (syncResult.name.replaceAll(' (Async)', '') == 
          asyncResult.name.replaceAll(' (Async)', '')) {
        final improvement = (syncResult.averageTimeMs - asyncResult.averageTimeMs) / 
            syncResult.averageTimeMs * 100;
        result[syncResult.name] = improvement;
      }
    }
    
    return result;
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    
    buffer.writeln('Benchmark Comparison:');
    buffer.writeln('Value Size: $valueSize characters');
    buffer.writeln('Iterations: $iterations');
    buffer.writeln();
    
    buffer.writeln('Synchronous Results:');
    for (final result in syncResults) {
      buffer.writeln('  $result');
    }
    
    buffer.writeln();
    buffer.writeln('Asynchronous Results:');
    for (final result in asyncResults) {
      buffer.writeln('  $result');
    }
    
    buffer.writeln();
    buffer.writeln('Performance Improvement (Async vs Sync):');
    final improvements = getImprovementPercentages();
    for (final entry in improvements.entries) {
      final sign = entry.value >= 0 ? '+' : '';
      buffer.writeln('  ${entry.key}: $sign${entry.value.toStringAsFixed(2)}%');
    }
    
    return buffer.toString();
  }
}
