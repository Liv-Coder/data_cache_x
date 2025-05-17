import 'package:data_cache_x/models/cache_policy.dart';

/// A class that holds data for batch processing in isolates.
class BatchProcessData<T> {
  /// The entries to process.
  final Map<String, T> entries;

  /// The cache policy to apply.
  final CachePolicy policy;

  /// The expiry duration.
  final Duration? expiry;

  /// The sliding expiry duration.
  final Duration? slidingExpiry;

  /// The tags to associate with the entries.
  final Set<String>? tags;

  /// Creates a new instance of [BatchProcessData].
  BatchProcessData({
    required this.entries,
    required this.policy,
    this.expiry,
    this.slidingExpiry,
    this.tags,
  });
}
