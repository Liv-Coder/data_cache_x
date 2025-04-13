import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';

/// Enum representing different encryption algorithms.
enum EncryptionAlgorithm {
  /// Advanced Encryption Standard (AES) with 256-bit key.
  aes256,
}

/// A class that provides encryption and decryption functionality.
class Encryption {
  /// The encryption algorithm to use.
  final EncryptionAlgorithm algorithm;

  /// The encryption key.
  final String encryptionKey;

  /// Creates a new instance of [Encryption].
  ///
  /// The [algorithm] parameter specifies the encryption algorithm to use.
  /// The [encryptionKey] parameter is the key used for encryption and decryption.
  Encryption({
    this.algorithm = EncryptionAlgorithm.aes256,
    required this.encryptionKey,
  });

  /// Encrypts the given data.
  ///
  /// Returns the encrypted data as a base64-encoded string.
  String encrypt(String data) {
    // Currently only AES-256 is supported
    return _aesEncrypt(data);
  }

  /// Decrypts the given encrypted data.
  ///
  /// Returns the decrypted data.
  String decrypt(String encryptedData) {
    // Currently only AES-256 is supported
    return _aesDecrypt(encryptedData);
  }

  /// Encrypts the given data using AES-256.
  String _aesEncrypt(String data) {
    final key = Key.fromUtf8(encryptionKey.padRight(32, '0').substring(0, 32));
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(data, iv: iv);
    return encrypted.base64;
  }

  /// Decrypts the given encrypted data using AES-256.
  String _aesDecrypt(String encryptedData) {
    final key = Key.fromUtf8(encryptionKey.padRight(32, '0').substring(0, 32));
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));
    final decrypted =
        encrypter.decrypt(Encrypted.fromBase64(encryptedData), iv: iv);
    return decrypted;
  }

  /// Generates a secure random key.
  ///
  /// The [length] parameter specifies the length of the key in bytes.
  /// Returns the key as a base64-encoded string.
  static String generateSecureKey({int length = 32}) {
    final key = Key.fromSecureRandom(length);
    return base64Encode(key.bytes);
  }

  /// Derives a key from a password using PBKDF2.
  ///
  /// The [password] parameter is the password to derive the key from.
  /// The [salt] parameter is a random value used to prevent dictionary attacks.
  /// The [iterations] parameter is the number of iterations to perform.
  /// The [keyLength] parameter is the length of the derived key in bytes.
  ///
  /// Returns the derived key as a base64-encoded string.
  static String deriveKeyFromPassword({
    required String password,
    required String salt,
    int iterations = 10000,
    int keyLength = 32,
  }) {
    final bytes = utf8.encode(password);
    final saltBytes = utf8.encode(salt);

    // Use PBKDF2 to derive a key from the password
    final key = pbkdf2(
      bytes: bytes,
      salt: saltBytes,
      iterations: iterations,
      keyLength: keyLength,
      hashAlgorithm: sha256,
    );

    return base64Encode(key);
  }

  /// Implements PBKDF2 (Password-Based Key Derivation Function 2).
  ///
  /// This is a simplified implementation for demonstration purposes.
  /// In a production environment, consider using a dedicated PBKDF2 library.
  static List<int> pbkdf2({
    required List<int> bytes,
    required List<int> salt,
    required int iterations,
    required int keyLength,
    required Hash hashAlgorithm,
  }) {
    final hmac = Hmac(hashAlgorithm, bytes);
    final blockCount = (keyLength / hashAlgorithm.blockSize).ceil();
    final result = List<int>.filled(keyLength, 0);

    for (var i = 1; i <= blockCount; i++) {
      final block = _pbkdf2Block(hmac, salt, iterations, i);
      final offset = (i - 1) * hashAlgorithm.blockSize;
      final length = i == blockCount
          ? keyLength - (blockCount - 1) * hashAlgorithm.blockSize
          : hashAlgorithm.blockSize;

      for (var j = 0; j < length; j++) {
        if (offset + j < result.length) {
          result[offset + j] = block[j];
        }
      }
    }

    return result;
  }

  /// Computes a single block for PBKDF2.
  static List<int> _pbkdf2Block(
      Hmac hmac, List<int> salt, int iterations, int blockIndex) {
    final block = List<int>.from(salt);
    block.addAll([
      (blockIndex >> 24) & 0xFF,
      (blockIndex >> 16) & 0xFF,
      (blockIndex >> 8) & 0xFF,
      blockIndex & 0xFF,
    ]);

    var result = hmac.convert(block).bytes;
    final temp = List<int>.from(result);

    for (var i = 1; i < iterations; i++) {
      temp.setAll(0, hmac.convert(temp).bytes);
      for (var j = 0; j < result.length; j++) {
        result[j] ^= temp[j];
      }
    }

    return result;
  }
}
