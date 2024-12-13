import 'package:hive/hive.dart';

part 'cache_item.g.dart';

@HiveType(typeId: 0)
class CacheItem {
  @HiveField(0)
  final dynamic value;

  @HiveField(1)
  final DateTime? expiry;

  CacheItem({required this.value, this.expiry});

  bool get isExpired => expiry != null && DateTime.now().isAfter(expiry!);
}
