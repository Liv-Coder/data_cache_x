import 'package:data_cache_x/data_cache_x.dart';

class AdapterBenchmark {
  final int itemCount;
  final int itemSize;
  final Duration? expiry;
  final CachePriority priority;
  final CompressionMode compression;

  const AdapterBenchmark({
    required this.itemCount,
    required this.itemSize,
    this.expiry,
    this.priority = CachePriority.normal,
    this.compression = CompressionMode.auto,
  });

  /// Creates a small benchmark (100 items, 100 bytes each)
  factory AdapterBenchmark.small() {
    return const AdapterBenchmark(
      itemCount: 100,
      itemSize: 100,
    );
  }

  /// Creates a medium benchmark (500 items, 500 bytes each)
  factory AdapterBenchmark.medium() {
    return const AdapterBenchmark(
      itemCount: 500,
      itemSize: 500,
    );
  }

  /// Creates a large benchmark (1000 items, 1000 bytes each)
  factory AdapterBenchmark.large() {
    return const AdapterBenchmark(
      itemCount: 1000,
      itemSize: 1000,
    );
  }

  /// Creates a custom benchmark
  factory AdapterBenchmark.custom({
    required int itemCount,
    required int itemSize,
    Duration? expiry,
    CachePriority priority = CachePriority.normal,
    CompressionMode compression = CompressionMode.auto,
  }) {
    return AdapterBenchmark(
      itemCount: itemCount,
      itemSize: itemSize,
      expiry: expiry,
      priority: priority,
      compression: compression,
    );
  }
}
