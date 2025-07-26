// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReportLocationImpl _$$ReportLocationImplFromJson(Map<String, dynamic> json) =>
    _$ReportLocationImpl(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
      city: json['city'] as String?,
      district: json['district'] as String?,
      postalCode: json['postalCode'] as String?,
      landmark: json['landmark'] as String?,
    );

Map<String, dynamic> _$$ReportLocationImplToJson(
        _$ReportLocationImpl instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'address': instance.address,
      'city': instance.city,
      'district': instance.district,
      'postalCode': instance.postalCode,
      'landmark': instance.landmark,
    };

_$ReportImageImpl _$$ReportImageImplFromJson(Map<String, dynamic> json) =>
    _$ReportImageImpl(
      id: json['id'] as String,
      url: json['url'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      filename: json['filename'] as String?,
      fileSize: (json['fileSize'] as num?)?.toInt(),
      mimeType: json['mimeType'] as String?,
      order: (json['order'] as num?)?.toInt() ?? 0,
      uploadedAt: json['uploadedAt'] == null
          ? null
          : DateTime.parse(json['uploadedAt'] as String),
    );

Map<String, dynamic> _$$ReportImageImplToJson(_$ReportImageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'thumbnailUrl': instance.thumbnailUrl,
      'filename': instance.filename,
      'fileSize': instance.fileSize,
      'mimeType': instance.mimeType,
      'order': instance.order,
      'uploadedAt': instance.uploadedAt?.toIso8601String(),
    };

_$AIAnalysisResultImpl _$$AIAnalysisResultImplFromJson(
        Map<String, dynamic> json) =>
    _$AIAnalysisResultImpl(
      id: json['id'] as String,
      detectedType: $enumDecode(_$ReportTypeEnumMap, json['detectedType']),
      confidence: (json['confidence'] as num).toDouble(),
      description: json['description'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      suggestedPriority:
          $enumDecodeNullable(_$PriorityEnumMap, json['suggestedPriority']) ??
              Priority.medium,
      analyzedAt: json['analyzedAt'] == null
          ? null
          : DateTime.parse(json['analyzedAt'] as String),
    );

Map<String, dynamic> _$$AIAnalysisResultImplToJson(
        _$AIAnalysisResultImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'detectedType': _$ReportTypeEnumMap[instance.detectedType]!,
      'confidence': instance.confidence,
      'description': instance.description,
      'metadata': instance.metadata,
      'tags': instance.tags,
      'suggestedPriority': _$PriorityEnumMap[instance.suggestedPriority]!,
      'analyzedAt': instance.analyzedAt?.toIso8601String(),
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

_$ReportImpl _$$ReportImplFromJson(Map<String, dynamic> json) => _$ReportImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$ReportTypeEnumMap, json['type']),
      status: $enumDecode(_$ReportStatusEnumMap, json['status']),
      location:
          ReportLocation.fromJson(json['location'] as Map<String, dynamic>),
      images: (json['images'] as List<dynamic>)
          .map((e) => ReportImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      userId: (json['userId'] as num).toInt(),
      userFullName: json['userFullName'] as String?,
      priority: $enumDecodeNullable(_$PriorityEnumMap, json['priority']) ??
          Priority.medium,
      aiAnalysis: json['aiAnalysis'] == null
          ? null
          : AIAnalysisResult.fromJson(
              json['aiAnalysis'] as Map<String, dynamic>),
      submittedAt: json['submittedAt'] == null
          ? null
          : DateTime.parse(json['submittedAt'] as String),
      reviewedAt: json['reviewedAt'] == null
          ? null
          : DateTime.parse(json['reviewedAt'] as String),
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      reviewComment: json['reviewComment'] as String?,
      resolutionComment: json['resolutionComment'] as String?,
      assignedToUserId: (json['assignedToUserId'] as num?)?.toInt(),
      assignedToUserName: json['assignedToUserName'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
    );

Map<String, dynamic> _$$ReportImplToJson(_$ReportImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'type': _$ReportTypeEnumMap[instance.type]!,
      'status': _$ReportStatusEnumMap[instance.status]!,
      'location': instance.location,
      'images': instance.images,
      'userId': instance.userId,
      'userFullName': instance.userFullName,
      'priority': _$PriorityEnumMap[instance.priority]!,
      'aiAnalysis': instance.aiAnalysis,
      'submittedAt': instance.submittedAt?.toIso8601String(),
      'reviewedAt': instance.reviewedAt?.toIso8601String(),
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'reviewComment': instance.reviewComment,
      'resolutionComment': instance.resolutionComment,
      'assignedToUserId': instance.assignedToUserId,
      'assignedToUserName': instance.assignedToUserName,
      'metadata': instance.metadata,
      'viewCount': instance.viewCount,
      'likeCount': instance.likeCount,
      'isLiked': instance.isLiked,
      'isBookmarked': instance.isBookmarked,
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

_$ReportCommentImpl _$$ReportCommentImplFromJson(Map<String, dynamic> json) =>
    _$ReportCommentImpl(
      id: json['id'] as String,
      reportId: json['reportId'] as String,
      userId: (json['userId'] as num).toInt(),
      userFullName: json['userFullName'] as String,
      userProfileImage: json['userProfileImage'] as String?,
      content: json['content'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      isEdited: json['isEdited'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );

Map<String, dynamic> _$$ReportCommentImplToJson(_$ReportCommentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reportId': instance.reportId,
      'userId': instance.userId,
      'userFullName': instance.userFullName,
      'userProfileImage': instance.userProfileImage,
      'content': instance.content,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'isEdited': instance.isEdited,
      'isDeleted': instance.isDeleted,
    };
