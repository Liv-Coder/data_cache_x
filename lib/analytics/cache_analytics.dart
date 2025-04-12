import 'dart:collection';

/// A class that tracks and provides analytics for cache operations.
class CacheAnalytics {
  /// The total number of cache hits.
  int _hitCount = 0;

  /// The total number of cache misses.
  int _missCount = 0;

  /// The total number of cache puts.
  int _putCount = 0;

  /// The total number of cache deletes.
  int _deleteCount = 0;

  /// The total number of cache clears.
  int _clearCount = 0;

  /// The total size of all items in the cache (estimated).
  int _totalSize = 0;

  /// The maximum size observed in the cache.
  int _maxSize = 0;

  /// The time when the analytics tracking started.
  final DateTime _startTime = DateTime.now();

  /// A map of key to access count.
  final Map<String, int> _keyAccessCount = {};

  /// A map of key to last access time.
  final Map<String, DateTime> _keyLastAccessTime = {};

  /// A map of key to estimated size.
  final Map<String, int> _keySizeMap = {};

  /// A queue of recent operations for detailed analysis.
  final Queue<CacheOperation> _recentOperations = Queue();

  /// The maximum number of recent operations to track.
  final int _maxRecentOperations;

  /// Creates a new instance of [CacheAnalytics].
  CacheAnalytics({int maxRecentOperations = 100})
      : _maxRecentOperations = maxRecentOperations;

  /// Gets the total number of cache hits.
  int get hitCount => _hitCount;

  /// Gets the total number of cache misses.
  int get missCount => _missCount;

  /// Gets the total number of cache operations (hits + misses).
  int get totalOperations => _hitCount + _missCount;

  /// Gets the cache hit rate (hits / total operations).
  double get hitRate {
    if (totalOperations == 0) return 0;
    return _hitCount / totalOperations;
  }

  /// Gets the total number of cache puts.
  int get putCount => _putCount;

  /// Gets the total number of cache deletes.
  int get deleteCount => _deleteCount;

  /// Gets the total number of cache clears.
  int get clearCount => _clearCount;

  /// Gets the total size of all items in the cache (estimated).
  int get totalSize => _totalSize;

  /// Gets the maximum size observed in the cache.
  int get maxSize => _maxSize;

  /// Gets the average size of items in the cache.
  double get averageItemSize {
    if (_keySizeMap.isEmpty) return 0;
    return _totalSize / _keySizeMap.length;
  }

  /// Gets the time when the analytics tracking started.
  DateTime get startTime => _startTime;

  /// Gets the duration since the analytics tracking started.
  Duration get uptime => DateTime.now().difference(_startTime);

  /// Gets the most frequently accessed keys.
  List<MapEntry<String, int>> get mostFrequentlyAccessedKeys {
    final entries = _keyAccessCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(10).toList();
  }

  /// Gets the most recently accessed keys.
  List<MapEntry<String, DateTime>> get mostRecentlyAccessedKeys {
    final entries = _keyLastAccessTime.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(10).toList();
  }

  /// Gets the largest items in the cache.
  List<MapEntry<String, int>> get largestItems {
    final entries = _keySizeMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(10).toList();
  }

  /// Gets the recent operations for detailed analysis.
  List<CacheOperation> get recentOperations => _recentOperations.toList();

  /// Records a cache hit for the given key.
  void recordHit(String key) {
    _hitCount++;
    _recordAccess(key);
    _addOperation(CacheOperationType.hit, key);
  }

  /// Records a cache miss for the given key.
  void recordMiss(String key) {
    _missCount++;
    _addOperation(CacheOperationType.miss, key);
  }

  /// Records a cache put for the given key with the estimated size.
  void recordPut(String key, int estimatedSize) {
    _putCount++;
    _updateSize(key, estimatedSize);
    _addOperation(CacheOperationType.put, key, size: estimatedSize);
  }

  /// Records a cache delete for the given key.
  void recordDelete(String key) {
    _deleteCount++;
    _removeSize(key);
    _addOperation(CacheOperationType.delete, key);
  }

  /// Records a cache clear.
  void recordClear() {
    _clearCount++;
    _totalSize = 0;
    _keySizeMap.clear();
    _addOperation(CacheOperationType.clear, '');
  }

  /// Records an access to the given key.
  void _recordAccess(String key) {
    _keyAccessCount[key] = (_keyAccessCount[key] ?? 0) + 1;
    _keyLastAccessTime[key] = DateTime.now();
  }

  /// Updates the size of the given key.
  void _updateSize(String key, int size) {
    final oldSize = _keySizeMap[key] ?? 0;
    _totalSize = _totalSize - oldSize + size;
    _keySizeMap[key] = size;
    
    if (_totalSize > _maxSize) {
      _maxSize = _totalSize;
    }
  }

