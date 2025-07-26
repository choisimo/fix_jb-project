// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreateReportRequestImpl _$$CreateReportRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateReportRequestImpl(
      title: json['title'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$ReportTypeEnumMap, json['type']),
      location:
          ReportLocation.fromJson(json['location'] as Map<String, dynamic>),
      imageIds: (json['imageIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      priority: $enumDecodeNullable(_$PriorityEnumMap, json['priority']) ??
          Priority.medium,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$CreateReportRequestImplToJson(
        _$CreateReportRequestImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'type': _$ReportTypeEnumMap[instance.type]!,
      'location': instance.location,
      'imageIds': instance.imageIds,
      'priority': _$PriorityEnumMap[instance.priority]!,
      'metadata': instance.metadata,
    };

const _$ReportTypeEnumMap = {
  ReportType.pothole: 'POTHOLE',
  ReportType.streetLight: 'STREET_LIGHT',
  ReportType.trash: 'TRASH',
  ReportType.graffiti: 'GRAFFITI',
  ReportType.roadDamage: 'ROAD_DAMAGE',
  ReportType.construction: 'CONSTRUCTION',
  ReportType.other: 'OTHER',
};

const _$PriorityEnumMap = {
  Priority.low: 'LOW',
  Priority.medium: 'MEDIUM',
  Priority.high: 'HIGH',
  Priority.urgent: 'URGENT',
};

_$UpdateReportRequestImpl _$$UpdateReportRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$UpdateReportRequestImpl(
      title: json['title'] as String?,
      description: json['description'] as String?,
      type: $enumDecodeNullable(_$ReportTypeEnumMap, json['type']),
      location: json['location'] == null
          ? null
          : ReportLocation.fromJson(json['location'] as Map<String, dynamic>),
      imageIds: (json['imageIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      priority: $enumDecodeNullable(_$PriorityEnumMap, json['priority']),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$UpdateReportRequestImplToJson(
        _$UpdateReportRequestImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'type': _$ReportTypeEnumMap[instance.type],
      'location': instance.location,
      'imageIds': instance.imageIds,
      'priority': _$PriorityEnumMap[instance.priority],
      'metadata': instance.metadata,
    };

_$ReportListRequestImpl _$$ReportListRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$ReportListRequestImpl(
      page: (json['page'] as num?)?.toInt() ?? 0,
      size: (json['size'] as num?)?.toInt() ?? 20,
      search: json['search'] as String?,
      type: $enumDecodeNullable(_$ReportTypeEnumMap, json['type']),
      status: $enumDecodeNullable(_$ReportStatusEnumMap, json['status']),
      priority: $enumDecodeNullable(_$PriorityEnumMap, json['priority']),
      userId: (json['userId'] as num?)?.toInt(),
      sortBy: json['sortBy'] as String?,
      sortDirection: json['sortDirection'] as String? ?? 'desc',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      radius: (json['radius'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$ReportListRequestImplToJson(
        _$ReportListRequestImpl instance) =>
    <String, dynamic>{
      'page': instance.page,
      'size': instance.size,
      'search': instance.search,
      'type': _$ReportTypeEnumMap[instance.type],
      'status': _$ReportStatusEnumMap[instance.status],
      'priority': _$PriorityEnumMap[instance.priority],
      'userId': instance.userId,
      'sortBy': instance.sortBy,
      'sortDirection': instance.sortDirection,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'radius': instance.radius,
    };

const _$ReportStatusEnumMap = {
  ReportStatus.draft: 'DRAFT',
  ReportStatus.submitted: 'SUBMITTED',
  ReportStatus.inReview: 'IN_REVIEW',
  ReportStatus.approved: 'APPROVED',
  ReportStatus.rejected: 'REJECTED',
  ReportStatus.resolved: 'RESOLVED',
  ReportStatus.closed: 'CLOSED',
};

_$ReportListResponseImpl _$$ReportListResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$ReportListResponseImpl(
      reports: (json['reports'] as List<dynamic>)
          .map((e) => Report.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalElements: (json['totalElements'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      currentPage: (json['currentPage'] as num).toInt(),
      size: (json['size'] as num).toInt(),
      hasNext: json['hasNext'] as bool? ?? false,
      hasPrevious: json['hasPrevious'] as bool? ?? false,
    );

Map<String, dynamic> _$$ReportListResponseImplToJson(
        _$ReportListResponseImpl instance) =>
    <String, dynamic>{
      'reports': instance.reports,
      'totalElements': instance.totalElements,
      'totalPages': instance.totalPages,
      'currentPage': instance.currentPage,
      'size': instance.size,
      'hasNext': instance.hasNext,
      'hasPrevious': instance.hasPrevious,
    };

_$ImageUploadRequestImpl _$$ImageUploadRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$ImageUploadRequestImpl(
      filename: json['filename'] as String,
      mimeType: json['mimeType'] as String,
      fileSize: (json['fileSize'] as num).toInt(),
    );

Map<String, dynamic> _$$ImageUploadRequestImplToJson(
        _$ImageUploadRequestImpl instance) =>
    <String, dynamic>{
      'filename': instance.filename,
      'mimeType': instance.mimeType,
      'fileSize': instance.fileSize,
    };

_$ImageUploadResponseImpl _$$ImageUploadResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$ImageUploadResponseImpl(
      imageId: json['imageId'] as String,
      uploadUrl: json['uploadUrl'] as String,
      imageUrl: json['imageUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$$ImageUploadResponseImplToJson(
        _$ImageUploadResponseImpl instance) =>
    <String, dynamic>{
      'imageId': instance.imageId,
      'uploadUrl': instance.uploadUrl,
      'imageUrl': instance.imageUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'expiresAt': instance.expiresAt?.toIso8601String(),
    };

_$AIAnalysisRequestImpl _$$AIAnalysisRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$AIAnalysisRequestImpl(
      imageId: json['imageId'] as String,
      expectedType:
          $enumDecodeNullable(_$ReportTypeEnumMap, json['expectedType']),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$AIAnalysisRequestImplToJson(
        _$AIAnalysisRequestImpl instance) =>
    <String, dynamic>{
      'imageId': instance.imageId,
      'expectedType': _$ReportTypeEnumMap[instance.expectedType],
      'metadata': instance.metadata,
    };

_$ReportStatsResponseImpl _$$ReportStatsResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$ReportStatsResponseImpl(
      totalReports: (json['totalReports'] as num).toInt(),
      submittedReports: (json['submittedReports'] as num).toInt(),
      inReviewReports: (json['inReviewReports'] as num).toInt(),
      approvedReports: (json['approvedReports'] as num).toInt(),
      resolvedReports: (json['resolvedReports'] as num).toInt(),
      rejectedReports: (json['rejectedReports'] as num).toInt(),
      reportsByType: Map<String, int>.from(json['reportsByType'] as Map),
      reportsByPriority:
          Map<String, int>.from(json['reportsByPriority'] as Map),
      reportsByMonth: Map<String, int>.from(json['reportsByMonth'] as Map),
    );

Map<String, dynamic> _$$ReportStatsResponseImplToJson(
        _$ReportStatsResponseImpl instance) =>
    <String, dynamic>{
      'totalReports': instance.totalReports,
      'submittedReports': instance.submittedReports,
      'inReviewReports': instance.inReviewReports,
      'approvedReports': instance.approvedReports,
      'resolvedReports': instance.resolvedReports,
      'rejectedReports': instance.rejectedReports,
      'reportsByType': instance.reportsByType,
      'reportsByPriority': instance.reportsByPriority,
      'reportsByMonth': instance.reportsByMonth,
    };

_$AddCommentRequestImpl _$$AddCommentRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$AddCommentRequestImpl(
      content: json['content'] as String,
    );

Map<String, dynamic> _$$AddCommentRequestImplToJson(
        _$AddCommentRequestImpl instance) =>
    <String, dynamic>{
      'content': instance.content,
    };

_$UpdateCommentRequestImpl _$$UpdateCommentRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$UpdateCommentRequestImpl(
      content: json['content'] as String,
    );

Map<String, dynamic> _$$UpdateCommentRequestImplToJson(
        _$UpdateCommentRequestImpl instance) =>
    <String, dynamic>{
      'content': instance.content,
    };
