import 'package:data_cache_x/data_cache_x.dart';

class BenchmarkResult {
  final String adapterName;
  final int writeTime;
  final int readTime;
  final int deleteTime;
  final int totalTime;
  final double hitRate;
  final int totalSize;
  final int itemCount;
  final int itemSize;
  final CompressionMode compression;
  final CachePriority priority;
  final Duration? expiry;

  const BenchmarkResult({
    required this.adapterName,
    required this.writeTime,
    required this.readTime,
    required this.deleteTime,
    required this.totalTime,
    required this.hitRate,
    required this.totalSize,
    required this.itemCount,
    required this.itemSize,
    required this.compression,
    required this.priority,
    required this.expiry,
  });

  /// Gets the adapter display name
  String get adapterDisplayName {
    switch (adapterName) {
      case 'memory':
        return 'Memory';
      case 'hive':
        return 'Hive';
      case 'sqlite':
        return 'SQLite';
      case 'shared_prefs':
        return 'SharedPreferences';
      default:
        return adapterName;
    }
  }

  /// Gets the operations per second for write operations
  double get writeOpsPerSecond {
    if (writeTime == 0) return 0;
    return itemCount / (writeTime / 1000);
  }

  /// Gets the operations per second for read operations
  double get readOpsPerSecond {
    if (readTime == 0) return 0;
    return itemCount / (readTime / 1000);
  }

  /// Gets the operations per second for delete operations
  double get deleteOpsPerSecond {
    if (deleteTime == 0) return 0;
    return itemCount / (deleteTime / 1000);
  }

  /// Gets the average operations per second
  double get averageOpsPerSecond {
    if (totalTime == 0) return 0;
    return (itemCount * 3) / (totalTime / 1000);
  }

  /// Gets the formatted write time
  String get formattedWriteTime => '${writeTime}ms';

  /// Gets the formatted read time
  String get formattedReadTime => '${readTime}ms';

  /// Gets the formatted delete time
  String get formattedDeleteTime => '${deleteTime}ms';

  /// Gets the formatted total time
  String get formattedTotalTime => '${totalTime}ms';

  /// Gets the formatted hit rate
  String get formattedHitRate => '${hitRate.toStringAsFixed(1)}%';

  /// Gets the formatted total size
  String get formattedTotalSize {
    if (totalSize < 1024) {
      return '$totalSize B';
    } else if (totalSize < 1024 * 1024) {
      return '${(totalSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(totalSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Gets the formatted write operations per second
  String get formattedWriteOpsPerSecond => '${writeOpsPerSecond.toStringAsFixed(1)}/s';

  /// Gets the formatted read operations per second
  String get formattedReadOpsPerSecond => '${readOpsPerSecond.toStringAsFixed(1)}/s';

  /// Gets the formatted delete operations per second
  String get formattedDeleteOpsPerSecond => '${deleteOpsPerSecond.toStringAsFixed(1)}/s';

  /// Gets the formatted average operations per second
  String get formattedAverageOpsPerSecond => '${averageOpsPerSecond.toStringAsFixed(1)}/s';
}
