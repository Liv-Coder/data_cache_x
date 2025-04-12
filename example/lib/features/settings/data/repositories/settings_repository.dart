import 'package:data_cache_x/data_cache_x.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cache_settings.dart';

class SettingsRepository {
  final DataCacheX _cache;
  final SharedPreferences _prefs;

  static const String _cleanupFrequencyKey = 'cleanup_frequency_minutes';
  static const String _maxItemsKey = 'max_items';
  static const String _defaultExpiryKey = 'default_expiry_minutes';
  static const String _defaultCompressionKey = 'default_compression';
  static const String _defaultPriorityKey = 'default_priority';
  static const String _encryptionEnabledKey = 'encryption_enabled';
  static const String _evictionStrategyKey = 'eviction_strategy';

  SettingsRepository({
    DataCacheX? cache,
    SharedPreferences? prefs,
  })  : _cache = cache ?? GetIt.I<DataCacheX>(),
        _prefs = prefs ?? GetIt.I<SharedPreferences>();

  /// Gets the current cache settings
  Future<CacheSettings> getSettings() async {
    final cleanupFrequency = Duration(
      minutes: _prefs.getInt(_cleanupFrequencyKey) ?? 30,
    );

    final maxItems = _prefs.getInt(_maxItemsKey) ?? 1000;

    final defaultExpiry = Duration(
      minutes: _prefs.getInt(_defaultExpiryKey) ?? 60,
    );

    final defaultCompressionString =
        _prefs.getString(_defaultCompressionKey) ?? 'auto';
    final defaultCompression = _parseCompressionMode(defaultCompressionString);

    final defaultPriorityString =
        _prefs.getString(_defaultPriorityKey) ?? 'normal';
    final defaultPriority = _parseCachePriority(defaultPriorityString);

    final encryptionEnabled = _prefs.getBool(_encryptionEnabledKey) ?? false;

    final evictionStrategyString =
        _prefs.getString(_evictionStrategyKey) ?? 'lru';
    final evictionStrategy = _parseEvictionStrategy(evictionStrategyString);

    return CacheSettings(
      cleanupFrequency: cleanupFrequency,
      maxItems: maxItems,
      defaultExpiry: defaultExpiry,
      defaultCompression: defaultCompression,
      defaultPriority: defaultPriority,
      encryptionEnabled: encryptionEnabled,
      evictionStrategy: evictionStrategy,
    );
  }

  /// Saves the cache settings
  Future<void> saveSettings(CacheSettings settings) async {
    await _prefs.setInt(
      _cleanupFrequencyKey,
      settings.cleanupFrequency.inMinutes,
    );

    await _prefs.setInt(
      _maxItemsKey,
      settings.maxItems,
    );

    await _prefs.setInt(
      _defaultExpiryKey,
      settings.defaultExpiry.inMinutes,
    );

    await _prefs.setString(
      _defaultCompressionKey,
      _compressionModeToString(settings.defaultCompression),
    );

    await _prefs.setString(
      _defaultPriorityKey,
      _cachePriorityToString(settings.defaultPriority),
    );

    await _prefs.setBool(
      _encryptionEnabledKey,
      settings.encryptionEnabled,
    );

    await _prefs.setString(
      _evictionStrategyKey,
      _evictionStrategyToString(settings.evictionStrategy),
    );
  }

  /// Applies the settings to the cache
  Future<void> applySettings(CacheSettings settings) async {
    // Some settings can only be applied when initializing the cache
    // For demonstration purposes, we'll just save the settings
    await saveSettings(settings);

    // In a real app, you would need to reinitialize the cache with the new settings
    // This would typically involve calling a method like:
    // await setupDataCacheX(
    //   adapterType: CacheAdapterType.hive,
    //   cleanupFrequency: settings.cleanupFrequency,
    //   maxItems: settings.maxItems,
    //   evictionStrategy: settings.evictionStrategy,
    //   encrypt: settings.encryptionEnabled,
    // );

    // And then updating the default policy:
    // Note: defaultPolicy is a const and can't be reassigned at runtime
    // This is just for demonstration purposes
    // CachePolicy.defaultPolicy = CachePolicy(
    //   expiry: settings.defaultExpiry,
    //   priority: settings.defaultPriority,
    //   compression: settings.defaultCompression,
    // );
  }

  /// Resets the cache settings to default values
  Future<void> resetSettings() async {
    await _prefs.remove(_cleanupFrequencyKey);
    await _prefs.remove(_maxItemsKey);
    await _prefs.remove(_defaultExpiryKey);
    await _prefs.remove(_defaultCompressionKey);
    await _prefs.remove(_defaultPriorityKey);
    await _prefs.remove(_encryptionEnabledKey);
    await _prefs.remove(_evictionStrategyKey);
  }

  /// Gets the current cache metrics
  Future<Map<String, dynamic>> getCacheMetrics() async {
    return {
      'hitCount': _cache.hitCount,
      'missCount': _cache.missCount,
      'hitRate': _cache.hitRate,
      'totalSize': _cache.totalSize,
      'averageItemSize': _cache.averageItemSize,
    };
  }

  /// Resets the cache metrics
  Future<void> resetMetrics() async {
    _cache.resetMetrics();
  }

  /// Clears the cache
  Future<void> clearCache() async {
    await _cache.clear();
  }

  // Helper methods for parsing enums
  CompressionMode _parseCompressionMode(String value) {
    switch (value) {
      case 'auto':
        return CompressionMode.auto;
      case 'always':
        return CompressionMode.always;
      case 'never':
        return CompressionMode.never;
      default:
        return CompressionMode.auto;
    }
  }

  String _compressionModeToString(CompressionMode mode) {
    switch (mode) {
      case CompressionMode.auto:
        return 'auto';
      case CompressionMode.always:
        return 'always';
      case CompressionMode.never:
        return 'never';
    }
  }

  CachePriority _parseCachePriority(String value) {
    switch (value) {
      case 'low':
        return CachePriority.low;
      case 'normal':
        return CachePriority.normal;
      case 'high':
        return CachePriority.high;
      case 'critical':
        return CachePriority.critical;
      default:
        return CachePriority.normal;
    }
  }

  String _cachePriorityToString(CachePriority priority) {
    switch (priority) {
      case CachePriority.low:
        return 'low';
      case CachePriority.normal:
        return 'normal';
      case CachePriority.high:
        return 'high';
      case CachePriority.critical:
        return 'critical';
    }
  }

  EvictionStrategy _parseEvictionStrategy(String value) {
    switch (value) {
      case 'lru':
        return EvictionStrategy.lru;
      case 'lfu':
        return EvictionStrategy.lfu;
      case 'fifo':
        return EvictionStrategy.fifo;
      default:
        return EvictionStrategy.lru;
    }
  }

  String _evictionStrategyToString(EvictionStrategy strategy) {
    switch (strategy) {
      case EvictionStrategy.lru:
        return 'lru';
      case EvictionStrategy.lfu:
        return 'lfu';
      case EvictionStrategy.fifo:
        return 'fifo';
      case EvictionStrategy.ttl:
        return 'ttl';
    }
  }
}
