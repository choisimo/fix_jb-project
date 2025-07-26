// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AdminUserImpl _$$AdminUserImplFromJson(Map<String, dynamic> json) =>
    _$AdminUserImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: $enumDecode(_$AdminRoleEnumMap, json['role']),
      department: json['department'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      status: $enumDecodeNullable(_$AdminStatusEnumMap, json['status']) ??
          AdminStatus.active,
      processedReports: (json['processedReports'] as num?)?.toInt() ?? 0,
      averageProcessingTime:
          (json['averageProcessingTime'] as num?)?.toDouble() ?? 0.0,
      satisfactionScore: (json['satisfactionScore'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] == null
          ? null
          : DateTime.parse(json['lastLoginAt'] as String),
      specializations: (json['specializations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      phoneNumber: json['phoneNumber'] as String?,
      position: json['position'] as String?,
      isOnline: json['isOnline'] as bool? ?? false,
      currentAssignments: (json['currentAssignments'] as num?)?.toInt() ?? 0,
      maxAssignments: (json['maxAssignments'] as num?)?.toInt() ?? 5,
      preferences: json['preferences'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$AdminUserImplToJson(_$AdminUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'role': _$AdminRoleEnumMap[instance.role]!,
      'department': instance.department,
      'profileImageUrl': instance.profileImageUrl,
      'status': _$AdminStatusEnumMap[instance.status]!,
      'processedReports': instance.processedReports,
      'averageProcessingTime': instance.averageProcessingTime,
      'satisfactionScore': instance.satisfactionScore,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
      'specializations': instance.specializations,
      'phoneNumber': instance.phoneNumber,
      'position': instance.position,
      'isOnline': instance.isOnline,
      'currentAssignments': instance.currentAssignments,
      'maxAssignments': instance.maxAssignments,
      'preferences': instance.preferences,
    };

const _$AdminRoleEnumMap = {
  AdminRole.systemAdmin: 'system_admin',
  AdminRole.processManager: 'process_manager',
  AdminRole.officer: 'officer',
  AdminRole.readOnly: 'read_only',
};

const _$AdminStatusEnumMap = {
  AdminStatus.active: 'active',
  AdminStatus.inactive: 'inactive',
  AdminStatus.suspended: 'suspended',
};
