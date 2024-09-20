import 'dart:convert';

class CacheModel {
  final String key;
  final dynamic data;
  final Duration expirationDuration;
  bool isCompressed;

  CacheModel({
    required this.key,
    required this.data,
    required this.expirationDuration,
    this.isCompressed = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'data': jsonEncode(data),
      'expirationDuration': expirationDuration.inMilliseconds,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'isCompressed': isCompressed ? 1 : 0,
    };
  }

  factory CacheModel.fromMap(Map<String, dynamic> map) {
    return CacheModel(
      key: map['key'],
      data: jsonDecode(map['data']),
      expirationDuration: Duration(milliseconds: map['expirationDuration']),
      isCompressed: map['isCompressed'] == 1,
    );
  }
}
