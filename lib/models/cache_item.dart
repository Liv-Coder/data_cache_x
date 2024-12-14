class CacheItem<T> {
  final T value;
  final DateTime? expiry;
  final Duration? slidingExpiry;

  CacheItem({required this.value, this.expiry, this.slidingExpiry});

  bool get isExpired => expiry != null && DateTime.now().isAfter(expiry!);

  CacheItem<T> updateExpiry() {
    if (slidingExpiry == null) {
      return this;
    }
    return CacheItem(
        value: value,
        expiry: DateTime.now().add(slidingExpiry!),
        slidingExpiry: slidingExpiry);
  }
}
