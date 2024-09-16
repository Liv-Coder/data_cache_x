// Importing the http package for making HTTP requests.
import 'package:http/http.dart' as http;

// Importing the dart:convert package for JSON encoding and decoding.
import 'dart:convert';

// Importing the CacheManager class for managing cached data.
import '../cache/cache_manager.dart';

// Importing custom exceptions related to caching.
import '../exceptions/cache_exceptions.dart';

// Importing the NetworkInfo class for checking network connectivity.
import 'network_info.dart';

// The ApiClient class is responsible for fetching data from the network and caching it.
class ApiClient {
  // The HTTP client used for making network requests.
  final http.Client _httpClient;

  // The CacheManager instance used for managing cached data.
  final CacheManager _cacheManager;

  // The NetworkInfo instance used for checking network connectivity.
  final NetworkInfo _networkInfo;

  // Constructor for initializing the ApiClient with the required dependencies.
  ApiClient(this._httpClient, this._cacheManager, this._networkInfo);

  // Fetches data from the given URL. If the device is online, it tries to fetch from the network.
  // If the network request fails or the device is offline, it fetches data from the cache.
  Future<dynamic> get(String url) async {
    // Check if the device is connected to the internet.
    if (await _networkInfo.isConnected) {
      try {
        // Try to fetch data from the network.
        return await _getFromNetwork(url);
      } catch (e) {
        // If network request fails, fetch data from the cache.
        return await _getFromCache(url);
      }
    } else {
      // If the device is offline, fetch data from the cache.
      return await _getFromCache(url);
    }
  }

  // Fetches data from the network for the given URL.
  // If the request is successful, the data is cached and returned.
  // If the request fails, an exception is thrown.
  Future<dynamic> _getFromNetwork(String url) async {
    // Make a GET request to the given URL.
    final response = await _httpClient.get(Uri.parse(url));
    // Check if the response status code is 200 (OK).
    if (response.statusCode == 200) {
      // Decode the JSON response body.
      final data = json.decode(response.body);
      // Cache the fetched data.
      await _cacheManager.cacheData(url, data);
      // Return the fetched data.
      return data;
    } else {
      // Throw an exception if the request fails.
      throw Exception('Failed to load data');
    }
  }

  // Fetches data from the cache for the given URL.
  // If the data is not found in the cache, an exception is thrown.
  Future<dynamic> _getFromCache(String url) async {
    try {
      // Try to get the cached data.
      return await _cacheManager.getData(url);
    } on CacheException {
      // Throw an exception if no cached data is available.
      throw OfflineDataNotFoundException('No cached data available for: $url');
    }
  }
}
