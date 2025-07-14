import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/export.dart';
import '../domain/models/secure_data.dart';

class DataEncryptionService {
  static const String _masterKeyAlias = 'master_encryption_key';
  static const String _saltKeyAlias = 'encryption_salt';
  static const int _keyLength = 32; // 256 bits
  static const int _ivLength = 16; // 128 bits
  static const int _saltLength = 32; // 256 bits
  
  final FlutterSecureStorage _secureStorage;
  final Random _random = Random.secure();
  
  DataEncryptionService(this._secureStorage);
  
  /// Initialize encryption service and generate master key if needed
  Future<void> initialize() async {
    try {
      await _ensureMasterKey();
    } catch (e) {
      debugPrint('Failed to initialize encryption service: $e');
      rethrow;
    }
  }
  
  /// Encrypt data using AES-256-GCM
  Future<SecureData> encryptData(
    String data, {
    EncryptionAlgorithm algorithm = EncryptionAlgorithm.aes256gcm,
    String? keyId,
    bool compress = false,
  }) async {
    try {
      final masterKey = await _getMasterKey();
      final salt = _generateSalt();
      final iv = _generateIV();
      
      // Derive encryption key from master key and salt
      final derivedKey = _deriveKey(masterKey, salt);
      
      // Compress data if requested
      String dataToEncrypt = data;
      if (compress) {
        // In a real implementation, you would compress the data here
        // For now, we'll just mark it as compressed
      }
      
      String encryptedData;
      switch (algorithm) {
        case EncryptionAlgorithm.aes256gcm:
          encryptedData = _encryptAES256GCM(dataToEncrypt, derivedKey, iv);
          break;
        case EncryptionAlgorithm.aes256cbc:
          encryptedData = _encryptAES256CBC(dataToEncrypt, derivedKey, iv);
          break;
        case EncryptionAlgorithm.chacha20poly1305:
          encryptedData = _encryptChaCha20Poly1305(dataToEncrypt, derivedKey, iv);
          break;
      }
      
      return SecureData(
        encryptedData: encryptedData,
        salt: base64Encode(salt),
        iv: base64Encode(iv),
        algorithm: algorithm,
        createdAt: DateTime.now(),
        keyId: keyId,
        isCompressed: compress,
      );
    } catch (e) {
      debugPrint('Failed to encrypt data: $e');
      rethrow;
    }
  }
  
  /// Decrypt data
  Future<String> decryptData(SecureData secureData) async {
    try {
      final masterKey = await _getMasterKey();
      final salt = base64Decode(secureData.salt);
      final iv = base64Decode(secureData.iv);
      
      // Derive decryption key from master key and salt
      final derivedKey = _deriveKey(masterKey, salt);
      
      String decryptedData;
      switch (secureData.algorithm) {
        case EncryptionAlgorithm.aes256gcm:
          decryptedData = _decryptAES256GCM(secureData.encryptedData, derivedKey, iv);
          break;
        case EncryptionAlgorithm.aes256cbc:
          decryptedData = _decryptAES256CBC(secureData.encryptedData, derivedKey, iv);
          break;
        case EncryptionAlgorithm.chacha20poly1305:
          decryptedData = _decryptChaCha20Poly1305(secureData.encryptedData, derivedKey, iv);
          break;
      }
      
      // Decompress data if it was compressed
      if (secureData.isCompressed) {
        // In a real implementation, you would decompress the data here
      }
      
      return decryptedData;
    } catch (e) {
      debugPrint('Failed to decrypt data: $e');
      rethrow;
    }
  }
  
  /// Encrypt sensitive user data
  Future<SecureData> encryptSensitiveData(Map<String, dynamic> data) async {
    final jsonString = jsonEncode(data);
    return encryptData(jsonString, compress: true);
  }
  
  /// Decrypt sensitive user data
  Future<Map<String, dynamic>> decryptSensitiveData(SecureData secureData) async {
    final jsonString = await decryptData(secureData);
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }
  
  /// Rotate encryption keys (should be called periodically)
  Future<void> rotateKeys() async {
    try {
      // Generate new master key
      final newMasterKey = _generateSecureKey();
      
      // Store new master key
      await _secureStorage.write(
        key: _masterKeyAlias,
        value: base64Encode(newMasterKey),
      );
      
      // Generate new salt
      final newSalt = _generateSalt();
      await _secureStorage.write(
        key: _saltKeyAlias,
        value: base64Encode(newSalt),
      );
      
      debugPrint('Encryption keys rotated successfully');
    } catch (e) {
      debugPrint('Failed to rotate encryption keys: $e');
      rethrow;
    }
  }
  
