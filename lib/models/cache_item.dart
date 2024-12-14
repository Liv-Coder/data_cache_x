class CacheItem<T> {
  final T value;
  final DateTime? expiry;

  CacheItem({required this.value, this.expiry});

  bool get isExpired => expiry != null && DateTime.now().isAfter(expiry!);
}
