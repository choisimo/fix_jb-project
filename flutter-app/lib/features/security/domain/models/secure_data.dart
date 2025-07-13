import 'package:freezed_annotation/freezed_annotation.dart';

part 'secure_data.freezed.dart';
part 'secure_data.g.dart';

@freezed
class SecureData with _$SecureData {
  const factory SecureData({
    required String encryptedData,
    required String salt,
    required String iv,
    required EncryptionAlgorithm algorithm,
    required DateTime createdAt,
    DateTime? expiresAt,
    String? keyId,
    @Default(false) bool isCompressed,
  }) = _SecureData;

  factory SecureData.fromJson(Map<String, dynamic> json) =>
      _$SecureDataFromJson(json);
}

@JsonEnum()
enum EncryptionAlgorithm {
  @JsonValue('aes256gcm')
  aes256gcm,
  @JsonValue('aes256cbc')
  aes256cbc,
  @JsonValue('chacha20poly1305')
  chacha20poly1305,
}