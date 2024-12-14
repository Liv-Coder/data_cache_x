import 'package:data_cache_x/adapters/hive/hive_adapter.dart';
import 'package:data_cache_x/core/data_cache_x.dart';
import 'package:data_cache_x/models/cache_item.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> setupDataCacheX() async {
  // Register HiveAdapter with CacheItemStringAdapter
  final hiveAdapter = HiveAdapter<String>(CacheItemStringAdapter());
  await hiveAdapter.init();
  getIt.registerSingleton<HiveAdapter<String>>(hiveAdapter);

  // Register DataCache, injecting the HiveAdapter
  getIt.registerSingleton<DataCacheX<String>>(
    DataCacheX<String>(getIt<HiveAdapter<String>>()),
  );
}
