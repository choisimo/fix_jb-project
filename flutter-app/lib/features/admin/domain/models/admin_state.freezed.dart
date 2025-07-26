// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AdminState _$AdminStateFromJson(Map<String, dynamic> json) {
  return _AdminState.fromJson(json);
}

/// @nodoc
mixin _$AdminState {
  AdminUser? get currentAdmin => throw _privateConstructorUsedError;
  AdminDashboardData? get dashboardData => throw _privateConstructorUsedError;
  List<Report> get managedReports => throw _privateConstructorUsedError;
  List<AdminUser> get teamMembers => throw _privateConstructorUsedError;
  List<ReportAssignment> get assignments => throw _privateConstructorUsedError;
  List<RecentActivity> get recentActivities =>
      throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isDashboardLoading => throw _privateConstructorUsedError;
  bool get isReportsLoading => throw _privateConstructorUsedError;
  bool get isUsersLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  Map<String, dynamic>? get filters => throw _privateConstructorUsedError;
  AdminViewMode? get currentView => throw _privateConstructorUsedError;
  DateTime? get lastDataRefresh => throw _privateConstructorUsedError;
  int get totalPages => throw _privateConstructorUsedError;
  int get currentPage => throw _privateConstructorUsedError;
  int get pageSize => throw _privateConstructorUsedError;
  Map<String, dynamic>? get statistics => throw _privateConstructorUsedError;

  /// Serializes this AdminState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AdminState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdminStateCopyWith<AdminState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdminStateCopyWith<$Res> {
  factory $AdminStateCopyWith(
          AdminState value, $Res Function(AdminState) then) =
      _$AdminStateCopyWithImpl<$Res, AdminState>;
  @useResult
  $Res call(
      {AdminUser? currentAdmin,
      AdminDashboardData? dashboardData,
      List<Report> managedReports,
      List<AdminUser> teamMembers,
      List<ReportAssignment> assignments,
      List<RecentActivity> recentActivities,
      bool isLoading,
      bool isDashboardLoading,
      bool isReportsLoading,
      bool isUsersLoading,
      String? error,
      Map<String, dynamic>? filters,
      AdminViewMode? currentView,
      DateTime? lastDataRefresh,
      int totalPages,
      int currentPage,
      int pageSize,
      Map<String, dynamic>? statistics});

  $AdminUserCopyWith<$Res>? get currentAdmin;
  $AdminDashboardDataCopyWith<$Res>? get dashboardData;
}

