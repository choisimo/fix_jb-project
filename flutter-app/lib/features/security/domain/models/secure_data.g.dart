// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'secure_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SecureDataImpl _$$SecureDataImplFromJson(Map<String, dynamic> json) =>
    _$SecureDataImpl(
      encryptedData: json['encryptedData'] as String,
      salt: json['salt'] as String,
      iv: json['iv'] as String,
      algorithm: $enumDecode(_$EncryptionAlgorithmEnumMap, json['algorithm']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      keyId: json['keyId'] as String?,
      isCompressed: json['isCompressed'] as bool? ?? false,
    );

Map<String, dynamic> _$$SecureDataImplToJson(_$SecureDataImpl instance) =>
    <String, dynamic>{
      'encryptedData': instance.encryptedData,
      'salt': instance.salt,
      'iv': instance.iv,
      'algorithm': _$EncryptionAlgorithmEnumMap[instance.algorithm]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'keyId': instance.keyId,
      'isCompressed': instance.isCompressed,
    };

const _$EncryptionAlgorithmEnumMap = {
  EncryptionAlgorithm.aes256gcm: 'aes256gcm',
  EncryptionAlgorithm.aes256cbc: 'aes256cbc',
  EncryptionAlgorithm.chacha20poly1305: 'chacha20poly1305',
};
