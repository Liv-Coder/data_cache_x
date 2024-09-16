// lib/src/exceptions/cache_exceptions.dart

class CacheException implements Exception {
  final String message;
  CacheException(this.message);
}

class CacheEntryNotFoundException extends CacheException {
  CacheEntryNotFoundException(super.message);
}

class CacheEntryExpiredException extends CacheException {
  CacheEntryExpiredException(super.message);
}

class OfflineDataNotFoundException extends CacheException {
  OfflineDataNotFoundException(super.message);
}
