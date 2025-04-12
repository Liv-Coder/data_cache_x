import 'package:data_cache_x/data_cache_x.dart';
import 'package:get_it/get_it.dart';

class AnalyticsRepository {
  final DataCacheX _cache;

  AnalyticsRepository({DataCacheX? cache}) : _cache = cache ?? GetIt.I<DataCacheX>();

  /// Gets the current cache analytics summary
  Map<String, dynamic> getAnalyticsSummary() {
    return _cache.getAnalyticsSummary();
  }

  /// Gets the hit rate as a percentage
  double getHitRate() {
    final summary = getAnalyticsSummary();
    final hitCount = summary['hitCount'] as int;
    final missCount = summary['missCount'] as int;
    
    if (hitCount + missCount == 0) {
      return 0.0;
    }
    
    return (hitCount / (hitCount + missCount)) * 100;
  }

  /// Gets the total cache size in bytes
  int getTotalSize() {
    final summary = getAnalyticsSummary();
    return summary['totalSize'] as int;
  }

  /// Gets the most frequently accessed keys
  List<Map<String, dynamic>> getMostFrequentlyAccessedKeys() {
    final summary = getAnalyticsSummary();
    return (summary['mostFrequentlyAccessedKeys'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
  }

  /// Gets the most recently accessed keys
  List<Map<String, dynamic>> getMostRecentlyAccessedKeys() {
    final summary = getAnalyticsSummary();
    return (summary['mostRecentlyAccessedKeys'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
  }

  /// Gets the largest items in the cache
  List<Map<String, dynamic>> getLargestItems() {
    final summary = getAnalyticsSummary();
    return (summary['largestItems'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
  }

  /// Resets the analytics metrics
  void resetMetrics() {
    _cache.resetMetrics();
  }

  /// Generates sample data for testing
  Future<void> generateSampleData() async {
    // Generate some cache operations to have data to display
    for (int i = 0; i < 20; i++) {
      final key = 'sample_key_$i';
      final value = 'sample_value_$i' * (i + 1); // Different sizes
      
      // Put the value in cache
      await _cache.put(key, value);
      
      // Access some keys multiple times to generate hits
      if (i % 3 == 0) {
        await _cache.get(key);
        await _cache.get(key);
      } else if (i % 5 == 0) {
        await _cache.get(key);
      }
      
      // Generate some misses
      await _cache.get('non_existent_key_$i');
    }
  }
}