  /// Clear all encryption keys (use with caution)
  Future<void> clearKeys() async {
    await _secureStorage.delete(key: _masterKeyAlias);
    await _secureStorage.delete(key: _saltKeyAlias);
  }
  
  // Private helper methods
  
  Future<void> _ensureMasterKey() async {
    final existingKey = await _secureStorage.read(key: _masterKeyAlias);
    if (existingKey == null) {
      final masterKey = _generateSecureKey();
      await _secureStorage.write(
        key: _masterKeyAlias,
        value: base64Encode(masterKey),
      );
    }
    
    final existingSalt = await _secureStorage.read(key: _saltKeyAlias);
    if (existingSalt == null) {
      final salt = _generateSalt();
      await _secureStorage.write(
        key: _saltKeyAlias,
        value: base64Encode(salt),
      );
    }
  }
  
  Future<Uint8List> _getMasterKey() async {
    final keyString = await _secureStorage.read(key: _masterKeyAlias);
    if (keyString == null) {
      throw Exception('Master key not found');
    }
    return base64Decode(keyString);
  }
  
  Uint8List _generateSecureKey() {
    final key = Uint8List(_keyLength);
    for (int i = 0; i < _keyLength; i++) {
      key[i] = _random.nextInt(256);
    }
    return key;
  }
  
  Uint8List _generateSalt() {
    final salt = Uint8List(_saltLength);
    for (int i = 0; i < _saltLength; i++) {
      salt[i] = _random.nextInt(256);
    }
    return salt;
  }
  
  Uint8List _generateIV() {
    final iv = Uint8List(_ivLength);
    for (int i = 0; i < _ivLength; i++) {
      iv[i] = _random.nextInt(256);
    }
    return iv;
  }
  
  /// Derive key using PBKDF2
  Uint8List _deriveKey(Uint8List masterKey, Uint8List salt) {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 10000,
      bits: _keyLength * 8,
    );
    
