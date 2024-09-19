/// Exception thrown when there is an issue with caching data.
class CacheException implements Exception {
  /// The error message associated with the exception.
  final String message;

  /// Creates a new [CacheException] with the given error [message].
  CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}

/// Exception thrown when no cached data is found.
class NoCachedDataFoundException extends CacheException {
  /// Creates a new [NoCachedDataFoundException] with the given error [message].
  NoCachedDataFoundException({required super.message});

  @override
  String toString() => 'NoCachedDataException: $message';
}

// Exception thrown when Handleing Json data.
class JsonParsingException extends CacheException {
  /// Creates a new [JsonParsingException] with the given error [message].
  JsonParsingException({required super.message});

  @override
  String toString() => 'JsonParsingException: $message';
}
