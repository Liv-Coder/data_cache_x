import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:isolate';
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

  /// The threshold (in characters) above which compression will be performed in a separate isolate.
  final int _asyncThreshold;

  /// Creates a new instance of [Compression].
  ///
  /// The [level] parameter can be used to set the compression level.
  /// Values range from 1 (fastest, least compression) to 9 (slowest, most compression).
  /// The default value is 6, which provides a good balance between speed and compression ratio.
  ///
  /// The [asyncThreshold] parameter determines the string size (in characters) above which
  /// compression will be performed in a separate isolate to avoid blocking the main thread.
  /// The default value is 50000 characters.
  Compression({int level = 6, int asyncThreshold = 50000})
      : _level = level.clamp(1, 9),
        _asyncThreshold = asyncThreshold;

  /// Compresses the given string data.
  ///
  /// Returns the compressed data as a base64-encoded string.
  /// For small strings, this is done synchronously.
  /// For large strings (above [_asyncThreshold]), this is done in a separate isolate.
  String compressString(String data) {
    try {
      // For small strings, compress synchronously
      if (data.length < _asyncThreshold) {
        return _compressStringSync(data);
      }

      // For large strings, we should use the async version
      // But since this method is synchronous, we'll log a warning and still do it synchronously
      _log.warning(
          'Large string (${data.length} chars) being compressed synchronously. Consider using compressStringAsync for better performance.');
      return _compressStringSync(data);
    } catch (e) {
      _log.warning('Failed to compress string: $e');
      // Return the original data if compression fails
      return data;
    }
  }

  /// Compresses the given string data asynchronously.
  ///
  /// Returns the compressed data as a base64-encoded string.
  /// For large strings (above [_asyncThreshold]), this is done in a separate isolate
  /// to avoid blocking the main thread.
  Future<String> compressStringAsync(String data) async {
    try {
      // For small strings, compress synchronously
      if (data.length < _asyncThreshold) {
        return _compressStringSync(data);
      }

      // For large strings, compress in a separate isolate
      _log.fine('Compressing large string (${data.length} chars) in isolate');

      // Create a message to send to the isolate
      final message = _CompressionMessage(
        data: data,
        level: _level,
      );

      // Compress in isolate
      final result = await Isolate.run(() => _compressInIsolate(message));

      _log.fine(
          'Compressed string from ${data.length} to ${result.length} characters in isolate');

      return result;
    } catch (e) {
      _log.warning('Failed to compress string asynchronously: $e');
      // Return the original data if compression fails
      return data;
    }
  }

  /// Synchronously compresses a string.
  String _compressStringSync(String data) {
    // Convert the string to bytes
    final bytes = utf8.encode(data);

    // Compress the bytes
    final compressedBytes = _compressBytes(bytes);

    // Convert the compressed bytes to a base64-encoded string
    final compressedString = base64Encode(compressedBytes);

    _log.fine(
        'Compressed string from ${data.length} to ${compressedString.length} characters');

    return compressedString;
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

  /// Decompresses the given base64-encoded compressed string asynchronously.
  ///
  /// Returns the decompressed string.
  /// For large strings (above [_asyncThreshold]), this is done in a separate isolate
  /// to avoid blocking the main thread.
  Future<String> decompressStringAsync(String compressedData) async {
    try {
      // For small strings, decompress synchronously
      if (compressedData.length < _asyncThreshold) {
        return decompressString(compressedData);
      }

      // For large strings, decompress in a separate isolate
      _log.fine(
          'Decompressing large string (${compressedData.length} chars) in isolate');

      // Create a message to send to the isolate
      final message = _DecompressionMessage(
        compressedString: compressedData,
      );

      // Decompress in isolate
      final result = await Isolate.run(() => _decompressInIsolate(message));

      _log.fine(
          'Decompressed string from ${compressedData.length} to ${result.length} characters in isolate');

      return result;
    } catch (e) {
      _log.warning('Failed to decompress string asynchronously: $e');
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

    // Return the compressed bytes
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

  /// Compresses a string in an isolate.
  static String _compressInIsolate(_CompressionMessage message) {
    final compression = Compression(level: message.level);
    return compression._compressStringSync(message.data);
  }

  /// Decompresses a string in an isolate.
  static String _decompressInIsolate(_DecompressionMessage message) {
    final compression = Compression();
    return compression.decompressString(message.compressedString);
  }
}

/// A message for compression in an isolate.
class _CompressionMessage {
  final String data;
  final int level;

  _CompressionMessage({
    required this.data,
    required this.level,
  });
}

/// A message for decompression in an isolate.
class _DecompressionMessage {
  final String compressedString;

  _DecompressionMessage({
    required this.compressedString,
  });
}
