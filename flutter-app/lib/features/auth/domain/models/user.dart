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
    required int id,
    required String email,
    required String username,
    String? fullName,
    String? profileImageUrl,
    @Default(UserRole.user) UserRole role,
    @Default(AuthProvider.local) AuthProvider authProvider,
    required DateTime createdAt,
    DateTime? updatedAt,
    @Default(true) bool isActive,
    @Default(false) bool emailVerified,
    String? phoneNumber,
    DateTime? lastLoginAt,
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