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

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'expiry': expiry?.toIso8601String(),
      'slidingExpiry': slidingExpiry?.inSeconds,
    };
  }

  factory CacheItem.fromJson(Map<String, dynamic> json) {
    return CacheItem<T>(
      value: json['value'] as T,
      expiry: json['expiry'] != null ? DateTime.parse(json['expiry']) : null,
      slidingExpiry: json['slidingExpiry'] != null
          ? Duration(seconds: json['slidingExpiry'])
          : null,
    );
  }
}
