import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/pocketbase_client.dart';
import '../../core/errors/exceptions.dart';
import '../../shared/services/storage_service.dart';
import '../../shared/services/analytics_service.dart';

class SessionManager {
  static SessionManager? _instance;
  late Logger _logger;
  late PocketBaseClient _pbClient;
  late StorageService _storageService;
  late AnalyticsService _analyticsService;
  late SharedPreferences _prefs;

  // Session management
  final Map<String, UserSession> _activeSessions = {};
  final Map<String, StreamingSession> _streamingSessions = {};
  final List<SessionEvent> _sessionHistory = [];

  // Session state
  UserSession? _currentSession;
  final StreamController<SessionEvent> _sessionEventController =
      StreamController<SessionEvent>.broadcast();

  // Session configuration
  Duration _sessionTimeout = const Duration(hours: 24);
  Duration _inactivityTimeout = const Duration(minutes: 30);
  Duration _maxSessionDuration = const Duration(days: 7);
  int _maxConcurrentSessions = 5;
  bool _allowMultipleDeviceSessions = true;

  // Session timers
  Timer? _sessionCleanupTimer;
  Timer? _sessionValidationTimer;
  Timer? _inactivityTimer;
  final Map<String, Timer> _sessionTimers = {};

  // Device and network info
  String? _deviceId;
  String? _deviceName;
  String? _deviceType;
  String? _networkType;
  late StreamSubscription _connectivitySubscription;

  // Session persistence
  final Map<String, SessionData> _sessionCache = {};
  bool _persistSessions = true;
  bool _encryptSessionData = true;

  SessionManager._() {
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
    _storageService = StorageService.instance;
    _analyticsService = AnalyticsService.instance;
  }

  static SessionManager get instance {
    _instance ??= SessionManager._();
    return _instance!;
  }

  // Getters
  Stream<SessionEvent> get sessionEvents => _sessionEventController.stream;
  UserSession? get currentSession => _currentSession;
  Map<String, UserSession> get activeSessions =>
      Map.unmodifiable(_activeSessions);
  Map<String, StreamingSession> get streamingSessions =>
      Map.unmodifiable(_streamingSessions);
  int get activeSessionCount => _activeSessions.length;
  int get streamingSessionCount => _streamingSessions.length;
  bool get hasActiveSession => _currentSession != null;
  String? get deviceId => _deviceId;
  String? get deviceName => _deviceName;

