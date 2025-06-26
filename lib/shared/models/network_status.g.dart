// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NetworkStatus _$NetworkStatusFromJson(Map<String, dynamic> json) =>
    NetworkStatus(
      isConnected: json['isConnected'] as bool,
      connectionType: json['connectionType'] as String,
      downloadSpeed: (json['downloadSpeed'] as num?)?.toDouble(),
      uploadSpeed: (json['uploadSpeed'] as num?)?.toDouble(),
      latency: (json['latency'] as num?)?.toInt(),
      lastChecked: DateTime.parse(json['lastChecked'] as String),
    );

Map<String, dynamic> _$NetworkStatusToJson(NetworkStatus instance) =>
    <String, dynamic>{
      'isConnected': instance.isConnected,
      'connectionType': instance.connectionType,
      'downloadSpeed': instance.downloadSpeed,
      'uploadSpeed': instance.uploadSpeed,
      'latency': instance.latency,
      'lastChecked': instance.lastChecked.toIso8601String(),
    };
