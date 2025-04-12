import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:logging/logging.dart';

/// A class that provides compression and decompression functionality.
class Compression {
  /// The logger instance.
  static final _log = Logger('Compression');

  /// The compression level to use.
  ///
  /// Values range from 1 (fastest, least compression) to 9 (slowest, most compression).
  final int _level;

  /// Creates a new instance of [Compression].
  ///
  /// The [level] parameter can be used to set the compression level.
  /// Values range from 1 (fastest, least compression) to 9 (slowest, most compression).
  /// The default value is 6, which provides a good balance between speed and compression ratio.
  Compression({int level = 6}) : _level = level.clamp(1, 9);

  /// Compresses the given string data.
  ///
  /// Returns the compressed data as a base64-encoded string.
  String compressString(String data) {
    try {
      // Convert the string to bytes
      final bytes = utf8.encode(data);

      // Compress the bytes
      final compressedBytes = _compressBytes(bytes);

      // Convert the compressed bytes to a base64-encoded string
      final compressedString = base64Encode(compressedBytes);

      _log.fine(
          'Compressed string from ${data.length} to ${compressedString.length} characters');

      return compressedString;
    } catch (e) {
      _log.warning('Failed to compress string: $e');
      // Return the original data if compression fails
      return data;
    }
  }

  /// Decompresses the given base64-encoded compressed string.
  ///
  /// Returns the decompressed string.
  String decompressString(String compressedData) {
    try {
      // Convert the base64-encoded string to bytes
      final compressedBytes = base64Decode(compressedData);

      // Decompress the bytes
      final decompressedBytes = _decompressBytes(compressedBytes);

      // Convert the decompressed bytes to a string
      final decompressedString = utf8.decode(decompressedBytes);

      _log.fine(
          'Decompressed string from ${compressedData.length} to ${decompressedString.length} characters');

      return decompressedString;
    } catch (e) {
      _log.warning('Failed to decompress string: $e');
      // Return the original data if decompression fails
      return compressedData;
    }
  }

  /// Compresses the given bytes.
  ///
  /// Returns the compressed bytes.
  Uint8List _compressBytes(List<int> bytes) {
    // Create a GZip encoder with the specified compression level
    final encoder = GZipEncoder();

    // Compress the bytes
    final compressedBytes = encoder.encode(bytes, level: _level);

    if (compressedBytes == null) {
      throw Exception('Compression failed');
    }

    return Uint8List.fromList(compressedBytes);
  }

  /// Decompresses the given compressed bytes.
  ///
  /// Returns the decompressed bytes.
  Uint8List _decompressBytes(List<int> compressedBytes) {
    // Create a GZip decoder
    final decoder = GZipDecoder();

    // Decompress the bytes
    final decompressedBytes = decoder.decodeBytes(compressedBytes);

    return Uint8List.fromList(decompressedBytes);
  }

  /// Determines if compression should be applied to the given data.
  ///
  /// Returns `true` if the data should be compressed, `false` otherwise.
  ///
  /// The decision is based on the size of the data and the potential compression ratio.
  /// Small data (less than 100 bytes) is not compressed because the overhead of compression
  /// would likely outweigh the benefits.
  bool shouldCompress(String data) {
    // Don't compress small data
    if (data.length < 100) {
      return false;
    }

    // For larger data, estimate the compression ratio
    if (data.length >= 1000) {
      // For very large data, compression is almost always beneficial
      return true;
    }

    // For medium-sized data, do a quick check to estimate compressibility
    // by looking at the entropy of a sample of the data
    final sample = data.length > 500 ? data.substring(0, 500) : data;
    final entropy = _calculateEntropy(sample);

    // If the entropy is low, the data is likely to be compressible
    // Entropy ranges from 0 (completely predictable) to 8 (completely random)
    return entropy < 6.0;
  }

  /// Calculates the entropy of the given string.
  ///
  /// Entropy is a measure of randomness. The higher the entropy, the more random the data,
  /// and the less compressible it is.
  double _calculateEntropy(String data) {
    if (data.isEmpty) {
      return 0.0;
    }

    // Count the frequency of each character
    final Map<int, int> frequencies = {};
    for (final codeUnit in data.codeUnits) {
      frequencies[codeUnit] = (frequencies[codeUnit] ?? 0) + 1;
    }

    // Calculate the entropy
    double entropy = 0.0;
    final length = data.length.toDouble();

    for (final frequency in frequencies.values) {
      final probability = frequency / length;
      entropy -= probability * (log2(probability));
    }

    return entropy;
  }

  /// Calculates the base-2 logarithm of the given value.
  double log2(double value) {
    return math.log(value) / math.ln2;
  }
}
