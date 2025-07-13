import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_assignment.freezed.dart';
part 'report_assignment.g.dart';

@freezed
class ReportAssignment with _$ReportAssignment {
  const factory ReportAssignment({
    required String id,
    required String reportId,
    required String adminUserId,
    required DateTime assignedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? dueDate,
    String? notes,
    String? internalNotes,
    @Default(AssignmentStatus.assigned) AssignmentStatus status,
    @Default(AssignmentPriority.normal) AssignmentPriority priority,
    String? assignedByUserId,
    List<String>? requiredSkills,
    @Default(0.0) double estimatedHours,
    @Default(0.0) double actualHours,
    Map<String, dynamic>? metadata,
  }) = _ReportAssignment;

  factory ReportAssignment.fromJson(Map<String, dynamic> json) =>
      _$ReportAssignmentFromJson(json);
}

@JsonEnum()
enum AssignmentStatus {
  @JsonValue('assigned')
  assigned,
  @JsonValue('accepted')
  accepted,
  @JsonValue('started')
  started,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('review')
  review,
  @JsonValue('completed')
  completed,
  @JsonValue('reassigned')
  reassigned,
  @JsonValue('cancelled')
  cancelled,
}

@JsonEnum()
enum AssignmentPriority {
  @JsonValue('low')
  low,
  @JsonValue('normal')
  normal,
  @JsonValue('high')
  high,
  @JsonValue('urgent')
  urgent,
  @JsonValue('critical')
  critical,
}

extension AssignmentStatusExtension on AssignmentStatus {
  String get displayName {
    switch (this) {
      case AssignmentStatus.assigned:
        return 'Assigned';
      case AssignmentStatus.accepted:
        return 'Accepted';
      case AssignmentStatus.started:
        return 'Started';
      case AssignmentStatus.inProgress:
        return 'In Progress';
      case AssignmentStatus.review:
        return 'Under Review';
      case AssignmentStatus.completed:
        return 'Completed';
      case AssignmentStatus.reassigned:
        return 'Reassigned';
      case AssignmentStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isActive {
    return this != AssignmentStatus.completed && 
           this != AssignmentStatus.cancelled &&
           this != AssignmentStatus.reassigned;
  }
}

extension AssignmentPriorityExtension on AssignmentPriority {
  String get displayName {
    switch (this) {
      case AssignmentPriority.low:
        return 'Low';
      case AssignmentPriority.normal:
        return 'Normal';
      case AssignmentPriority.high:
        return 'High';
      case AssignmentPriority.urgent:
        return 'Urgent';
      case AssignmentPriority.critical:
        return 'Critical';
    }
  }

  int get priorityLevel {
    switch (this) {
      case AssignmentPriority.low:
        return 1;
      case AssignmentPriority.normal:
        return 2;
      case AssignmentPriority.high:
        return 3;
      case AssignmentPriority.urgent:
        return 4;
      case AssignmentPriority.critical:
        return 5;
    }
  }
}