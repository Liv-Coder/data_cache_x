import 'dart:async';
import 'dart:isolate';
import 'package:logging/logging.dart';

/// A utility class for running operations in isolates.
///
/// This class provides a simple way to run operations in separate isolates,
/// which can help improve performance for CPU-intensive tasks by avoiding
/// blocking the main thread.
class IsolateRunner {
  /// The logger instance.
  static final _log = Logger('IsolateRunner');

  /// The default threshold (in bytes) above which operations will be performed in a separate isolate.
  static const int defaultAsyncThreshold = 50000;

  /// Runs a function in an isolate if the data size exceeds the threshold.
  ///
  /// The [function] parameter is the function to run in the isolate.
  /// The [message] parameter is the data to pass to the function.
  /// The [dataSize] parameter is the size of the data in bytes.
  /// The [asyncThreshold] parameter determines the data size (in bytes) above which
  /// the operation will be performed in a separate isolate.
  ///
  /// Returns the result of the function.
  static Future<R> runWithThreshold<T, R>({
    required R Function(T) function,
    required T message,
    required int dataSize,
    int asyncThreshold = defaultAsyncThreshold,
  }) async {
    // If the data size is below the threshold, run synchronously
    if (dataSize < asyncThreshold) {
      return function(message);
    }

    // Otherwise, run in a separate isolate
    _log.fine('Running operation in isolate for data size: $dataSize bytes');
    return Isolate.run(() => function(message));
  }

  /// Runs a function in an isolate.
  ///
  /// The [function] parameter is the function to run in the isolate.
  /// The [message] parameter is the data to pass to the function.
  ///
  /// Returns the result of the function.
  static Future<R> run<T, R>({
    required R Function(T) function,
    required T message,
  }) async {
    _log.fine('Running operation in isolate');
    return Isolate.run(() => function(message));
  }

  /// Runs a batch of operations in an isolate.
  ///
  /// The [function] parameter is the function to run for each item in the batch.
  /// The [items] parameter is the list of items to process.
  /// The [batchSize] parameter determines how many items to process in each isolate.
  ///
  /// Returns a list of results, one for each input item.
  static Future<List<R>> runBatch<T, R>({
    required R Function(T) function,
    required List<T> items,
    int batchSize = 50,
  }) async {
    if (items.isEmpty) {
      return [];
    }

    if (items.length <= batchSize) {
      // For small batches, run in a single isolate
      return Isolate.run(() => items.map(function).toList());
    }

    // For larger batches, split into multiple isolates
    final results = <R>[];
    final batches = <List<T>>[];

    // Split items into batches
    for (var i = 0; i < items.length; i += batchSize) {
      final end = (i + batchSize < items.length) ? i + batchSize : items.length;
      batches.add(items.sublist(i, end));
    }

    _log.fine('Processing ${items.length} items in ${batches.length} batches');

    // Process each batch in a separate isolate
    final futures = batches.map((batch) {
      return Isolate.run(() => batch.map(function).toList());
    });

    // Collect results
    final batchResults = await Future.wait(futures);
    for (final batchResult in batchResults) {
      results.addAll(batchResult);
    }

    return results;
  }
}
