import 'package:data_cache_x/data_cache_x.dart';

class CacheEntry {
  final String key;
  final int size;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final DateTime lastAccessedAt;
  final int accessCount;
  final CachePriority priority;
  final bool isCompressed;
  final bool isEncrypted;
  final Set<String> tags;

  CacheEntry({
    required this.key,
    required this.size,
    required this.createdAt,
    this.expiresAt,
    required this.lastAccessedAt,
    required this.accessCount,
    required this.priority,
    required this.isCompressed,
    required this.isEncrypted,
    this.tags = const {},
  });

  String get priorityString {
    switch (priority) {
      case CachePriority.low:
        return 'Low';
      case CachePriority.normal:
        return 'Normal';
      case CachePriority.high:
        return 'High';
      case CachePriority.critical:
        return 'Critical';
    }
  }

  String get formattedSize {
    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  String get timeToExpiry {
    if (expiresAt == null) {
      return 'Never';
    }

    final now = DateTime.now();
    if (expiresAt!.isBefore(now)) {
      return 'Expired';
    }

    final difference = expiresAt!.difference(now);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ${difference.inHours % 24}h';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ${difference.inSeconds % 60}s';
    } else {
      return '${difference.inSeconds}s';
    }
  }
}
