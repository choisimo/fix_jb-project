// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LoginRequestImpl _$$LoginRequestImplFromJson(Map<String, dynamic> json) =>
    _$LoginRequestImpl(
      email: json['email'] as String,
      password: json['password'] as String,
      rememberMe: json['rememberMe'] as bool? ?? false,
      deviceId: json['deviceId'] as String?,
      deviceName: json['deviceName'] as String?,
    );

Map<String, dynamic> _$$LoginRequestImplToJson(_$LoginRequestImpl instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'rememberMe': instance.rememberMe,
      'deviceId': instance.deviceId,
      'deviceName': instance.deviceName,
    };

_$SignupRequestImpl _$$SignupRequestImplFromJson(Map<String, dynamic> json) =>
    _$SignupRequestImpl(
      email: json['email'] as String,
      password: json['password'] as String,
      username: json['username'] as String,
      fullName: json['fullName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      acceptTerms: json['acceptTerms'] as bool? ?? true,
      acceptPrivacy: json['acceptPrivacy'] as bool? ?? true,
      deviceId: json['deviceId'] as String?,
      deviceName: json['deviceName'] as String?,
    );

Map<String, dynamic> _$$SignupRequestImplToJson(_$SignupRequestImpl instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'username': instance.username,
      'fullName': instance.fullName,
      'phoneNumber': instance.phoneNumber,
      'acceptTerms': instance.acceptTerms,
      'acceptPrivacy': instance.acceptPrivacy,
      'deviceId': instance.deviceId,
      'deviceName': instance.deviceName,
    };

_$SocialLoginRequestImpl _$$SocialLoginRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$SocialLoginRequestImpl(
      provider: json['provider'] as String,
      accessToken: json['accessToken'] as String,
      idToken: json['idToken'] as String?,
      email: json['email'] as String?,
      username: json['username'] as String?,
      fullName: json['fullName'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      deviceId: json['deviceId'] as String?,
      deviceName: json['deviceName'] as String?,
    );

Map<String, dynamic> _$$SocialLoginRequestImplToJson(
        _$SocialLoginRequestImpl instance) =>
    <String, dynamic>{
      'provider': instance.provider,
      'accessToken': instance.accessToken,
      'idToken': instance.idToken,
      'email': instance.email,
      'username': instance.username,
      'fullName': instance.fullName,
      'profileImageUrl': instance.profileImageUrl,
      'deviceId': instance.deviceId,
      'deviceName': instance.deviceName,
    };

_$AuthResponseImpl _$$AuthResponseImplFromJson(Map<String, dynamic> json) =>
    _$AuthResponseImpl(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      expiresIn: (json['expiresIn'] as num).toInt(),
      tokenType: json['tokenType'] as String?,
    );

Map<String, dynamic> _$$AuthResponseImplToJson(_$AuthResponseImpl instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'user': instance.user,
      'expiresIn': instance.expiresIn,
      'tokenType': instance.tokenType,
    };

_$RefreshTokenRequestImpl _$$RefreshTokenRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$RefreshTokenRequestImpl(
      refreshToken: json['refreshToken'] as String,
    );

Map<String, dynamic> _$$RefreshTokenRequestImplToJson(
        _$RefreshTokenRequestImpl instance) =>
    <String, dynamic>{
      'refreshToken': instance.refreshToken,
    };

_$PasswordResetRequestImpl _$$PasswordResetRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$PasswordResetRequestImpl(
      email: json['email'] as String,
    );

Map<String, dynamic> _$$PasswordResetRequestImplToJson(
        _$PasswordResetRequestImpl instance) =>
    <String, dynamic>{
      'email': instance.email,
    };

_$PasswordChangeRequestImpl _$$PasswordChangeRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$PasswordChangeRequestImpl(
      currentPassword: json['currentPassword'] as String,
      newPassword: json['newPassword'] as String,
    );

Map<String, dynamic> _$$PasswordChangeRequestImplToJson(
        _$PasswordChangeRequestImpl instance) =>
    <String, dynamic>{
      'currentPassword': instance.currentPassword,
      'newPassword': instance.newPassword,
    };

_$EmailVerificationRequestImpl _$$EmailVerificationRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$EmailVerificationRequestImpl(
      token: json['token'] as String,
    );

Map<String, dynamic> _$$EmailVerificationRequestImplToJson(
        _$EmailVerificationRequestImpl instance) =>
    <String, dynamic>{
      'token': instance.token,
    };

_$BiometricSetupRequestImpl _$$BiometricSetupRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$BiometricSetupRequestImpl(
      biometricType: json['biometricType'] as String,
      publicKey: json['publicKey'] as String,
      deviceId: json['deviceId'] as String?,
    );

Map<String, dynamic> _$$BiometricSetupRequestImplToJson(
        _$BiometricSetupRequestImpl instance) =>
    <String, dynamic>{
      'biometricType': instance.biometricType,
      'publicKey': instance.publicKey,
      'deviceId': instance.deviceId,
    };

_$AuthErrorImpl _$$AuthErrorImplFromJson(Map<String, dynamic> json) =>
    _$AuthErrorImpl(
      code: json['code'] as String,
      message: json['message'] as String,
      field: json['field'] as String?,
      details: json['details'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$AuthErrorImplToJson(_$AuthErrorImpl instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'field': instance.field,
      'details': instance.details,
    };
