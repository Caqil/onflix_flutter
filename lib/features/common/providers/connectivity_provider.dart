import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../shared/services/storage_service.dart';
import '../../../shared/services/analytics_service.dart';

part 'connectivity_provider.g.dart';

// Base connectivity stream provider
@riverpod
Stream<ConnectivityResult> connectivityStream(Ref ref) {
  final connectivity = Connectivity();
  return connectivity.onConnectivityChanged;
}

// Enhanced connectivity state provider
@riverpod
class ConnectivityState extends _$ConnectivityState {
  Timer? _connectionCheckTimer;
  final Logger _logger = Logger();

  @override
  Future<ConnectivityInfo> build() async {
    // Initial connectivity check
    final initialState = await _checkConnectivityState();

    // Listen to connectivity changes
    ref.listen(connectivityStreamProvider, (previous, next) {
      next.when(
        data: (result) => _handleConnectivityChange(result),
        loading: () {},
        error: (error, stack) => _logger.e('Connectivity stream error: $error'),
      );
    });

    return initialState;
  }

  // Check current connectivity state
  Future<ConnectivityInfo> _checkConnectivityState() async {
    try {
      final connectivity = Connectivity();
      final result = await connectivity.checkConnectivity();

      return await _buildConnectivityInfo(result);
    } catch (e) {
      _logger.e('Failed to check connectivity: $e');
      return ConnectivityInfo.disconnected();
    }
  }

  // Handle connectivity changes
  Future<void> _handleConnectivityChange(ConnectivityResult result) async {
    try {
      final newConnectivityInfo = await _buildConnectivityInfo(result);

      // Update state
      state = AsyncValue.data(newConnectivityInfo);

      // Track analytics
      _trackConnectivityChange(newConnectivityInfo);

      // Handle connection quality monitoring
      if (newConnectivityInfo.isConnected) {
        _startConnectionQualityMonitoring();
      } else {
        _stopConnectionQualityMonitoring();
      }
    } catch (e) {
      _logger.e('Failed to handle connectivity change: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Build comprehensive connectivity info
  Future<ConnectivityInfo> _buildConnectivityInfo(
      ConnectivityResult result) async {
    final isConnected = _isConnected(result);
    final connectionType = _getConnectionType(result);
    final connectionQuality =
        isConnected ? await _assessConnectionQuality() : ConnectionQuality.none;

    return ConnectivityInfo(
      result: result,
      isConnected: isConnected,
      connectionType: connectionType,
      connectionQuality: connectionQuality,
      lastChecked: DateTime.now(),
      isWifi: result == ConnectivityResult.wifi,
      isMobile: result == ConnectivityResult.mobile,
      isEthernet: result == ConnectivityResult.ethernet,
    );
  }

  // Check if connected
  bool _isConnected(ConnectivityResult result) {
    return result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet ||
        result == ConnectivityResult.bluetooth;
  }

  // Get connection type
  ConnectionType _getConnectionType(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return ConnectionType.wifi;
      case ConnectivityResult.mobile:
        return ConnectionType.mobile;
      case ConnectivityResult.ethernet:
        return ConnectionType.ethernet;
      case ConnectivityResult.bluetooth:
        return ConnectionType.bluetooth;
      case ConnectivityResult.vpn:
        return ConnectionType.vpn;
      case ConnectivityResult.other:
        return ConnectionType.other;
      case ConnectivityResult.none:
      return ConnectionType.none;
    }
  }

  // Assess connection quality
  Future<ConnectionQuality> _assessConnectionQuality() async {
    try {
      // This is a simplified quality assessment
      // In a real app, you might want to implement actual network speed testing
      final stopwatch = Stopwatch()..start();

      // Simulate a small network request to assess latency
      await Future.delayed(const Duration(milliseconds: 100));

      stopwatch.stop();
      final latency = stopwatch.elapsedMilliseconds;

      if (latency < 100) {
        return ConnectionQuality.excellent;
      } else if (latency < 300) {
        return ConnectionQuality.good;
      } else if (latency < 600) {
        return ConnectionQuality.fair;
      } else {
        return ConnectionQuality.poor;
      }
    } catch (e) {
      _logger.w('Failed to assess connection quality: $e');
      return ConnectionQuality.unknown;
    }
  }

  // Start connection quality monitoring
  void _startConnectionQualityMonitoring() {
    _stopConnectionQualityMonitoring();

    _connectionCheckTimer = Timer.periodic(
      const Duration(minutes: 2),
      (_) => _updateConnectionQuality(),
    );
  }

  // Stop connection quality monitoring
  void _stopConnectionQualityMonitoring() {
    _connectionCheckTimer?.cancel();
    _connectionCheckTimer = null;
  }

  // Update connection quality
  Future<void> _updateConnectionQuality() async {
    final currentState = state.value;
    if (currentState == null || !currentState.isConnected) return;

    try {
      final newQuality = await _assessConnectionQuality();

      if (newQuality != currentState.connectionQuality) {
        final updatedInfo = currentState.copyWith(
          connectionQuality: newQuality,
          lastChecked: DateTime.now(),
        );

        state = AsyncValue.data(updatedInfo);
      }
    } catch (e) {
      _logger.e('Failed to update connection quality: $e');
    }
  }

  // Track connectivity change analytics
  void _trackConnectivityChange(ConnectivityInfo info) {
    final analyticsService = AnalyticsService.instance;
    analyticsService.trackEvent('connectivity_changed', {
      'connection_type': info.connectionType.name,
      'is_connected': info.isConnected,
      'connection_quality': info.connectionQuality.name,
      'timestamp': info.lastChecked.toIso8601String(),
    });
  }

  // Force refresh connectivity state
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final newState = await _checkConnectivityState();
    state = AsyncValue.data(newState);
  }

  void dispose() {
    _stopConnectionQualityMonitoring();
  }
}

// Network preferences provider
@riverpod
class NetworkPreferences extends _$NetworkPreferences {
  @override
  Future<NetworkPreferencesState> build() async {
    return await _loadNetworkPreferences();
  }

