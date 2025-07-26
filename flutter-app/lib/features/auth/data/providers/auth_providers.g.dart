// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tokenServiceHash() => r'3f7c199dcab8f65045d080752d0fc6bbcc67e561';

/// 토큰 서비스 Provider
///
/// Copied from [tokenService].
@ProviderFor(tokenService)
final tokenServiceProvider = AutoDisposeProvider<TokenService>.internal(
  tokenService,
  name: r'tokenServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$tokenServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TokenServiceRef = AutoDisposeProviderRef<TokenService>;
String _$authRepositoryHash() => r'f488b05abbbc320b0d7844435f934c0f3f24d50d';

/// 인증 리포지토리 Provider
///
/// Copied from [authRepository].
@ProviderFor(authRepository)
final authRepositoryProvider = AutoDisposeProvider<AuthRepository>.internal(
  authRepository,
  name: r'authRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthRepositoryRef = AutoDisposeProviderRef<AuthRepository>;
String _$currentUserHash() => r'74fffb932eb5a1ad664f891bf982812e39d228e4';

/// 현재 사용자 Provider
///
/// Copied from [CurrentUser].
@ProviderFor(CurrentUser)
final currentUserProvider =
    AutoDisposeAsyncNotifierProvider<CurrentUser, User?>.internal(
  CurrentUser.new,
  name: r'currentUserProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$currentUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CurrentUser = AutoDisposeAsyncNotifier<User?>;
String _$authStatusHash() => r'0b60a7edf1c89ac489933284815b71bb4a0324b5';

/// 로그인 상태 Provider
///
/// Copied from [AuthStatus].
@ProviderFor(AuthStatus)
final authStatusProvider =
    AutoDisposeAsyncNotifierProvider<AuthStatus, bool>.internal(
  AuthStatus.new,
  name: r'authStatusProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthStatus = AutoDisposeAsyncNotifier<bool>;
String _$biometricStatusHash() => r'8d292b8cd8b270725402b975db00fb3358299aac';

/// 생체 인증 상태 Provider
///
/// Copied from [BiometricStatus].
@ProviderFor(BiometricStatus)
final biometricStatusProvider =
    AutoDisposeAsyncNotifierProvider<BiometricStatus, bool>.internal(
  BiometricStatus.new,
  name: r'biometricStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$biometricStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BiometricStatus = AutoDisposeAsyncNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
