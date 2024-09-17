import 'package:data_cache_x/domain/error/cache_execption.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cache_model.dart';

class LocalDataSource {
  Future<void> cacheData(CacheModel cacheModel) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(cacheModel.key, cacheModel.data);
  }

  Future<String?> getCachedData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> clearCache(String key) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(key)) {
      await prefs.remove(key);
    } else {
      throw NoCachedDataFoundException(
        message: 'No cached data found for key: $key',
      );
    }
  }
}