  Future<NetworkPreferencesState> _loadNetworkPreferences() async {
    try {
      final storageService = StorageService.instance;

      final wifiOnlyStreaming = await storageService.getSetting<bool>(
        StorageKeys.wifiOnlyStreaming,
        defaultValue: false,
      );

      final cellularStreamingQuality = await storageService.getSetting<String>(
        StorageKeys.cellularStreamingQuality,
        defaultValue: 'medium',
      );

      final dataUsageLimit = await storageService.getSetting<int>(
        StorageKeys.dataUsageLimit,
        defaultValue: 0, // 0 means unlimited
      );

      final preloadEnabled = await storageService.getSetting<bool>(
        StorageKeys.preloadEnabled,
        defaultValue: true,
      );

      final adaptiveStreaming = await storageService.getSetting<bool>(
        StorageKeys.adaptiveStreaming,
        defaultValue: true,
      );

      return NetworkPreferencesState(
        wifiOnlyStreaming: wifiOnlyStreaming ?? false,
        cellularStreamingQuality: cellularStreamingQuality ?? 'medium',
        dataUsageLimit: dataUsageLimit ?? 0,
        preloadEnabled: preloadEnabled ?? true,
        adaptiveStreaming: adaptiveStreaming ?? true,
      );
    } catch (e) {
      // Return default preferences if loading fails
      return const NetworkPreferencesState(
        wifiOnlyStreaming: false,
        cellularStreamingQuality: 'medium',
        dataUsageLimit: 0,
        preloadEnabled: true,
        adaptiveStreaming: true,
      );
    }
  }

