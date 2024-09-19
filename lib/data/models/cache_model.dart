class CacheModel {
  final String key;
  final String data;
  final Duration expirationDuration; // in milliseconds
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
      'expirationDuration': expirationDuration,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'isCompressed': isCompressed ? 1 : 0,
    };
  }

  factory CacheModel.fromMap(Map<String, dynamic> map) {
    return CacheModel(
      key: map['key'],
      data: map['data'],
      expirationDuration: map['expirationDuration'],
      isCompressed: map['isCompressed'] == 1,
    );
  }
}
