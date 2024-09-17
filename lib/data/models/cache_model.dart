// lib/data/models/cache_model.dart
class CacheModel {
  final String key;
  final String data;

  CacheModel({
    required this.key,
    required this.data,
  });

  Map<String, dynamic> toJson() => {
        'key': key,
        'data': data,
      };

  static CacheModel fromJson(Map<String, dynamic> json) {
    return CacheModel(
      key: json['key'],
      data: json['data'],
    );
  }
}
