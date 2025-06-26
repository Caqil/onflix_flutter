import 'package:json_annotation/json_annotation.dart';

part 'network_status.g.dart';

@JsonSerializable()
class NetworkStatus {
  final bool isConnected;
  final String connectionType;
  final double? downloadSpeed; // Mbps
  final double? uploadSpeed; // Mbps
  final int? latency; // milliseconds
  final DateTime lastChecked;

  const NetworkStatus({
    required this.isConnected,
    required this.connectionType,
    this.downloadSpeed,
    this.uploadSpeed,
    this.latency,
    required this.lastChecked,
  });

  factory NetworkStatus.fromJson(Map<String, dynamic> json) =>
      _$NetworkStatusFromJson(json);

  Map<String, dynamic> toJson() => _$NetworkStatusToJson(this);

  factory NetworkStatus.disconnected() {
    return NetworkStatus(
      isConnected: false,
      connectionType: 'none',
      lastChecked: DateTime.now(),
    );
  }

  factory NetworkStatus.connected(String type) {
    return NetworkStatus(
      isConnected: true,
      connectionType: type,
      lastChecked: DateTime.now(),
    );
  }

  NetworkQuality get quality {
    if (!isConnected) return NetworkQuality.offline;
    if (downloadSpeed == null || latency == null) return NetworkQuality.unknown;

    if (latency! < 50 && downloadSpeed! > 25) {
      return NetworkQuality.excellent;
    } else if (latency! < 100 && downloadSpeed! > 10) {
      return NetworkQuality.good;
    } else if (latency! < 200 && downloadSpeed! > 5) {
      return NetworkQuality.fair;
    } else if (latency! < 500 && downloadSpeed! > 1) {
      return NetworkQuality.poor;
    } else {
      return NetworkQuality.bad;
    }
  }

  @override
  String toString() {
    return 'NetworkStatus(connected: $isConnected, type: $connectionType, quality: $quality)';
  }
}

enum NetworkQuality {
  offline,
  unknown,
  bad,
  poor,
  fair,
  good,
  excellent,
}
