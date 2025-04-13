import 'package:data_cache_x/utils/encryption.dart';

/// A class that represents encryption options for the cache.
class EncryptionOptions {
  /// The encryption algorithm to use.
  final EncryptionAlgorithm algorithm;

  /// The encryption key.
  final String key;

  /// Creates a new instance of [EncryptionOptions].
  ///
  /// The [algorithm] parameter specifies the encryption algorithm to use.
  /// The [key] parameter is the key used for encryption and decryption.
  const EncryptionOptions({
    this.algorithm = EncryptionAlgorithm.aes256,
    required this.key,
  });

  /// Creates a new instance of [EncryptionOptions] with AES-256 encryption.
  factory EncryptionOptions.aes256({required String key}) {
    return EncryptionOptions(
      algorithm: EncryptionAlgorithm.aes256,
      key: key,
    );
  }

  /// Creates a new instance of [EncryptionOptions] with a randomly generated key.
  factory EncryptionOptions.withRandomKey({
    EncryptionAlgorithm algorithm = EncryptionAlgorithm.aes256,
  }) {
    return EncryptionOptions(
      algorithm: algorithm,
      key: Encryption.generateSecureKey(),
    );
  }

  /// Creates a new instance of [EncryptionOptions] with a key derived from a password.
  factory EncryptionOptions.fromPassword({
    required String password,
    required String salt,
    EncryptionAlgorithm algorithm = EncryptionAlgorithm.aes256,
    int iterations = 10000,
  }) {
    return EncryptionOptions(
      algorithm: algorithm,
      key: Encryption.deriveKeyFromPassword(
        password: password,
        salt: salt,
        iterations: iterations,
      ),
    );
  }
}
