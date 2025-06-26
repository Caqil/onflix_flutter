import 'package:json_annotation/json_annotation.dart';
import 'package:onflix/shared/models/base_model.dart';

part 'admin_user_model.g.dart';

@JsonSerializable()
class AdminUserModel extends BaseModel {
  final String email;
  final bool emailVisibility;
  final bool verified;
  

  const AdminUserModel({
    required super.id,
    super.collectionId,
    super.collectionName,
    required super.created,
    required super.updated,
    required this.email,
    required this.emailVisibility,
    required this.verified,
   
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) =>
      _$AdminUserModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AdminUserModelToJson(this);

  factory AdminUserModel.fromRecord(dynamic record) {
    // PocketBase _superusers auth response structure:
    // {
    //   "token": "JWT_TOKEN",
    //   "record": {
    //     "collectionId": "pbc_3142635823",
    //     "collectionName": "_superusers", 
    //     "id": "test",
    //     "email": "test@example.com",
    //     "emailVisibility": true,
    //     "verified": true,
    //     "created": "2022-01-01 10:00:00.123Z",
    //     "updated": "2022-01-01 10:00:00.123Z"
    //   }
    // }

    return AdminUserModel(
      id: record.id,
      collectionId: record.collectionId,
      collectionName: record.collectionName,
      created: DateTime.parse(record.created),
      updated: DateTime.parse(record.updated),
      
      // Core _superusers fields
      email: record.email ?? '',
      emailVisibility: record.emailVisibility ?? false,
      verified: record.verified ?? false,
    
    );
  }

  // Helper methods to safely extract optional custom fields
  static String? _getFieldValue(dynamic record, String key) {
    try {
      // Check if property exists on record object
      if (record.data != null && record.data.containsKey(key)) {
        return record.data[key]?.toString();
      }
      // Check if property exists at root level (for extended _superusers schema)
      if (record.toJson().containsKey(key)) {
        return record.toJson()[key]?.toString();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static List<String>? _getListValue(dynamic record, String key) {
    try {
      dynamic value;
      if (record.data != null && record.data.containsKey(key)) {
        value = record.data[key];
      } else if (record.toJson().containsKey(key)) {
        value = record.toJson()[key];
      }
      
      if (value != null && value is List) {
        return List<String>.from(value);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Map<String, dynamic>? _getMapValue(dynamic record, String key) {
    try {
      dynamic value;
      if (record.data != null && record.data.containsKey(key)) {
        value = record.data[key];
      } else if (record.toJson().containsKey(key)) {
        value = record.toJson()[key];
      }
      
      if (value != null && value is Map) {
        return Map<String, dynamic>.from(value);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static DateTime? _getDateTimeValue(dynamic record, String key) {
    try {
      final dateString = _getFieldValue(record, key);
      return dateString != null ? DateTime.parse(dateString) : null;
    } catch (e) {
      return null;
    }
  }

  static int? _getIntValue(dynamic record, String key) {
    try {
      final value = _getFieldValue(record, key);
      return value != null ? int.tryParse(value) : null;
    } catch (e) {
      return null;
    }
  }

  static bool? _getBoolValue(dynamic record, String key) {
    try {
      dynamic value;
      if (record.data != null && record.data.containsKey(key)) {
        value = record.data[key];
      } else if (record.toJson().containsKey(key)) {
        value = record.toJson()[key];
      }
      
      if (value is bool) return value;
      if (value is String) return value.toLowerCase() == 'true';
      return null;
    } catch (e) {
      return null;
    }
  }

  // Copy with method
  AdminUserModel copyWith({
    String? email,
    bool? emailVisibility,
    bool? verified,
  }) {
    return AdminUserModel(
      id: id,
      collectionId: collectionId,
      collectionName: collectionName,
      created: created,
      updated: updated,
      email: email ?? this.email,
      emailVisibility: emailVisibility ?? this.emailVisibility,
      verified: verified ?? this.verified,
     
    );
  }

  @override
  String toString() {
    return 'AdminUserModel(id: $id, email: $email,verified: $verified)';
  }
}

// Admin role constants - same as before but with better defaults
class AdminRole {
  static const String superAdmin = 'super_admin';
  static const String admin = 'admin';
  static const String moderator = 'moderator';
  static const String contentManager = 'content_manager';
  static const String analyst = 'analyst';

  static const List<String> all = [
    superAdmin,
    admin,
    moderator,
    contentManager,
    analyst,
  ];

  static String getDisplayName(String role) {
    switch (role) {
      case superAdmin:
        return 'Super Admin';
      case admin:
        return 'Admin';
      case moderator:
        return 'Moderator';
      case contentManager:
        return 'Content Manager';
      case analyst:
        return 'Analyst';
      default:
        return 'Admin';
    }
  }

  static List<String> getPermissions(String role) {
    switch (role) {
      case superAdmin:
        return AdminPermissions.all;
      case admin:
        return [
          AdminPermissions.manageUsers,
          AdminPermissions.manageContent,
          AdminPermissions.viewAnalytics,
          AdminPermissions.manageReports,
          AdminPermissions.managePayments,
        ];
      case moderator:
        return [
          AdminPermissions.manageContent,
          AdminPermissions.manageReports,
          AdminPermissions.viewAnalytics,
        ];
      case contentManager:
        return [
          AdminPermissions.manageContent,
          AdminPermissions.viewAnalytics,
        ];
      case analyst:
        return [
          AdminPermissions.viewAnalytics,
        ];
      default:
        return [
          AdminPermissions.manageUsers,
          AdminPermissions.manageContent,
          AdminPermissions.viewAnalytics,
          AdminPermissions.manageReports,
        ];
    }
  }
}

// Admin status constants (same as before)
class AdminStatus {
  static const String active = 'active';
  static const String suspended = 'suspended';
  static const String pending = 'pending';

  static const List<String> all = [
    active,
    suspended,
    pending,
  ];
}

// Admin permissions constants (same as before)
class AdminPermissions {
  static const String manageUsers = 'manage_users';
  static const String manageContent = 'manage_content';
  static const String viewAnalytics = 'view_analytics';
  static const String manageReports = 'manage_reports';
  static const String managePayments = 'manage_payments';
  static const String manageSystem = 'manage_system';
  static const String manageNotifications = 'manage_notifications';
  static const String viewLogs = 'view_logs';

  static const List<String> all = [
    manageUsers,
    manageContent,
    viewAnalytics,
    manageReports,
    managePayments,
    manageSystem,
    manageNotifications,
    viewLogs,
  ];

  static String getDisplayName(String permission) {
    switch (permission) {
      case manageUsers:
        return 'Manage Users';
      case manageContent:
        return 'Manage Content';
      case viewAnalytics:
        return 'View Analytics';
      case manageReports:
        return 'Manage Reports';
      case managePayments:
        return 'Manage Payments';
      case manageSystem:
        return 'Manage System';
      case manageNotifications:
        return 'Manage Notifications';
      case viewLogs:
        return 'View Logs';
      default:
        return 'Unknown';
    }
  }
}