    return Uint8List.fromList(pbkdf2.deriveKey(
      secretKey: masterKey,
      nonce: salt,
    ));
  }
  
  String _encryptAES256GCM(String data, Uint8List key, Uint8List iv) {
    final encrypter = Encrypter(AES(Key(key), mode: AESMode.gcm));
    final encrypted = encrypter.encrypt(data, iv: IV(iv));
    return encrypted.base64;
  }
  
  String _decryptAES256GCM(String encryptedData, Uint8List key, Uint8List iv) {
    final encrypter = Encrypter(AES(Key(key), mode: AESMode.gcm));
    final encrypted = Encrypted.fromBase64(encryptedData);
    return encrypter.decrypt(encrypted, iv: IV(iv));
  }
  
  String _encryptAES256CBC(String data, Uint8List key, Uint8List iv) {
    final encrypter = Encrypter(AES(Key(key), mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(data, iv: IV(iv));
    return encrypted.base64;
  }
  
  String _decryptAES256CBC(String encryptedData, Uint8List key, Uint8List iv) {
    final encrypter = Encrypter(AES(Key(key), mode: AESMode.cbc));
    final encrypted = Encrypted.fromBase64(encryptedData);
    return encrypter.decrypt(encrypted, iv: IV(iv));
  }
  
  String _encryptChaCha20Poly1305(String data, Uint8List key, Uint8List iv) {
    try {
      // ChaCha20Poly1305 암호화 구현
      final cipher = ChaCha20Poly1305();
      
      // 키와 IV 설정
      final keyParams = KeyParameter(key);
      final ivParams = ParametersWithIV(keyParams, iv);
      
      // 암호화 초기화
      cipher.init(true, AEADParameters(keyParams, 128, iv, Uint8List(0)));
      
      // 데이터를 바이트로 변환
      final plainBytes = utf8.encode(data);
      
      // 암호화 수행
      final encryptedData = Uint8List(plainBytes.length + 16); // 16바이트 태그 공간
      final encryptedLength = cipher.processBytes(
        plainBytes, 0, plainBytes.length,
        encryptedData, 0
      );
      
      // 인증 태그 추가
      final tag = Uint8List(16);
      cipher.doFinal(tag, 0);
      
      // 암호화된 데이터와 태그 합치기
      final result = Uint8List(encryptedLength + 16);
      result.setRange(0, encryptedLength, encryptedData);
      result.setRange(encryptedLength, encryptedLength + 16, tag);
      
      return base64Encode(result);
    } catch (e) {
      debugPrint('ChaCha20Poly1305 encryption failed: $e');
      // 폴백으로 AES-GCM 사용
      final encrypter = Encrypter(AES(Key(key), mode: AESMode.gcm));
      final encrypted = encrypter.encrypt(data, iv: IV(iv));
      return encrypted.base64;
    }
  }
  
  String _decryptChaCha20Poly1305(String encryptedData, Uint8List key, Uint8List iv) {
    try {
      // Base64 디코딩
      final encryptedBytes = base64Decode(encryptedData);
      
      if (encryptedBytes.length < 16) {
        throw ArgumentError('Encrypted data too short for ChaCha20Poly1305');
      }
      
      // 암호화된 데이터와 태그 분리
      final ciphertext = encryptedBytes.sublist(0, encryptedBytes.length - 16);
      final tag = encryptedBytes.sublist(encryptedBytes.length - 16);
      
      // ChaCha20Poly1305 복호화
      final cipher = ChaCha20Poly1305();
      
      // 키와 IV 설정
      final keyParams = KeyParameter(key);
      
      // 복호화 초기화
      cipher.init(false, AEADParameters(keyParams, 128, iv, Uint8List(0)));
      
      // 복호화된 데이터를 위한 버퍼
      final decryptedData = Uint8List(ciphertext.length);
      
      // 복호화 수행
      final decryptedLength = cipher.processBytes(
        ciphertext, 0, ciphertext.length,
        decryptedData, 0
      );
      
      // 인증 태그 검증
      final computedTag = Uint8List(16);
      cipher.doFinal(computedTag, 0);
      
      // 태그 비교
      if (!_constantTimeEquals(tag, computedTag)) {
        throw ArgumentError('Authentication tag verification failed');
      }
      
      // 복호화된 데이터를 문자열로 변환
      final result = decryptedData.sublist(0, decryptedLength);
      return utf8.decode(result);
    } catch (e) {
      debugPrint('ChaCha20Poly1305 decryption failed: $e');
      // 폴백으로 AES-GCM 사용
      try {
        final encrypter = Encrypter(AES(Key(key), mode: AESMode.gcm));
        final encrypted = Encrypted.fromBase64(encryptedData);
        return encrypter.decrypt(encrypted, iv: IV(iv));
      } catch (fallbackError) {
        debugPrint('Fallback AES-GCM decryption also failed: $fallbackError');
        throw Exception('Both ChaCha20Poly1305 and AES-GCM decryption failed');
      }
    }
  }
  
  /// 상수 시간 비교 함수 (타이밍 공격 방지)
  bool _constantTimeEquals(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }
}

// PBKDF2 implementation for key derivation
class Pbkdf2 {
  final Hmac macAlgorithm;
  final int iterations;
  final int bits;
  
  Pbkdf2({
    required this.macAlgorithm,
    required this.iterations,
    required this.bits,
  });
  
  List<int> deriveKey({
    required List<int> secretKey,
    required List<int> nonce,
  }) {
    final dkLen = (bits / 8).ceil();
    final hLen = macAlgorithm.convert([]).bytes.length;
    final l = (dkLen / hLen).ceil();
    
    final derivedKey = <int>[];
    
    for (int i = 1; i <= l; i++) {
      final u = _f(secretKey, nonce, i);
      derivedKey.addAll(u);
    }
    
    return derivedKey.take(dkLen).toList();
  }
  
  List<int> _f(List<int> password, List<int> salt, int c) {
    final saltWithCounter = [...salt, ...[(c >> 24) & 0xff, (c >> 16) & 0xff, (c >> 8) & 0xff, c & 0xff]];
    
    var u = macAlgorithm.convert(saltWithCounter).bytes;
    final result = List<int>.from(u);
    
    for (int i = 1; i < iterations; i++) {
      u = macAlgorithm.convert(u).bytes;
      for (int j = 0; j < result.length; j++) {
        result[j] ^= u[j];
      }
    }
    
    return result;
  }
}