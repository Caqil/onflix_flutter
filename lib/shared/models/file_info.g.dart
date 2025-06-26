// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FileInfo _$FileInfoFromJson(Map<String, dynamic> json) => FileInfo(
      name: json['name'] as String,
      path: json['path'] as String,
      mimeType: json['mimeType'] as String,
      size: (json['size'] as num).toInt(),
      url: json['url'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
    );

Map<String, dynamic> _$FileInfoToJson(FileInfo instance) => <String, dynamic>{
      'name': instance.name,
      'path': instance.path,
      'mimeType': instance.mimeType,
      'size': instance.size,
      'url': instance.url,
      'thumbnailUrl': instance.thumbnailUrl,
      'metadata': instance.metadata,
      'uploadedAt': instance.uploadedAt.toIso8601String(),
    };
