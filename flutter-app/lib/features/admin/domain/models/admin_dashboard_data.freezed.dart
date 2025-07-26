// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_dashboard_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AdminDashboardData _$AdminDashboardDataFromJson(Map<String, dynamic> json) {
  return _AdminDashboardData.fromJson(json);
}

/// @nodoc
mixin _$AdminDashboardData {
  int get totalReports => throw _privateConstructorUsedError;
  int get pendingReports => throw _privateConstructorUsedError;
  int get todayReports => throw _privateConstructorUsedError;
  int get thisWeekReports => throw _privateConstructorUsedError;
  int get thisMonthReports => throw _privateConstructorUsedError;
  double get completionRate => throw _privateConstructorUsedError;
  double get averageProcessingHours => throw _privateConstructorUsedError;
  int get urgentReports => throw _privateConstructorUsedError;
  int get activeAdmins => throw _privateConstructorUsedError;
  List<ChartData> get dailyTrend => throw _privateConstructorUsedError;
  List<ChartData> get categoryDistribution =>
      throw _privateConstructorUsedError;
  List<ChartData> get statusDistribution => throw _privateConstructorUsedError;
  List<ChartData> get regionDistribution => throw _privateConstructorUsedError;
  List<ProcessingTimeData> get processingTimes =>
      throw _privateConstructorUsedError;
  List<AdminPerformanceData> get teamPerformance =>
      throw _privateConstructorUsedError;
  DateTime get lastUpdated => throw _privateConstructorUsedError;
  SystemHealthData? get systemHealth => throw _privateConstructorUsedError;
  List<RecentActivity>? get recentActivities =>
      throw _privateConstructorUsedError;

  /// Serializes this AdminDashboardData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AdminDashboardData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdminDashboardDataCopyWith<AdminDashboardData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdminDashboardDataCopyWith<$Res> {
  factory $AdminDashboardDataCopyWith(
          AdminDashboardData value, $Res Function(AdminDashboardData) then) =
      _$AdminDashboardDataCopyWithImpl<$Res, AdminDashboardData>;
  @useResult
  $Res call(
      {int totalReports,
      int pendingReports,
      int todayReports,
      int thisWeekReports,
      int thisMonthReports,
      double completionRate,
      double averageProcessingHours,
      int urgentReports,
      int activeAdmins,
      List<ChartData> dailyTrend,
      List<ChartData> categoryDistribution,
      List<ChartData> statusDistribution,
      List<ChartData> regionDistribution,
      List<ProcessingTimeData> processingTimes,
      List<AdminPerformanceData> teamPerformance,
      DateTime lastUpdated,
      SystemHealthData? systemHealth,
      List<RecentActivity>? recentActivities});

  $SystemHealthDataCopyWith<$Res>? get systemHealth;
}

