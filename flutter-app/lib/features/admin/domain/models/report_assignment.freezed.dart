// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_assignment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ReportAssignment _$ReportAssignmentFromJson(Map<String, dynamic> json) {
  return _ReportAssignment.fromJson(json);
}

/// @nodoc
mixin _$ReportAssignment {
  String get id => throw _privateConstructorUsedError;
  String get reportId => throw _privateConstructorUsedError;
  String get adminUserId => throw _privateConstructorUsedError;
  DateTime get assignedAt => throw _privateConstructorUsedError;
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  DateTime? get dueDate => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get internalNotes => throw _privateConstructorUsedError;
  AssignmentStatus get status => throw _privateConstructorUsedError;
  AssignmentPriority get priority => throw _privateConstructorUsedError;
  String? get assignedByUserId => throw _privateConstructorUsedError;
  List<String>? get requiredSkills => throw _privateConstructorUsedError;
  double get estimatedHours => throw _privateConstructorUsedError;
  double get actualHours => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this ReportAssignment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReportAssignment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReportAssignmentCopyWith<ReportAssignment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReportAssignmentCopyWith<$Res> {
  factory $ReportAssignmentCopyWith(
          ReportAssignment value, $Res Function(ReportAssignment) then) =
      _$ReportAssignmentCopyWithImpl<$Res, ReportAssignment>;
  @useResult
  $Res call(
      {String id,
      String reportId,
      String adminUserId,
      DateTime assignedAt,
      DateTime? startedAt,
      DateTime? completedAt,
      DateTime? dueDate,
      String? notes,
      String? internalNotes,
      AssignmentStatus status,
      AssignmentPriority priority,
      String? assignedByUserId,
      List<String>? requiredSkills,
      double estimatedHours,
      double actualHours,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class _$ReportAssignmentCopyWithImpl<$Res, $Val extends ReportAssignment>
    implements $ReportAssignmentCopyWith<$Res> {
  _$ReportAssignmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReportAssignment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reportId = null,
    Object? adminUserId = null,
    Object? assignedAt = null,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? dueDate = freezed,
    Object? notes = freezed,
    Object? internalNotes = freezed,
    Object? status = null,
    Object? priority = null,
    Object? assignedByUserId = freezed,
    Object? requiredSkills = freezed,
    Object? estimatedHours = null,
    Object? actualHours = null,
    Object? metadata = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      reportId: null == reportId
          ? _value.reportId
          : reportId // ignore: cast_nullable_to_non_nullable
              as String,
      adminUserId: null == adminUserId
          ? _value.adminUserId
          : adminUserId // ignore: cast_nullable_to_non_nullable
              as String,
      assignedAt: null == assignedAt
          ? _value.assignedAt
          : assignedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      startedAt: freezed == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dueDate: freezed == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      internalNotes: freezed == internalNotes
          ? _value.internalNotes
          : internalNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as AssignmentStatus,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as AssignmentPriority,
      assignedByUserId: freezed == assignedByUserId
          ? _value.assignedByUserId
          : assignedByUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      requiredSkills: freezed == requiredSkills
          ? _value.requiredSkills
          : requiredSkills // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      estimatedHours: null == estimatedHours
          ? _value.estimatedHours
          : estimatedHours // ignore: cast_nullable_to_non_nullable
              as double,
      actualHours: null == actualHours
          ? _value.actualHours
          : actualHours // ignore: cast_nullable_to_non_nullable
              as double,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReportAssignmentImplCopyWith<$Res>
    implements $ReportAssignmentCopyWith<$Res> {
  factory _$$ReportAssignmentImplCopyWith(_$ReportAssignmentImpl value,
          $Res Function(_$ReportAssignmentImpl) then) =
      __$$ReportAssignmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String reportId,
      String adminUserId,
      DateTime assignedAt,
      DateTime? startedAt,
      DateTime? completedAt,
      DateTime? dueDate,
      String? notes,
      String? internalNotes,
      AssignmentStatus status,
      AssignmentPriority priority,
      String? assignedByUserId,
      List<String>? requiredSkills,
      double estimatedHours,
      double actualHours,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$ReportAssignmentImplCopyWithImpl<$Res>
    extends _$ReportAssignmentCopyWithImpl<$Res, _$ReportAssignmentImpl>
    implements _$$ReportAssignmentImplCopyWith<$Res> {
  __$$ReportAssignmentImplCopyWithImpl(_$ReportAssignmentImpl _value,
      $Res Function(_$ReportAssignmentImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReportAssignment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reportId = null,
    Object? adminUserId = null,
    Object? assignedAt = null,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? dueDate = freezed,
    Object? notes = freezed,
    Object? internalNotes = freezed,
    Object? status = null,
    Object? priority = null,
    Object? assignedByUserId = freezed,
    Object? requiredSkills = freezed,
    Object? estimatedHours = null,
    Object? actualHours = null,
    Object? metadata = freezed,
  }) {
    return _then(_$ReportAssignmentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      reportId: null == reportId
          ? _value.reportId
          : reportId // ignore: cast_nullable_to_non_nullable
              as String,
      adminUserId: null == adminUserId
          ? _value.adminUserId
          : adminUserId // ignore: cast_nullable_to_non_nullable
              as String,
      assignedAt: null == assignedAt
          ? _value.assignedAt
          : assignedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      startedAt: freezed == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dueDate: freezed == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      internalNotes: freezed == internalNotes
          ? _value.internalNotes
          : internalNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as AssignmentStatus,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as AssignmentPriority,
      assignedByUserId: freezed == assignedByUserId
          ? _value.assignedByUserId
          : assignedByUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      requiredSkills: freezed == requiredSkills
          ? _value._requiredSkills
          : requiredSkills // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      estimatedHours: null == estimatedHours
          ? _value.estimatedHours
          : estimatedHours // ignore: cast_nullable_to_non_nullable
              as double,
      actualHours: null == actualHours
          ? _value.actualHours
          : actualHours // ignore: cast_nullable_to_non_nullable
              as double,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReportAssignmentImpl implements _ReportAssignment {
  const _$ReportAssignmentImpl(
      {required this.id,
      required this.reportId,
      required this.adminUserId,
      required this.assignedAt,
      this.startedAt,
      this.completedAt,
      this.dueDate,
      this.notes,
      this.internalNotes,
      this.status = AssignmentStatus.assigned,
      this.priority = AssignmentPriority.normal,
      this.assignedByUserId,
      final List<String>? requiredSkills,
      this.estimatedHours = 0.0,
      this.actualHours = 0.0,
      final Map<String, dynamic>? metadata})
      : _requiredSkills = requiredSkills,
        _metadata = metadata;

  factory _$ReportAssignmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReportAssignmentImplFromJson(json);

  @override
  final String id;
  @override
  final String reportId;
  @override
  final String adminUserId;
  @override
  final DateTime assignedAt;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? completedAt;
  @override
  final DateTime? dueDate;
  @override
  final String? notes;
  @override
  final String? internalNotes;
  @override
  @JsonKey()
  final AssignmentStatus status;
  @override
  @JsonKey()
  final AssignmentPriority priority;
  @override
  final String? assignedByUserId;
  final List<String>? _requiredSkills;
  @override
  List<String>? get requiredSkills {
    final value = _requiredSkills;
    if (value == null) return null;
    if (_requiredSkills is EqualUnmodifiableListView) return _requiredSkills;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey()
  final double estimatedHours;
  @override
  @JsonKey()
  final double actualHours;
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
    return 'ReportAssignment(id: $id, reportId: $reportId, adminUserId: $adminUserId, assignedAt: $assignedAt, startedAt: $startedAt, completedAt: $completedAt, dueDate: $dueDate, notes: $notes, internalNotes: $internalNotes, status: $status, priority: $priority, assignedByUserId: $assignedByUserId, requiredSkills: $requiredSkills, estimatedHours: $estimatedHours, actualHours: $actualHours, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReportAssignmentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.reportId, reportId) ||
                other.reportId == reportId) &&
            (identical(other.adminUserId, adminUserId) ||
                other.adminUserId == adminUserId) &&
            (identical(other.assignedAt, assignedAt) ||
                other.assignedAt == assignedAt) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.internalNotes, internalNotes) ||
                other.internalNotes == internalNotes) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.assignedByUserId, assignedByUserId) ||
                other.assignedByUserId == assignedByUserId) &&
            const DeepCollectionEquality()
                .equals(other._requiredSkills, _requiredSkills) &&
            (identical(other.estimatedHours, estimatedHours) ||
                other.estimatedHours == estimatedHours) &&
            (identical(other.actualHours, actualHours) ||
                other.actualHours == actualHours) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      reportId,
      adminUserId,
      assignedAt,
      startedAt,
      completedAt,
      dueDate,
      notes,
      internalNotes,
      status,
      priority,
      assignedByUserId,
      const DeepCollectionEquality().hash(_requiredSkills),
      estimatedHours,
      actualHours,
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of ReportAssignment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReportAssignmentImplCopyWith<_$ReportAssignmentImpl> get copyWith =>
      __$$ReportAssignmentImplCopyWithImpl<_$ReportAssignmentImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReportAssignmentImplToJson(
      this,
    );
  }
}

abstract class _ReportAssignment implements ReportAssignment {
  const factory _ReportAssignment(
      {required final String id,
      required final String reportId,
      required final String adminUserId,
      required final DateTime assignedAt,
      final DateTime? startedAt,
      final DateTime? completedAt,
      final DateTime? dueDate,
      final String? notes,
      final String? internalNotes,
      final AssignmentStatus status,
      final AssignmentPriority priority,
      final String? assignedByUserId,
      final List<String>? requiredSkills,
      final double estimatedHours,
      final double actualHours,
      final Map<String, dynamic>? metadata}) = _$ReportAssignmentImpl;

  factory _ReportAssignment.fromJson(Map<String, dynamic> json) =
      _$ReportAssignmentImpl.fromJson;

  @override
  String get id;
  @override
  String get reportId;
  @override
  String get adminUserId;
  @override
  DateTime get assignedAt;
  @override
  DateTime? get startedAt;
  @override
  DateTime? get completedAt;
  @override
  DateTime? get dueDate;
  @override
  String? get notes;
  @override
  String? get internalNotes;
  @override
  AssignmentStatus get status;
  @override
  AssignmentPriority get priority;
  @override
  String? get assignedByUserId;
  @override
  List<String>? get requiredSkills;
  @override
  double get estimatedHours;
  @override
  double get actualHours;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of ReportAssignment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReportAssignmentImplCopyWith<_$ReportAssignmentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