  /// Removes the size of the given key.
  void _removeSize(String key) {
    final size = _keySizeMap[key] ?? 0;
    _totalSize -= size;
    _keySizeMap.remove(key);
  }

  /// Adds an operation to the recent operations queue.
  void _addOperation(CacheOperationType type, String key, {int? size}) {
    final operation = CacheOperation(
      type: type,
      key: key,
      timestamp: DateTime.now(),
      size: size,
    );
    
    _recentOperations.add(operation);
    
    while (_recentOperations.length > _maxRecentOperations) {
      _recentOperations.removeFirst();
    }
  }

  /// Resets all analytics data.
  void reset() {
    _hitCount = 0;
    _missCount = 0;
    _putCount = 0;
    _deleteCount = 0;
    _clearCount = 0;
    _totalSize = 0;
    _maxSize = 0;
    _keyAccessCount.clear();
    _keyLastAccessTime.clear();
    _keySizeMap.clear();
    _recentOperations.clear();
  }

  /// Gets a summary of the cache analytics.
  Map<String, dynamic> getSummary() {
    return {
      'hitCount': _hitCount,
      'missCount': _missCount,
      'hitRate': hitRate,
      'putCount': _putCount,
      'deleteCount': _deleteCount,
      'clearCount': _clearCount,
      'totalSize': _totalSize,
      'maxSize': _maxSize,
      'averageItemSize': averageItemSize,
      'itemCount': _keySizeMap.length,
      'uptime': uptime.toString(),
      'mostFrequentlyAccessedKeys': mostFrequentlyAccessedKeys
          .map((e) => {'key': e.key, 'accessCount': e.value})
          .toList(),
      'mostRecentlyAccessedKeys': mostRecentlyAccessedKeys
          .map((e) => {
                'key': e.key,
                'lastAccessTime': e.value.toIso8601String(),
              })
          .toList(),
      'largestItems': largestItems
          .map((e) => {'key': e.key, 'size': e.value})
          .toList(),
    };
  }
}

/// The type of cache operation.
enum CacheOperationType {
  /// A cache hit.
  hit,

  /// A cache miss.
  miss,

  /// A cache put.
  put,

  /// A cache delete.
  delete,

  /// A cache clear.
  clear,
}

/// A class that represents a cache operation.
class CacheOperation {
  /// The type of operation.
  final CacheOperationType type;

  /// The key involved in the operation.
  final String key;

  /// The timestamp of the operation.
  final DateTime timestamp;

  /// The size of the item involved in the operation (for put operations).
  final int? size;

  /// Creates a new instance of [CacheOperation].
  CacheOperation({
    required this.type,
    required this.key,
    required this.timestamp,
    this.size,
  });

  @override
  String toString() {
    return 'CacheOperation{type: $type, key: $key, timestamp: $timestamp, size: $size}';
  }
}

/// A class that provides analytics for a specific time period.
class CacheAnalyticsPeriod {
  /// The start time of the period.
  final DateTime startTime;

  /// The end time of the period.
  final DateTime endTime;

  /// The number of cache hits during the period.
  final int hitCount;

  /// The number of cache misses during the period.
  final int missCount;

  /// The number of cache puts during the period.
  final int putCount;

  /// The number of cache deletes during the period.
  final int deleteCount;

  /// The number of cache clears during the period.
  final int clearCount;

  /// Creates a new instance of [CacheAnalyticsPeriod].
  CacheAnalyticsPeriod({
    required this.startTime,
    required this.endTime,
    required this.hitCount,
    required this.missCount,
    required this.putCount,
    required this.deleteCount,
    required this.clearCount,
  });

  /// Gets the total number of cache operations during the period.
  int get totalOperations => hitCount + missCount;

  /// Gets the cache hit rate during the period.
  double get hitRate {
    if (totalOperations == 0) return 0;
    return hitCount / totalOperations;
  }

  /// Gets the duration of the period.
  Duration get duration => endTime.difference(startTime);

  /// Gets the operations per second during the period.
  double get operationsPerSecond {
    final seconds = duration.inMilliseconds / 1000;
    if (seconds == 0) return 0;
    return totalOperations / seconds;
  }

  @override
  String toString() {
    return 'CacheAnalyticsPeriod{'
        'startTime: $startTime, '
        'endTime: $endTime, '
        'hitCount: $hitCount, '
        'missCount: $missCount, '
        'hitRate: $hitRate, '
        'putCount: $putCount, '
        'deleteCount: $deleteCount, '
        'clearCount: $clearCount, '
        'operationsPerSecond: $operationsPerSecond'
        '}';
  }
}
