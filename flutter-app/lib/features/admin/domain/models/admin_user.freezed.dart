// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AdminUser _$AdminUserFromJson(Map<String, dynamic> json) {
  return _AdminUser.fromJson(json);
}

/// @nodoc
mixin _$AdminUser {
  String get id => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  AdminRole get role => throw _privateConstructorUsedError;
  String get department => throw _privateConstructorUsedError;
  String? get profileImageUrl => throw _privateConstructorUsedError;
  AdminStatus get status => throw _privateConstructorUsedError;
  int get processedReports => throw _privateConstructorUsedError;
  double get averageProcessingTime => throw _privateConstructorUsedError;
  double get satisfactionScore => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get lastLoginAt => throw _privateConstructorUsedError;
  List<String>? get specializations => throw _privateConstructorUsedError;
  String? get phoneNumber => throw _privateConstructorUsedError;
  String? get position => throw _privateConstructorUsedError;
  bool get isOnline => throw _privateConstructorUsedError;
  int get currentAssignments => throw _privateConstructorUsedError;
  int get maxAssignments => throw _privateConstructorUsedError;
  Map<String, dynamic>? get preferences => throw _privateConstructorUsedError;

  /// Serializes this AdminUser to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AdminUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdminUserCopyWith<AdminUser> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdminUserCopyWith<$Res> {
  factory $AdminUserCopyWith(AdminUser value, $Res Function(AdminUser) then) =
      _$AdminUserCopyWithImpl<$Res, AdminUser>;
  @useResult
  $Res call(
      {String id,
      String email,
      String name,
      AdminRole role,
      String department,
      String? profileImageUrl,
      AdminStatus status,
      int processedReports,
      double averageProcessingTime,
      double satisfactionScore,
      DateTime createdAt,
      DateTime? lastLoginAt,
      List<String>? specializations,
      String? phoneNumber,
      String? position,
      bool isOnline,
      int currentAssignments,
      int maxAssignments,
      Map<String, dynamic>? preferences});
}

/// @nodoc
class _$AdminUserCopyWithImpl<$Res, $Val extends AdminUser>
    implements $AdminUserCopyWith<$Res> {
  _$AdminUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AdminUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? name = null,
    Object? role = null,
    Object? department = null,
    Object? profileImageUrl = freezed,
    Object? status = null,
    Object? processedReports = null,
    Object? averageProcessingTime = null,
    Object? satisfactionScore = null,
    Object? createdAt = null,
    Object? lastLoginAt = freezed,
    Object? specializations = freezed,
    Object? phoneNumber = freezed,
    Object? position = freezed,
    Object? isOnline = null,
    Object? currentAssignments = null,
    Object? maxAssignments = null,
    Object? preferences = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as AdminRole,
      department: null == department
          ? _value.department
          : department // ignore: cast_nullable_to_non_nullable
              as String,
      profileImageUrl: freezed == profileImageUrl
          ? _value.profileImageUrl
          : profileImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as AdminStatus,
      processedReports: null == processedReports
          ? _value.processedReports
          : processedReports // ignore: cast_nullable_to_non_nullable
              as int,
      averageProcessingTime: null == averageProcessingTime
          ? _value.averageProcessingTime
          : averageProcessingTime // ignore: cast_nullable_to_non_nullable
              as double,
      satisfactionScore: null == satisfactionScore
          ? _value.satisfactionScore
          : satisfactionScore // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastLoginAt: freezed == lastLoginAt
          ? _value.lastLoginAt
          : lastLoginAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      specializations: freezed == specializations
          ? _value.specializations
          : specializations // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      position: freezed == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as String?,
      isOnline: null == isOnline
          ? _value.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool,
      currentAssignments: null == currentAssignments
          ? _value.currentAssignments
          : currentAssignments // ignore: cast_nullable_to_non_nullable
              as int,
      maxAssignments: null == maxAssignments
          ? _value.maxAssignments
          : maxAssignments // ignore: cast_nullable_to_non_nullable
              as int,
      preferences: freezed == preferences
          ? _value.preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AdminUserImplCopyWith<$Res>
    implements $AdminUserCopyWith<$Res> {
  factory _$$AdminUserImplCopyWith(
          _$AdminUserImpl value, $Res Function(_$AdminUserImpl) then) =
      __$$AdminUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String email,
      String name,
      AdminRole role,
      String department,
      String? profileImageUrl,
      AdminStatus status,
      int processedReports,
      double averageProcessingTime,
      double satisfactionScore,
      DateTime createdAt,
      DateTime? lastLoginAt,
      List<String>? specializations,
      String? phoneNumber,
      String? position,
      bool isOnline,
      int currentAssignments,
      int maxAssignments,
      Map<String, dynamic>? preferences});
}

