import 'package:json_annotation/json_annotation.dart';

part 'app_metadata.g.dart';

@JsonSerializable()
class AppMetadata {
  final String version;
  final String buildNumber;
  final String platform;
  final String deviceId;
  final DateTime installedAt;
  final DateTime lastOpenedAt;
  final Map<String, dynamic> features;
  final Map<String, dynamic> settings;

  const AppMetadata({
    required this.version,
    required this.buildNumber,
    required this.platform,
    required this.deviceId,
    required this.installedAt,
    required this.lastOpenedAt,
    required this.features,
    required this.settings,
  });

  factory AppMetadata.fromJson(Map<String, dynamic> json) =>
      _$AppMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$AppMetadataToJson(this);

  AppMetadata copyWith({
    String? version,
    String? buildNumber,
    String? platform,
    String? deviceId,
    DateTime? installedAt,
    DateTime? lastOpenedAt,
    Map<String, dynamic>? features,
    Map<String, dynamic>? settings,
  }) {
    return AppMetadata(
      version: version ?? this.version,
      buildNumber: buildNumber ?? this.buildNumber,
      platform: platform ?? this.platform,
      deviceId: deviceId ?? this.deviceId,
      installedAt: installedAt ?? this.installedAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      features: features ?? this.features,
      settings: settings ?? this.settings,
    );
  }

  @override
  String toString() {
    return 'AppMetadata(version: $version, platform: $platform, device: $deviceId)';
  }
}
