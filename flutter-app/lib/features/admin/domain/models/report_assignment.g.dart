// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_assignment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReportAssignmentImpl _$$ReportAssignmentImplFromJson(
        Map<String, dynamic> json) =>
    _$ReportAssignmentImpl(
      id: json['id'] as String,
      reportId: json['reportId'] as String,
      adminUserId: json['adminUserId'] as String,
      assignedAt: DateTime.parse(json['assignedAt'] as String),
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      notes: json['notes'] as String?,
      internalNotes: json['internalNotes'] as String?,
      status: $enumDecodeNullable(_$AssignmentStatusEnumMap, json['status']) ??
          AssignmentStatus.assigned,
      priority:
          $enumDecodeNullable(_$AssignmentPriorityEnumMap, json['priority']) ??
              AssignmentPriority.normal,
      assignedByUserId: json['assignedByUserId'] as String?,
      requiredSkills: (json['requiredSkills'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      estimatedHours: (json['estimatedHours'] as num?)?.toDouble() ?? 0.0,
      actualHours: (json['actualHours'] as num?)?.toDouble() ?? 0.0,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$ReportAssignmentImplToJson(
        _$ReportAssignmentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reportId': instance.reportId,
      'adminUserId': instance.adminUserId,
      'assignedAt': instance.assignedAt.toIso8601String(),
      'startedAt': instance.startedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'dueDate': instance.dueDate?.toIso8601String(),
      'notes': instance.notes,
      'internalNotes': instance.internalNotes,
      'status': _$AssignmentStatusEnumMap[instance.status]!,
      'priority': _$AssignmentPriorityEnumMap[instance.priority]!,
      'assignedByUserId': instance.assignedByUserId,
      'requiredSkills': instance.requiredSkills,
      'estimatedHours': instance.estimatedHours,
      'actualHours': instance.actualHours,
      'metadata': instance.metadata,
    };

const _$AssignmentStatusEnumMap = {
  AssignmentStatus.assigned: 'assigned',
  AssignmentStatus.accepted: 'accepted',
  AssignmentStatus.started: 'started',
  AssignmentStatus.inProgress: 'in_progress',
  AssignmentStatus.review: 'review',
  AssignmentStatus.completed: 'completed',
  AssignmentStatus.reassigned: 'reassigned',
  AssignmentStatus.cancelled: 'cancelled',
};

const _$AssignmentPriorityEnumMap = {
  AssignmentPriority.low: 'low',
  AssignmentPriority.normal: 'normal',
  AssignmentPriority.high: 'high',
  AssignmentPriority.urgent: 'urgent',
  AssignmentPriority.critical: 'critical',
};
