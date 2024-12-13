class DataCacheXException implements Exception {
  final String message;
  DataCacheXException(this.message);

  @override
  String toString() => 'DataStoreException: $message';
}

class KeyNotFoundException implements Exception {
  final String message;
  KeyNotFoundException(this.message);

  @override
  String toString() => 'KeyNotFoundException: $message';
}

class DataTypeMismatchException implements Exception {
  final String message;
  DataTypeMismatchException(this.message);

  @override
  String toString() => 'DataTypeMismatchException: $message';
}

class StorageException implements Exception {
  final String message;
  StorageException(this.message);

  @override
  String toString() => 'StorageException: $message';
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}
