// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminUserModel _$AdminUserModelFromJson(Map<String, dynamic> json) =>
    AdminUserModel(
      id: json['id'] as String,
      collectionId: json['collectionId'] as String?,
      collectionName: json['collectionName'] as String?,
      created: DateTime.parse(json['created'] as String),
      updated: DateTime.parse(json['updated'] as String),
      email: json['email'] as String,
      name: json['name'] as String,
      username: json['username'] as String?,
      role: json['role'] as String,
      status: json['status'] as String,
      avatar: json['avatar'] as String?,
      verified: json['verified'] as bool,
      permissions: (json['permissions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      department: json['department'] as String?,
      jobTitle: json['jobTitle'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      settings: json['settings'] as Map<String, dynamic>?,
      lastLogin: json['lastLogin'] == null
          ? null
          : DateTime.parse(json['lastLogin'] as String),
      lastLoginIp: json['lastLoginIp'] as String?,
      loginCount: (json['loginCount'] as num).toInt(),
      passwordChangedAt: json['passwordChangedAt'] == null
          ? null
          : DateTime.parse(json['passwordChangedAt'] as String),
      twoFactorEnabled: json['twoFactorEnabled'] as bool,
      managedRegions: (json['managedRegions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      preferences: json['preferences'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$AdminUserModelToJson(AdminUserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'collectionId': instance.collectionId,
      'collectionName': instance.collectionName,
      'created': instance.created.toIso8601String(),
      'updated': instance.updated.toIso8601String(),
      'email': instance.email,
      'name': instance.name,
      'username': instance.username,
      'role': instance.role,
      'status': instance.status,
      'avatar': instance.avatar,
      'verified': instance.verified,
      'permissions': instance.permissions,
      'department': instance.department,
      'jobTitle': instance.jobTitle,
      'phoneNumber': instance.phoneNumber,
      'settings': instance.settings,
      'lastLogin': instance.lastLogin?.toIso8601String(),
      'lastLoginIp': instance.lastLoginIp,
      'loginCount': instance.loginCount,
      'passwordChangedAt': instance.passwordChangedAt?.toIso8601String(),
      'twoFactorEnabled': instance.twoFactorEnabled,
      'managedRegions': instance.managedRegions,
      'preferences': instance.preferences,
    };
