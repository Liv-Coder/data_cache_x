import 'dart:async';

import 'package:data_cache_x/core/data_cache_x.dart';
import 'package:data_cache_x/models/cache_policy.dart';
import 'package:logging/logging.dart';

/// Defines the status of a preloading operation.
enum PreloadStatus {
  /// The preloading operation has not started.
  notStarted,

  /// The preloading operation is in progress.
  inProgress,

  /// The preloading operation has completed successfully.
  completed,

  /// The preloading operation has failed.
  failed,

  /// The preloading operation has been cancelled.
  cancelled,
}

/// Represents a preloading operation.
class PreloadOperation {
  /// The key of the item being preloaded.
  final String key;

  /// The status of the preloading operation.
  PreloadStatus status;

  /// The error that occurred during preloading, if any.
  Object? error;

  /// The time when the preloading operation started.
  final DateTime startTime;

  /// The time when the preloading operation completed, if any.
  DateTime? endTime;

  /// Creates a new instance of [PreloadOperation].
  PreloadOperation({
    required this.key,
    this.status = PreloadStatus.notStarted,
  }) : startTime = DateTime.now();

  /// Marks the operation as in progress.
  void markInProgress() {
    status = PreloadStatus.inProgress;
  }

  /// Marks the operation as completed.
  void markCompleted() {
    status = PreloadStatus.completed;
    endTime = DateTime.now();
  }

  /// Marks the operation as failed.
  void markFailed(Object error) {
    status = PreloadStatus.failed;
    this.error = error;
    endTime = DateTime.now();
  }

  /// Marks the operation as cancelled.
  void markCancelled() {
    status = PreloadStatus.cancelled;
    endTime = DateTime.now();
  }

  /// Gets the duration of the operation.
  Duration get duration {
    if (endTime == null) {
      return DateTime.now().difference(startTime);
    }
    return endTime!.difference(startTime);
  }
}

/// A class that handles preloading data into the cache.
class CachePreloader {
  /// The logger instance.
  final _log = Logger('CachePreloader');

  /// The cache instance.
  final DataCacheX _cache;

  /// The controller for preload events.
  final _preloadController = StreamController<PreloadOperation>.broadcast();

  /// The operations that are currently in progress.
  final Map<String, PreloadOperation> _operations = {};

  /// Creates a new instance of [CachePreloader].
  CachePreloader(this._cache);

  /// Gets the stream of preload events.
  Stream<PreloadOperation> get preloadEvents => _preloadController.stream;

  /// Gets the operations that are currently in progress.
  Map<String, PreloadOperation> get operations => Map.unmodifiable(_operations);

  /// Preloads data into the cache.
  ///
  /// The [dataProviders] parameter is a map where the keys are the cache keys and the values are
  /// functions that return the data to be cached.
  ///
  /// The [policy] parameter can be used to set a cache policy for all the data.
  /// The [tags] parameter can be used to associate tags with all the data.
  /// The [parallelism] parameter determines how many items to preload in parallel.
  /// The [onProgress] parameter is a callback that is called when an item is preloaded.
  ///
  /// Returns a map where the keys are the cache keys and the values are the preload operations.
  Future<Map<String, PreloadOperation>> preload<T>({
    required Map<String, Future<T> Function()> dataProviders,
    CachePolicy? policy,
    Set<String>? tags,
    int parallelism = 5,
    void Function(String key, PreloadStatus status, double progress)?
        onProgress,
  }) async {
    if (dataProviders.isEmpty) {
      _log.warning('No data providers specified for preloading');
      return {};
    }

    _log.info('Preloading ${dataProviders.length} items');

    // Create operations for each key
    final operations = <String, PreloadOperation>{};
    for (final key in dataProviders.keys) {
      final operation = PreloadOperation(key: key);
      operations[key] = operation;
      _operations[key] = operation;
      _preloadController.add(operation);
    }

    // Process in batches based on parallelism
    final keys = dataProviders.keys.toList();
    final totalItems = keys.length;
    var completedItems = 0;

    for (var i = 0; i < keys.length; i += parallelism) {
      final end =
          (i + parallelism < keys.length) ? i + parallelism : keys.length;
      final batch = keys.sublist(i, end);

      // Process batch in parallel
      final futures = <Future<void>>[];

      for (final key in batch) {
        futures.add(_preloadItem(
          key,
          dataProviders[key]!,
          operations[key]!,
          policy: policy,
          tags: tags,
          onProgress: (status) {
            completedItems++;
            final progress = completedItems / totalItems;
            onProgress?.call(key, status, progress);
          },
        ));
      }

      // Wait for all items in the batch to complete
      await Future.wait(futures);
    }

    _log.info('Preloading completed for ${dataProviders.length} items');
    return operations;
  }

