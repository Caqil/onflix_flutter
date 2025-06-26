import 'dart:async';
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/pocketbase_client.dart';
import '../../core/utils/helpers.dart';

class AnalyticsService {
  static AnalyticsService? _instance;
  late Logger _logger;
  late SharedPreferences _prefs;
  late PocketBaseClient _pbClient;

  // Event queue for offline support
  final List<AnalyticsEvent> _eventQueue = [];
  bool _isProcessingQueue = false;
  Timer? _batchTimer;

  // Session tracking
  String? _sessionId;
  DateTime? _sessionStart;
  final Map<String, dynamic> _sessionData = {};

  // User tracking
  String? _userId;
  String? _anonymousId;
  Map<String, dynamic> _userProperties = {};

  // Device info
  Map<String, dynamic> _deviceInfo = {};

  // Performance tracking
  final Map<String, Stopwatch> _performanceTrackers = {};
  final List<PerformanceMetric> _performanceMetrics = [];

  AnalyticsService._() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 1,
        errorMethodCount: 3,
        lineLength: 80,
        colors: true,
        printEmojis: true,
      ),
    );
    _pbClient = PocketBaseClient.instance;
  }

  static AnalyticsService get instance {
    _instance ??= AnalyticsService._();
    return _instance!;
  }

  // Initialize the service
  Future<void> initialize() async {
    try {
      _logger.i('Initializing Analytics Service...');

      _prefs = await SharedPreferences.getInstance();
      await _loadDeviceInfo();
      await _loadUserData();
      _startSession();
      _setupBatchTimer();

      _logger.i('Analytics Service initialized successfully');
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize Analytics Service',
          error: e, stackTrace: stackTrace);
    }
  }

  // Load device information
  Future<void> _loadDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();

      _deviceInfo = {
        'appName': packageInfo.appName,
        'appVersion': packageInfo.version,
        'buildNumber': packageInfo.buildNumber,
        'packageName': packageInfo.packageName,
        'platform': 'flutter',
      };

      // Add platform-specific info (simplified for cross-platform)
      _deviceInfo.addAll({
        'deviceId': await _getOrCreateDeviceId(),
        'locale': 'en_US', // You might want to get this from the actual locale
        'timezone': DateTime.now().timeZoneName,
      });
    } catch (e) {
      _logger.w('Failed to load device info: $e');
    }
  }

  // Get or create anonymous device ID
  Future<String> _getOrCreateDeviceId() async {
    String? deviceId = _prefs.getString(StorageKeys.deviceId);
    if (deviceId == null) {
      deviceId = Helpers.generateId();
      await _prefs.setString(StorageKeys.deviceId, deviceId);
    }
    return deviceId;
  }

  // Load user data
  Future<void> _loadUserData() async {
    _userId = _prefs.getString(StorageKeys.userId);
    _anonymousId = await _getOrCreateDeviceId();

    // Load user properties from storage
    final userPropsJson = _prefs.getString('user_properties');
    if (userPropsJson != null) {
      try {
        _userProperties = jsonDecode(userPropsJson);
      } catch (e) {
        _logger.w('Failed to parse user properties: $e');
        _userProperties = {};
      }
    }
  }

  // Start a new session
  void _startSession() {
    _sessionId = Helpers.generateSessionId();
    _sessionStart = DateTime.now();
    _sessionData.clear();

    trackEvent('session_start', {
      'sessionId': _sessionId,
      'timestamp': _sessionStart!.toIso8601String(),
    });
  }

  // Setup batch processing timer
  void _setupBatchTimer() {
    _batchTimer?.cancel();
    _batchTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _processBatch();
    });
  }

  // Set user ID
  Future<void> setUserId(String userId) async {
    _userId = userId;
    await _prefs.setString(StorageKeys.userId, userId);

    trackEvent('user_identified', {
      'userId': userId,
      'previousAnonymousId': _anonymousId,
    });
  }

  // Set user properties
  Future<void> setUserProperties(Map<String, dynamic> properties) async {
    _userProperties.addAll(properties);
    await _prefs.setString('user_properties', jsonEncode(_userProperties));

    trackEvent('user_properties_updated', {
      'properties': properties,
    });
  }

  // Track screen view
  void trackScreenView(String screenName, {Map<String, dynamic>? properties}) {
    trackEvent('screen_view', {
      'screen_name': screenName,
      'previous_screen': _sessionData['current_screen'],
      ...?properties,
    });

    _sessionData['current_screen'] = screenName;
    _sessionData['screen_view_time'] = DateTime.now().toIso8601String();
  }

  // Track generic event
  void trackEvent(String eventName, [Map<String, dynamic>? properties]) {
    final event = AnalyticsEvent(
      name: eventName,
      properties: {
        ...?properties,
        'timestamp': DateTime.now().toIso8601String(),
        'sessionId': _sessionId,
        'userId': _userId,
        'anonymousId': _anonymousId,
        'platform': _deviceInfo['platform'],
        'appVersion': _deviceInfo['appVersion'],
        'screen': _sessionData['current_screen'],
      },
      timestamp: DateTime.now(),
    );

    _eventQueue.add(event);
    _logger.d('Event tracked: $eventName');

    // Process immediately for critical events
    if (_isCriticalEvent(eventName)) {
      _processBatch();
    }
  }

  // Content-specific tracking methods
  void trackContentView(String contentId, String contentType, String title) {
    trackEvent('content_view', {
      'content_id': contentId,
      'content_type': contentType,
      'content_title': title,
    });
  }

  void trackContentPlay(String contentId, String contentType, String title) {
    trackEvent('content_play', {
      'content_id': contentId,
      'content_type': contentType,
      'content_title': title,
      'play_method': 'click',
    });
  }

  void trackContentPause(String contentId, int position, int duration) {
    trackEvent('content_pause', {
      'content_id': contentId,
      'position': position,
      'duration': duration,
      'progress_percentage': duration > 0 ? (position / duration * 100) : 0,
    });
  }

  void trackContentComplete(String contentId, int duration) {
    trackEvent('content_complete', {
      'content_id': contentId,
      'duration': duration,
      'completion_rate': 100,
    });
  }

  void trackSearch(String query, int resultCount) {
    trackEvent('search', {
      'query': query,
      'result_count': resultCount,
      'query_length': query.length,
    });
  }

  void trackDownload(String contentId, String quality, int fileSize) {
    trackEvent('content_download', {
      'content_id': contentId,
      'quality': quality,
      'file_size': fileSize,
    });
  }

  void trackWatchlistAdd(String contentId, String contentType) {
    trackEvent('watchlist_add', {
      'content_id': contentId,
      'content_type': contentType,
    });
  }

  void trackWatchlistRemove(String contentId, String contentType) {
    trackEvent('watchlist_remove', {
      'content_id': contentId,
      'content_type': contentType,
    });
  }

  void trackRating(String contentId, double rating) {
    trackEvent('content_rating', {
      'content_id': contentId,
      'rating': rating,
    });
  }

  void trackSubscription(String plan, double amount, String currency) {
    trackEvent('subscription_purchase', {
      'plan': plan,
      'amount': amount,
      'currency': currency,
    });
  }

  void trackError(String errorType, String errorMessage, {String? context}) {
    trackEvent('error_occurred', {
      'error_type': errorType,
      'error_message': errorMessage,
      'context': context,
      'stack_trace': StackTrace.current.toString(),
    });
  }

  // Performance tracking
  void startPerformanceTimer(String operation) {
    _performanceTrackers[operation] = Stopwatch()..start();
  }

  void stopPerformanceTimer(String operation,
      {Map<String, dynamic>? metadata}) {
    final stopwatch = _performanceTrackers.remove(operation);
    if (stopwatch != null) {
      stopwatch.stop();

      final metric = PerformanceMetric(
        operation: operation,
        duration: stopwatch.elapsedMilliseconds,
        timestamp: DateTime.now(),
        metadata: metadata,
      );

      _performanceMetrics.add(metric);

      trackEvent('performance_metric', {
        'operation': operation,
        'duration_ms': stopwatch.elapsedMilliseconds,
        'metadata': metadata,
      });

      // Keep only recent metrics
      if (_performanceMetrics.length > 1000) {
        _performanceMetrics.removeAt(0);
      }
    }
  }

  // Get performance insights
  Map<String, dynamic> getPerformanceInsights() {
    final operationStats = <String, List<int>>{};

    for (final metric in _performanceMetrics) {
      operationStats.putIfAbsent(metric.operation, () => []);
      operationStats[metric.operation]!.add(metric.duration);
    }

    final insights = <String, dynamic>{};
    for (final entry in operationStats.entries) {
      final durations = entry.value;
      durations.sort();

      insights[entry.key] = {
        'count': durations.length,
        'average':
            durations.fold<int>(0, (sum, d) => sum + d) / durations.length,
        'median': durations[durations.length ~/ 2],
        'p95': durations[(durations.length * 0.95).floor()],
        'min': durations.first,
        'max': durations.last,
      };
    }

    return insights;
  }

  // Process event batch
  Future<void> _processBatch() async {
    if (_isProcessingQueue || _eventQueue.isEmpty) return;

    _isProcessingQueue = true;

    try {
      // Check if analytics is enabled
      final analyticsEnabled =
          _prefs.getBool(StorageKeys.analyticsEnabled) ?? true;
      if (!analyticsEnabled) {
        _eventQueue.clear();
        return;
      }

      final events = List<AnalyticsEvent>.from(_eventQueue);
      _eventQueue.clear();

      await _sendEventsToServer(events);
      _logger.d('Processed ${events.length} analytics events');
    } catch (e) {
      _logger.e('Failed to process analytics batch: $e');
      // Re-queue events if they failed to send
      // _eventQueue.addAll(events); // Uncomment if you want to retry
    } finally {
      _isProcessingQueue = false;
    }
  }

  // Send events to server
  Future<void> _sendEventsToServer(List<AnalyticsEvent> events) async {
    try {
      final batch = {
        'events': events.map((e) => e.toJson()).toList(),
        'device_info': _deviceInfo,
        'user_properties': _userProperties,
        'session_id': _sessionId,
        'batch_timestamp': DateTime.now().toIso8601String(),
      };

      await _pbClient.createRecord('analytics', batch);
    } catch (e) {
      _logger.e('Failed to send analytics events: $e');
      rethrow;
    }
  }

  // Check if event is critical and should be sent immediately
  bool _isCriticalEvent(String eventName) {
    const criticalEvents = [
      'session_start',
      'session_end',
      'error_occurred',
      'subscription_purchase',
      'user_identified',
    ];
    return criticalEvents.contains(eventName);
  }

  // End session
  Future<void> endSession() async {
    if (_sessionId != null && _sessionStart != null) {
      final sessionDuration = DateTime.now().difference(_sessionStart!);

      trackEvent('session_end', {
        'session_duration': sessionDuration.inSeconds,
        'screens_viewed': _sessionData['screens_viewed'] ?? 0,
      });

      await _processBatch();
    }
  }

  // Flush all pending events
  Future<void> flush() async {
    await _processBatch();
  }

  // Get analytics summary
  Map<String, dynamic> getAnalyticsSummary() {
    return {
      'session_id': _sessionId,
      'user_id': _userId,
      'anonymous_id': _anonymousId,
      'session_start': _sessionStart?.toIso8601String(),
      'session_duration': _sessionStart != null
          ? DateTime.now().difference(_sessionStart!).inMinutes
          : 0,
      'events_queued': _eventQueue.length,
      'performance_metrics': _performanceMetrics.length,
      'current_screen': _sessionData['current_screen'],
      'device_info': _deviceInfo,
      'user_properties': _userProperties,
    };
  }

  // Disable analytics
  Future<void> disableAnalytics() async {
    await _prefs.setBool(StorageKeys.analyticsEnabled, false);
    _eventQueue.clear();
    _logger.i('Analytics disabled');
  }

  // Enable analytics
  Future<void> enableAnalytics() async {
    await _prefs.setBool(StorageKeys.analyticsEnabled, true);
    _logger.i('Analytics enabled');
  }

  // Check if analytics is enabled
  bool get isAnalyticsEnabled {
    return _prefs.getBool(StorageKeys.analyticsEnabled) ?? true;
  }

  // Dispose resources
  void dispose() {
    _batchTimer?.cancel();
    _performanceTrackers.clear();
    _performanceMetrics.clear();
    _eventQueue.clear();
  }
}

// Analytics event model
class AnalyticsEvent {
  final String name;
  final Map<String, dynamic> properties;
  final DateTime timestamp;

  AnalyticsEvent({
    required this.name,
    required this.properties,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'properties': properties,
        'timestamp': timestamp.toIso8601String(),
      };
}

// Performance metric model
class PerformanceMetric {
  final String operation;
  final int duration;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  PerformanceMetric({
    required this.operation,
    required this.duration,
    required this.timestamp,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
        'operation': operation,
        'duration': duration,
        'timestamp': timestamp.toIso8601String(),
        'metadata': metadata,
      };
}
