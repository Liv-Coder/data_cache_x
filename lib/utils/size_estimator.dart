import 'dart:convert';
import 'dart:typed_data';

/// A utility class for estimating the size of objects in memory.
///
/// This class provides more accurate size estimation than the simple
/// string length * 2 approach used in earlier versions.
class SizeEstimator {
  /// Estimates the size of an object in bytes.
  ///
  /// This method provides a more accurate estimation of the memory
  /// footprint of various Dart types.
  static int estimateSize(dynamic value) {
    if (value == null) {
      return 0;
    } else if (value is String) {
      // UTF-16 encoding (2 bytes per character)
      return value.length * 2;
    } else if (value is num) {
      // Numbers are typically 8 bytes (double) or 4 bytes (int)
      return value is double ? 8 : 4;
    } else if (value is bool) {
      // Booleans are typically 1 byte
      return 1;
    } else if (value is DateTime) {
      // DateTime is typically 8 bytes (64-bit timestamp)
      return 8;
    } else if (value is List) {
      // For lists, estimate the size of each element plus overhead
      int size = 16; // List overhead
      for (var item in value) {
        size += estimateSize(item);
      }
      return size;
    } else if (value is Map) {
      // For maps, estimate the size of each key-value pair plus overhead
      int size = 32; // Map overhead
      for (var entry in value.entries) {
        size += estimateSize(entry.key) + estimateSize(entry.value);
      }
      return size;
    } else if (value is Set) {
      // For sets, estimate the size of each element plus overhead
      int size = 16; // Set overhead
      for (var item in value) {
        size += estimateSize(item);
      }
      return size;
    } else if (value is Uint8List || value is Int8List) {
      // For byte arrays, each element is 1 byte
      return value.length;
    } else if (value is Uint16List || value is Int16List) {
      // For 16-bit arrays, each element is 2 bytes
      return value.length * 2;
    } else if (value is Uint32List || value is Int32List || value is Float32List) {
      // For 32-bit arrays, each element is 4 bytes
      return value.length * 4;
    } else if (value is Uint64List || value is Int64List || value is Float64List) {
      // For 64-bit arrays, each element is 8 bytes
      return value.length * 8;
    } else {
      // For other objects, serialize to JSON and measure
      try {
        final jsonString = jsonEncode(value);
        return jsonString.length * 2;
      } catch (e) {
        // If serialization fails, use a rough estimate
        return 100; // Arbitrary size for non-serializable objects
      }
    }
  }

  /// Estimates the size of a cache item in bytes.
  ///
  /// This method takes into account the value, expiry, and other metadata.
  static int estimateCacheItemSize(dynamic value, {
    bool hasExpiry = false,
    bool hasSlidingExpiry = false,
    bool isCompressed = false,
    int? originalSize,
  }) {
    // Base size for cache item metadata
    int size = 64; // Overhead for CacheItem object
    
    // Add size for value
    size += estimateSize(value);
    
    // Add size for expiry (if present)
    if (hasExpiry) {
      size += 8; // DateTime is typically 8 bytes
    }
    
    // Add size for sliding expiry (if present)
    if (hasSlidingExpiry) {
      size += 8; // Duration is typically 8 bytes
    }
    
    // For compressed items, use the compressed size
    if (isCompressed && originalSize != null) {
      // Replace the value size with the compressed size
      size = size - estimateSize(value) + (originalSize ~/ 2); // Rough estimate of compression
    }
    
    return size;
  }

  /// Estimates the size of a JSON string in bytes.
  ///
  /// This is useful for estimating the size of serialized objects.
  static int estimateJsonSize(String jsonString) {
    return jsonString.length * 2; // UTF-16 encoding
  }
}
