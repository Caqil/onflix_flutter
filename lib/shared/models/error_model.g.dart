// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ErrorModel _$ErrorModelFromJson(Map<String, dynamic> json) => ErrorModel(
      message: json['message'] as String,
      code: json['code'] as String?,
      field: json['field'] as String?,
      details: json['details'] as Map<String, dynamic>?,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$ErrorModelToJson(ErrorModel instance) =>
    <String, dynamic>{
      'message': instance.message,
      'code': instance.code,
      'field': instance.field,
      'details': instance.details,
      'timestamp': instance.timestamp?.toIso8601String(),
    };
