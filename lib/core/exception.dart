/// A base class for exceptions related to data store operations.
class DataCacheXException implements Exception {
  final String message;
  DataCacheXException(this.message);

  @override
  String toString() => 'DataStoreException: $message';
}

/// Thrown when a key is not found in the cache.
class KeyNotFoundException implements Exception {
  final String message;

  /// Creates a new instance of [KeyNotFoundException].
  ///
  /// The [message] parameter provides more details about the exception.
  KeyNotFoundException(this.message);

  @override
  String toString() => 'KeyNotFoundException: $message';
}

/// Thrown when there is a mismatch between the expected data type and the actual data type.
class DataTypeMismatchException implements Exception {
  final String message;

  /// Creates a new instance of [DataTypeMismatchException].
  ///
  /// The [message] parameter provides more details about the exception.
  DataTypeMismatchException(this.message);

  @override
  String toString() => 'DataTypeMismatchException: $message';
}

/// Thrown when there is an error with the underlying storage mechanism.
class StorageException implements Exception {
  final String message;

  /// Creates a new instance of [StorageException].
  ///
  /// The [message] parameter provides more details about the exception.
  StorageException(this.message);

  @override
  String toString() => 'StorageException: $message';
}

/// Thrown when there is a general error with the cache.
class CacheException implements Exception {
  final String message;

  /// Creates a new instance of [CacheException].
  ///
  /// The [message] parameter provides more details about the exception.
  CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}

/// Thrown when an adapter is not found in the registry.
class AdapterNotFoundException implements Exception {
  final String message;

  /// Creates a new instance of [AdapterNotFoundException].
  ///
  /// The [message] parameter provides more details about the exception.
  AdapterNotFoundException(this.message);

  @override
  String toString() => 'AdapterNotFoundException: $message';
}

/// Thrown when a serializer is not found in the registry.
class SerializerNotFoundException implements Exception {
  final String message;

  /// Creates a new instance of [SerializerNotFoundException].
  ///
  /// The [message] parameter provides more details about the exception.
  SerializerNotFoundException(this.message);

  @override
  String toString() => 'SerializerNotFoundException: $message';
}
