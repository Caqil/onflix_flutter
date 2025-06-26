import 'package:json_annotation/json_annotation.dart';

part 'cache_entry.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class CacheEntry<T> {
  final T data;
  final DateTime timestamp;
  final Duration ttl;
  final String key;
  final Map<String, dynamic>? metadata;

  const CacheEntry({
    required this.data,
    required this.timestamp,
    required this.ttl,
    required this.key,
    this.metadata,
  });

  factory CacheEntry.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$CacheEntryFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$CacheEntryToJson(this, toJsonT);

  bool get isExpired => DateTime.now().isAfter(timestamp.add(ttl));
  bool get isValid => !isExpired;

  Duration get timeToLive {
    final expiry = timestamp.add(ttl);
    final now = DateTime.now();
    return expiry.isAfter(now) ? expiry.difference(now) : Duration.zero;
  }

  factory CacheEntry.create(
    String key,
    T data, {
    Duration ttl = const Duration(minutes: 5),
    Map<String, dynamic>? metadata,
  }) {
    return CacheEntry(
      key: key,
      data: data,
      timestamp: DateTime.now(),
      ttl: ttl,
      metadata: metadata,
    );
  }

  @override
  String toString() {
    return 'CacheEntry(key: $key, expired: $isExpired, ttl: ${timeToLive.inSeconds}s)';
  }
}
