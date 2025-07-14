import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_user.freezed.dart';
part 'admin_user.g.dart';

@freezed
class AdminUser with _$AdminUser {
  const factory AdminUser({
    required String id,
    required String email,
    required String name,
    required AdminRole role,
    required String department,
    String? profileImageUrl,
    @Default(AdminStatus.active) AdminStatus status,
    @Default(0) int processedReports,
    @Default(0.0) double averageProcessingTime,
    @Default(0.0) double satisfactionScore,
    required DateTime createdAt,
    DateTime? lastLoginAt,
    List<String>? specializations,
    String? phoneNumber,
    String? position,
    @Default(false) bool isOnline,
    @Default(0) int currentAssignments,
    @Default(5) int maxAssignments,
    Map<String, dynamic>? preferences,
  }) = _AdminUser;

  factory AdminUser.fromJson(Map<String, dynamic> json) =>
      _$AdminUserFromJson(json);
}

@JsonEnum()
enum AdminRole {
  @JsonValue('system_admin')
  systemAdmin,
  @JsonValue('process_manager')
  processManager,
  @JsonValue('officer')
  officer,
  @JsonValue('read_only')
  readOnly,
}

@JsonEnum()
enum AdminStatus {
  @JsonValue('active')
  active,
  @JsonValue('inactive')
  inactive,
  @JsonValue('suspended')
  suspended,
}

extension AdminRoleExtension on AdminRole {
  String get displayName {
    switch (this) {
      case AdminRole.systemAdmin:
        return 'System Administrator';
      case AdminRole.processManager:
        return 'Process Manager';
      case AdminRole.officer:
        return 'Officer';
      case AdminRole.readOnly:
        return 'Read Only';
    }
  }

  List<AdminPermission> get permissions {
    switch (this) {
      case AdminRole.systemAdmin:
        return AdminPermission.values;
      case AdminRole.processManager:
        return [
          AdminPermission.viewDashboard,
          AdminPermission.manageReports,
          AdminPermission.assignReports,
          AdminPermission.viewStatistics,
          AdminPermission.generateReports,
          AdminPermission.manageNotifications,
          AdminPermission.viewAuditLogs,
        ];
      case AdminRole.officer:
        return [
          AdminPermission.viewDashboard,
          AdminPermission.viewAssignedReports,
          AdminPermission.updateReportStatus,
          AdminPermission.addComments,
          AdminPermission.viewBasicStatistics,
        ];
      case AdminRole.readOnly:
        return [
          AdminPermission.viewDashboard,
          AdminPermission.viewReports,
          AdminPermission.viewBasicStatistics,
        ];
    }
  }
}

enum AdminPermission {
  viewDashboard,
  manageReports,
  viewReports,
  viewAssignedReports,
  updateReportStatus,
  assignReports,
  addComments,
  manageUsers,
  manageSystemSettings,
  viewStatistics,
  viewBasicStatistics,
  generateReports,
  manageNotifications,
  viewAuditLogs,
  manageAI,
}