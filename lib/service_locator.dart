import 'package:data_cache_x/adapters/hive/hive_adapter.dart';
import 'package:data_cache_x/core/data_cache_x.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> setupDataCacheX() async {
  // Register HiveAdapter
  final hiveAdapter = HiveAdapter();
  await hiveAdapter.init();
  getIt.registerSingleton<HiveAdapter>(hiveAdapter);

  // Register DataCache, injecting the HiveAdapter
  getIt.registerSingleton<DataCacheX>(DataCacheX(getIt<HiveAdapter>()));
}
