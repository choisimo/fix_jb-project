// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

NotificationSettings _$NotificationSettingsFromJson(Map<String, dynamic> json) {
  return _NotificationSettings.fromJson(json);
}

/// @nodoc
mixin _$NotificationSettings {
// 기본 알림 설정
  bool get enableNotifications => throw _privateConstructorUsedError;
  bool get enablePushNotifications => throw _privateConstructorUsedError;
  bool get enableInAppNotifications => throw _privateConstructorUsedError;
  bool get enableEmailNotifications =>
      throw _privateConstructorUsedError; // 소리 및 진동 설정
  bool get enableSound => throw _privateConstructorUsedError;
  bool get enableVibration => throw _privateConstructorUsedError;
  bool get enableLedIndicator =>
      throw _privateConstructorUsedError; // 타입별 알림 설정
  bool get enableReportStatusNotifications =>
      throw _privateConstructorUsedError;
  bool get enableCommentNotifications => throw _privateConstructorUsedError;
  bool get enableSystemNotifications => throw _privateConstructorUsedError;
  bool get enableAnnouncementNotifications =>
      throw _privateConstructorUsedError;
  bool get enableReminderNotifications =>
      throw _privateConstructorUsedError; // 시간 설정
  String get quietHoursStart => throw _privateConstructorUsedError;
  String get quietHoursEnd => throw _privateConstructorUsedError;
  bool get enableQuietHours => throw _privateConstructorUsedError; // 고급 설정
  NotificationPriority get minimumPriority =>
      throw _privateConstructorUsedError;
  int get maxNotificationsPerDay => throw _privateConstructorUsedError;
  bool get groupSimilarNotifications =>
      throw _privateConstructorUsedError; // FCM 토큰
  String? get fcmToken => throw _privateConstructorUsedError; // 마지막 업데이트 시간
  DateTime? get lastUpdated => throw _privateConstructorUsedError;

  /// Serializes this NotificationSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationSettingsCopyWith<NotificationSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationSettingsCopyWith<$Res> {
  factory $NotificationSettingsCopyWith(NotificationSettings value,
          $Res Function(NotificationSettings) then) =
      _$NotificationSettingsCopyWithImpl<$Res, NotificationSettings>;
  @useResult
  $Res call(
      {bool enableNotifications,
      bool enablePushNotifications,
      bool enableInAppNotifications,
      bool enableEmailNotifications,
      bool enableSound,
      bool enableVibration,
      bool enableLedIndicator,
      bool enableReportStatusNotifications,
      bool enableCommentNotifications,
      bool enableSystemNotifications,
      bool enableAnnouncementNotifications,
      bool enableReminderNotifications,
      String quietHoursStart,
      String quietHoursEnd,
      bool enableQuietHours,
      NotificationPriority minimumPriority,
      int maxNotificationsPerDay,
      bool groupSimilarNotifications,
      String? fcmToken,
      DateTime? lastUpdated});
}

