import 'package:hive/hive.dart';

/// Represents a single item in the cache.
///
/// The generic type parameter `T` represents the type of the value stored in the cache item.
///
/// Each cache item has a [value] and an optional [expiry] date and time.
class CacheItem<T> {
  /// The value stored in the cache item.
  @HiveField(0)
  final T value;

  /// The optional expiry date and time for the cache item.
  @HiveField(1)
  final DateTime? expiry;

  /// Creates a new instance of [CacheItem].
  ///
  /// The [value] parameter is required, while the [expiry] parameter is optional.
  CacheItem({required this.value, this.expiry});

  /// Checks if the cache item is expired.
  ///
  /// Returns `true` if the cache item has an expiry date and time that is in the past, `false` otherwise.
  bool get isExpired => expiry != null && DateTime.now().isAfter(expiry!);
}

// Example of a TypeAdapter for CacheItem<String>
class CacheItemStringAdapter extends TypeAdapter<CacheItem<String>> {
  @override
  // unique typeId for each specific type
  final int typeId = 1;

  @override
  CacheItem<String> read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CacheItem<String>(
      value: fields[0] as String,
      expiry: fields[1] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, CacheItem<String> obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.value)
      ..writeByte(1)
      ..write(obj.expiry);
  }
}
