class CacheModel {
  final String key;
  final String data;
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
      'data': data,
      'expirationDuration':
          expirationDuration.inMilliseconds, // Convert to milliseconds
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'isCompressed': isCompressed ? 1 : 0,
    };
  }

  factory CacheModel.fromMap(Map<String, dynamic> map) {
    return CacheModel(
      key: map['key'],
      data: map['data'],
      expirationDuration: Duration(
          milliseconds: map['expirationDuration']), // Convert to Duration
      isCompressed: map['isCompressed'] == 1,
    );
  }
}