  /// Preloads a single item into the cache.
  Future<void> _preloadItem<T>(
    String key,
    Future<T> Function() dataProvider,
    PreloadOperation operation, {
    CachePolicy? policy,
    Set<String>? tags,
    void Function(PreloadStatus status)? onProgress,
  }) async {
    try {
      operation.markInProgress();
      _preloadController.add(operation);

      _log.fine('Preloading item: $key');

      // Fetch the data
      final data = await dataProvider();

      // Store in cache
      await _cache.put(key, data, policy: policy, tags: tags);

      operation.markCompleted();
      _preloadController.add(operation);
      onProgress?.call(PreloadStatus.completed);

      _log.fine('Preloaded item: $key');
    } catch (e) {
      _log.warning('Failed to preload item: $key - $e');
      operation.markFailed(e);
      _preloadController.add(operation);
      onProgress?.call(PreloadStatus.failed);
    }
  }

  /// Preloads data into the cache in the background.
  ///
  /// This method returns immediately and performs the preloading in the background.
  /// The [dataProviders] parameter is a map where the keys are the cache keys and the values are
  /// functions that return the data to be cached.
  ///
  /// The [policy] parameter can be used to set a cache policy for all the data.
  /// The [tags] parameter can be used to associate tags with all the data.
  /// The [parallelism] parameter determines how many items to preload in parallel.
  /// The [onProgress] parameter is a callback that is called when an item is preloaded.
  ///
  /// Returns a stream of preload operations.
  Stream<PreloadOperation> preloadInBackground<T>({
    required Map<String, Future<T> Function()> dataProviders,
    CachePolicy? policy,
    Set<String>? tags,
    int parallelism = 5,
    void Function(String key, PreloadStatus status, double progress)?
        onProgress,
  }) {
    // Start preloading in the background
    preload(
      dataProviders: dataProviders,
      policy: policy,
      tags: tags,
      parallelism: parallelism,
      onProgress: onProgress,
    );

    // Return the stream of preload operations
    return preloadEvents;
  }

  /// Cancels a preloading operation.
  ///
  /// Returns true if the operation was cancelled, false if it was not found or already completed.
  bool cancelPreload(String key) {
    final operation = _operations[key];
    if (operation == null) {
      return false;
    }

    if (operation.status == PreloadStatus.notStarted ||
        operation.status == PreloadStatus.inProgress) {
      operation.markCancelled();
      _preloadController.add(operation);
      return true;
    }

    return false;
  }

  /// Cancels all preloading operations.
  ///
  /// Returns the number of operations that were cancelled.
  int cancelAllPreloads() {
    var count = 0;

    for (final key in _operations.keys) {
      if (cancelPreload(key)) {
        count++;
      }
    }

    return count;
  }

  /// Clears completed operations from the operations map.
  ///
  /// Returns the number of operations that were cleared.
  int clearCompletedOperations() {
    final keysToRemove = <String>[];

    for (final entry in _operations.entries) {
      if (entry.value.status == PreloadStatus.completed ||
          entry.value.status == PreloadStatus.failed ||
          entry.value.status == PreloadStatus.cancelled) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      _operations.remove(key);
    }

    return keysToRemove.length;
  }

  /// Disposes the preloader.
  void dispose() {
    cancelAllPreloads();
    _preloadController.close();
  }
}
