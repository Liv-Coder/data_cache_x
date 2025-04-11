import 'dart:async';
import 'dart:developer';

import 'package:data_cache_x/adapters/cache_adapter.dart';

/// A class that handles background cleanup of expired cache items.
///
/// This implementation uses a simple Timer to periodically clean up expired items
/// instead of relying on workmanager, which has compatibility issues with newer Flutter versions.
class BackgroundCleanup {
  static Timer? _cleanupTimer;
  static bool _isRunning = false;

  /// Performs the cleanup operation.
  ///
  /// This function retrieves the [CacheAdapter] from the service locator and iterates through the keys in batches,
  /// deleting any expired cache items.
  static Future<bool> performCleanup(CacheAdapter cacheAdapter) async {
    if (_isRunning) return true; // Prevent concurrent runs

    _isRunning = true;
    try {
      const batchSize = 50;
      int offset = 0;

      while (true) {
        final keys =
            await cacheAdapter.getKeys(limit: batchSize, offset: offset);
        if (keys.isEmpty) {
          break;
        }

        for (final key in keys) {
          final cacheItem = await cacheAdapter.get(key);
          if (cacheItem != null && cacheItem.isExpired) {
            await cacheAdapter.delete(key);
          }
        }
        offset += batchSize;
      }
      return true;
    } catch (err) {
      log("Error in background cleanup: $err");
      return false;
    } finally {
      _isRunning = false;
    }
  }

  /// Initializes the background cleanup process.
  ///
  /// This function sets up a periodic timer that runs the cleanup operation.
  ///
  /// The frequency of the task can be configured using the [frequency] parameter.
  /// By default, it runs every hour.
  static void initializeBackgroundCleanup(
      {required CacheAdapter adapter, Duration? frequency}) {
    // Cancel any existing timer
    _cleanupTimer?.cancel();

    // Set up a new periodic timer
    _cleanupTimer = Timer.periodic(
      frequency ?? Duration(hours: 1),
      (_) => performCleanup(adapter),
    );
  }

  /// Stops the background cleanup process.
  static void stopBackgroundCleanup() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
  }
}