/// @nodoc
class _$NotificationSettingsCopyWithImpl<$Res,
        $Val extends NotificationSettings>
    implements $NotificationSettingsCopyWith<$Res> {
  _$NotificationSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enableNotifications = null,
    Object? enablePushNotifications = null,
    Object? enableInAppNotifications = null,
    Object? enableEmailNotifications = null,
    Object? enableSound = null,
    Object? enableVibration = null,
    Object? enableLedIndicator = null,
    Object? enableReportStatusNotifications = null,
    Object? enableCommentNotifications = null,
    Object? enableSystemNotifications = null,
    Object? enableAnnouncementNotifications = null,
    Object? enableReminderNotifications = null,
    Object? quietHoursStart = null,
    Object? quietHoursEnd = null,
    Object? enableQuietHours = null,
    Object? minimumPriority = null,
    Object? maxNotificationsPerDay = null,
    Object? groupSimilarNotifications = null,
    Object? fcmToken = freezed,
    Object? lastUpdated = freezed,
  }) {
    return _then(_value.copyWith(
      enableNotifications: null == enableNotifications
          ? _value.enableNotifications
          : enableNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      enablePushNotifications: null == enablePushNotifications
          ? _value.enablePushNotifications
          : enablePushNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      enableInAppNotifications: null == enableInAppNotifications
          ? _value.enableInAppNotifications
          : enableInAppNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      enableEmailNotifications: null == enableEmailNotifications
          ? _value.enableEmailNotifications
          : enableEmailNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      enableSound: null == enableSound
          ? _value.enableSound
          : enableSound // ignore: cast_nullable_to_non_nullable
              as bool,
      enableVibration: null == enableVibration
          ? _value.enableVibration
          : enableVibration // ignore: cast_nullable_to_non_nullable
              as bool,
      enableLedIndicator: null == enableLedIndicator
          ? _value.enableLedIndicator
          : enableLedIndicator // ignore: cast_nullable_to_non_nullable
              as bool,
      enableReportStatusNotifications: null == enableReportStatusNotifications
          ? _value.enableReportStatusNotifications
          : enableReportStatusNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      enableCommentNotifications: null == enableCommentNotifications
          ? _value.enableCommentNotifications
          : enableCommentNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      enableSystemNotifications: null == enableSystemNotifications
          ? _value.enableSystemNotifications
          : enableSystemNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      enableAnnouncementNotifications: null == enableAnnouncementNotifications
          ? _value.enableAnnouncementNotifications
          : enableAnnouncementNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      enableReminderNotifications: null == enableReminderNotifications
          ? _value.enableReminderNotifications
          : enableReminderNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      quietHoursStart: null == quietHoursStart
          ? _value.quietHoursStart
          : quietHoursStart // ignore: cast_nullable_to_non_nullable
              as String,
      quietHoursEnd: null == quietHoursEnd
          ? _value.quietHoursEnd
          : quietHoursEnd // ignore: cast_nullable_to_non_nullable
              as String,
      enableQuietHours: null == enableQuietHours
          ? _value.enableQuietHours
          : enableQuietHours // ignore: cast_nullable_to_non_nullable
              as bool,
      minimumPriority: null == minimumPriority
          ? _value.minimumPriority
          : minimumPriority // ignore: cast_nullable_to_non_nullable
              as NotificationPriority,
      maxNotificationsPerDay: null == maxNotificationsPerDay
          ? _value.maxNotificationsPerDay
          : maxNotificationsPerDay // ignore: cast_nullable_to_non_nullable
              as int,
      groupSimilarNotifications: null == groupSimilarNotifications
          ? _value.groupSimilarNotifications
          : groupSimilarNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      fcmToken: freezed == fcmToken
          ? _value.fcmToken
          : fcmToken // ignore: cast_nullable_to_non_nullable
              as String?,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationSettingsImplCopyWith<$Res>
    implements $NotificationSettingsCopyWith<$Res> {
  factory _$$NotificationSettingsImplCopyWith(_$NotificationSettingsImpl value,
          $Res Function(_$NotificationSettingsImpl) then) =
      __$$NotificationSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool enableNotifications,
      bool enablePushNotifications,
      bool enableInAppNotifications,
      bool enableEmailNotifications,
      bool enableSound,
      bool enableVibration,
      bool enableLedIndicator,
      bool enableReportStatusNotifications,
      bool enableCommentNotifications,
      bool enableSystemNotifications,
      bool enableAnnouncementNotifications,
      bool enableReminderNotifications,
      String quietHoursStart,
      String quietHoursEnd,
      bool enableQuietHours,
      NotificationPriority minimumPriority,
      int maxNotificationsPerDay,
      bool groupSimilarNotifications,
      String? fcmToken,
      DateTime? lastUpdated});
}

/// @nodoc
class __$$NotificationSettingsImplCopyWithImpl<$Res>
    extends _$NotificationSettingsCopyWithImpl<$Res, _$NotificationSettingsImpl>
    implements _$$NotificationSettingsImplCopyWith<$Res> {
  __$$NotificationSettingsImplCopyWithImpl(_$NotificationSettingsImpl _value,
      $Res Function(_$NotificationSettingsImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enableNotifications = null,
    Object? enablePushNotifications = null,
    Object? enableInAppNotifications = null,
    Object? enableEmailNotifications = null,
    Object? enableSound = null,
    Object? enableVibration = null,
    Object? enableLedIndicator = null,
    Object? enableReportStatusNotifications = null,
    Object? enableCommentNotifications = null,
    Object? enableSystemNotifications = null,
    Object? enableAnnouncementNotifications = null,
    Object? enableReminderNotifications = null,
    Object? quietHoursStart = null,
    Object? quietHoursEnd = null,
    Object? enableQuietHours = null,
    Object? minimumPriority = null,
    Object? maxNotificationsPerDay = null,
    Object? groupSimilarNotifications = null,
    Object? fcmToken = freezed,
    Object? lastUpdated = freezed,
  }) {
    return _then(_$NotificationSettingsImpl(
      enableNotifications: null == enableNotifications
          ? _value.enableNotifications
          : enableNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      enablePushNotifications: null == enablePushNotifications
          ? _value.enablePushNotifications
          : enablePushNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      enableInAppNotifications: null == enableInAppNotifications
          ? _value.enableInAppNotifications
          : enableInAppNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      enableEmailNotifications: null == enableEmailNotifications
          ? _value.enableEmailNotifications
          : enableEmailNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      enableSound: null == enableSound
          ? _value.enableSound
          : enableSound // ignore: cast_nullable_to_non_nullable
              as bool,
      enableVibration: null == enableVibration
          ? _value.enableVibration
          : enableVibration // ignore: cast_nullable_to_non_nullable
              as bool,
      enableLedIndicator: null == enableLedIndicator
          ? _value.enableLedIndicator
          : enableLedIndicator // ignore: cast_nullable_to_non_nullable
              as bool,
      enableReportStatusNotifications: null == enableReportStatusNotifications
          ? _value.enableReportStatusNotifications
          : enableReportStatusNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      enableCommentNotifications: null == enableCommentNotifications
          ? _value.enableCommentNotifications
          : enableCommentNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      enableSystemNotifications: null == enableSystemNotifications
          ? _value.enableSystemNotifications
          : enableSystemNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      enableAnnouncementNotifications: null == enableAnnouncementNotifications
          ? _value.enableAnnouncementNotifications
          : enableAnnouncementNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      enableReminderNotifications: null == enableReminderNotifications
          ? _value.enableReminderNotifications
          : enableReminderNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      quietHoursStart: null == quietHoursStart
          ? _value.quietHoursStart
          : quietHoursStart // ignore: cast_nullable_to_non_nullable
              as String,
      quietHoursEnd: null == quietHoursEnd
          ? _value.quietHoursEnd
          : quietHoursEnd // ignore: cast_nullable_to_non_nullable
              as String,
      enableQuietHours: null == enableQuietHours
          ? _value.enableQuietHours
          : enableQuietHours // ignore: cast_nullable_to_non_nullable
              as bool,
      minimumPriority: null == minimumPriority
          ? _value.minimumPriority
          : minimumPriority // ignore: cast_nullable_to_non_nullable
              as NotificationPriority,
      maxNotificationsPerDay: null == maxNotificationsPerDay
          ? _value.maxNotificationsPerDay
          : maxNotificationsPerDay // ignore: cast_nullable_to_non_nullable
              as int,
      groupSimilarNotifications: null == groupSimilarNotifications
          ? _value.groupSimilarNotifications
          : groupSimilarNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      fcmToken: freezed == fcmToken
          ? _value.fcmToken
          : fcmToken // ignore: cast_nullable_to_non_nullable
              as String?,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationSettingsImpl extends _NotificationSettings {
  const _$NotificationSettingsImpl(
      {this.enableNotifications = true,
      this.enablePushNotifications = true,
      this.enableInAppNotifications = true,
      this.enableEmailNotifications = true,
      this.enableSound = true,
      this.enableVibration = true,
      this.enableLedIndicator = true,
      this.enableReportStatusNotifications = true,
      this.enableCommentNotifications = true,
      this.enableSystemNotifications = true,
      this.enableAnnouncementNotifications = true,
      this.enableReminderNotifications = false,
      this.quietHoursStart = '09:00',
      this.quietHoursEnd = '22:00',
      this.enableQuietHours = false,
      this.minimumPriority = NotificationPriority.normal,
      this.maxNotificationsPerDay = 100,
      this.groupSimilarNotifications = false,
      this.fcmToken,
      this.lastUpdated})
      : super._();

  factory _$NotificationSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationSettingsImplFromJson(json);

// 기본 알림 설정
  @override
  @JsonKey()
  final bool enableNotifications;
  @override
  @JsonKey()
  final bool enablePushNotifications;
  @override
  @JsonKey()
  final bool enableInAppNotifications;
  @override
  @JsonKey()
  final bool enableEmailNotifications;
// 소리 및 진동 설정
  @override
  @JsonKey()
  final bool enableSound;
  @override
  @JsonKey()
  final bool enableVibration;
  @override
  @JsonKey()
  final bool enableLedIndicator;
// 타입별 알림 설정
  @override
  @JsonKey()
  final bool enableReportStatusNotifications;
  @override
  @JsonKey()
  final bool enableCommentNotifications;
  @override
  @JsonKey()
  final bool enableSystemNotifications;
  @override
  @JsonKey()
  final bool enableAnnouncementNotifications;
  @override
  @JsonKey()
  final bool enableReminderNotifications;
// 시간 설정
  @override
  @JsonKey()
  final String quietHoursStart;
  @override
  @JsonKey()
  final String quietHoursEnd;
  @override
  @JsonKey()
  final bool enableQuietHours;
// 고급 설정
  @override
  @JsonKey()
  final NotificationPriority minimumPriority;
  @override
  @JsonKey()
  final int maxNotificationsPerDay;
  @override
  @JsonKey()
  final bool groupSimilarNotifications;
// FCM 토큰
  @override
  final String? fcmToken;
// 마지막 업데이트 시간
  @override
  final DateTime? lastUpdated;

  @override
  String toString() {
    return 'NotificationSettings(enableNotifications: $enableNotifications, enablePushNotifications: $enablePushNotifications, enableInAppNotifications: $enableInAppNotifications, enableEmailNotifications: $enableEmailNotifications, enableSound: $enableSound, enableVibration: $enableVibration, enableLedIndicator: $enableLedIndicator, enableReportStatusNotifications: $enableReportStatusNotifications, enableCommentNotifications: $enableCommentNotifications, enableSystemNotifications: $enableSystemNotifications, enableAnnouncementNotifications: $enableAnnouncementNotifications, enableReminderNotifications: $enableReminderNotifications, quietHoursStart: $quietHoursStart, quietHoursEnd: $quietHoursEnd, enableQuietHours: $enableQuietHours, minimumPriority: $minimumPriority, maxNotificationsPerDay: $maxNotificationsPerDay, groupSimilarNotifications: $groupSimilarNotifications, fcmToken: $fcmToken, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationSettingsImpl &&
            (identical(other.enableNotifications, enableNotifications) ||
                other.enableNotifications == enableNotifications) &&
            (identical(other.enablePushNotifications, enablePushNotifications) ||
                other.enablePushNotifications == enablePushNotifications) &&
            (identical(other.enableInAppNotifications, enableInAppNotifications) ||
                other.enableInAppNotifications == enableInAppNotifications) &&
            (identical(other.enableEmailNotifications, enableEmailNotifications) ||
                other.enableEmailNotifications == enableEmailNotifications) &&
            (identical(other.enableSound, enableSound) ||
                other.enableSound == enableSound) &&
            (identical(other.enableVibration, enableVibration) ||
                other.enableVibration == enableVibration) &&
            (identical(other.enableLedIndicator, enableLedIndicator) ||
                other.enableLedIndicator == enableLedIndicator) &&
            (identical(other.enableReportStatusNotifications, enableReportStatusNotifications) ||
                other.enableReportStatusNotifications ==
                    enableReportStatusNotifications) &&
            (identical(other.enableCommentNotifications, enableCommentNotifications) ||
                other.enableCommentNotifications ==
                    enableCommentNotifications) &&
            (identical(other.enableSystemNotifications, enableSystemNotifications) ||
                other.enableSystemNotifications == enableSystemNotifications) &&
            (identical(other.enableAnnouncementNotifications, enableAnnouncementNotifications) ||
                other.enableAnnouncementNotifications ==
                    enableAnnouncementNotifications) &&
            (identical(other.enableReminderNotifications, enableReminderNotifications) ||
                other.enableReminderNotifications ==
                    enableReminderNotifications) &&
            (identical(other.quietHoursStart, quietHoursStart) ||
                other.quietHoursStart == quietHoursStart) &&
            (identical(other.quietHoursEnd, quietHoursEnd) ||
                other.quietHoursEnd == quietHoursEnd) &&
            (identical(other.enableQuietHours, enableQuietHours) ||
                other.enableQuietHours == enableQuietHours) &&
            (identical(other.minimumPriority, minimumPriority) ||
                other.minimumPriority == minimumPriority) &&
            (identical(other.maxNotificationsPerDay, maxNotificationsPerDay) ||
                other.maxNotificationsPerDay == maxNotificationsPerDay) &&
            (identical(other.groupSimilarNotifications, groupSimilarNotifications) || other.groupSimilarNotifications == groupSimilarNotifications) &&
            (identical(other.fcmToken, fcmToken) || other.fcmToken == fcmToken) &&
            (identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        enableNotifications,
        enablePushNotifications,
        enableInAppNotifications,
        enableEmailNotifications,
        enableSound,
        enableVibration,
        enableLedIndicator,
        enableReportStatusNotifications,
        enableCommentNotifications,
        enableSystemNotifications,
        enableAnnouncementNotifications,
        enableReminderNotifications,
        quietHoursStart,
        quietHoursEnd,
        enableQuietHours,
        minimumPriority,
        maxNotificationsPerDay,
        groupSimilarNotifications,
        fcmToken,
        lastUpdated
      ]);

  /// Create a copy of NotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationSettingsImplCopyWith<_$NotificationSettingsImpl>
      get copyWith =>
          __$$NotificationSettingsImplCopyWithImpl<_$NotificationSettingsImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationSettingsImplToJson(
      this,
    );
  }
}

abstract class _NotificationSettings extends NotificationSettings {
  const factory _NotificationSettings(
      {final bool enableNotifications,
      final bool enablePushNotifications,
      final bool enableInAppNotifications,
      final bool enableEmailNotifications,
      final bool enableSound,
      final bool enableVibration,
      final bool enableLedIndicator,
      final bool enableReportStatusNotifications,
      final bool enableCommentNotifications,
      final bool enableSystemNotifications,
      final bool enableAnnouncementNotifications,
      final bool enableReminderNotifications,
      final String quietHoursStart,
      final String quietHoursEnd,
      final bool enableQuietHours,
      final NotificationPriority minimumPriority,
      final int maxNotificationsPerDay,
      final bool groupSimilarNotifications,
      final String? fcmToken,
      final DateTime? lastUpdated}) = _$NotificationSettingsImpl;
  const _NotificationSettings._() : super._();

  factory _NotificationSettings.fromJson(Map<String, dynamic> json) =
      _$NotificationSettingsImpl.fromJson;

// 기본 알림 설정
  @override
  bool get enableNotifications;
  @override
  bool get enablePushNotifications;
  @override
  bool get enableInAppNotifications;
  @override
  bool get enableEmailNotifications; // 소리 및 진동 설정
  @override
  bool get enableSound;
  @override
  bool get enableVibration;
  @override
  bool get enableLedIndicator; // 타입별 알림 설정
  @override
  bool get enableReportStatusNotifications;
  @override
  bool get enableCommentNotifications;
  @override
  bool get enableSystemNotifications;
  @override
  bool get enableAnnouncementNotifications;
  @override
  bool get enableReminderNotifications; // 시간 설정
  @override
  String get quietHoursStart;
  @override
  String get quietHoursEnd;
  @override
  bool get enableQuietHours; // 고급 설정
  @override
  NotificationPriority get minimumPriority;
  @override
  int get maxNotificationsPerDay;
  @override
  bool get groupSimilarNotifications; // FCM 토큰
  @override
  String? get fcmToken; // 마지막 업데이트 시간
  @override
  DateTime? get lastUpdated;

  /// Create a copy of NotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationSettingsImplCopyWith<_$NotificationSettingsImpl>
      get copyWith => throw _privateConstructorUsedError;
}

NotificationAction _$NotificationActionFromJson(Map<String, dynamic> json) {
  return _NotificationAction.fromJson(json);
}

/// @nodoc
mixin _$NotificationAction {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get icon => throw _privateConstructorUsedError;
  Map<String, dynamic>? get data => throw _privateConstructorUsedError;

  /// Serializes this NotificationAction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationActionCopyWith<NotificationAction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationActionCopyWith<$Res> {
  factory $NotificationActionCopyWith(
          NotificationAction value, $Res Function(NotificationAction) then) =
      _$NotificationActionCopyWithImpl<$Res, NotificationAction>;
  @useResult
  $Res call(
      {String id, String title, String? icon, Map<String, dynamic>? data});
}

/// @nodoc
class _$NotificationActionCopyWithImpl<$Res, $Val extends NotificationAction>
    implements $NotificationActionCopyWith<$Res> {
  _$NotificationActionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? icon = freezed,
    Object? data = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationActionImplCopyWith<$Res>
    implements $NotificationActionCopyWith<$Res> {
  factory _$$NotificationActionImplCopyWith(_$NotificationActionImpl value,
          $Res Function(_$NotificationActionImpl) then) =
      __$$NotificationActionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id, String title, String? icon, Map<String, dynamic>? data});
}

/// @nodoc
class __$$NotificationActionImplCopyWithImpl<$Res>
    extends _$NotificationActionCopyWithImpl<$Res, _$NotificationActionImpl>
    implements _$$NotificationActionImplCopyWith<$Res> {
  __$$NotificationActionImplCopyWithImpl(_$NotificationActionImpl _value,
      $Res Function(_$NotificationActionImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? icon = freezed,
    Object? data = freezed,
  }) {
    return _then(_$NotificationActionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
      data: freezed == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationActionImpl implements _NotificationAction {
  const _$NotificationActionImpl(
      {required this.id,
      required this.title,
      this.icon,
      final Map<String, dynamic>? data})
      : _data = data;

  factory _$NotificationActionImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationActionImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String? icon;
  final Map<String, dynamic>? _data;
  @override
  Map<String, dynamic>? get data {
    final value = _data;
    if (value == null) return null;
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'NotificationAction(id: $id, title: $title, icon: $icon, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationActionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, title, icon, const DeepCollectionEquality().hash(_data));

  /// Create a copy of NotificationAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationActionImplCopyWith<_$NotificationActionImpl> get copyWith =>
      __$$NotificationActionImplCopyWithImpl<_$NotificationActionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationActionImplToJson(
      this,
    );
  }
}

abstract class _NotificationAction implements NotificationAction {
  const factory _NotificationAction(
      {required final String id,
      required final String title,
      final String? icon,
      final Map<String, dynamic>? data}) = _$NotificationActionImpl;

  factory _NotificationAction.fromJson(Map<String, dynamic> json) =
      _$NotificationActionImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String? get icon;
  @override
  Map<String, dynamic>? get data;

  /// Create a copy of NotificationAction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationActionImplCopyWith<_$NotificationActionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
