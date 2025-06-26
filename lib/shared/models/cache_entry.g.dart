// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CacheEntry<T> _$CacheEntryFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    CacheEntry<T>(
      data: fromJsonT(json['data']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      ttl: Duration(microseconds: (json['ttl'] as num).toInt()),
      key: json['key'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$CacheEntryToJson<T>(
  CacheEntry<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'data': toJsonT(instance.data),
      'timestamp': instance.timestamp.toIso8601String(),
      'ttl': instance.ttl.inMicroseconds,
      'key': instance.key,
      'metadata': instance.metadata,
    };
