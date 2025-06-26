// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppMetadata _$AppMetadataFromJson(Map<String, dynamic> json) => AppMetadata(
      version: json['version'] as String,
      buildNumber: json['buildNumber'] as String,
      platform: json['platform'] as String,
      deviceId: json['deviceId'] as String,
      installedAt: DateTime.parse(json['installedAt'] as String),
      lastOpenedAt: DateTime.parse(json['lastOpenedAt'] as String),
      features: json['features'] as Map<String, dynamic>,
      settings: json['settings'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$AppMetadataToJson(AppMetadata instance) =>
    <String, dynamic>{
      'version': instance.version,
      'buildNumber': instance.buildNumber,
      'platform': instance.platform,
      'deviceId': instance.deviceId,
      'installedAt': instance.installedAt.toIso8601String(),
      'lastOpenedAt': instance.lastOpenedAt.toIso8601String(),
      'features': instance.features,
      'settings': instance.settings,
    };