  // Initialize the session manager
  Future<void> initialize() async {
    try {
      _logger.i('Initializing Session Manager...');

      _prefs = await SharedPreferences.getInstance();
      await _loadSessionConfiguration();
      await _loadDeviceInfo();
      await _setupNetworkMonitoring();
      await _restorePersistedSessions();
      _setupSessionTimers();

      _logger.i('Session Manager initialized successfully');
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize Session Manager',
          error: e, stackTrace: stackTrace);
      throw SessionException(
        message: 'Failed to initialize session manager: $e',
        code: 'SESSION_INIT_ERROR',
        details: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Load session configuration from preferences
  Future<void> _loadSessionConfiguration() async {
    try {
      final sessionTimeoutMinutes =
          _prefs.getInt('session_timeout_minutes') ?? 1440; // 24 hours
      _sessionTimeout = Duration(minutes: sessionTimeoutMinutes);

      final inactivityMinutes =
          _prefs.getInt('inactivity_timeout_minutes') ?? 30;
      _inactivityTimeout = Duration(minutes: inactivityMinutes);

      final maxSessionDays = _prefs.getInt('max_session_duration_days') ?? 7;
      _maxSessionDuration = Duration(days: maxSessionDays);

      _maxConcurrentSessions = _prefs.getInt('max_concurrent_sessions') ?? 5;
      _allowMultipleDeviceSessions =
          _prefs.getBool('allow_multiple_device_sessions') ?? true;
      _persistSessions = _prefs.getBool('persist_sessions') ?? true;
      _encryptSessionData = _prefs.getBool('encrypt_session_data') ?? true;

      _logger.d('Session configuration loaded');
    } catch (e) {
      _logger.w('Failed to load session configuration: $e');
    }
  }

  // Load device information
  Future<void> _loadDeviceInfo() async {
    try {
      _deviceId = await _getOrCreateDeviceId();

      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _deviceName = '${androidInfo.brand} ${androidInfo.model}';
        _deviceType = 'Android';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _deviceName = '${iosInfo.name} ${iosInfo.model}';
        _deviceType = 'iOS';
      } else {
        _deviceName = 'Unknown Device';
        _deviceType = 'Unknown';
      }

      _logger.d('Device info loaded: $_deviceName ($_deviceType)');
    } catch (e) {
      _logger.w('Failed to load device info: $e');
      _deviceName = 'Unknown Device';
      _deviceType = 'Unknown';
    }
  }

  // Get or create device ID
  Future<String> _getOrCreateDeviceId() async {
    try {
      String? deviceId =
          await _storageService.getSecureData<String>('device_id');

      return deviceId;
    } catch (e) {
      _logger.w('Failed to get/create device ID: $e');
      return 'dev_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  // Setup network monitoring
  Future<void> _setupNetworkMonitoring() async {
    try {
      final connectivity = Connectivity();
      final result = await connectivity.checkConnectivity();
      _networkType = _getNetworkTypeName(result);

      _connectivitySubscription =
          connectivity.onConnectivityChanged.listen((result) {
        _networkType = _getNetworkTypeName(result);
        _onNetworkChanged(result);
      });

      _logger.d('Network monitoring setup: $_networkType');
    } catch (e) {
      _logger.w('Failed to setup network monitoring: $e');
    }
  }

  // Get network type name
  String _getNetworkTypeName(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      default:
        return 'Unknown';
    }
  }

  // Handle network changes
  void _onNetworkChanged(ConnectivityResult result) {
    final newNetworkType = _getNetworkTypeName(result);
    if (newNetworkType != _networkType) {
      _logger.d('Network changed: $_networkType -> $newNetworkType');
      _networkType = newNetworkType;

      // Update all active sessions with new network info
      for (final session in _activeSessions.values) {
        session.networkType = newNetworkType;
        session.lastActivity = DateTime.now();
      }

      _emitSessionEvent(SessionEvent(
        type: SessionEventType.networkChanged,
        sessionId: _currentSession?.id,
        networkType: newNetworkType,
        timestamp: DateTime.now(),
      ));
    }
  }

  // Restore persisted sessions
  Future<void> _restorePersistedSessions() async {
    if (!_persistSessions) return;

    try {
      final sessionDataJson =
          await _storageService.getSecureData<String>('persisted_sessions');
      if (sessionDataJson != null) {
        final sessionDataList = jsonDecode(sessionDataJson) as List<dynamic>;

        for (final sessionData in sessionDataList) {
          final session =
              UserSession.fromJson(sessionData as Map<String, dynamic>);

          // Validate session
          if (!session.isExpired && _isValidSession(session)) {
            _activeSessions[session.id] = session;

            if (session.deviceId == _deviceId) {
              _currentSession = session;
            }
          }
        }

        _logger.i('Restored ${_activeSessions.length} persisted sessions');
      }
    } catch (e) {
      _logger.w('Failed to restore persisted sessions: $e');
    }
  }

  // Setup session timers
  void _setupSessionTimers() {
    // Session cleanup timer - runs every 5 minutes
    _sessionCleanupTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _cleanupExpiredSessions();
    });

    // Session validation timer - runs every 15 minutes
    _sessionValidationTimer =
        Timer.periodic(const Duration(minutes: 15), (timer) {
      _validateActiveSessions();
    });

    _logger.d('Session timers setup');
  }

