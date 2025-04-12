import 'package:data_cache_x/data_cache_x.dart';

class CacheSettings {
  final Duration cleanupFrequency;
  final int maxItems;
  final Duration defaultExpiry;
  final CompressionMode defaultCompression;
  final CachePriority defaultPriority;
  final bool encryptionEnabled;
  final EvictionStrategy evictionStrategy;

  const CacheSettings({
    required this.cleanupFrequency,
    required this.maxItems,
    required this.defaultExpiry,
    required this.defaultCompression,
    required this.defaultPriority,
    required this.encryptionEnabled,
    required this.evictionStrategy,
  });

  /// Creates a copy of this settings object with the given fields replaced with the new values
  CacheSettings copyWith({
    Duration? cleanupFrequency,
    int? maxItems,
    Duration? defaultExpiry,
    CompressionMode? defaultCompression,
    CachePriority? defaultPriority,
    bool? encryptionEnabled,
    EvictionStrategy? evictionStrategy,
  }) {
    return CacheSettings(
      cleanupFrequency: cleanupFrequency ?? this.cleanupFrequency,
      maxItems: maxItems ?? this.maxItems,
      defaultExpiry: defaultExpiry ?? this.defaultExpiry,
      defaultCompression: defaultCompression ?? this.defaultCompression,
      defaultPriority: defaultPriority ?? this.defaultPriority,
      encryptionEnabled: encryptionEnabled ?? this.encryptionEnabled,
      evictionStrategy: evictionStrategy ?? this.evictionStrategy,
    );
  }

  /// Creates default settings
  factory CacheSettings.defaults() {
    return const CacheSettings(
      cleanupFrequency: Duration(minutes: 30),
      maxItems: 1000,
      defaultExpiry: Duration(minutes: 60),
      defaultCompression: CompressionMode.auto,
      defaultPriority: CachePriority.normal,
      encryptionEnabled: false,
      evictionStrategy: EvictionStrategy.lru,
    );
  }
}