/// @nodoc
class __$$AdminUserImplCopyWithImpl<$Res>
    extends _$AdminUserCopyWithImpl<$Res, _$AdminUserImpl>
    implements _$$AdminUserImplCopyWith<$Res> {
  __$$AdminUserImplCopyWithImpl(
      _$AdminUserImpl _value, $Res Function(_$AdminUserImpl) _then)
      : super(_value, _then);

  /// Create a copy of AdminUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? name = null,
    Object? role = null,
    Object? department = null,
    Object? profileImageUrl = freezed,
    Object? status = null,
    Object? processedReports = null,
    Object? averageProcessingTime = null,
    Object? satisfactionScore = null,
    Object? createdAt = null,
    Object? lastLoginAt = freezed,
    Object? specializations = freezed,
    Object? phoneNumber = freezed,
    Object? position = freezed,
    Object? isOnline = null,
    Object? currentAssignments = null,
    Object? maxAssignments = null,
    Object? preferences = freezed,
  }) {
    return _then(_$AdminUserImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as AdminRole,
      department: null == department
          ? _value.department
          : department // ignore: cast_nullable_to_non_nullable
              as String,
      profileImageUrl: freezed == profileImageUrl
          ? _value.profileImageUrl
          : profileImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as AdminStatus,
      processedReports: null == processedReports
          ? _value.processedReports
          : processedReports // ignore: cast_nullable_to_non_nullable
              as int,
      averageProcessingTime: null == averageProcessingTime
          ? _value.averageProcessingTime
          : averageProcessingTime // ignore: cast_nullable_to_non_nullable
              as double,
      satisfactionScore: null == satisfactionScore
          ? _value.satisfactionScore
          : satisfactionScore // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastLoginAt: freezed == lastLoginAt
          ? _value.lastLoginAt
          : lastLoginAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      specializations: freezed == specializations
          ? _value._specializations
          : specializations // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      position: freezed == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as String?,
      isOnline: null == isOnline
          ? _value.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool,
      currentAssignments: null == currentAssignments
          ? _value.currentAssignments
          : currentAssignments // ignore: cast_nullable_to_non_nullable
              as int,
      maxAssignments: null == maxAssignments
          ? _value.maxAssignments
          : maxAssignments // ignore: cast_nullable_to_non_nullable
              as int,
      preferences: freezed == preferences
          ? _value._preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AdminUserImpl implements _AdminUser {
  const _$AdminUserImpl(
      {required this.id,
      required this.email,
      required this.name,
      required this.role,
      required this.department,
      this.profileImageUrl,
      this.status = AdminStatus.active,
      this.processedReports = 0,
      this.averageProcessingTime = 0.0,
      this.satisfactionScore = 0.0,
      required this.createdAt,
      this.lastLoginAt,
      final List<String>? specializations,
      this.phoneNumber,
      this.position,
      this.isOnline = false,
      this.currentAssignments = 0,
      this.maxAssignments = 5,
      final Map<String, dynamic>? preferences})
      : _specializations = specializations,
        _preferences = preferences;

  factory _$AdminUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$AdminUserImplFromJson(json);

  @override
  final String id;
  @override
  final String email;
  @override
  final String name;
  @override
  final AdminRole role;
  @override
  final String department;
  @override
  final String? profileImageUrl;
  @override
  @JsonKey()
  final AdminStatus status;
  @override
  @JsonKey()
  final int processedReports;
  @override
  @JsonKey()
  final double averageProcessingTime;
  @override
  @JsonKey()
  final double satisfactionScore;
  @override
  final DateTime createdAt;
  @override
  final DateTime? lastLoginAt;
  final List<String>? _specializations;
  @override
  List<String>? get specializations {
    final value = _specializations;
    if (value == null) return null;
    if (_specializations is EqualUnmodifiableListView) return _specializations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? phoneNumber;
  @override
  final String? position;
  @override
  @JsonKey()
  final bool isOnline;
  @override
  @JsonKey()
  final int currentAssignments;
  @override
  @JsonKey()
  final int maxAssignments;
  final Map<String, dynamic>? _preferences;
  @override
  Map<String, dynamic>? get preferences {
    final value = _preferences;
    if (value == null) return null;
    if (_preferences is EqualUnmodifiableMapView) return _preferences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AdminUser(id: $id, email: $email, name: $name, role: $role, department: $department, profileImageUrl: $profileImageUrl, status: $status, processedReports: $processedReports, averageProcessingTime: $averageProcessingTime, satisfactionScore: $satisfactionScore, createdAt: $createdAt, lastLoginAt: $lastLoginAt, specializations: $specializations, phoneNumber: $phoneNumber, position: $position, isOnline: $isOnline, currentAssignments: $currentAssignments, maxAssignments: $maxAssignments, preferences: $preferences)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminUserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.department, department) ||
                other.department == department) &&
            (identical(other.profileImageUrl, profileImageUrl) ||
                other.profileImageUrl == profileImageUrl) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.processedReports, processedReports) ||
                other.processedReports == processedReports) &&
            (identical(other.averageProcessingTime, averageProcessingTime) ||
                other.averageProcessingTime == averageProcessingTime) &&
            (identical(other.satisfactionScore, satisfactionScore) ||
                other.satisfactionScore == satisfactionScore) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastLoginAt, lastLoginAt) ||
                other.lastLoginAt == lastLoginAt) &&
            const DeepCollectionEquality()
                .equals(other._specializations, _specializations) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.isOnline, isOnline) ||
                other.isOnline == isOnline) &&
            (identical(other.currentAssignments, currentAssignments) ||
                other.currentAssignments == currentAssignments) &&
            (identical(other.maxAssignments, maxAssignments) ||
                other.maxAssignments == maxAssignments) &&
            const DeepCollectionEquality()
                .equals(other._preferences, _preferences));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        email,
        name,
        role,
        department,
        profileImageUrl,
        status,
        processedReports,
        averageProcessingTime,
        satisfactionScore,
        createdAt,
        lastLoginAt,
        const DeepCollectionEquality().hash(_specializations),
        phoneNumber,
        position,
        isOnline,
        currentAssignments,
        maxAssignments,
        const DeepCollectionEquality().hash(_preferences)
      ]);

  /// Create a copy of AdminUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdminUserImplCopyWith<_$AdminUserImpl> get copyWith =>
      __$$AdminUserImplCopyWithImpl<_$AdminUserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AdminUserImplToJson(
      this,
    );
  }
}

