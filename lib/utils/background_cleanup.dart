import 'package:data_cache_x/adapters/hive/hive_adapter.dart';
import 'package:workmanager/workmanager.dart';
import '../service_locator.dart';

// Unique Task Name
const cleanupTaskName = "com.vishwasaraxit.data_cache_x.cleanup";

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == cleanupTaskName) {
      try {
        // Get the HiveAdapter from the service locator (make sure setup() has been called)
        final hiveAdapter = getIt<HiveAdapter>();

        // Iterate through the keys and delete expired items
        final keys = hiveAdapter.keys();
        for (final key in keys) {
          final cacheItem = await hiveAdapter.get(key);
          if (cacheItem != null && cacheItem.isExpired) {
            await hiveAdapter.delete(key);
            print("Deleted expired item with key: $key");
          }
        }
      } catch (err) {
        print("Error during background cleanup: $err");
        return Future.value(false); // Indicate task failure
      }
    }
    return Future.value(true); // Indicate task success
  });
}

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