/// @nodoc
class _$AdminDashboardDataCopyWithImpl<$Res, $Val extends AdminDashboardData>
    implements $AdminDashboardDataCopyWith<$Res> {
  _$AdminDashboardDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AdminDashboardData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalReports = null,
    Object? pendingReports = null,
    Object? todayReports = null,
    Object? thisWeekReports = null,
    Object? thisMonthReports = null,
    Object? completionRate = null,
    Object? averageProcessingHours = null,
    Object? urgentReports = null,
    Object? activeAdmins = null,
    Object? dailyTrend = null,
    Object? categoryDistribution = null,
    Object? statusDistribution = null,
    Object? regionDistribution = null,
    Object? processingTimes = null,
    Object? teamPerformance = null,
    Object? lastUpdated = null,
    Object? systemHealth = freezed,
    Object? recentActivities = freezed,
  }) {
    return _then(_value.copyWith(
      totalReports: null == totalReports
          ? _value.totalReports
          : totalReports // ignore: cast_nullable_to_non_nullable
              as int,
      pendingReports: null == pendingReports
          ? _value.pendingReports
          : pendingReports // ignore: cast_nullable_to_non_nullable
              as int,
      todayReports: null == todayReports
          ? _value.todayReports
          : todayReports // ignore: cast_nullable_to_non_nullable
              as int,
      thisWeekReports: null == thisWeekReports
          ? _value.thisWeekReports
          : thisWeekReports // ignore: cast_nullable_to_non_nullable
              as int,
      thisMonthReports: null == thisMonthReports
          ? _value.thisMonthReports
          : thisMonthReports // ignore: cast_nullable_to_non_nullable
              as int,
      completionRate: null == completionRate
          ? _value.completionRate
          : completionRate // ignore: cast_nullable_to_non_nullable
              as double,
      averageProcessingHours: null == averageProcessingHours
          ? _value.averageProcessingHours
          : averageProcessingHours // ignore: cast_nullable_to_non_nullable
              as double,
      urgentReports: null == urgentReports
          ? _value.urgentReports
          : urgentReports // ignore: cast_nullable_to_non_nullable
              as int,
      activeAdmins: null == activeAdmins
          ? _value.activeAdmins
          : activeAdmins // ignore: cast_nullable_to_non_nullable
              as int,
      dailyTrend: null == dailyTrend
          ? _value.dailyTrend
          : dailyTrend // ignore: cast_nullable_to_non_nullable
              as List<ChartData>,
      categoryDistribution: null == categoryDistribution
          ? _value.categoryDistribution
          : categoryDistribution // ignore: cast_nullable_to_non_nullable
              as List<ChartData>,
      statusDistribution: null == statusDistribution
          ? _value.statusDistribution
          : statusDistribution // ignore: cast_nullable_to_non_nullable
              as List<ChartData>,
      regionDistribution: null == regionDistribution
          ? _value.regionDistribution
          : regionDistribution // ignore: cast_nullable_to_non_nullable
              as List<ChartData>,
      processingTimes: null == processingTimes
          ? _value.processingTimes
          : processingTimes // ignore: cast_nullable_to_non_nullable
              as List<ProcessingTimeData>,
      teamPerformance: null == teamPerformance
          ? _value.teamPerformance
          : teamPerformance // ignore: cast_nullable_to_non_nullable
              as List<AdminPerformanceData>,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
      systemHealth: freezed == systemHealth
          ? _value.systemHealth
          : systemHealth // ignore: cast_nullable_to_non_nullable
              as SystemHealthData?,
      recentActivities: freezed == recentActivities
          ? _value.recentActivities
          : recentActivities // ignore: cast_nullable_to_non_nullable
              as List<RecentActivity>?,
    ) as $Val);
  }

  /// Create a copy of AdminDashboardData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SystemHealthDataCopyWith<$Res>? get systemHealth {
    if (_value.systemHealth == null) {
      return null;
    }

    return $SystemHealthDataCopyWith<$Res>(_value.systemHealth!, (value) {
      return _then(_value.copyWith(systemHealth: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AdminDashboardDataImplCopyWith<$Res>
    implements $AdminDashboardDataCopyWith<$Res> {
  factory _$$AdminDashboardDataImplCopyWith(_$AdminDashboardDataImpl value,
          $Res Function(_$AdminDashboardDataImpl) then) =
      __$$AdminDashboardDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalReports,
      int pendingReports,
      int todayReports,
      int thisWeekReports,
      int thisMonthReports,
      double completionRate,
      double averageProcessingHours,
      int urgentReports,
      int activeAdmins,
      List<ChartData> dailyTrend,
      List<ChartData> categoryDistribution,
      List<ChartData> statusDistribution,
      List<ChartData> regionDistribution,
      List<ProcessingTimeData> processingTimes,
      List<AdminPerformanceData> teamPerformance,
      DateTime lastUpdated,
      SystemHealthData? systemHealth,
      List<RecentActivity>? recentActivities});

  @override
  $SystemHealthDataCopyWith<$Res>? get systemHealth;
}

/// @nodoc
class __$$AdminDashboardDataImplCopyWithImpl<$Res>
    extends _$AdminDashboardDataCopyWithImpl<$Res, _$AdminDashboardDataImpl>
    implements _$$AdminDashboardDataImplCopyWith<$Res> {
  __$$AdminDashboardDataImplCopyWithImpl(_$AdminDashboardDataImpl _value,
      $Res Function(_$AdminDashboardDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of AdminDashboardData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalReports = null,
    Object? pendingReports = null,
    Object? todayReports = null,
    Object? thisWeekReports = null,
    Object? thisMonthReports = null,
    Object? completionRate = null,
    Object? averageProcessingHours = null,
    Object? urgentReports = null,
    Object? activeAdmins = null,
    Object? dailyTrend = null,
    Object? categoryDistribution = null,
    Object? statusDistribution = null,
    Object? regionDistribution = null,
    Object? processingTimes = null,
    Object? teamPerformance = null,
    Object? lastUpdated = null,
    Object? systemHealth = freezed,
    Object? recentActivities = freezed,
  }) {
    return _then(_$AdminDashboardDataImpl(
      totalReports: null == totalReports
          ? _value.totalReports
          : totalReports // ignore: cast_nullable_to_non_nullable
              as int,
      pendingReports: null == pendingReports
          ? _value.pendingReports
          : pendingReports // ignore: cast_nullable_to_non_nullable
              as int,
      todayReports: null == todayReports
          ? _value.todayReports
          : todayReports // ignore: cast_nullable_to_non_nullable
              as int,
      thisWeekReports: null == thisWeekReports
          ? _value.thisWeekReports
          : thisWeekReports // ignore: cast_nullable_to_non_nullable
              as int,
      thisMonthReports: null == thisMonthReports
          ? _value.thisMonthReports
          : thisMonthReports // ignore: cast_nullable_to_non_nullable
              as int,
      completionRate: null == completionRate
          ? _value.completionRate
          : completionRate // ignore: cast_nullable_to_non_nullable
              as double,
      averageProcessingHours: null == averageProcessingHours
          ? _value.averageProcessingHours
          : averageProcessingHours // ignore: cast_nullable_to_non_nullable
              as double,
      urgentReports: null == urgentReports
          ? _value.urgentReports
          : urgentReports // ignore: cast_nullable_to_non_nullable
              as int,
      activeAdmins: null == activeAdmins
          ? _value.activeAdmins
          : activeAdmins // ignore: cast_nullable_to_non_nullable
              as int,
      dailyTrend: null == dailyTrend
          ? _value._dailyTrend
          : dailyTrend // ignore: cast_nullable_to_non_nullable
              as List<ChartData>,
      categoryDistribution: null == categoryDistribution
          ? _value._categoryDistribution
          : categoryDistribution // ignore: cast_nullable_to_non_nullable
              as List<ChartData>,
      statusDistribution: null == statusDistribution
          ? _value._statusDistribution
          : statusDistribution // ignore: cast_nullable_to_non_nullable
              as List<ChartData>,
      regionDistribution: null == regionDistribution
          ? _value._regionDistribution
          : regionDistribution // ignore: cast_nullable_to_non_nullable
              as List<ChartData>,
      processingTimes: null == processingTimes
          ? _value._processingTimes
          : processingTimes // ignore: cast_nullable_to_non_nullable
              as List<ProcessingTimeData>,
      teamPerformance: null == teamPerformance
          ? _value._teamPerformance
          : teamPerformance // ignore: cast_nullable_to_non_nullable
              as List<AdminPerformanceData>,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
      systemHealth: freezed == systemHealth
          ? _value.systemHealth
          : systemHealth // ignore: cast_nullable_to_non_nullable
              as SystemHealthData?,
      recentActivities: freezed == recentActivities
          ? _value._recentActivities
          : recentActivities // ignore: cast_nullable_to_non_nullable
              as List<RecentActivity>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AdminDashboardDataImpl implements _AdminDashboardData {
  const _$AdminDashboardDataImpl(
      {required this.totalReports,
      required this.pendingReports,
      required this.todayReports,
      required this.thisWeekReports,
      required this.thisMonthReports,
      required this.completionRate,
      required this.averageProcessingHours,
      required this.urgentReports,
      required this.activeAdmins,
      required final List<ChartData> dailyTrend,
      required final List<ChartData> categoryDistribution,
      required final List<ChartData> statusDistribution,
      required final List<ChartData> regionDistribution,
      required final List<ProcessingTimeData> processingTimes,
      required final List<AdminPerformanceData> teamPerformance,
      required this.lastUpdated,
      this.systemHealth,
      final List<RecentActivity>? recentActivities})
      : _dailyTrend = dailyTrend,
        _categoryDistribution = categoryDistribution,
        _statusDistribution = statusDistribution,
        _regionDistribution = regionDistribution,
        _processingTimes = processingTimes,
        _teamPerformance = teamPerformance,
        _recentActivities = recentActivities;

  factory _$AdminDashboardDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$AdminDashboardDataImplFromJson(json);

  @override
  final int totalReports;
  @override
  final int pendingReports;
  @override
  final int todayReports;
  @override
  final int thisWeekReports;
  @override
  final int thisMonthReports;
  @override
  final double completionRate;
  @override
  final double averageProcessingHours;
  @override
  final int urgentReports;
  @override
  final int activeAdmins;
  final List<ChartData> _dailyTrend;
  @override
  List<ChartData> get dailyTrend {
    if (_dailyTrend is EqualUnmodifiableListView) return _dailyTrend;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dailyTrend);
  }

  final List<ChartData> _categoryDistribution;
  @override
  List<ChartData> get categoryDistribution {
    if (_categoryDistribution is EqualUnmodifiableListView)
      return _categoryDistribution;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categoryDistribution);
  }

  final List<ChartData> _statusDistribution;
  @override
  List<ChartData> get statusDistribution {
    if (_statusDistribution is EqualUnmodifiableListView)
      return _statusDistribution;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_statusDistribution);
  }

  final List<ChartData> _regionDistribution;
  @override
  List<ChartData> get regionDistribution {
    if (_regionDistribution is EqualUnmodifiableListView)
      return _regionDistribution;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_regionDistribution);
  }

  final List<ProcessingTimeData> _processingTimes;
  @override
  List<ProcessingTimeData> get processingTimes {
    if (_processingTimes is EqualUnmodifiableListView) return _processingTimes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_processingTimes);
  }

  final List<AdminPerformanceData> _teamPerformance;
  @override
  List<AdminPerformanceData> get teamPerformance {
    if (_teamPerformance is EqualUnmodifiableListView) return _teamPerformance;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_teamPerformance);
  }

  @override
  final DateTime lastUpdated;
  @override
  final SystemHealthData? systemHealth;
  final List<RecentActivity>? _recentActivities;
  @override
  List<RecentActivity>? get recentActivities {
    final value = _recentActivities;
    if (value == null) return null;
    if (_recentActivities is EqualUnmodifiableListView)
      return _recentActivities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'AdminDashboardData(totalReports: $totalReports, pendingReports: $pendingReports, todayReports: $todayReports, thisWeekReports: $thisWeekReports, thisMonthReports: $thisMonthReports, completionRate: $completionRate, averageProcessingHours: $averageProcessingHours, urgentReports: $urgentReports, activeAdmins: $activeAdmins, dailyTrend: $dailyTrend, categoryDistribution: $categoryDistribution, statusDistribution: $statusDistribution, regionDistribution: $regionDistribution, processingTimes: $processingTimes, teamPerformance: $teamPerformance, lastUpdated: $lastUpdated, systemHealth: $systemHealth, recentActivities: $recentActivities)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminDashboardDataImpl &&
            (identical(other.totalReports, totalReports) ||
                other.totalReports == totalReports) &&
            (identical(other.pendingReports, pendingReports) ||
                other.pendingReports == pendingReports) &&
            (identical(other.todayReports, todayReports) ||
                other.todayReports == todayReports) &&
            (identical(other.thisWeekReports, thisWeekReports) ||
                other.thisWeekReports == thisWeekReports) &&
            (identical(other.thisMonthReports, thisMonthReports) ||
                other.thisMonthReports == thisMonthReports) &&
            (identical(other.completionRate, completionRate) ||
                other.completionRate == completionRate) &&
            (identical(other.averageProcessingHours, averageProcessingHours) ||
                other.averageProcessingHours == averageProcessingHours) &&
            (identical(other.urgentReports, urgentReports) ||
                other.urgentReports == urgentReports) &&
            (identical(other.activeAdmins, activeAdmins) ||
                other.activeAdmins == activeAdmins) &&
            const DeepCollectionEquality()
                .equals(other._dailyTrend, _dailyTrend) &&
            const DeepCollectionEquality()
                .equals(other._categoryDistribution, _categoryDistribution) &&
            const DeepCollectionEquality()
                .equals(other._statusDistribution, _statusDistribution) &&
            const DeepCollectionEquality()
                .equals(other._regionDistribution, _regionDistribution) &&
            const DeepCollectionEquality()
                .equals(other._processingTimes, _processingTimes) &&
            const DeepCollectionEquality()
                .equals(other._teamPerformance, _teamPerformance) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            (identical(other.systemHealth, systemHealth) ||
                other.systemHealth == systemHealth) &&
            const DeepCollectionEquality()
                .equals(other._recentActivities, _recentActivities));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalReports,
      pendingReports,
      todayReports,
      thisWeekReports,
      thisMonthReports,
      completionRate,
      averageProcessingHours,
      urgentReports,
      activeAdmins,
      const DeepCollectionEquality().hash(_dailyTrend),
      const DeepCollectionEquality().hash(_categoryDistribution),
      const DeepCollectionEquality().hash(_statusDistribution),
      const DeepCollectionEquality().hash(_regionDistribution),
      const DeepCollectionEquality().hash(_processingTimes),
      const DeepCollectionEquality().hash(_teamPerformance),
      lastUpdated,
      systemHealth,
      const DeepCollectionEquality().hash(_recentActivities));

  /// Create a copy of AdminDashboardData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdminDashboardDataImplCopyWith<_$AdminDashboardDataImpl> get copyWith =>
      __$$AdminDashboardDataImplCopyWithImpl<_$AdminDashboardDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AdminDashboardDataImplToJson(
      this,
    );
  }
}

