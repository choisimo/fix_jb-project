import 'package:freezed_annotation/freezed_annotation.dart';

/// 리포트 타입 열거형
enum ReportType {
  @JsonValue('pothole')
  pothole,
  
  @JsonValue('street_light')
  streetLight,
  
  @JsonValue('trash')
  trash,
  
  @JsonValue('graffiti')
  graffiti,
  
  @JsonValue('road_damage')
  roadDamage,
  
  @JsonValue('construction')
  construction,
  
  @JsonValue('other')
  other,
}

/// 우선순위 열거형
enum Priority {
  @JsonValue('low')
  low,
  
  @JsonValue('medium')
  medium,
  
  @JsonValue('high')
  high,
  
  @JsonValue('urgent')
  urgent,
}

/// 리포트 상태 열거형
enum ReportStatus {
  @JsonValue('draft')
  draft,
  
  @JsonValue('submitted')
  submitted,
  
  @JsonValue('in_progress')
  inProgress,
  
  @JsonValue('completed')
  completed,
  
  @JsonValue('rejected')
  rejected,
}

/// ReportType 확장
extension ReportTypeExtension on ReportType {
  String get displayName {
    switch (this) {
      case ReportType.pothole:
        return '포트홀';
      case ReportType.streetLight:
        return '가로등';
      case ReportType.trash:
        return '쓰레기';
      case ReportType.graffiti:
        return '낙서';
      case ReportType.roadDamage:
        return '도로 손상';
      case ReportType.construction:
        return '공사';
      case ReportType.other:
        return '기타';
    }
  }

  String get description {
    switch (this) {
      case ReportType.pothole:
        return '도로의 움푹 팬 부분';
      case ReportType.streetLight:
        return '가로등 고장 또는 문제';
      case ReportType.trash:
        return '불법 투기 쓰레기';
      case ReportType.graffiti:
        return '공공시설 낙서';
      case ReportType.roadDamage:
        return '도로 파손 및 손상';
      case ReportType.construction:
        return '공사 관련 문제';
      case ReportType.other:
        return '기타 시설물 문제';
    }
  }

  String get iconName {
    switch (this) {
      case ReportType.pothole:
        return 'road';
      case ReportType.streetLight:
        return 'lightbulb';
      case ReportType.trash:
        return 'delete';
      case ReportType.graffiti:
        return 'brush';
      case ReportType.roadDamage:
        return 'construction';
      case ReportType.construction:
        return 'build';
      case ReportType.other:
        return 'help_outline';
    }
  }
}

/// Priority 확장
extension PriorityExtension on Priority {
  String get displayName {
    switch (this) {
      case Priority.low:
        return '낮음';
      case Priority.medium:
        return '보통';
      case Priority.high:
        return '높음';
      case Priority.urgent:
        return '긴급';
    }
  }

  int get order {
    switch (this) {
      case Priority.low:
        return 1;
      case Priority.medium:
        return 2;
      case Priority.high:
        return 3;
      case Priority.urgent:
        return 4;
    }
  }
}

/// ReportStatus 확장
extension ReportStatusExtension on ReportStatus {
  String get displayName {
    switch (this) {
      case ReportStatus.draft:
        return '임시저장';
      case ReportStatus.submitted:
        return '제출됨';
      case ReportStatus.inProgress:
        return '처리중';
      case ReportStatus.completed:
        return '완료';
      case ReportStatus.rejected:
        return '반려';
    }
  }

  bool get isEditable {
    return this == ReportStatus.draft;
  }

  bool get canCancel {
    return this == ReportStatus.submitted || this == ReportStatus.inProgress;
  }
}