  // Create new user session
  Future<UserSession> createSession({
    required String userId,
    bool rememberMe = false,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Check concurrent session limit
      if (_activeSessions.length >= _maxConcurrentSessions) {
        await _removeOldestSession();
      }

      final sessionId = _generateSessionId();
      final now = DateTime.now();

      final session = UserSession(
        id: sessionId,
        userId: userId,
        deviceId: _deviceId!,
        deviceName: _deviceName ?? 'Unknown',
        deviceType: _deviceType ?? 'Unknown',
        networkType: _networkType ?? 'Unknown',
        startTime: now,
        lastActivity: now,
        expiryTime: now.add(_sessionTimeout),
        rememberMe: rememberMe,
        metadata: metadata ?? {},
      );

      // Store session
      _activeSessions[sessionId] = session;
      _currentSession = session;

      // Setup session timer
      _setupSessionTimer(session);

      // Persist sessions
      if (_persistSessions) {
        await _persistSessions();
      }

      // Track analytics
      _analyticsService.trackEvent('session_created', {
        'session_id': sessionId,
        'device_type': _deviceType,
        'network_type': _networkType,
        'remember_me': rememberMe,
      });

      _emitSessionEvent(SessionEvent(
        type: SessionEventType.sessionCreated,
        sessionId: sessionId,
        userId: userId,
        deviceId: _deviceId,
        timestamp: now,
      ));

      _logger.i('Session created: $sessionId for user: $userId');
      return session;
    } catch (e) {
      _logger.e('Failed to create session: $e');
      throw SessionException(
        message: 'Failed to create session: $e',
        code: 'SESSION_CREATE_ERROR',
        details: e,
      );
    }
  }

  // Setup individual session timer
  void _setupSessionTimer(UserSession session) {
    _sessionTimers[session.id]?.cancel();

    final timeUntilExpiry = session.expiryTime.difference(DateTime.now());
    if (timeUntilExpiry.isNegative) return;

    _sessionTimers[session.id] = Timer(timeUntilExpiry, () {
      _expireSession(session.id);
    });
  }