/// @nodoc
class _$AdminStateCopyWithImpl<$Res, $Val extends AdminState>
    implements $AdminStateCopyWith<$Res> {
  _$AdminStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AdminState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentAdmin = freezed,
    Object? dashboardData = freezed,
    Object? managedReports = null,
    Object? teamMembers = null,
    Object? assignments = null,
    Object? recentActivities = null,
    Object? isLoading = null,
    Object? isDashboardLoading = null,
    Object? isReportsLoading = null,
    Object? isUsersLoading = null,
    Object? error = freezed,
    Object? filters = freezed,
    Object? currentView = freezed,
    Object? lastDataRefresh = freezed,
    Object? totalPages = null,
    Object? currentPage = null,
    Object? pageSize = null,
    Object? statistics = freezed,
  }) {
    return _then(_value.copyWith(
      currentAdmin: freezed == currentAdmin
          ? _value.currentAdmin
          : currentAdmin // ignore: cast_nullable_to_non_nullable
              as AdminUser?,
      dashboardData: freezed == dashboardData
          ? _value.dashboardData
          : dashboardData // ignore: cast_nullable_to_non_nullable
              as AdminDashboardData?,
      managedReports: null == managedReports
          ? _value.managedReports
          : managedReports // ignore: cast_nullable_to_non_nullable
              as List<Report>,
      teamMembers: null == teamMembers
          ? _value.teamMembers
          : teamMembers // ignore: cast_nullable_to_non_nullable
              as List<AdminUser>,
      assignments: null == assignments
          ? _value.assignments
          : assignments // ignore: cast_nullable_to_non_nullable
              as List<ReportAssignment>,
      recentActivities: null == recentActivities
          ? _value.recentActivities
          : recentActivities // ignore: cast_nullable_to_non_nullable
              as List<RecentActivity>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isDashboardLoading: null == isDashboardLoading
          ? _value.isDashboardLoading
          : isDashboardLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isReportsLoading: null == isReportsLoading
          ? _value.isReportsLoading
          : isReportsLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isUsersLoading: null == isUsersLoading
          ? _value.isUsersLoading
          : isUsersLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      filters: freezed == filters
          ? _value.filters
          : filters // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      currentView: freezed == currentView
          ? _value.currentView
          : currentView // ignore: cast_nullable_to_non_nullable
              as AdminViewMode?,
      lastDataRefresh: freezed == lastDataRefresh
          ? _value.lastDataRefresh
          : lastDataRefresh // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalPages: null == totalPages
          ? _value.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      pageSize: null == pageSize
          ? _value.pageSize
          : pageSize // ignore: cast_nullable_to_non_nullable
              as int,
      statistics: freezed == statistics
          ? _value.statistics
          : statistics // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }

  /// Create a copy of AdminState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AdminUserCopyWith<$Res>? get currentAdmin {
    if (_value.currentAdmin == null) {
      return null;
    }

    return $AdminUserCopyWith<$Res>(_value.currentAdmin!, (value) {
      return _then(_value.copyWith(currentAdmin: value) as $Val);
    });
  }

  /// Create a copy of AdminState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AdminDashboardDataCopyWith<$Res>? get dashboardData {
    if (_value.dashboardData == null) {
      return null;
    }

    return $AdminDashboardDataCopyWith<$Res>(_value.dashboardData!, (value) {
      return _then(_value.copyWith(dashboardData: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AdminStateImplCopyWith<$Res>
    implements $AdminStateCopyWith<$Res> {
  factory _$$AdminStateImplCopyWith(
          _$AdminStateImpl value, $Res Function(_$AdminStateImpl) then) =
      __$$AdminStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {AdminUser? currentAdmin,
      AdminDashboardData? dashboardData,
      List<Report> managedReports,
      List<AdminUser> teamMembers,
      List<ReportAssignment> assignments,
      List<RecentActivity> recentActivities,
      bool isLoading,
      bool isDashboardLoading,
      bool isReportsLoading,
      bool isUsersLoading,
      String? error,
      Map<String, dynamic>? filters,
      AdminViewMode? currentView,
      DateTime? lastDataRefresh,
      int totalPages,
      int currentPage,
      int pageSize,
      Map<String, dynamic>? statistics});

  @override
  $AdminUserCopyWith<$Res>? get currentAdmin;
  @override
  $AdminDashboardDataCopyWith<$Res>? get dashboardData;
}

/// @nodoc
class __$$AdminStateImplCopyWithImpl<$Res>
    extends _$AdminStateCopyWithImpl<$Res, _$AdminStateImpl>
    implements _$$AdminStateImplCopyWith<$Res> {
  __$$AdminStateImplCopyWithImpl(
      _$AdminStateImpl _value, $Res Function(_$AdminStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of AdminState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentAdmin = freezed,
    Object? dashboardData = freezed,
    Object? managedReports = null,
    Object? teamMembers = null,
    Object? assignments = null,
    Object? recentActivities = null,
    Object? isLoading = null,
    Object? isDashboardLoading = null,
    Object? isReportsLoading = null,
    Object? isUsersLoading = null,
    Object? error = freezed,
    Object? filters = freezed,
    Object? currentView = freezed,
    Object? lastDataRefresh = freezed,
    Object? totalPages = null,
    Object? currentPage = null,
    Object? pageSize = null,
    Object? statistics = freezed,
  }) {
    return _then(_$AdminStateImpl(
      currentAdmin: freezed == currentAdmin
          ? _value.currentAdmin
          : currentAdmin // ignore: cast_nullable_to_non_nullable
              as AdminUser?,
      dashboardData: freezed == dashboardData
          ? _value.dashboardData
          : dashboardData // ignore: cast_nullable_to_non_nullable
              as AdminDashboardData?,
      managedReports: null == managedReports
          ? _value._managedReports
          : managedReports // ignore: cast_nullable_to_non_nullable
              as List<Report>,
      teamMembers: null == teamMembers
          ? _value._teamMembers
          : teamMembers // ignore: cast_nullable_to_non_nullable
              as List<AdminUser>,
      assignments: null == assignments
          ? _value._assignments
          : assignments // ignore: cast_nullable_to_non_nullable
              as List<ReportAssignment>,
      recentActivities: null == recentActivities
          ? _value._recentActivities
          : recentActivities // ignore: cast_nullable_to_non_nullable
              as List<RecentActivity>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isDashboardLoading: null == isDashboardLoading
          ? _value.isDashboardLoading
          : isDashboardLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isReportsLoading: null == isReportsLoading
          ? _value.isReportsLoading
          : isReportsLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isUsersLoading: null == isUsersLoading
          ? _value.isUsersLoading
          : isUsersLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      filters: freezed == filters
          ? _value._filters
          : filters // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      currentView: freezed == currentView
          ? _value.currentView
          : currentView // ignore: cast_nullable_to_non_nullable
              as AdminViewMode?,
      lastDataRefresh: freezed == lastDataRefresh
          ? _value.lastDataRefresh
          : lastDataRefresh // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalPages: null == totalPages
          ? _value.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      pageSize: null == pageSize
          ? _value.pageSize
          : pageSize // ignore: cast_nullable_to_non_nullable
              as int,
      statistics: freezed == statistics
          ? _value._statistics
          : statistics // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AdminStateImpl implements _AdminState {
  const _$AdminStateImpl(
      {this.currentAdmin,
      this.dashboardData,
      final List<Report> managedReports = const [],
      final List<AdminUser> teamMembers = const [],
      final List<ReportAssignment> assignments = const [],
      final List<RecentActivity> recentActivities = const [],
      this.isLoading = false,
      this.isDashboardLoading = false,
      this.isReportsLoading = false,
      this.isUsersLoading = false,
      this.error,
      final Map<String, dynamic>? filters,
      this.currentView,
      this.lastDataRefresh,
      this.totalPages = 0,
      this.currentPage = 1,
      this.pageSize = 20,
      final Map<String, dynamic>? statistics})
      : _managedReports = managedReports,
        _teamMembers = teamMembers,
        _assignments = assignments,
        _recentActivities = recentActivities,
        _filters = filters,
        _statistics = statistics;

  factory _$AdminStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$AdminStateImplFromJson(json);

  @override
  final AdminUser? currentAdmin;
  @override
  final AdminDashboardData? dashboardData;
  final List<Report> _managedReports;
  @override
  @JsonKey()
  List<Report> get managedReports {
    if (_managedReports is EqualUnmodifiableListView) return _managedReports;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_managedReports);
  }

  final List<AdminUser> _teamMembers;
  @override
  @JsonKey()
  List<AdminUser> get teamMembers {
    if (_teamMembers is EqualUnmodifiableListView) return _teamMembers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_teamMembers);
  }

  final List<ReportAssignment> _assignments;
  @override
  @JsonKey()
  List<ReportAssignment> get assignments {
    if (_assignments is EqualUnmodifiableListView) return _assignments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_assignments);
  }

  final List<RecentActivity> _recentActivities;
  @override
  @JsonKey()
  List<RecentActivity> get recentActivities {
    if (_recentActivities is EqualUnmodifiableListView)
      return _recentActivities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentActivities);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isDashboardLoading;
  @override
  @JsonKey()
  final bool isReportsLoading;
  @override
  @JsonKey()
  final bool isUsersLoading;
  @override
  final String? error;
  final Map<String, dynamic>? _filters;
  @override
  Map<String, dynamic>? get filters {
    final value = _filters;
    if (value == null) return null;
    if (_filters is EqualUnmodifiableMapView) return _filters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final AdminViewMode? currentView;
  @override
  final DateTime? lastDataRefresh;
  @override
  @JsonKey()
  final int totalPages;
  @override
  @JsonKey()
  final int currentPage;
  @override
  @JsonKey()
  final int pageSize;
  final Map<String, dynamic>? _statistics;
  @override
  Map<String, dynamic>? get statistics {
    final value = _statistics;
    if (value == null) return null;
    if (_statistics is EqualUnmodifiableMapView) return _statistics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AdminState(currentAdmin: $currentAdmin, dashboardData: $dashboardData, managedReports: $managedReports, teamMembers: $teamMembers, assignments: $assignments, recentActivities: $recentActivities, isLoading: $isLoading, isDashboardLoading: $isDashboardLoading, isReportsLoading: $isReportsLoading, isUsersLoading: $isUsersLoading, error: $error, filters: $filters, currentView: $currentView, lastDataRefresh: $lastDataRefresh, totalPages: $totalPages, currentPage: $currentPage, pageSize: $pageSize, statistics: $statistics)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminStateImpl &&
            (identical(other.currentAdmin, currentAdmin) ||
                other.currentAdmin == currentAdmin) &&
            (identical(other.dashboardData, dashboardData) ||
                other.dashboardData == dashboardData) &&
            const DeepCollectionEquality()
                .equals(other._managedReports, _managedReports) &&
            const DeepCollectionEquality()
                .equals(other._teamMembers, _teamMembers) &&
            const DeepCollectionEquality()
                .equals(other._assignments, _assignments) &&
            const DeepCollectionEquality()
                .equals(other._recentActivities, _recentActivities) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isDashboardLoading, isDashboardLoading) ||
                other.isDashboardLoading == isDashboardLoading) &&
            (identical(other.isReportsLoading, isReportsLoading) ||
                other.isReportsLoading == isReportsLoading) &&
            (identical(other.isUsersLoading, isUsersLoading) ||
                other.isUsersLoading == isUsersLoading) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality().equals(other._filters, _filters) &&
            (identical(other.currentView, currentView) ||
                other.currentView == currentView) &&
            (identical(other.lastDataRefresh, lastDataRefresh) ||
                other.lastDataRefresh == lastDataRefresh) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.pageSize, pageSize) ||
                other.pageSize == pageSize) &&
            const DeepCollectionEquality()
                .equals(other._statistics, _statistics));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      currentAdmin,
      dashboardData,
      const DeepCollectionEquality().hash(_managedReports),
      const DeepCollectionEquality().hash(_teamMembers),
      const DeepCollectionEquality().hash(_assignments),
      const DeepCollectionEquality().hash(_recentActivities),
      isLoading,
      isDashboardLoading,
      isReportsLoading,
      isUsersLoading,
      error,
      const DeepCollectionEquality().hash(_filters),
      currentView,
      lastDataRefresh,
      totalPages,
      currentPage,
      pageSize,
      const DeepCollectionEquality().hash(_statistics));

  /// Create a copy of AdminState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdminStateImplCopyWith<_$AdminStateImpl> get copyWith =>
      __$$AdminStateImplCopyWithImpl<_$AdminStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AdminStateImplToJson(
      this,
    );
  }
}

