// import 'package:freezed_annotation/freezed_annotation.dart';

// part 'report_filter.freezed.dart';
// part 'report_filter.g.dart';

/// 신고서 필터링을 위한 모델
// @freezed
class ReportFilter {
  final String keyword;
  final List<String> categories;
  final List<String> statuses;
  final List<String> priorities;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool onlyMyReports;
  final bool onlyComplexSubjects;
  final bool onlyWithImages;
  final String? location;
  final double radiusKm;

  const ReportFilter({
    this.keyword = '',
    this.categories = const [],
    this.statuses = const [],
    this.priorities = const [],
    this.startDate,
    this.endDate,
    this.onlyMyReports = false,
    this.onlyComplexSubjects = false,
    this.onlyWithImages = false,
    this.location,
    this.radiusKm = 10.0,
  });

  ReportFilter copyWith({
    String? keyword,
    List<String>? categories,
    List<String>? statuses,
    List<String>? priorities,
    DateTime? startDate,
    DateTime? endDate,
    bool? onlyMyReports,
    bool? onlyComplexSubjects,
    bool? onlyWithImages,
    String? location,
    double? radiusKm,
  }) {
    return ReportFilter(
      keyword: keyword ?? this.keyword,
      categories: categories ?? this.categories,
      statuses: statuses ?? this.statuses,
      priorities: priorities ?? this.priorities,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      onlyMyReports: onlyMyReports ?? this.onlyMyReports,
      onlyComplexSubjects: onlyComplexSubjects ?? this.onlyComplexSubjects,
      onlyWithImages: onlyWithImages ?? this.onlyWithImages,
      location: location ?? this.location,
      radiusKm: radiusKm ?? this.radiusKm,
    );
  }

  // factory ReportFilter.fromJson(Map<String, dynamic> json) =>
  //     _$ReportFilterFromJson(json);
}

/// 사용 가능한 필터 옵션들
class FilterOptions {
  static const List<String> priorities = [
    'LOW',
    'MEDIUM', 
    'HIGH',
    'URGENT',
  ];

  static const List<String> statuses = [
    '신규',
    '접수',
    '처리중',
    '완료',
    '보류',
    '취소',
  ];

  static const List<String> categories = [
    '도로/교통',
    '환경',
    '안전',
    '시설물',
    '민원',
    '기타',
  ];

  /// 우선순위를 한국어로 변환
  static String getPriorityDisplayName(String priority) {
    switch (priority) {
      case 'LOW':
        return '낮음';
      case 'MEDIUM':
        return '보통';
      case 'HIGH':
        return '높음';
      case 'URGENT':
        return '긴급';
      default:
        return priority;
    }
  }

  /// 한국어 우선순위를 영어로 변환
  static String getPriorityValue(String displayName) {
    switch (displayName) {
      case '낮음':
        return 'LOW';
      case '보통':
        return 'MEDIUM';
      case '높음':
        return 'HIGH';
      case '긴급':
        return 'URGENT';
      default:
        return displayName;
    }
  }
}