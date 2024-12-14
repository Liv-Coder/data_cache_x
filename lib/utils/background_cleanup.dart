import 'package:data_cache_x/adapters/hive/hive_adapter.dart';
import 'package:workmanager/workmanager.dart';
import '../service_locator.dart';

/// The unique name for the background cleanup task.
const cleanupTaskName = "com.vishwasaraxit.data_cache_x.cleanup";

/// The callback dispatcher for the workmanager.
///
/// This function is executed by the workmanager in the background.
/// It retrieves the [HiveAdapter] from the service locator and iterates through the keys,
/// deleting any expired cache items.
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == cleanupTaskName) {
      try {
        // Get the HiveAdapter from the service locator (make sure setup() has been called)
        final hiveAdapter = getIt<HiveAdapter<String>>();

        // Iterate through the keys and delete expired items
        final keys = hiveAdapter.keys();
        for (final key in keys) {
          final cacheItem = await hiveAdapter.get(key);
          if (cacheItem != null && cacheItem.isExpired) {
            await hiveAdapter.delete(key);
          }
        }
      } catch (err) {
        return Future.value(false); // Indicate task failure
      }
    }
    return Future.value(true); // Indicate task success
  });
}

/// Initializes the background cleanup process.
///
/// This function initializes the workmanager and registers a periodic task
/// that runs the [callbackDispatcher] function.
///
/// The frequency of the task can be configured using the [registerPeriodicTask] method.
/// By default, it runs every hour.
void initializeBackgroundCleanup() {
  Workmanager().initialize(
    callbackDispatcher,
    // Set the flag to true if you want to see the logs
    isInDebugMode: false,
  );

  // Register a periodic task (e.g., run every hour)
  Workmanager().registerPeriodicTask(
    cleanupTaskName,
    cleanupTaskName,
    frequency: Duration(hours: 1),
  );
}
