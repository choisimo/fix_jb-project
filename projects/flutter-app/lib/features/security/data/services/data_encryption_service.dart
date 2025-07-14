import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';

class DataEncryptionService {
  final _storage = const FlutterSecureStorage();
  
  DataEncryptionService(); // 매개변수 없는 생성자 추가
  
  Future<String> encryptData(String plainText) async {
    // Simple encryption for demo - in production use proper encryption
    final bytes = utf8.encode(plainText);
    final hash = sha256.convert(bytes);
    return base64.encode(hash.bytes);
  }
  
  Future<String> decryptData(String encryptedText) async {
    // Simple decryption for demo
    try {
      final bytes = base64.decode(encryptedText);
      return utf8.decode(bytes);
    } catch (e) {
      return encryptedText; // Return original if decoding fails
    }
  }
  
  Future<void> secureStore(String key, String value) async {
    await _storage.write(key: key, value: value);
  }
  
  Future<String?> secureRetrieve(String key) async {
    return await _storage.read(key: key);
  }
  
  Future<void> secureDelete(String key) async {
    await _storage.delete(key: key);
  }
  
  Future<void> clearAllSecureData() async {
    await _storage.deleteAll();
  }
}