abstract class _AdminUser implements AdminUser {
  const factory _AdminUser(
      {required final String id,
      required final String email,
      required final String name,
      required final AdminRole role,
      required final String department,
      final String? profileImageUrl,
      final AdminStatus status,
      final int processedReports,
      final double averageProcessingTime,
      final double satisfactionScore,
      required final DateTime createdAt,
      final DateTime? lastLoginAt,
      final List<String>? specializations,
      final String? phoneNumber,
      final String? position,
      final bool isOnline,
      final int currentAssignments,
      final int maxAssignments,
      final Map<String, dynamic>? preferences}) = _$AdminUserImpl;

  factory _AdminUser.fromJson(Map<String, dynamic> json) =
      _$AdminUserImpl.fromJson;

  @override
  String get id;
  @override
  String get email;
  @override
  String get name;
  @override
  AdminRole get role;
  @override
  String get department;
  @override
  String? get profileImageUrl;
  @override
  AdminStatus get status;
  @override
  int get processedReports;
  @override
  double get averageProcessingTime;
  @override
  double get satisfactionScore;
  @override
  DateTime get createdAt;
  @override
  DateTime? get lastLoginAt;
  @override
  List<String>? get specializations;
  @override
  String? get phoneNumber;
  @override
  String? get position;
  @override
  bool get isOnline;
  @override
  int get currentAssignments;
  @override
  int get maxAssignments;
  @override
  Map<String, dynamic>? get preferences;

  /// Create a copy of AdminUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdminUserImplCopyWith<_$AdminUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