  // Generate unique session ID
  String _generateSessionId() {
    return 'sess_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  // Update session activity
  Future<void> updateActivity(String sessionId) async {
    try {
      final session = _activeSessions[sessionId];
      if (session == null) return;

      session.lastActivity = DateTime.now();

      // Reset inactivity timer
      _inactivityTimer?.cancel();
      _inactivityTimer = Timer(_inactivityTimeout, () {
        _handleInactiveSession(sessionId);
      });

      // Persist updated session
      if (_persistSessions) {
        await _persistSessions();
      }

      _emitSessionEvent(SessionEvent(
        type: SessionEventType.activityUpdated,
        sessionId: sessionId,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      _logger.e('Failed to update activity: $e');
    }
  }

  // Handle inactive session
  void _handleInactiveSession(String sessionId) {
    _logger.w('Session inactive: $sessionId');

    _emitSessionEvent(SessionEvent(
      type: SessionEventType.sessionInactive,
      sessionId: sessionId,
      timestamp: DateTime.now(),
    ));

    // Optionally auto-expire inactive sessions
    final autoExpireInactive = _prefs.getBool('auto_expire_inactive') ?? false;
    if (autoExpireInactive) {
      _expireSession(sessionId);
    }
  }

  // Validate session
  Future<bool> validateSession(String sessionId) async {
    try {
      final session = _activeSessions[sessionId];
      if (session == null) return false;

      // Check expiry
      if (session.isExpired) {
        await _expireSession(sessionId);
        return false;
      }

      // Check inactivity
      final inactivityDuration =
          DateTime.now().difference(session.lastActivity);
      if (inactivityDuration > _inactivityTimeout) {
        _logger.w('Session inactive for too long: $sessionId');
        return false;
      }

      // Validate with server if online
      if (_networkType != 'Unknown') {
        try {
          await _pbClient.client.collection('users').authRefresh();
        } catch (e) {
          _logger.w('Server validation failed for session: $sessionId');
          return false;
        }
      }

      return true;
    } catch (e) {
      _logger.e('Session validation error: $e');
      return false;
    }
  }

  // Expire session
  Future<void> _expireSession(String sessionId) async {
    try {
      final session = _activeSessions.remove(sessionId);
      if (session == null) return;

      // Cancel session timer
      _sessionTimers[sessionId]?.cancel();
      _sessionTimers.remove(sessionId);

      // Clear current session if it matches
      if (_currentSession?.id == sessionId) {
        _currentSession = null;
      }

      // Track analytics
      final duration = DateTime.now().difference(session.startTime);
      _analyticsService.trackEvent('session_expired', {
        'session_id': sessionId,
        'duration_minutes': duration.inMinutes,
        'device_type': session.deviceType,
      });

      _emitSessionEvent(SessionEvent(
        type: SessionEventType.sessionExpired,
        sessionId: sessionId,
        userId: session.userId,
        timestamp: DateTime.now(),
      ));

      // Persist updated sessions
      if (_persistSessions) {
        await _persistSessions();
      }

      _logger.i('Session expired: $sessionId');
    } catch (e) {
      _logger.e('Failed to expire session: $e');
    }
  }

  // End session manually
  Future<void> endSession(String sessionId) async {
    try {
      final session = _activeSessions.remove(sessionId);
      if (session == null) return;

      // Cancel session timer
      _sessionTimers[sessionId]?.cancel();
      _sessionTimers.remove(sessionId);

      // Clear current session if it matches
      if (_currentSession?.id == sessionId) {
        _currentSession = null;
      }

      // Track analytics
      final duration = DateTime.now().difference(session.startTime);
      _analyticsService.trackEvent('session_ended', {
        'session_id': sessionId,
        'duration_minutes': duration.inMinutes,
        'device_type': session.deviceType,
      });

      _emitSessionEvent(SessionEvent(
        type: SessionEventType.sessionEnded,
        sessionId: sessionId,
        userId: session.userId,
        timestamp: DateTime.now(),
      ));

      // Persist updated sessions
      if (_persistSessions) {
        await _persistSessions();
      }

      _logger.i('Session ended: $sessionId');
    } catch (e) {
      _logger.e('Failed to end session: $e');
    }
  }

  // End all sessions
  Future<void> endAllSessions() async {
    try {
      final sessionIds = List<String>.from(_activeSessions.keys);

      for (final sessionId in sessionIds) {
        await endSession(sessionId);
      }

      _logger.i('All sessions ended');
    } catch (e) {
      _logger.e('Failed to end all sessions: $e');
    }
  }

  // End sessions for specific device
  Future<void> endDeviceSessions(String deviceId) async {
    try {
      final sessionsToEnd = _activeSessions.values
          .where((session) => session.deviceId == deviceId)
          .map((session) => session.id)
          .toList();

      for (final sessionId in sessionsToEnd) {
        await endSession(sessionId);
      }

      _logger.i('Ended ${sessionsToEnd.length} sessions for device: $deviceId');
    } catch (e) {
      _logger.e('Failed to end device sessions: $e');
    }
  }

  // Create streaming session
  Future<StreamingSession> createStreamingSession({
    required String sessionId,
    required String contentId,
    required String contentType,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final userSession = _activeSessions[sessionId];
      if (userSession == null) {
        throw SessionException(
          message: 'User session not found',
          code: 'USER_SESSION_NOT_FOUND',
        );
      }

      final streamingSessionId = _generateStreamingSessionId();
      final now = DateTime.now();

      final streamingSession = StreamingSession(
        id: streamingSessionId,
        userSessionId: sessionId,
        contentId: contentId,
        contentType: contentType,
        startTime: now,
        lastActivity: now,
        status: StreamingStatus.initializing,
        metadata: metadata ?? {},
      );

      _streamingSessions[streamingSessionId] = streamingSession;

      _emitSessionEvent(SessionEvent(
        type: SessionEventType.streamingSessionCreated,
        sessionId: sessionId,
        streamingSessionId: streamingSessionId,
        contentId: contentId,
        timestamp: now,
      ));

      _logger.i(
          'Streaming session created: $streamingSessionId for content: $contentId');
      return streamingSession;
    } catch (e) {
      _logger.e('Failed to create streaming session: $e');
      rethrow;
    }
  }

  // Generate streaming session ID
  String _generateStreamingSessionId() {
    return 'stream_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  // Update streaming session
  Future<void> updateStreamingSession({
    required String streamingSessionId,
    StreamingStatus? status,
    int? position,
    String? quality,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final session = _streamingSessions[streamingSessionId];
      if (session == null) return;

      session.lastActivity = DateTime.now();

      if (status != null) session.status = status;
      if (position != null) session.currentPosition = position;
      if (quality != null) session.currentQuality = quality;
      if (metadata != null) session.metadata.addAll(metadata);

      _emitSessionEvent(SessionEvent(
        type: SessionEventType.streamingSessionUpdated,
        streamingSessionId: streamingSessionId,
        status: status?.toString(),
        position: position,
        quality: quality,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      _logger.e('Failed to update streaming session: $e');
    }
  }

  // End streaming session
  Future<void> endStreamingSession(String streamingSessionId) async {
    try {
      final session = _streamingSessions.remove(streamingSessionId);
      if (session == null) return;

      session.endTime = DateTime.now();
      session.status = StreamingStatus.ended;

      // Track analytics
      final duration = session.endTime!.difference(session.startTime);
      _analyticsService.trackEvent('streaming_session_ended', {
        'streaming_session_id': streamingSessionId,
        'content_id': session.contentId,
        'duration_minutes': duration.inMinutes,
        'final_position': session.currentPosition,
      });

      _emitSessionEvent(SessionEvent(
        type: SessionEventType.streamingSessionEnded,
        streamingSessionId: streamingSessionId,
        contentId: session.contentId,
        timestamp: DateTime.now(),
      ));

      _logger.i('Streaming session ended: $streamingSessionId');
    } catch (e) {
      _logger.e('Failed to end streaming session: $e');
    }
  }

  // Cleanup expired sessions
  void _cleanupExpiredSessions() {
    try {
      final now = DateTime.now();
      final expiredSessionIds = <String>[];

      for (final entry in _activeSessions.entries) {
        if (entry.value.isExpired) {
          expiredSessionIds.add(entry.key);
        }
      }

      for (final sessionId in expiredSessionIds) {
        _expireSession(sessionId);
      }

      if (expiredSessionIds.isNotEmpty) {
        _logger.i('Cleaned up ${expiredSessionIds.length} expired sessions');
      }
    } catch (e) {
      _logger.e('Session cleanup error: $e');
    }
  }

  // Validate all active sessions
  Future<void> _validateActiveSessions() async {
    try {
      final sessionIds = List<String>.from(_activeSessions.keys);
      int invalidCount = 0;

      for (final sessionId in sessionIds) {
        final isValid = await validateSession(sessionId);
        if (!isValid) {
          invalidCount++;
        }
      }

      if (invalidCount > 0) {
        _logger.i('Validated sessions: $invalidCount invalid sessions found');
      }
    } catch (e) {
      _logger.e('Session validation error: $e');
    }
  }

  // Remove oldest session to make room for new one
  Future<void> _removeOldestSession() async {
    try {
      if (_activeSessions.isEmpty) return;

      UserSession? oldestSession;
      for (final session in _activeSessions.values) {
        if (oldestSession == null ||
            session.startTime.isBefore(oldestSession.startTime)) {
          oldestSession = session;
        }
      }

      if (oldestSession != null) {
        await endSession(oldestSession.id);
        _logger.i('Removed oldest session to make room: ${oldestSession.id}');
      }
    } catch (e) {
      _logger.e('Failed to remove oldest session: $e');
    }
  }

  // Check if session is valid
  bool _isValidSession(UserSession session) {
    // Check basic validity
    if (session.id.isEmpty || session.userId.isEmpty) return false;

    // Check if not too old
    final age = DateTime.now().difference(session.startTime);
    if (age > _maxSessionDuration) return false;

    return true;
  }

  // Persist sessions to storage
  Future<void> _persistSessions() async {
    try {
      if (!_persistSessions) return;

      final sessionDataList =
          _activeSessions.values.map((session) => session.toJson()).toList();

      final sessionDataJson = jsonEncode(sessionDataList);
      await _storageService.setSecureData(
          'persisted_sessions', sessionDataJson);

      _logger.d('Sessions persisted: ${sessionDataList.length} sessions');
    } catch (e) {
      _logger.e('Failed to persist sessions: $e');
    }
  }

  // Emit session event
  void _emitSessionEvent(SessionEvent event) {
    _sessionHistory.add(event);
    _sessionEventController.add(event);

    // Keep history size manageable
    if (_sessionHistory.length > 1000) {
      _sessionHistory.removeRange(0, 500);
    }
  }

  // Get session statistics
  Map<String, dynamic> getSessionStatistics() {
    final now = DateTime.now();
    final activeSessions = _activeSessions.values.toList();

    return {
      'total_active_sessions': activeSessions.length,
      'total_streaming_sessions': _streamingSessions.length,
      'current_session_id': _currentSession?.id,
      'device_id': _deviceId,
      'device_name': _deviceName,
      'device_type': _deviceType,
      'network_type': _networkType,
      'session_timeout_minutes': _sessionTimeout.inMinutes,
      'inactivity_timeout_minutes': _inactivityTimeout.inMinutes,
      'max_concurrent_sessions': _maxConcurrentSessions,
      'sessions_by_device': _getSessionsByDevice(),
      'average_session_duration': _getAverageSessionDuration(),
      'session_events_count': _sessionHistory.length,
    };
  }

  // Get sessions grouped by device
  Map<String, int> _getSessionsByDevice() {
    final deviceSessions = <String, int>{};

    for (final session in _activeSessions.values) {
      final deviceKey = '${session.deviceName} (${session.deviceType})';
      deviceSessions[deviceKey] = (deviceSessions[deviceKey] ?? 0) + 1;
    }

    return deviceSessions;
  }

  // Get average session duration
  double _getAverageSessionDuration() {
    if (_activeSessions.isEmpty) return 0.0;

    final now = DateTime.now();
    double totalMinutes = 0.0;

    for (final session in _activeSessions.values) {
      final duration = now.difference(session.startTime);
      totalMinutes += duration.inMinutes;
    }

    return totalMinutes / _activeSessions.length;
  }

  // Update session configuration
  Future<void> updateConfiguration({
    Duration? sessionTimeout,
    Duration? inactivityTimeout,
    Duration? maxSessionDuration,
    int? maxConcurrentSessions,
    bool? allowMultipleDeviceSessions,
    bool? persistSessions,
    bool? encryptSessionData,
  }) async {
    try {
      if (sessionTimeout != null) {
        _sessionTimeout = sessionTimeout;
        await _prefs.setInt(
            'session_timeout_minutes', sessionTimeout.inMinutes);
      }

      if (inactivityTimeout != null) {
        _inactivityTimeout = inactivityTimeout;
        await _prefs.setInt(
            'inactivity_timeout_minutes', inactivityTimeout.inMinutes);
      }

      if (maxSessionDuration != null) {
        _maxSessionDuration = maxSessionDuration;
        await _prefs.setInt(
            'max_session_duration_days', maxSessionDuration.inDays);
      }

      if (maxConcurrentSessions != null) {
        _maxConcurrentSessions = maxConcurrentSessions;
        await _prefs.setInt('max_concurrent_sessions', maxConcurrentSessions);
      }

      if (allowMultipleDeviceSessions != null) {
        _allowMultipleDeviceSessions = allowMultipleDeviceSessions;
        await _prefs.setBool(
            'allow_multiple_device_sessions', allowMultipleDeviceSessions);
      }

      if (persistSessions != null) {
        _persistSessions = persistSessions;
        await _prefs.setBool('persist_sessions', persistSessions);
      }

      if (encryptSessionData != null) {
        _encryptSessionData = encryptSessionData;
        await _prefs.setBool('encrypt_session_data', encryptSessionData);
      }

      _logger.i('Session configuration updated');
    } catch (e) {
      _logger.e('Failed to update session configuration: $e');
    }
  }

  // Dispose resources
  void dispose() {
    _sessionCleanupTimer?.cancel();
    _sessionValidationTimer?.cancel();
    _inactivityTimer?.cancel();
    _connectivitySubscription.cancel();

    for (final timer in _sessionTimers.values) {
      timer.cancel();
    }
    _sessionTimers.clear();

    _sessionEventController.close();
    _activeSessions.clear();
    _streamingSessions.clear();
    _sessionHistory.clear();
    _sessionCache.clear();

    _logger.i('Session Manager disposed');
  }
}

// User session model
class UserSession {
  final String id;
  final String userId;
  final String deviceId;
  final String deviceName;
  final String deviceType;
  String networkType;
  final DateTime startTime;
  DateTime lastActivity;
  final DateTime expiryTime;
  final bool rememberMe;
  final Map<String, dynamic> metadata;

  UserSession({
    required this.id,
    required this.userId,
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    required this.networkType,
    required this.startTime,
    required this.lastActivity,
    required this.expiryTime,
    required this.rememberMe,
    required this.metadata,
  });

  bool get isExpired => DateTime.now().isAfter(expiryTime);
  Duration get duration => DateTime.now().difference(startTime);
  Duration get timeUntilExpiry => expiryTime.difference(DateTime.now());
  bool get isActive => !isExpired;

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      id: json['id'] as String,
      userId: json['userId'] as String,
      deviceId: json['deviceId'] as String,
      deviceName: json['deviceName'] as String,
      deviceType: json['deviceType'] as String,
      networkType: json['networkType'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      lastActivity: DateTime.parse(json['lastActivity'] as String),
      expiryTime: DateTime.parse(json['expiryTime'] as String),
      rememberMe: json['rememberMe'] as bool,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'deviceId': deviceId,
      'deviceName': deviceName,
      'deviceType': deviceType,
      'networkType': networkType,
      'startTime': startTime.toIso8601String(),
      'lastActivity': lastActivity.toIso8601String(),
      'expiryTime': expiryTime.toIso8601String(),
      'rememberMe': rememberMe,
      'metadata': metadata,
    };
  }
}

// Streaming session model
class StreamingSession {
  final String id;
  final String userSessionId;
  final String contentId;
  final String contentType;
  final DateTime startTime;
  DateTime lastActivity;
  DateTime? endTime;
  StreamingStatus status;
  int currentPosition;
  String? currentQuality;
  final Map<String, dynamic> metadata;

  StreamingSession({
    required this.id,
    required this.userSessionId,
    required this.contentId,
    required this.contentType,
    required this.startTime,
    required this.lastActivity,
    this.endTime,
    required this.status,
    this.currentPosition = 0,
    this.currentQuality,
    required this.metadata,
  });

  Duration get duration => (endTime ?? DateTime.now()).difference(startTime);
  bool get isActive => endTime == null && status != StreamingStatus.ended;

  factory StreamingSession.fromJson(Map<String, dynamic> json) {
    return StreamingSession(
      id: json['id'] as String,
      userSessionId: json['userSessionId'] as String,
      contentId: json['contentId'] as String,
      contentType: json['contentType'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      lastActivity: DateTime.parse(json['lastActivity'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      status: StreamingStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => StreamingStatus.initializing,
      ),
      currentPosition: json['currentPosition'] as int? ?? 0,
      currentQuality: json['currentQuality'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userSessionId': userSessionId,
      'contentId': contentId,
      'contentType': contentType,
      'startTime': startTime.toIso8601String(),
      'lastActivity': lastActivity.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'status': status.toString(),
      'currentPosition': currentPosition,
      'currentQuality': currentQuality,
      'metadata': metadata,
    };
  }
}

// Session event model
class SessionEvent {
  final SessionEventType type;
  final String? sessionId;
  final String? streamingSessionId;
  final String? userId;
  final String? deviceId;
  final String? contentId;
  final String? networkType;
  final String? status;
  final int? position;
  final String? quality;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  SessionEvent({
    required this.type,
    this.sessionId,
    this.streamingSessionId,
    this.userId,
    this.deviceId,
    this.contentId,
    this.networkType,
    this.status,
    this.position,
    this.quality,
    required this.timestamp,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'sessionId': sessionId,
      'streamingSessionId': streamingSessionId,
      'userId': userId,
      'deviceId': deviceId,
      'contentId': contentId,
      'networkType': networkType,
      'status': status,
      'position': position,
      'quality': quality,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}

// Session data model for caching
class SessionData {
  final String sessionId;
  final Map<String, dynamic> data;
  final DateTime cachedAt;
  final DateTime expiresAt;

  SessionData({
    required this.sessionId,
    required this.data,
    required this.cachedAt,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

// Enums
enum SessionEventType {
  sessionCreated,
  sessionExpired,
  sessionEnded,
  sessionInactive,
  activityUpdated,
  networkChanged,
  streamingSessionCreated,
  streamingSessionUpdated,
  streamingSessionEnded,
}

enum StreamingStatus {
  initializing,
  buffering,
  playing,
  paused,
  seeking,
  ended,
  error,
}

// Session exception
class SessionException implements Exception {
  final String message;
  final String code;
  final dynamic details;
  final StackTrace? stackTrace;

  const SessionException({
    required this.message,
    required this.code,
    this.details,
    this.stackTrace,
  });

  @override
  String toString() => 'SessionException: $message (Code: $code)';
}
