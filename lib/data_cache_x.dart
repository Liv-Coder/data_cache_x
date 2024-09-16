// Importing the http package for making HTTP requests.
import 'package:http/http.dart' as http;

// Importing the connectivity_plus package for monitoring network connectivity.
import 'package:connectivity_plus/connectivity_plus.dart';

// Importing the CacheManager class for managing cached data.
import 'src/cache/cache_manager.dart';

// Importing the CachePolicy class for defining cache policies.
import 'src/cache/cache_policy.dart';

// Importing the ApiClient class for fetching data from the network and caching it.
import 'src/network/api_client.dart';

// Importing the NetworkInfo class for checking network connectivity.
import 'src/network/network_info.dart';

// The DataCacheX class provides a high-level API for caching and retrieving data.
class DataCacheX {
  // The ApiClient instance used for fetching data from the network and caching it.
  late final ApiClient _apiClient;

  // The NetworkInfo instance used for checking network connectivity.
  late final NetworkInfo _networkInfo;

  // Constructor for initializing the DataCacheX with the required dependencies.
  // The [expirationDuration] parameter specifies the duration for which cached data is valid.
  DataCacheX({Duration expirationDuration = const Duration(hours: 1)}) {
    // Create a TimedExpirationCachePolicy with the specified expiration duration.
    final cachePolicy = TimedExpirationCachePolicy(expirationDuration);

    // Create a CacheManager with the specified cache policy.
    final cacheManager = CacheManager(cachePolicy);

    // Create an HTTP client for making network requests.
    final httpClient = http.Client();

    // Create a Connectivity instance for monitoring network connectivity.
    final connectivity = Connectivity();

    // Initialize the NetworkInfo instance with the Connectivity instance.
    _networkInfo = NetworkInfo(connectivity);

    // Initialize the ApiClient instance with the HTTP client, CacheManager, and NetworkInfo.
    _apiClient = ApiClient(httpClient, cacheManager, _networkInfo);
  }

  // Fetches data from the given URL. If the device is online, it tries to fetch from the network.
  // If the network request fails or the device is offline, it fetches data from the cache.
  Future<dynamic> getData(String url) async {
    return _apiClient.get(url);
  }

  // Checks if the device is connected to the internet.
  Future<bool> get isConnected => _networkInfo.isConnected;

  // A stream that emits connectivity changes.
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _networkInfo.onConnectivityChanged;
}
