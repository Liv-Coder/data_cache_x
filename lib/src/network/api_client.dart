import 'package:http/http.dart' as http;
import 'dart:convert';
import '../cache/cache_manager.dart';
import '../exceptions/cache_exceptions.dart';

class ApiClient {
  final http.Client _httpClient;
  final CacheManager _cacheManager;

  ApiClient(this._httpClient, this._cacheManager);

  Future<dynamic> get(String url) async {
    try {
      final cachedData = await _cacheManager.getData(url);
      return cachedData;
    } on CacheEntryNotFoundException {
      final response = await _httpClient.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _cacheManager.cacheData(url, data);
        return data;
      } else {
        throw Exception('Failed to load data');
      }
    } on CacheEntryExpiredException {
      final response = await _httpClient.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _cacheManager.cacheData(url, data);
        return data;
      } else {
        throw Exception('Failed to load data');
      }
    }
  }
}