abstract class _AdminDashboardData implements AdminDashboardData {
  const factory _AdminDashboardData(
      {required final int totalReports,
      required final int pendingReports,
      required final int todayReports,
      required final int thisWeekReports,
      required final int thisMonthReports,
      required final double completionRate,
      required final double averageProcessingHours,
      required final int urgentReports,
      required final int activeAdmins,
      required final List<ChartData> dailyTrend,
      required final List<ChartData> categoryDistribution,
      required final List<ChartData> statusDistribution,
      required final List<ChartData> regionDistribution,
      required final List<ProcessingTimeData> processingTimes,
      required final List<AdminPerformanceData> teamPerformance,
      required final DateTime lastUpdated,
      final SystemHealthData? systemHealth,
      final List<RecentActivity>? recentActivities}) = _$AdminDashboardDataImpl;

  factory _AdminDashboardData.fromJson(Map<String, dynamic> json) =
      _$AdminDashboardDataImpl.fromJson;

  @override
  int get totalReports;
  @override
  int get pendingReports;
  @override
  int get todayReports;
  @override
  int get thisWeekReports;
  @override
  int get thisMonthReports;
  @override
  double get completionRate;
  @override
  double get averageProcessingHours;
  @override
  int get urgentReports;
  @override
  int get activeAdmins;
  @override
  List<ChartData> get dailyTrend;
  @override
  List<ChartData> get categoryDistribution;
  @override
  List<ChartData> get statusDistribution;
  @override
  List<ChartData> get regionDistribution;
  @override
  List<ProcessingTimeData> get processingTimes;
  @override
  List<AdminPerformanceData> get teamPerformance;
  @override
  DateTime get lastUpdated;
  @override
  SystemHealthData? get systemHealth;
  @override
  List<RecentActivity>? get recentActivities;

