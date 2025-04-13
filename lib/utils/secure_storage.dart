import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:data_cache_x/models/encryption_options.dart';
import 'package:data_cache_x/utils/encryption.dart';
import 'package:logging/logging.dart';

/// A utility class for securely storing encryption keys.
class SecureStorage {
  static final _log = Logger('SecureStorage');
  static const _keyPrefix = 'data_cache_x_';
  static const _defaultKeyName = 'encryption_key';
  static const _defaultSaltName = 'encryption_salt';
  static const _defaultAlgorithmName = 'encryption_algorithm';

  /// The secure storage instance.
  final FlutterSecureStorage _secureStorage;

  /// Creates a new instance of [SecureStorage].
  ///
  /// The [secureStorage] parameter can be used to provide a custom secure storage instance.
  /// If not provided, a default instance will be created.
  SecureStorage({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Generates a secure random key and stores it in secure storage.
  ///
  /// The [keyName] parameter can be used to specify a custom name for the key.
  /// If not provided, a default name will be used.
  ///
  /// Returns the generated encryption options.
  Future<EncryptionOptions> generateAndStoreKey({
    String? keyName,
    EncryptionAlgorithm algorithm = EncryptionAlgorithm.aes256,
  }) async {
    final key = Encryption.generateSecureKey();
    final effectiveKeyName = keyName ?? _defaultKeyName;

    await _secureStorage.write(
      key: _getKey(effectiveKeyName),
      value: key,
    );

    await _secureStorage.write(
      key: _getKey(_defaultAlgorithmName),
      value: algorithm.toString().split('.').last,
    );

    _log.info('Generated and stored encryption key: $effectiveKeyName');

    return EncryptionOptions(
      algorithm: algorithm,
      key: key,
    );
  }

  /// Derives a key from a password and stores it in secure storage.
  ///
  /// The [password] parameter is the password to derive the key from.
  /// The [keyName] parameter can be used to specify a custom name for the key.
  /// If not provided, a default name will be used.
  ///
  /// Returns the generated encryption options.
  Future<EncryptionOptions> deriveAndStoreKey({
    required String password,
    String? keyName,
    EncryptionAlgorithm algorithm = EncryptionAlgorithm.aes256,
    int iterations = 10000,
  }) async {
    // Generate a random salt
    final salt = _generateRandomString(16);
    final effectiveKeyName = keyName ?? _defaultKeyName;

    // Derive the key
    final key = Encryption.deriveKeyFromPassword(
      password: password,
      salt: salt,
      iterations: iterations,
    );

    // Store the key and salt
    await _secureStorage.write(
      key: _getKey(effectiveKeyName),
      value: key,
    );

    await _secureStorage.write(
      key: _getKey(_defaultSaltName),
      value: salt,
    );

    await _secureStorage.write(
      key: _getKey(_defaultAlgorithmName),
      value: algorithm.toString().split('.').last,
    );

    _log.info('Derived and stored encryption key: $effectiveKeyName');

    return EncryptionOptions(
      algorithm: algorithm,
      key: key,
    );
  }

  /// Retrieves encryption options from secure storage.
  ///
  /// The [keyName] parameter can be used to specify a custom name for the key.
  /// If not provided, a default name will be used.
  ///
  /// Returns the encryption options, or `null` if no key is found.
  Future<EncryptionOptions?> getEncryptionOptions({
    String? keyName,
  }) async {
    final effectiveKeyName = keyName ?? _defaultKeyName;
    final key = await _secureStorage.read(key: _getKey(effectiveKeyName));

    if (key == null) {
      _log.warning('No encryption key found: $effectiveKeyName');
      return null;
    }

    // Currently only AES-256 is supported
    EncryptionAlgorithm algorithm = EncryptionAlgorithm.aes256;

    return EncryptionOptions(
      algorithm: algorithm,
      key: key,
    );
  }

  /// Deletes an encryption key from secure storage.
  ///
  /// The [keyName] parameter can be used to specify a custom name for the key.
  /// If not provided, a default name will be used.
  Future<void> deleteKey({
    String? keyName,
  }) async {
    final effectiveKeyName = keyName ?? _defaultKeyName;
    await _secureStorage.delete(key: _getKey(effectiveKeyName));
    await _secureStorage.delete(key: _getKey(_defaultSaltName));
    await _secureStorage.delete(key: _getKey(_defaultAlgorithmName));

    _log.info('Deleted encryption key: $effectiveKeyName');
  }

  /// Checks if an encryption key exists in secure storage.
  ///
  /// The [keyName] parameter can be used to specify a custom name for the key.
  /// If not provided, a default name will be used.
  ///
  /// Returns `true` if the key exists, `false` otherwise.
  Future<bool> hasKey({
    String? keyName,
  }) async {
    final effectiveKeyName = keyName ?? _defaultKeyName;
    final key = await _secureStorage.read(key: _getKey(effectiveKeyName));
    return key != null;
  }

  /// Gets the full key name with the prefix.
  String _getKey(String keyName) => '$_keyPrefix$keyName';

  /// Generates a random string of the specified length.
  String _generateRandomString(int length) {
    final random = Random.secure();
    final values = List<int>.generate(length, (i) => random.nextInt(256));
    return base64Url.encode(values).substring(0, length);
  }
}
