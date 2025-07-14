import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

enum UserRole {
  @JsonValue('USER')
  user,
  @JsonValue('ADMIN')
  admin,
  @JsonValue('MODERATOR')
  moderator,
}

enum AuthProvider {
  @JsonValue('LOCAL')
  local,
  @JsonValue('GOOGLE')
  google,
  @JsonValue('KAKAO')
  kakao,
}

@freezed
class User with _$User {
  const factory User({
    required String id, // UUID를 String으로 받음
    required String email,
    required String name, // 서버에서는 name을 사용
    String? phone,
    String? department,
    @Default(UserRole.user) UserRole role,
    String? roleDescription,
    String? oauthProvider,
    @Default(false) bool isOAuthUser,
    @Default(true) bool isActive,
    @Default(false) bool emailVerified,
    DateTime? lastLogin,
    required DateTime createdAt,
    DateTime? updatedAt,
    int? reportCount,
    int? commentCount,
    // 이전 필드들 (호환성을 위해 유지하되 선택적으로)
    String? username, // name에서 매핑
    String? fullName,
    String? profileImageUrl,
    @Default(AuthProvider.local) AuthProvider authProvider,
    String? phoneNumber, // phone에서 매핑
    DateTime? lastLoginAt, // lastLogin에서 매핑
    Map<String, dynamic>? preferences,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required int userId,
    String? firstName,
    String? lastName,
    String? bio,
    String? profileImageUrl,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? address,
    String? city,
    String? country,
    String? postalCode,
    Map<String, dynamic>? socialLinks,
    @Default(true) bool isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}