  /// Create a copy of AdminDashboardData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdminDashboardDataImplCopyWith<_$AdminDashboardDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChartData _$ChartDataFromJson(Map<String, dynamic> json) {
  return _ChartData.fromJson(json);
}

/// @nodoc
mixin _$ChartData {
  String get label => throw _privateConstructorUsedError;
  double get value => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this ChartData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChartData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChartDataCopyWith<ChartData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChartDataCopyWith<$Res> {
  factory $ChartDataCopyWith(ChartData value, $Res Function(ChartData) then) =
      _$ChartDataCopyWithImpl<$Res, ChartData>;
  @useResult
  $Res call(
      {String label,
      double value,
      String? color,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class _$ChartDataCopyWithImpl<$Res, $Val extends ChartData>
    implements $ChartDataCopyWith<$Res> {
  _$ChartDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChartData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? value = null,
    Object? color = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_value.copyWith(
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChartDataImplCopyWith<$Res>
    implements $ChartDataCopyWith<$Res> {
  factory _$$ChartDataImplCopyWith(
          _$ChartDataImpl value, $Res Function(_$ChartDataImpl) then) =
      __$$ChartDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String label,
      double value,
      String? color,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$ChartDataImplCopyWithImpl<$Res>
    extends _$ChartDataCopyWithImpl<$Res, _$ChartDataImpl>
    implements _$$ChartDataImplCopyWith<$Res> {
  __$$ChartDataImplCopyWithImpl(
      _$ChartDataImpl _value, $Res Function(_$ChartDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChartData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? value = null,
    Object? color = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_$ChartDataImpl(
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChartDataImpl implements _ChartData {
  const _$ChartDataImpl(
      {required this.label,
      required this.value,
      this.color,
      final Map<String, dynamic>? metadata})
      : _metadata = metadata;

  factory _$ChartDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChartDataImplFromJson(json);

  @override
  final String label;
  @override
  final double value;
  @override
  final String? color;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'ChartData(label: $label, value: $value, color: $color, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChartDataImpl &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.color, color) || other.color == color) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, label, value, color,
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of ChartData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChartDataImplCopyWith<_$ChartDataImpl> get copyWith =>
      __$$ChartDataImplCopyWithImpl<_$ChartDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChartDataImplToJson(
      this,
    );
  }
}

abstract class _ChartData implements ChartData {
  const factory _ChartData(
      {required final String label,
      required final double value,
      final String? color,
      final Map<String, dynamic>? metadata}) = _$ChartDataImpl;

  factory _ChartData.fromJson(Map<String, dynamic> json) =
      _$ChartDataImpl.fromJson;

  @override
  String get label;
  @override
  double get value;
  @override
  String? get color;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of ChartData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChartDataImplCopyWith<_$ChartDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProcessingTimeData _$ProcessingTimeDataFromJson(Map<String, dynamic> json) {
  return _ProcessingTimeData.fromJson(json);
}

/// @nodoc
mixin _$ProcessingTimeData {
  String get category => throw _privateConstructorUsedError;
  double get averageHours => throw _privateConstructorUsedError;
  double get targetHours => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;
  double get efficiency => throw _privateConstructorUsedError;

  /// Serializes this ProcessingTimeData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProcessingTimeData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProcessingTimeDataCopyWith<ProcessingTimeData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProcessingTimeDataCopyWith<$Res> {
  factory $ProcessingTimeDataCopyWith(
          ProcessingTimeData value, $Res Function(ProcessingTimeData) then) =
      _$ProcessingTimeDataCopyWithImpl<$Res, ProcessingTimeData>;
  @useResult
  $Res call(
      {String category,
      double averageHours,
      double targetHours,
      int count,
      double efficiency});
}

/// @nodoc
class _$ProcessingTimeDataCopyWithImpl<$Res, $Val extends ProcessingTimeData>
    implements $ProcessingTimeDataCopyWith<$Res> {
  _$ProcessingTimeDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProcessingTimeData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? averageHours = null,
    Object? targetHours = null,
    Object? count = null,
    Object? efficiency = null,
  }) {
    return _then(_value.copyWith(
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      averageHours: null == averageHours
          ? _value.averageHours
          : averageHours // ignore: cast_nullable_to_non_nullable
              as double,
      targetHours: null == targetHours
          ? _value.targetHours
          : targetHours // ignore: cast_nullable_to_non_nullable
              as double,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      efficiency: null == efficiency
          ? _value.efficiency
          : efficiency // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProcessingTimeDataImplCopyWith<$Res>
    implements $ProcessingTimeDataCopyWith<$Res> {
  factory _$$ProcessingTimeDataImplCopyWith(_$ProcessingTimeDataImpl value,
          $Res Function(_$ProcessingTimeDataImpl) then) =
      __$$ProcessingTimeDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String category,
      double averageHours,
      double targetHours,
      int count,
      double efficiency});
}

/// @nodoc
class __$$ProcessingTimeDataImplCopyWithImpl<$Res>
    extends _$ProcessingTimeDataCopyWithImpl<$Res, _$ProcessingTimeDataImpl>
    implements _$$ProcessingTimeDataImplCopyWith<$Res> {
  __$$ProcessingTimeDataImplCopyWithImpl(_$ProcessingTimeDataImpl _value,
      $Res Function(_$ProcessingTimeDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProcessingTimeData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? averageHours = null,
    Object? targetHours = null,
    Object? count = null,
    Object? efficiency = null,
  }) {
    return _then(_$ProcessingTimeDataImpl(
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      averageHours: null == averageHours
          ? _value.averageHours
          : averageHours // ignore: cast_nullable_to_non_nullable
              as double,
      targetHours: null == targetHours
          ? _value.targetHours
          : targetHours // ignore: cast_nullable_to_non_nullable
              as double,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      efficiency: null == efficiency
          ? _value.efficiency
          : efficiency // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProcessingTimeDataImpl implements _ProcessingTimeData {
  const _$ProcessingTimeDataImpl(
      {required this.category,
      required this.averageHours,
      required this.targetHours,
      required this.count,
      this.efficiency = 0.0});

  factory _$ProcessingTimeDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProcessingTimeDataImplFromJson(json);

  @override
  final String category;
  @override
  final double averageHours;
  @override
  final double targetHours;
  @override
  final int count;
  @override
  @JsonKey()
  final double efficiency;

  @override
  String toString() {
    return 'ProcessingTimeData(category: $category, averageHours: $averageHours, targetHours: $targetHours, count: $count, efficiency: $efficiency)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProcessingTimeDataImpl &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.averageHours, averageHours) ||
                other.averageHours == averageHours) &&
            (identical(other.targetHours, targetHours) ||
                other.targetHours == targetHours) &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.efficiency, efficiency) ||
                other.efficiency == efficiency));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, category, averageHours, targetHours, count, efficiency);

  /// Create a copy of ProcessingTimeData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProcessingTimeDataImplCopyWith<_$ProcessingTimeDataImpl> get copyWith =>
      __$$ProcessingTimeDataImplCopyWithImpl<_$ProcessingTimeDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProcessingTimeDataImplToJson(
      this,
    );
  }
}

abstract class _ProcessingTimeData implements ProcessingTimeData {
  const factory _ProcessingTimeData(
      {required final String category,
      required final double averageHours,
      required final double targetHours,
      required final int count,
      final double efficiency}) = _$ProcessingTimeDataImpl;

  factory _ProcessingTimeData.fromJson(Map<String, dynamic> json) =
      _$ProcessingTimeDataImpl.fromJson;

  @override
  String get category;
  @override
  double get averageHours;
  @override
  double get targetHours;
  @override
  int get count;
  @override
  double get efficiency;

  /// Create a copy of ProcessingTimeData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProcessingTimeDataImplCopyWith<_$ProcessingTimeDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AdminPerformanceData _$AdminPerformanceDataFromJson(Map<String, dynamic> json) {
  return _AdminPerformanceData.fromJson(json);
}

/// @nodoc
mixin _$AdminPerformanceData {
  String get adminId => throw _privateConstructorUsedError;
  String get adminName => throw _privateConstructorUsedError;
  int get processedCount => throw _privateConstructorUsedError;
  double get averageTime => throw _privateConstructorUsedError;
  double get satisfactionScore => throw _privateConstructorUsedError;
  int get currentAssignments => throw _privateConstructorUsedError;
  double get workloadPercentage => throw _privateConstructorUsedError;

  /// Serializes this AdminPerformanceData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AdminPerformanceData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdminPerformanceDataCopyWith<AdminPerformanceData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdminPerformanceDataCopyWith<$Res> {
  factory $AdminPerformanceDataCopyWith(AdminPerformanceData value,
          $Res Function(AdminPerformanceData) then) =
      _$AdminPerformanceDataCopyWithImpl<$Res, AdminPerformanceData>;
  @useResult
  $Res call(
      {String adminId,
      String adminName,
      int processedCount,
      double averageTime,
      double satisfactionScore,
      int currentAssignments,
      double workloadPercentage});
}

/// @nodoc
class _$AdminPerformanceDataCopyWithImpl<$Res,
        $Val extends AdminPerformanceData>
    implements $AdminPerformanceDataCopyWith<$Res> {
  _$AdminPerformanceDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AdminPerformanceData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? adminId = null,
    Object? adminName = null,
    Object? processedCount = null,
    Object? averageTime = null,
    Object? satisfactionScore = null,
    Object? currentAssignments = null,
    Object? workloadPercentage = null,
  }) {
    return _then(_value.copyWith(
      adminId: null == adminId
          ? _value.adminId
          : adminId // ignore: cast_nullable_to_non_nullable
              as String,
      adminName: null == adminName
          ? _value.adminName
          : adminName // ignore: cast_nullable_to_non_nullable
              as String,
      processedCount: null == processedCount
          ? _value.processedCount
          : processedCount // ignore: cast_nullable_to_non_nullable
              as int,
      averageTime: null == averageTime
          ? _value.averageTime
          : averageTime // ignore: cast_nullable_to_non_nullable
              as double,
      satisfactionScore: null == satisfactionScore
          ? _value.satisfactionScore
          : satisfactionScore // ignore: cast_nullable_to_non_nullable
              as double,
      currentAssignments: null == currentAssignments
          ? _value.currentAssignments
          : currentAssignments // ignore: cast_nullable_to_non_nullable
              as int,
      workloadPercentage: null == workloadPercentage
          ? _value.workloadPercentage
          : workloadPercentage // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AdminPerformanceDataImplCopyWith<$Res>
    implements $AdminPerformanceDataCopyWith<$Res> {
  factory _$$AdminPerformanceDataImplCopyWith(_$AdminPerformanceDataImpl value,
          $Res Function(_$AdminPerformanceDataImpl) then) =
      __$$AdminPerformanceDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String adminId,
      String adminName,
      int processedCount,
      double averageTime,
      double satisfactionScore,
      int currentAssignments,
      double workloadPercentage});
}

/// @nodoc
class __$$AdminPerformanceDataImplCopyWithImpl<$Res>
    extends _$AdminPerformanceDataCopyWithImpl<$Res, _$AdminPerformanceDataImpl>
    implements _$$AdminPerformanceDataImplCopyWith<$Res> {
  __$$AdminPerformanceDataImplCopyWithImpl(_$AdminPerformanceDataImpl _value,
      $Res Function(_$AdminPerformanceDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of AdminPerformanceData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? adminId = null,
    Object? adminName = null,
    Object? processedCount = null,
    Object? averageTime = null,
    Object? satisfactionScore = null,
    Object? currentAssignments = null,
    Object? workloadPercentage = null,
  }) {
    return _then(_$AdminPerformanceDataImpl(
      adminId: null == adminId
          ? _value.adminId
          : adminId // ignore: cast_nullable_to_non_nullable
              as String,
      adminName: null == adminName
          ? _value.adminName
          : adminName // ignore: cast_nullable_to_non_nullable
              as String,
      processedCount: null == processedCount
          ? _value.processedCount
          : processedCount // ignore: cast_nullable_to_non_nullable
              as int,
      averageTime: null == averageTime
          ? _value.averageTime
          : averageTime // ignore: cast_nullable_to_non_nullable
              as double,
      satisfactionScore: null == satisfactionScore
          ? _value.satisfactionScore
          : satisfactionScore // ignore: cast_nullable_to_non_nullable
              as double,
      currentAssignments: null == currentAssignments
          ? _value.currentAssignments
          : currentAssignments // ignore: cast_nullable_to_non_nullable
              as int,
      workloadPercentage: null == workloadPercentage
          ? _value.workloadPercentage
          : workloadPercentage // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AdminPerformanceDataImpl implements _AdminPerformanceData {
  const _$AdminPerformanceDataImpl(
      {required this.adminId,
      required this.adminName,
      required this.processedCount,
      required this.averageTime,
      required this.satisfactionScore,
      required this.currentAssignments,
      this.workloadPercentage = 100.0});

  factory _$AdminPerformanceDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$AdminPerformanceDataImplFromJson(json);

  @override
  final String adminId;
  @override
  final String adminName;
  @override
  final int processedCount;
  @override
  final double averageTime;
  @override
  final double satisfactionScore;
  @override
  final int currentAssignments;
  @override
  @JsonKey()
  final double workloadPercentage;

  @override
  String toString() {
    return 'AdminPerformanceData(adminId: $adminId, adminName: $adminName, processedCount: $processedCount, averageTime: $averageTime, satisfactionScore: $satisfactionScore, currentAssignments: $currentAssignments, workloadPercentage: $workloadPercentage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminPerformanceDataImpl &&
            (identical(other.adminId, adminId) || other.adminId == adminId) &&
            (identical(other.adminName, adminName) ||
                other.adminName == adminName) &&
            (identical(other.processedCount, processedCount) ||
                other.processedCount == processedCount) &&
            (identical(other.averageTime, averageTime) ||
                other.averageTime == averageTime) &&
            (identical(other.satisfactionScore, satisfactionScore) ||
                other.satisfactionScore == satisfactionScore) &&
            (identical(other.currentAssignments, currentAssignments) ||
                other.currentAssignments == currentAssignments) &&
            (identical(other.workloadPercentage, workloadPercentage) ||
                other.workloadPercentage == workloadPercentage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      adminId,
      adminName,
      processedCount,
      averageTime,
      satisfactionScore,
      currentAssignments,
      workloadPercentage);

  /// Create a copy of AdminPerformanceData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdminPerformanceDataImplCopyWith<_$AdminPerformanceDataImpl>
      get copyWith =>
          __$$AdminPerformanceDataImplCopyWithImpl<_$AdminPerformanceDataImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AdminPerformanceDataImplToJson(
      this,
    );
  }
}

abstract class _AdminPerformanceData implements AdminPerformanceData {
  const factory _AdminPerformanceData(
      {required final String adminId,
      required final String adminName,
      required final int processedCount,
      required final double averageTime,
      required final double satisfactionScore,
      required final int currentAssignments,
      final double workloadPercentage}) = _$AdminPerformanceDataImpl;

  factory _AdminPerformanceData.fromJson(Map<String, dynamic> json) =
      _$AdminPerformanceDataImpl.fromJson;

  @override
  String get adminId;
  @override
  String get adminName;
  @override
  int get processedCount;
  @override
  double get averageTime;
  @override
  double get satisfactionScore;
  @override
  int get currentAssignments;
  @override
  double get workloadPercentage;

  /// Create a copy of AdminPerformanceData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdminPerformanceDataImplCopyWith<_$AdminPerformanceDataImpl>
      get copyWith => throw _privateConstructorUsedError;
}

SystemHealthData _$SystemHealthDataFromJson(Map<String, dynamic> json) {
  return _SystemHealthData.fromJson(json);
}

/// @nodoc
mixin _$SystemHealthData {
  double get cpuUsage => throw _privateConstructorUsedError;
  double get memoryUsage => throw _privateConstructorUsedError;
  double get diskUsage => throw _privateConstructorUsedError;
  int get activeConnections => throw _privateConstructorUsedError;
  double get responseTime => throw _privateConstructorUsedError;
  double get uptime => throw _privateConstructorUsedError;
  SystemStatus get status => throw _privateConstructorUsedError;
  List<String>? get alerts => throw _privateConstructorUsedError;

  /// Serializes this SystemHealthData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SystemHealthData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SystemHealthDataCopyWith<SystemHealthData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SystemHealthDataCopyWith<$Res> {
  factory $SystemHealthDataCopyWith(
          SystemHealthData value, $Res Function(SystemHealthData) then) =
      _$SystemHealthDataCopyWithImpl<$Res, SystemHealthData>;
  @useResult
  $Res call(
      {double cpuUsage,
      double memoryUsage,
      double diskUsage,
      int activeConnections,
      double responseTime,
      double uptime,
      SystemStatus status,
      List<String>? alerts});
}

/// @nodoc
class _$SystemHealthDataCopyWithImpl<$Res, $Val extends SystemHealthData>
    implements $SystemHealthDataCopyWith<$Res> {
  _$SystemHealthDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SystemHealthData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cpuUsage = null,
    Object? memoryUsage = null,
    Object? diskUsage = null,
    Object? activeConnections = null,
    Object? responseTime = null,
    Object? uptime = null,
    Object? status = null,
    Object? alerts = freezed,
  }) {
    return _then(_value.copyWith(
      cpuUsage: null == cpuUsage
          ? _value.cpuUsage
          : cpuUsage // ignore: cast_nullable_to_non_nullable
              as double,
      memoryUsage: null == memoryUsage
          ? _value.memoryUsage
          : memoryUsage // ignore: cast_nullable_to_non_nullable
              as double,
      diskUsage: null == diskUsage
          ? _value.diskUsage
          : diskUsage // ignore: cast_nullable_to_non_nullable
              as double,
      activeConnections: null == activeConnections
          ? _value.activeConnections
          : activeConnections // ignore: cast_nullable_to_non_nullable
              as int,
      responseTime: null == responseTime
          ? _value.responseTime
          : responseTime // ignore: cast_nullable_to_non_nullable
              as double,
      uptime: null == uptime
          ? _value.uptime
          : uptime // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SystemStatus,
      alerts: freezed == alerts
          ? _value.alerts
          : alerts // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SystemHealthDataImplCopyWith<$Res>
    implements $SystemHealthDataCopyWith<$Res> {
  factory _$$SystemHealthDataImplCopyWith(_$SystemHealthDataImpl value,
          $Res Function(_$SystemHealthDataImpl) then) =
      __$$SystemHealthDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double cpuUsage,
      double memoryUsage,
      double diskUsage,
      int activeConnections,
      double responseTime,
      double uptime,
      SystemStatus status,
      List<String>? alerts});
}

/// @nodoc
class __$$SystemHealthDataImplCopyWithImpl<$Res>
    extends _$SystemHealthDataCopyWithImpl<$Res, _$SystemHealthDataImpl>
    implements _$$SystemHealthDataImplCopyWith<$Res> {
  __$$SystemHealthDataImplCopyWithImpl(_$SystemHealthDataImpl _value,
      $Res Function(_$SystemHealthDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of SystemHealthData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cpuUsage = null,
    Object? memoryUsage = null,
    Object? diskUsage = null,
    Object? activeConnections = null,
    Object? responseTime = null,
    Object? uptime = null,
    Object? status = null,
    Object? alerts = freezed,
  }) {
    return _then(_$SystemHealthDataImpl(
      cpuUsage: null == cpuUsage
          ? _value.cpuUsage
          : cpuUsage // ignore: cast_nullable_to_non_nullable
              as double,
      memoryUsage: null == memoryUsage
          ? _value.memoryUsage
          : memoryUsage // ignore: cast_nullable_to_non_nullable
              as double,
      diskUsage: null == diskUsage
          ? _value.diskUsage
          : diskUsage // ignore: cast_nullable_to_non_nullable
              as double,
      activeConnections: null == activeConnections
          ? _value.activeConnections
          : activeConnections // ignore: cast_nullable_to_non_nullable
              as int,
      responseTime: null == responseTime
          ? _value.responseTime
          : responseTime // ignore: cast_nullable_to_non_nullable
              as double,
      uptime: null == uptime
          ? _value.uptime
          : uptime // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SystemStatus,
      alerts: freezed == alerts
          ? _value._alerts
          : alerts // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SystemHealthDataImpl implements _SystemHealthData {
  const _$SystemHealthDataImpl(
      {this.cpuUsage = 100.0,
      this.memoryUsage = 100.0,
      this.diskUsage = 100.0,
      this.activeConnections = 0,
      this.responseTime = 0.0,
      this.uptime = 99.9,
      this.status = SystemStatus.healthy,
      final List<String>? alerts})
      : _alerts = alerts;

  factory _$SystemHealthDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$SystemHealthDataImplFromJson(json);

  @override
  @JsonKey()
  final double cpuUsage;
  @override
  @JsonKey()
  final double memoryUsage;
  @override
  @JsonKey()
  final double diskUsage;
  @override
  @JsonKey()
  final int activeConnections;
  @override
  @JsonKey()
  final double responseTime;
  @override
  @JsonKey()
  final double uptime;
  @override
  @JsonKey()
  final SystemStatus status;
  final List<String>? _alerts;
  @override
  List<String>? get alerts {
    final value = _alerts;
    if (value == null) return null;
    if (_alerts is EqualUnmodifiableListView) return _alerts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'SystemHealthData(cpuUsage: $cpuUsage, memoryUsage: $memoryUsage, diskUsage: $diskUsage, activeConnections: $activeConnections, responseTime: $responseTime, uptime: $uptime, status: $status, alerts: $alerts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SystemHealthDataImpl &&
            (identical(other.cpuUsage, cpuUsage) ||
                other.cpuUsage == cpuUsage) &&
            (identical(other.memoryUsage, memoryUsage) ||
                other.memoryUsage == memoryUsage) &&
            (identical(other.diskUsage, diskUsage) ||
                other.diskUsage == diskUsage) &&
            (identical(other.activeConnections, activeConnections) ||
                other.activeConnections == activeConnections) &&
            (identical(other.responseTime, responseTime) ||
                other.responseTime == responseTime) &&
            (identical(other.uptime, uptime) || other.uptime == uptime) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._alerts, _alerts));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      cpuUsage,
      memoryUsage,
      diskUsage,
      activeConnections,
      responseTime,
      uptime,
      status,
      const DeepCollectionEquality().hash(_alerts));

  /// Create a copy of SystemHealthData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SystemHealthDataImplCopyWith<_$SystemHealthDataImpl> get copyWith =>
      __$$SystemHealthDataImplCopyWithImpl<_$SystemHealthDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SystemHealthDataImplToJson(
      this,
    );
  }
}

abstract class _SystemHealthData implements SystemHealthData {
  const factory _SystemHealthData(
      {final double cpuUsage,
      final double memoryUsage,
      final double diskUsage,
      final int activeConnections,
      final double responseTime,
      final double uptime,
      final SystemStatus status,
      final List<String>? alerts}) = _$SystemHealthDataImpl;

  factory _SystemHealthData.fromJson(Map<String, dynamic> json) =
      _$SystemHealthDataImpl.fromJson;

  @override
  double get cpuUsage;
  @override
  double get memoryUsage;
  @override
  double get diskUsage;
  @override
  int get activeConnections;
  @override
  double get responseTime;
  @override
  double get uptime;
  @override
  SystemStatus get status;
  @override
  List<String>? get alerts;

  /// Create a copy of SystemHealthData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SystemHealthDataImplCopyWith<_$SystemHealthDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RecentActivity _$RecentActivityFromJson(Map<String, dynamic> json) {
  return _RecentActivity.fromJson(json);
}

/// @nodoc
mixin _$RecentActivity {
  String get id => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get adminName => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  ActivityType get type => throw _privateConstructorUsedError;
  String? get reportId => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this RecentActivity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecentActivity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecentActivityCopyWith<RecentActivity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecentActivityCopyWith<$Res> {
  factory $RecentActivityCopyWith(
          RecentActivity value, $Res Function(RecentActivity) then) =
      _$RecentActivityCopyWithImpl<$Res, RecentActivity>;
  @useResult
  $Res call(
      {String id,
      String description,
      String adminName,
      DateTime timestamp,
      ActivityType type,
      String? reportId,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class _$RecentActivityCopyWithImpl<$Res, $Val extends RecentActivity>
    implements $RecentActivityCopyWith<$Res> {
  _$RecentActivityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecentActivity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? description = null,
    Object? adminName = null,
    Object? timestamp = null,
    Object? type = null,
    Object? reportId = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      adminName: null == adminName
          ? _value.adminName
          : adminName // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ActivityType,
      reportId: freezed == reportId
          ? _value.reportId
          : reportId // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecentActivityImplCopyWith<$Res>
    implements $RecentActivityCopyWith<$Res> {
  factory _$$RecentActivityImplCopyWith(_$RecentActivityImpl value,
          $Res Function(_$RecentActivityImpl) then) =
      __$$RecentActivityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String description,
      String adminName,
      DateTime timestamp,
      ActivityType type,
      String? reportId,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$RecentActivityImplCopyWithImpl<$Res>
    extends _$RecentActivityCopyWithImpl<$Res, _$RecentActivityImpl>
    implements _$$RecentActivityImplCopyWith<$Res> {
  __$$RecentActivityImplCopyWithImpl(
      _$RecentActivityImpl _value, $Res Function(_$RecentActivityImpl) _then)
      : super(_value, _then);

  /// Create a copy of RecentActivity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? description = null,
    Object? adminName = null,
    Object? timestamp = null,
    Object? type = null,
    Object? reportId = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_$RecentActivityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      adminName: null == adminName
          ? _value.adminName
          : adminName // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ActivityType,
      reportId: freezed == reportId
          ? _value.reportId
          : reportId // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecentActivityImpl implements _RecentActivity {
  const _$RecentActivityImpl(
      {required this.id,
      required this.description,
      required this.adminName,
      required this.timestamp,
      required this.type,
      this.reportId,
      final Map<String, dynamic>? metadata})
      : _metadata = metadata;

  factory _$RecentActivityImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecentActivityImplFromJson(json);

  @override
  final String id;
  @override
  final String description;
  @override
  final String adminName;
  @override
  final DateTime timestamp;
  @override
  final ActivityType type;
  @override
  final String? reportId;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'RecentActivity(id: $id, description: $description, adminName: $adminName, timestamp: $timestamp, type: $type, reportId: $reportId, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecentActivityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.adminName, adminName) ||
                other.adminName == adminName) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.reportId, reportId) ||
                other.reportId == reportId) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      description,
      adminName,
      timestamp,
      type,
      reportId,
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of RecentActivity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecentActivityImplCopyWith<_$RecentActivityImpl> get copyWith =>
      __$$RecentActivityImplCopyWithImpl<_$RecentActivityImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecentActivityImplToJson(
      this,
    );
  }
}

abstract class _RecentActivity implements RecentActivity {
  const factory _RecentActivity(
      {required final String id,
      required final String description,
      required final String adminName,
      required final DateTime timestamp,
      required final ActivityType type,
      final String? reportId,
      final Map<String, dynamic>? metadata}) = _$RecentActivityImpl;

  factory _RecentActivity.fromJson(Map<String, dynamic> json) =
      _$RecentActivityImpl.fromJson;

  @override
  String get id;
  @override
  String get description;
  @override
  String get adminName;
  @override
  DateTime get timestamp;
  @override
  ActivityType get type;
  @override
  String? get reportId;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of RecentActivity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecentActivityImplCopyWith<_$RecentActivityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
