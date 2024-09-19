class CacheEntity {
  final String key;
  final String data;
  final int expirationDuration;

  CacheEntity({
    required this.key,
    required this.data,
    required this.expirationDuration,
  });
}
