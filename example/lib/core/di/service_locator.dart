import 'package:data_cache_x/data_cache_x.dart';
import 'package:data_cache_x/service_locator.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

final getIt = GetIt.instance;

/// Sets up the service locator for the application.
/// This initializes all the dependencies needed for the app.
Future<void> setupServiceLocator() async {
  // Initialize data_cache_x with memory adapter for simplicity
  // This avoids potential serialization issues during development
  await setupDataCacheX(
    adapterType: CacheAdapterType.memory,
    cleanupFrequency: const Duration(minutes: 30),
  );

  // Register DataCacheX instance from the package's service locator
  if (!getIt.isRegistered<DataCacheX>()) {
    getIt.registerSingleton<DataCacheX>(GetIt.I<DataCacheX>());
  }

  // Register HTTP client
  getIt.registerLazySingleton<http.Client>(() => http.Client());
}
