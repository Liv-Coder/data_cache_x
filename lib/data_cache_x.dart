library data_cache_x;

import 'package:http/http.dart' as http;
import 'src/cache/cache_manager.dart';
import 'src/cache/cache_policy.dart';
import 'src/network/api_client.dart';

class DataCacheX {
  late final ApiClient _apiClient;

  DataCacheX({Duration expirationDuration = const Duration(hours: 1)}) {
    final cachePolicy = TimedExpirationCachePolicy(expirationDuration);
    final cacheManager = CacheManager(cachePolicy);
    final httpClient = http.Client();
    _apiClient = ApiClient(httpClient, cacheManager);
  }

  Future<dynamic> getData(String url) async {
    return _apiClient.get(url);
  }
}