  // Update WiFi-only streaming preference
  Future<void> setWifiOnlyStreaming(bool enabled) async {
    try {
      final storageService = StorageService.instance;
      await storageService.setSetting(StorageKeys.wifiOnlyStreaming, enabled);

      final currentState = state.value;
      if (currentState != null) {
        state = AsyncValue.data(
          currentState.copyWith(wifiOnlyStreaming: enabled),
        );
      }

      // Track analytics
      final analyticsService = AnalyticsService.instance;
      analyticsService.trackEvent('wifi_only_streaming_changed', {
        'enabled': enabled,
      });
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Update cellular streaming quality
  Future<void> setCellularStreamingQuality(String quality) async {
    try {
      final storageService = StorageService.instance;
      await storageService.setSetting(
          StorageKeys.cellularStreamingQuality, quality);

      final currentState = state.value;
      if (currentState != null) {
        state = AsyncValue.data(
          currentState.copyWith(cellularStreamingQuality: quality),
        );
      }

      // Track analytics
      final analyticsService = AnalyticsService.instance;
      analyticsService.trackEvent('cellular_quality_changed', {
        'quality': quality,
      });
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Update data usage limit
  Future<void> setDataUsageLimit(int limitMB) async {
    try {
      final storageService = StorageService.instance;
      await storageService.setSetting(StorageKeys.dataUsageLimit, limitMB);

      final currentState = state.value;
      if (currentState != null) {
        state = AsyncValue.data(
          currentState.copyWith(dataUsageLimit: limitMB),
        );
      }

      // Track analytics
      final analyticsService = AnalyticsService.instance;
      analyticsService.trackEvent('data_usage_limit_changed', {
        'limit_mb': limitMB,
      });
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Update preload enabled
  Future<void> setPreloadEnabled(bool enabled) async {
    try {
      final storageService = StorageService.instance;
      await storageService.setSetting(StorageKeys.preloadEnabled, enabled);

      final currentState = state.value;
      if (currentState != null) {
        state = AsyncValue.data(
          currentState.copyWith(preloadEnabled: enabled),
        );
      }

      // Track analytics
      final analyticsService = AnalyticsService.instance;
      analyticsService.trackEvent('preload_enabled_changed', {
        'enabled': enabled,
      });
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Update adaptive streaming
  Future<void> setAdaptiveStreaming(bool enabled) async {
    try {
      final storageService = StorageService.instance;
      await storageService.setSetting(StorageKeys.adaptiveStreaming, enabled);

      final currentState = state.value;
      if (currentState != null) {
        state = AsyncValue.data(
          currentState.copyWith(adaptiveStreaming: enabled),
        );
      }

      // Track analytics
      final analyticsService = AnalyticsService.instance;
      analyticsService.trackEvent('adaptive_streaming_changed', {
        'enabled': enabled,
      });
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Reset to defaults
  Future<void> resetToDefaults() async {
    try {
      await setWifiOnlyStreaming(false);
      await setCellularStreamingQuality('medium');
      await setDataUsageLimit(0);
      await setPreloadEnabled(true);
      await setAdaptiveStreaming(true);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// Connection status helpers provider
@riverpod
ConnectionHelpers connectionHelpers(Ref ref) {
  return ConnectionHelpers();
}

// Bandwidth monitor provider
@riverpod
class BandwidthMonitor extends _$BandwidthMonitor {
  Timer? _bandwidthTimer;
  final List<BandwidthSample> _samples = [];
  static const int _maxSamples = 20;

  @override
  BandwidthInfo build() {
    // Start monitoring when first accessed
    _startMonitoring();

    return const BandwidthInfo(
      downloadSpeed: 0.0,
      uploadSpeed: 0.0,
      latency: 0,
      samples: [],
      lastUpdated: null,
    );
  }

  void _startMonitoring() {
    _stopMonitoring();

    _bandwidthTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _measureBandwidth(),
    );
  }

  void _stopMonitoring() {
    _bandwidthTimer?.cancel();
    _bandwidthTimer = null;
  }

  Future<void> _measureBandwidth() async {
    try {
      // This is a simplified bandwidth measurement
      // In a real app, you might want to implement actual network speed testing
      final stopwatch = Stopwatch()..start();

      // Simulate network request
      await Future.delayed(const Duration(milliseconds: 200));

      stopwatch.stop();
      final latency = stopwatch.elapsedMilliseconds;

      // Mock download/upload speeds based on connection type
      final connectivityState = ref.read(connectivityStateProvider);
      final connectionInfo = connectivityState.value;

      double downloadSpeed = 0.0;
      double uploadSpeed = 0.0;

      if (connectionInfo?.isConnected == true) {
        switch (connectionInfo!.connectionType) {
          case ConnectionType.wifi:
            downloadSpeed = 50.0; // Mbps
            uploadSpeed = 25.0;
            break;
          case ConnectionType.mobile:
            downloadSpeed = 25.0;
            uploadSpeed = 10.0;
            break;
          case ConnectionType.ethernet:
            downloadSpeed = 100.0;
            uploadSpeed = 50.0;
            break;
          default:
            downloadSpeed = 10.0;
            uploadSpeed = 5.0;
        }
      }

      final sample = BandwidthSample(
        downloadSpeed: downloadSpeed,
        uploadSpeed: uploadSpeed,
        latency: latency,
        timestamp: DateTime.now(),
      );

      _samples.add(sample);

      // Keep only recent samples
      if (_samples.length > _maxSamples) {
        _samples.removeAt(0);
      }

      // Calculate averages
      final avgDownload =
          _samples.map((s) => s.downloadSpeed).reduce((a, b) => a + b) /
              _samples.length;
      final avgUpload =
          _samples.map((s) => s.uploadSpeed).reduce((a, b) => a + b) /
              _samples.length;
      final avgLatency =
          (_samples.map((s) => s.latency).reduce((a, b) => a + b) /
                  _samples.length)
              .round();

      state = BandwidthInfo(
        downloadSpeed: avgDownload,
        uploadSpeed: avgUpload,
        latency: avgLatency,
        samples: List.from(_samples),
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      Logger().e('Failed to measure bandwidth: $e');
    }
  }

  // Force a bandwidth measurement
  Future<void> measureNow() async {
    await _measureBandwidth();
  }

  void dispose() {
    _stopMonitoring();
  }
}

// Models
class ConnectivityInfo {
  final ConnectivityResult result;
  final bool isConnected;
  final ConnectionType connectionType;
  final ConnectionQuality connectionQuality;
  final DateTime lastChecked;
  final bool isWifi;
  final bool isMobile;
  final bool isEthernet;

  const ConnectivityInfo({
    required this.result,
    required this.isConnected,
    required this.connectionType,
    required this.connectionQuality,
    required this.lastChecked,
    required this.isWifi,
    required this.isMobile,
    required this.isEthernet,
  });

  factory ConnectivityInfo.disconnected() {
    return ConnectivityInfo(
      result: ConnectivityResult.none,
      isConnected: false,
      connectionType: ConnectionType.none,
      connectionQuality: ConnectionQuality.none,
      lastChecked: DateTime.now(),
      isWifi: false,
      isMobile: false,
      isEthernet: false,
    );
  }

  ConnectivityInfo copyWith({
    ConnectivityResult? result,
    bool? isConnected,
    ConnectionType? connectionType,
    ConnectionQuality? connectionQuality,
    DateTime? lastChecked,
    bool? isWifi,
    bool? isMobile,
    bool? isEthernet,
  }) {
    return ConnectivityInfo(
      result: result ?? this.result,
      isConnected: isConnected ?? this.isConnected,
      connectionType: connectionType ?? this.connectionType,
      connectionQuality: connectionQuality ?? this.connectionQuality,
      lastChecked: lastChecked ?? this.lastChecked,
      isWifi: isWifi ?? this.isWifi,
      isMobile: isMobile ?? this.isMobile,
      isEthernet: isEthernet ?? this.isEthernet,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectivityInfo &&
          runtimeType == other.runtimeType &&
          result == other.result &&
          isConnected == other.isConnected &&
          connectionType == other.connectionType &&
          connectionQuality == other.connectionQuality &&
          isWifi == other.isWifi &&
          isMobile == other.isMobile &&
          isEthernet == other.isEthernet;

  @override
  int get hashCode =>
      result.hashCode ^
      isConnected.hashCode ^
      connectionType.hashCode ^
      connectionQuality.hashCode ^
      isWifi.hashCode ^
      isMobile.hashCode ^
      isEthernet.hashCode;

  @override
  String toString() {
    return 'ConnectivityInfo(result: $result, isConnected: $isConnected, connectionType: $connectionType, connectionQuality: $connectionQuality, lastChecked: $lastChecked)';
  }
}

class NetworkPreferencesState {
  final bool wifiOnlyStreaming;
  final String cellularStreamingQuality;
  final int dataUsageLimit; // in MB, 0 means unlimited
  final bool preloadEnabled;
  final bool adaptiveStreaming;

  const NetworkPreferencesState({
    required this.wifiOnlyStreaming,
    required this.cellularStreamingQuality,
    required this.dataUsageLimit,
    required this.preloadEnabled,
    required this.adaptiveStreaming,
  });

  NetworkPreferencesState copyWith({
    bool? wifiOnlyStreaming,
    String? cellularStreamingQuality,
    int? dataUsageLimit,
    bool? preloadEnabled,
    bool? adaptiveStreaming,
  }) {
    return NetworkPreferencesState(
      wifiOnlyStreaming: wifiOnlyStreaming ?? this.wifiOnlyStreaming,
      cellularStreamingQuality:
          cellularStreamingQuality ?? this.cellularStreamingQuality,
      dataUsageLimit: dataUsageLimit ?? this.dataUsageLimit,
      preloadEnabled: preloadEnabled ?? this.preloadEnabled,
      adaptiveStreaming: adaptiveStreaming ?? this.adaptiveStreaming,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkPreferencesState &&
          runtimeType == other.runtimeType &&
          wifiOnlyStreaming == other.wifiOnlyStreaming &&
          cellularStreamingQuality == other.cellularStreamingQuality &&
          dataUsageLimit == other.dataUsageLimit &&
          preloadEnabled == other.preloadEnabled &&
          adaptiveStreaming == other.adaptiveStreaming;

  @override
  int get hashCode =>
      wifiOnlyStreaming.hashCode ^
      cellularStreamingQuality.hashCode ^
      dataUsageLimit.hashCode ^
      preloadEnabled.hashCode ^
      adaptiveStreaming.hashCode;

  @override
  String toString() {
    return 'NetworkPreferencesState(wifiOnlyStreaming: $wifiOnlyStreaming, cellularStreamingQuality: $cellularStreamingQuality, dataUsageLimit: $dataUsageLimit, preloadEnabled: $preloadEnabled, adaptiveStreaming: $adaptiveStreaming)';
  }
}

class BandwidthInfo {
  final double downloadSpeed; // Mbps
  final double uploadSpeed; // Mbps
  final int latency; // milliseconds
  final List<BandwidthSample> samples;
  final DateTime? lastUpdated;

  const BandwidthInfo({
    required this.downloadSpeed,
    required this.uploadSpeed,
    required this.latency,
    required this.samples,
    required this.lastUpdated,
  });

  @override
  String toString() {
    return 'BandwidthInfo(downloadSpeed: ${downloadSpeed.toStringAsFixed(1)} Mbps, uploadSpeed: ${uploadSpeed.toStringAsFixed(1)} Mbps, latency: ${latency}ms)';
  }
}

class BandwidthSample {
  final double downloadSpeed;
  final double uploadSpeed;
  final int latency;
  final DateTime timestamp;

  const BandwidthSample({
    required this.downloadSpeed,
    required this.uploadSpeed,
    required this.latency,
    required this.timestamp,
  });
}

// Enums
enum ConnectionType {
  none,
  wifi,
  mobile,
  ethernet,
  bluetooth,
  vpn,
  other,
}

enum ConnectionQuality {
  none,
  poor,
  fair,
  good,
  excellent,
  unknown,
}

// Helper class for connection-related utilities
class ConnectionHelpers {
  // Check if streaming should be allowed based on connection and preferences
  bool shouldAllowStreaming(
      ConnectivityInfo connectivity, NetworkPreferencesState preferences) {
    if (!connectivity.isConnected) return false;

    if (preferences.wifiOnlyStreaming && !connectivity.isWifi) {
      return false;
    }

    return true;
  }

  // Get recommended streaming quality based on connection
  String getRecommendedStreamingQuality(
      ConnectivityInfo connectivity, NetworkPreferencesState preferences) {
    if (!connectivity.isConnected) return 'offline';

    if (connectivity.isMobile && preferences.wifiOnlyStreaming) {
      return 'disabled';
    }

    switch (connectivity.connectionQuality) {
      case ConnectionQuality.excellent:
        return connectivity.isWifi ? 'ultra' : 'high';
      case ConnectionQuality.good:
        return connectivity.isWifi ? 'high' : 'medium';
      case ConnectionQuality.fair:
        return 'medium';
      case ConnectionQuality.poor:
        return 'low';
      default:
        return connectivity.isMobile
            ? preferences.cellularStreamingQuality
            : 'medium';
    }
  }

  // Get connection type display name
  String getConnectionTypeDisplayName(ConnectionType type) {
    switch (type) {
      case ConnectionType.wifi:
        return 'Wi-Fi';
      case ConnectionType.mobile:
        return 'Mobile Data';
      case ConnectionType.ethernet:
        return 'Ethernet';
      case ConnectionType.bluetooth:
        return 'Bluetooth';
      case ConnectionType.vpn:
        return 'VPN';
      case ConnectionType.other:
        return 'Other';
      case ConnectionType.none:
        return 'Disconnected';
    }
  }

  // Get connection quality display name
  String getConnectionQualityDisplayName(ConnectionQuality quality) {
    switch (quality) {
      case ConnectionQuality.excellent:
        return 'Excellent';
      case ConnectionQuality.good:
        return 'Good';
      case ConnectionQuality.fair:
        return 'Fair';
      case ConnectionQuality.poor:
        return 'Poor';
      case ConnectionQuality.unknown:
        return 'Unknown';
      case ConnectionQuality.none:
        return 'No Connection';
    }
  }

  // Get connection quality color (for UI)
  String getConnectionQualityColor(ConnectionQuality quality) {
    switch (quality) {
      case ConnectionQuality.excellent:
        return '#22c55e'; // green
      case ConnectionQuality.good:
        return '#84cc16'; // lime
      case ConnectionQuality.fair:
        return '#eab308'; // yellow
      case ConnectionQuality.poor:
        return '#f97316'; // orange
      case ConnectionQuality.unknown:
        return '#6b7280'; // gray
      case ConnectionQuality.none:
        return '#ef4444'; // red
    }
  }

  // Format data usage
  String formatDataUsage(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  // Check if connection is metered
  bool isMeteredConnection(ConnectivityInfo connectivity) {
    return connectivity.isMobile;
  }

  // Get data saving recommendations
  List<String> getDataSavingRecommendations(
      ConnectivityInfo connectivity, NetworkPreferencesState preferences) {
    final recommendations = <String>[];

    if (connectivity.isMobile) {
      recommendations.add('You\'re on mobile data');

      if (!preferences.wifiOnlyStreaming) {
        recommendations.add('Consider enabling Wi-Fi only streaming');
      }

      if (preferences.cellularStreamingQuality == 'high' ||
          preferences.cellularStreamingQuality == 'ultra') {
        recommendations.add('Lower cellular streaming quality to save data');
      }

      if (preferences.preloadEnabled) {
        recommendations.add('Disable preloading to save data');
      }
    }

    if (connectivity.connectionQuality == ConnectionQuality.poor) {
      recommendations
          .add('Connection quality is poor, consider lowering video quality');
    }

    return recommendations;
  }
}