abstract class _AdminState implements AdminState {
  const factory _AdminState(
      {final AdminUser? currentAdmin,
      final AdminDashboardData? dashboardData,
      final List<Report> managedReports,
      final List<AdminUser> teamMembers,
      final List<ReportAssignment> assignments,
      final List<RecentActivity> recentActivities,
      final bool isLoading,
      final bool isDashboardLoading,
      final bool isReportsLoading,
      final bool isUsersLoading,
      final String? error,
      final Map<String, dynamic>? filters,
      final AdminViewMode? currentView,
      final DateTime? lastDataRefresh,
      final int totalPages,
      final int currentPage,
      final int pageSize,
      final Map<String, dynamic>? statistics}) = _$AdminStateImpl;

  factory _AdminState.fromJson(Map<String, dynamic> json) =
      _$AdminStateImpl.fromJson;

  @override
  AdminUser? get currentAdmin;
  @override
  AdminDashboardData? get dashboardData;
  @override
  List<Report> get managedReports;
  @override
  List<AdminUser> get teamMembers;
  @override
  List<ReportAssignment> get assignments;
  @override
  List<RecentActivity> get recentActivities;
  @override
  bool get isLoading;
  @override
  bool get isDashboardLoading;
  @override
  bool get isReportsLoading;
  @override
  bool get isUsersLoading;
  @override
  String? get error;
  @override
  Map<String, dynamic>? get filters;
  @override
  AdminViewMode? get currentView;
  @override
  DateTime? get lastDataRefresh;
  @override
  int get totalPages;
  @override
  int get currentPage;
  @override
  int get pageSize;
  @override
  Map<String, dynamic>? get statistics;

  /// Create a copy of AdminState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdminStateImplCopyWith<_$AdminStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
