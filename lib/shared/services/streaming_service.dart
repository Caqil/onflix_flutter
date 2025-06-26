import 'dart:async';
import 'dart:math' as math;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';
import 'package:onflix/core/constants/storage_keys.dart';
import 'package:onflix/core/errors/exceptions.dart';
import 'package:onflix/core/network/pocketbase_client.dart';
import 'package:onflix/core/utils/helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'storage_service.dart';
import 'analytics_service.dart';

class StreamingService {
  static StreamingService? _instance;
  late Logger _logger;
  late SharedPreferences _prefs;
  late PocketBaseClient _pbClient;
  late StorageService _storageService;
  late AnalyticsService _analyticsService;

  // Streaming state
  final Map<String, StreamingSession> _activeSessions = {};
  final StreamController<StreamingEvent> _streamingEventController =
      StreamController<StreamingEvent>.broadcast();

  // Quality management
  String _currentQuality = 'Auto';
  bool _adaptiveStreamingEnabled = true;
  final List<QualityProfile> _qualityProfiles = [];

  // Network monitoring
  bool _isOnline = true;
  String _connectionType = 'unknown';
  double _bandwidthEstimate = 0.0;
  final List<BandwidthSample> _bandwidthSamples = [];

  // CDN and server management
  final List<StreamingServer> _availableServers = [];
  StreamingServer? _currentServer;

  // Buffering and preloading
  final Map<String, BufferStatus> _bufferStatus = {};
  bool _preloadingEnabled = true;
  final List<String> _preloadQueue = [];

  // DRM and security
  final Map<String, DrmLicense> _drmLicenses = {};
  bool _drmEnabled = false;

  StreamingService._() {
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

  static StreamingService get instance {
    _instance ??= StreamingService._();
    return _instance!;
  }

  // Stream for streaming events
  Stream<StreamingEvent> get streamingEvents =>
      _streamingEventController.stream;

  // Initialize the service
  Future<void> initialize() async {
    try {
      _logger.i('Initializing Streaming Service...');

      _prefs = await SharedPreferences.getInstance();
      await _loadStreamingSettings();
      await _initializeQualityProfiles();
      await _loadStreamingServers();
      _setupNetworkMonitoring();
      _setupBandwidthMonitoring();

      _logger.i('Streaming Service initialized successfully');
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize Streaming Service',
          error: e, stackTrace: stackTrace);
      throw PlaybackException(
        message: 'Failed to initialize streaming service: $e',
        code: 'STREAMING_INITIALIZATION_ERROR',
        details: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Load streaming settings
  Future<void> _loadStreamingSettings() async {
    _currentQuality = _prefs.getString(StorageKeys.videoQuality) ?? 'Auto';
    _adaptiveStreamingEnabled =
        _prefs.getBool(StorageKeys.adaptiveStreaming) ?? true;
    _preloadingEnabled = _prefs.getBool(StorageKeys.preloadEnabled) ?? true;
    _drmEnabled = _prefs.getBool('drm_enabled') ?? false;

    _logger.d('Streaming settings loaded');
  }

  // Initialize quality profiles
  Future<void> _initializeQualityProfiles() async {
    _qualityProfiles.clear();
    _qualityProfiles.addAll([
      QualityProfile(
        name: '240p',
        resolution: '426x240',
        bitrate: 400,
        fps: 24,
        codec: 'h264',
        minBandwidth: 500,
      ),
      QualityProfile(
        name: '360p',
        resolution: '640x360',
        bitrate: 700,
        fps: 24,
        codec: 'h264',
        minBandwidth: 800,
      ),
      QualityProfile(
        name: '480p',
        resolution: '854x480',
        bitrate: 1200,
        fps: 30,
        codec: 'h264',
        minBandwidth: 1500,
      ),
      QualityProfile(
        name: '720p',
        resolution: '1280x720',
        bitrate: 2500,
        fps: 30,
        codec: 'h264',
        minBandwidth: 3000,
      ),
      QualityProfile(
        name: '1080p',
        resolution: '1920x1080',
        bitrate: 5000,
        fps: 30,
        codec: 'h264',
        minBandwidth: 6000,
      ),
      QualityProfile(
        name: '1440p',
        resolution: '2560x1440',
        bitrate: 10000,
        fps: 30,
        codec: 'h265',
        minBandwidth: 12000,
      ),
      QualityProfile(
        name: '2160p',
        resolution: '3840x2160',
        bitrate: 20000,
        fps: 30,
        codec: 'h265',
        minBandwidth: 25000,
      ),
    ]);

    _logger.d('Quality profiles initialized: ${_qualityProfiles.length}');
  }

  // Load streaming servers
  Future<void> _loadStreamingServers() async {
    try {
      final response = await _pbClient.getRecords(
        'streaming_servers',
        filter: 'active=true',
        sort: 'priority',
      );

      if (response.isSuccess && response.data != null) {
        _availableServers.clear();

        for (final record in response.data!.items) {
          final server = StreamingServer.fromRecord(record);
          _availableServers.add(server);
        }

        // Select the best server
        if (_availableServers.isNotEmpty) {
          _currentServer = _availableServers.first;
        }
      }

      _logger.d('Loaded ${_availableServers.length} streaming servers');
    } catch (e) {
      _logger.w('Failed to load streaming servers: $e');

      // Fallback to default server
      _currentServer = StreamingServer(
        id: 'default',
        name: 'Default Server',
        url: 'https://stream.onflix.com',
        priority: 1,
        region: 'global',
        isActive: true,
        maxBitrate: 25000,
        supportedCodecs: ['h264', 'h265'],
      );
      _availableServers.add(_currentServer!);
    }
  }

  // Setup network monitoring
  void _setupNetworkMonitoring() {
    Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      final isConnected = result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.ethernet;

      _isOnline = isConnected;

      if (isConnected) {
        _connectionType = result.toString().split('.').last;
      } else {
        _connectionType = 'none';
      }

      _handleConnectivityChange(isConnected);
    });
  }

  // Handle connectivity changes
  void _handleConnectivityChange(bool isConnected) {
    if (!isConnected) {
      // Pause all active sessions
      for (final session in _activeSessions.values) {
        _pauseSession(session.id);
      }

      _streamingEventController.add(StreamingEvent(
        type: StreamingEventType.networkLost,
        sessionId: '',
        message: 'Network connection lost',
      ));
    } else {
      _streamingEventController.add(StreamingEvent(
        type: StreamingEventType.networkRestored,
        sessionId: '',
        message: 'Network connection restored',
      ));

      // Resume sessions if auto-resume is enabled
      _resumeSessionsAfterReconnect();
    }

    _logger.i('Network connectivity changed: $isConnected ($_connectionType)');
  }

  // Resume sessions after reconnect
  Future<void> _resumeSessionsAfterReconnect() async {
    try {
      await Future.delayed(
          const Duration(seconds: 2)); // Wait for stable connection

      for (final session in _activeSessions.values) {
        if (session.status == StreamingStatus.paused) {
          await _resumeSession(session.id);
        }
      }
    } catch (e) {
      _logger.e('Failed to resume sessions after reconnect: $e');
    }
  }

  // Setup bandwidth monitoring
  void _setupBandwidthMonitoring() {
    Timer.periodic(const Duration(seconds: 10), (timer) {
      _updateBandwidthEstimate();
    });
  }

  // Update bandwidth estimate
  void _updateBandwidthEstimate() {
    try {
      // Calculate bandwidth based on recent samples
      final now = DateTime.now();
      final recentSamples = _bandwidthSamples
          .where((sample) => now.difference(sample.timestamp).inMinutes < 5)
          .toList();

      if (recentSamples.isNotEmpty) {
        final totalBytes =
            recentSamples.fold<int>(0, (sum, sample) => sum + sample.bytes);
        final totalTime = recentSamples.fold<int>(
            0, (sum, sample) => sum + sample.duration.inMilliseconds);

        if (totalTime > 0) {
          _bandwidthEstimate =
              (totalBytes * 8 / totalTime) * 1000; // bits per second
        }
      }

      // Adjust quality if adaptive streaming is enabled
      if (_adaptiveStreamingEnabled && _currentQuality == 'Auto') {
        _adjustQualityForBandwidth();
      }
    } catch (e) {
      _logger.w('Failed to update bandwidth estimate: $e');
    }
  }

  // Adjust quality based on bandwidth
  void _adjustQualityForBandwidth() {
    try {
      final bandwidthKbps = _bandwidthEstimate / 1000;

      // Find the best quality that fits the current bandwidth
      QualityProfile? bestQuality;
      for (final profile in _qualityProfiles.reversed) {
        if (bandwidthKbps >= profile.minBandwidth * 1.2) {
          // 20% buffer
          bestQuality = profile;
          break;
        }
      }

      if (bestQuality != null) {
        for (final session in _activeSessions.values) {
          if (session.currentQuality != bestQuality.name) {
            _switchQuality(session.id, bestQuality.name);
          }
        }
      }
    } catch (e) {
      _logger.w('Failed to adjust quality for bandwidth: $e');
    }
  }

  // Start streaming session
  Future<String> startStream({
    required String contentId,
    required String contentTitle,
    required String contentType,
    String? quality,
    int startPosition = 0,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      if (!_isOnline) {
        throw const PlaybackException(
          message: 'No internet connection available',
          code: 'NO_CONNECTION',
        );
      }

      final sessionId = Helpers.generateId();

      _logger.i('Starting stream session: $contentTitle');

      // Get stream URLs
      final streamUrls = await _getStreamUrls(contentId, quality);
      if (streamUrls.isEmpty) {
        throw PlaybackException.streamingError();
      }

      // Create streaming session
      final session = StreamingSession(
        id: sessionId,
        contentId: contentId,
        contentTitle: contentTitle,
        contentType: contentType,
        startTime: DateTime.now(),
        currentPosition: startPosition,
        streamUrls: streamUrls,
        currentQuality: quality ?? _currentQuality,
        server: _currentServer,
        metadata: metadata,
      );

      _activeSessions[sessionId] = session;

      // Initialize DRM if required
      if (_drmEnabled && session.metadata?['drm_required'] == true) {
        await _initializeDrm(sessionId);
      }

      // Start buffering
      await _startBuffering(sessionId);

      // Track analytics
      _analyticsService.trackContentPlay(contentId, contentType, contentTitle);

      // Emit event
      _streamingEventController.add(StreamingEvent(
        type: StreamingEventType.sessionStarted,
        sessionId: sessionId,
        contentId: contentId,
        quality: session.currentQuality,
      ));

      _logger.i('Stream session started: $sessionId');
      return sessionId;
    } catch (e) {
      _logger.e('Failed to start stream: $e');
      rethrow;
    }
  }

  // Get stream URLs from server
  Future<Map<String, String>> _getStreamUrls(
      String contentId, String? quality) async {
    try {
      final response = await _pbClient.createRecord('stream_requests', {
        'content_id': contentId,
        'quality': quality,
        'user_id': _pbClient.currentUser?.id,
        'device_id': await _getDeviceId(),
      });

      if (response.isSuccess && response.data != null) {
        final data = response.data!.data;
        final urls = data['stream_urls'] as Map<String, dynamic>?;

        if (urls != null) {
          return urls.cast<String, String>();
        }
      }

      throw const PlaybackException(
        message: 'Failed to get stream URLs',
        code: 'STREAM_URL_ERROR',
      );
    } catch (e) {
      _logger.e('Failed to get stream URLs: $e');
      rethrow;
    }
  }

  // Get device ID
  Future<String> _getDeviceId() async {
    return _storageService.getString(StorageKeys.deviceId);
  }

  // Initialize DRM
  Future<void> _initializeDrm(String sessionId) async {
    try {
      final session = _activeSessions[sessionId];
      if (session == null) return;

      final licenseUrl = session.metadata?['drm_license_url'] as String?;
      if (licenseUrl == null) return;

      // Request DRM license
      final licenseResponse = await _pbClient.createRecord('drm_licenses', {
        'content_id': session.contentId,
        'session_id': sessionId,
        'license_url': licenseUrl,
      });

      if (licenseResponse.isSuccess && licenseResponse.data != null) {
        final licenseData = licenseResponse.data!.data;

        final license = DrmLicense(
          sessionId: sessionId,
          licenseData: licenseData['license'],
          expiryTime: DateTime.parse(licenseData['expires_at']),
        );

        _drmLicenses[sessionId] = license;

        _logger.d('DRM license acquired for session: $sessionId');
      }
    } catch (e) {
      _logger.e('Failed to initialize DRM: $e');
      throw PlaybackException.drmError();
    }
  }

  // Start buffering
  Future<void> _startBuffering(String sessionId) async {
    try {
      final session = _activeSessions[sessionId];
      if (session == null) return;

      session.status = StreamingStatus.buffering;

      final bufferStatus = BufferStatus(
        sessionId: sessionId,
        bufferLevel: 0,
        targetBuffer: 30, // 30 seconds
        isBuffering: true,
      );

      _bufferStatus[sessionId] = bufferStatus;

      // Simulate buffering progress
      _simulateBuffering(sessionId);

      _streamingEventController.add(StreamingEvent(
        type: StreamingEventType.bufferingStarted,
        sessionId: sessionId,
        bufferLevel: bufferStatus.bufferLevel,
      ));
    } catch (e) {
      _logger.e('Failed to start buffering: $e');
    }
  }

  // Simulate buffering (replace with actual implementation)
  void _simulateBuffering(String sessionId) {
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      final bufferStatus = _bufferStatus[sessionId];
      final session = _activeSessions[sessionId];

      if (bufferStatus == null || session == null) {
        timer.cancel();
        return;
      }

      // Simulate buffer filling based on bandwidth
      final fillRate =
          math.min(_bandwidthEstimate / 1000, 10); // Max 10 seconds per update
      bufferStatus.bufferLevel += fillRate;

      if (bufferStatus.bufferLevel >= bufferStatus.targetBuffer) {
        bufferStatus.isBuffering = false;
        session.status = StreamingStatus.playing;
        timer.cancel();

        _streamingEventController.add(StreamingEvent(
          type: StreamingEventType.bufferingCompleted,
          sessionId: sessionId,
          bufferLevel: bufferStatus.bufferLevel,
        ));

        _logger.d('Buffering completed for session: $sessionId');
      } else {
        _streamingEventController.add(StreamingEvent(
          type: StreamingEventType.bufferingProgress,
          sessionId: sessionId,
          bufferLevel: bufferStatus.bufferLevel,
        ));
      }
    });
  }

  // Play session
  Future<void> playSession(String sessionId) async {
    try {
      final session = _activeSessions[sessionId];
      if (session == null) {
        throw const PlaybackException(
          message: 'Session not found',
          code: 'SESSION_NOT_FOUND',
        );
      }

      session.status = StreamingStatus.playing;
      session.lastActivity = DateTime.now();

      _streamingEventController.add(StreamingEvent(
        type: StreamingEventType.playing,
        sessionId: sessionId,
        position: session.currentPosition,
      ));

      _logger.d('Session playing: $sessionId');
    } catch (e) {
      _logger.e('Failed to play session: $e');
      rethrow;
    }
  }

  // Pause session
  Future<void> _pauseSession(String sessionId) async {
    try {
      final session = _activeSessions[sessionId];
      if (session == null) return;

      session.status = StreamingStatus.paused;
      session.lastActivity = DateTime.now();

      _streamingEventController.add(StreamingEvent(
        type: StreamingEventType.paused,
        sessionId: sessionId,
        position: session.currentPosition,
      ));

      _logger.d('Session paused: $sessionId');
    } catch (e) {
      _logger.e('Failed to pause session: $e');
    }
  }

  // Resume session
  Future<void> _resumeSession(String sessionId) async {
    try {
      final session = _activeSessions[sessionId];
      if (session == null) return;

      if (!_isOnline) {
        throw const PlaybackException(
          message: 'No internet connection available',
          code: 'NO_CONNECTION',
        );
      }

      session.status = StreamingStatus.playing;
      session.lastActivity = DateTime.now();

      _streamingEventController.add(StreamingEvent(
        type: StreamingEventType.resumed,
        sessionId: sessionId,
        position: session.currentPosition,
      ));

      _logger.d('Session resumed: $sessionId');
    } catch (e) {
      _logger.e('Failed to resume session: $e');
      rethrow;
    }
  }

  // Seek to position
  Future<void> seekToPosition(String sessionId, int position) async {
    try {
      final session = _activeSessions[sessionId];
      if (session == null) {
        throw const PlaybackException(
          message: 'Session not found',
          code: 'SESSION_NOT_FOUND',
        );
      }

      session.currentPosition = position;
      session.lastActivity = DateTime.now();

      // Restart buffering if needed
      if (session.status == StreamingStatus.playing) {
        await _startBuffering(sessionId);
      }

      _streamingEventController.add(StreamingEvent(
        type: StreamingEventType.seeked,
        sessionId: sessionId,
        position: position,
      ));

      _logger.d('Session seeked to $position: $sessionId');
    } catch (e) {
      _logger.e('Failed to seek session: $e');
      rethrow;
    }
  }

  // Switch quality
  Future<void> _switchQuality(String sessionId, String quality) async {
    try {
      final session = _activeSessions[sessionId];
      if (session == null) return;

      if (session.currentQuality == quality) return;

      session.currentQuality = quality;
      session.lastActivity = DateTime.now();

      // Get new stream URL for the quality
      final newUrls = await _getStreamUrls(session.contentId, quality);
      session.streamUrls = newUrls;

      // Restart buffering
      await _startBuffering(sessionId);

      _streamingEventController.add(StreamingEvent(
        type: StreamingEventType.qualityChanged,
        sessionId: sessionId,
        quality: quality,
      ));

      _logger.d('Quality switched to $quality for session: $sessionId');
    } catch (e) {
      _logger.e('Failed to switch quality: $e');
    }
  }

  // Update position
  Future<void> updatePosition(String sessionId, int position) async {
    try {
      final session = _activeSessions[sessionId];
      if (session == null) return;

      session.currentPosition = position;
      session.lastActivity = DateTime.now();

      // Update watch progress periodically
      if (position % 30 == 0) {
        // Every 30 seconds
        await _updateWatchProgress(sessionId);
      }
    } catch (e) {
      _logger.e('Failed to update position: $e');
    }
  }

  // Update watch progress
  Future<void> _updateWatchProgress(String sessionId) async {
    try {
      final session = _activeSessions[sessionId];
      if (session == null) return;

      await _pbClient.createRecord('watch_progress', {
        'user': _pbClient.currentUser?.id,
        'content': session.contentId,
        'position': session.currentPosition,
        'session_id': sessionId,
      });
    } catch (e) {
      _logger.w('Failed to update watch progress: $e');
    }
  }

  // Stop session
  Future<void> stopSession(String sessionId) async {
    try {
      final session = _activeSessions.remove(sessionId);
      if (session == null) return;

      session.status = StreamingStatus.stopped;
      session.endTime = DateTime.now();

      // Clean up resources
      _bufferStatus.remove(sessionId);
      _drmLicenses.remove(sessionId);

      // Update final watch progress
      await _updateWatchProgress(sessionId);

      // Track analytics
      final duration = session.endTime!.difference(session.startTime).inSeconds;
      _analyticsService.trackContentPause(
        session.contentId,
        session.currentPosition,
        duration,
      );

      _streamingEventController.add(StreamingEvent(
        type: StreamingEventType.sessionEnded,
        sessionId: sessionId,
        position: session.currentPosition,
      ));

      _logger.i('Session stopped: $sessionId');
    } catch (e) {
      _logger.e('Failed to stop session: $e');
    }
  }

  // Get available qualities
  List<String> getAvailableQualities() {
    final qualities = ['Auto'];
    qualities.addAll(_qualityProfiles.map((p) => p.name));
    return qualities;
  }

  // Get current quality
  String getCurrentQuality(String sessionId) {
    final session = _activeSessions[sessionId];
    return session?.currentQuality ?? _currentQuality;
  }

  // Set quality preference
  Future<void> setQualityPreference(String quality) async {
    _currentQuality = quality;
    await _prefs.setString(StorageKeys.videoQuality, quality);

    // Apply to all active sessions
    for (final session in _activeSessions.values) {
      if (quality != 'Auto') {
        await _switchQuality(session.id, quality);
      }
    }

    _logger.i('Quality preference set: $quality');
  }

  // Enable/disable adaptive streaming
  Future<void> setAdaptiveStreaming(bool enabled) async {
    _adaptiveStreamingEnabled = enabled;
    await _prefs.setBool(StorageKeys.adaptiveStreaming, enabled);
    _logger.i('Adaptive streaming: $enabled');
  }

  // Get active sessions
  List<StreamingSession> getActiveSessions() {
    return _activeSessions.values.toList();
  }

  // Get session
  StreamingSession? getSession(String sessionId) {
    return _activeSessions[sessionId];
  }

  // Get streaming statistics
  Map<String, dynamic> getStreamingStats() {
    final stats = <String, dynamic>{
      'activeSessions': _activeSessions.length,
      'isOnline': _isOnline,
      'connectionType': _connectionType,
      'bandwidthEstimate': _bandwidthEstimate,
      'currentServer': _currentServer?.name,
      'totalServers': _availableServers.length,
      'adaptiveStreamingEnabled': _adaptiveStreamingEnabled,
      'currentQuality': _currentQuality,
      'drmEnabled': _drmEnabled,
    };

    // Add session details
    for (final session in _activeSessions.values) {
      stats['session_${session.id}'] = {
        'contentTitle': session.contentTitle,
        'status': session.status.toString(),
        'quality': session.currentQuality,
        'position': session.currentPosition,
        'duration': DateTime.now().difference(session.startTime).inMinutes,
        'bufferLevel': _bufferStatus[session.id]?.bufferLevel ?? 0,
      };
    }

    return stats;
  }

  // Preload content
  Future<void> preloadContent(String contentId) async {
    try {
      if (!_preloadingEnabled || !_isOnline) return;

      if (!_preloadQueue.contains(contentId)) {
        _preloadQueue.add(contentId);
        _logger.d('Content added to preload queue: $contentId');
      }

      // Process preload queue
      _processPreloadQueue();
    } catch (e) {
      _logger.e('Failed to preload content: $e');
    }
  }

  // Process preload queue
  void _processPreloadQueue() {
    // Implement preloading logic here
    // This would typically involve downloading initial segments
    // of the video for faster startup
  }

  // Handle server failure

  // Dispose resources
  void dispose() {
    for (final sessionId in _activeSessions.keys.toList()) {
      stopSession(sessionId);
    }

    _streamingEventController.close();
    _bandwidthSamples.clear();
    _drmLicenses.clear();
    _bufferStatus.clear();
  }
}

// Streaming session model
class StreamingSession {
  final String id;
  final String contentId;
  final String contentTitle;
  final String contentType;
  final DateTime startTime;
  DateTime? endTime;
  DateTime lastActivity;

  int currentPosition;
  StreamingStatus status;
  String currentQuality;
  Map<String, String> streamUrls;
  StreamingServer? server;
  Map<String, dynamic>? metadata;

  StreamingSession({
    required this.id,
    required this.contentId,
    required this.contentTitle,
    required this.contentType,
    required this.startTime,
    required this.currentPosition,
    required this.streamUrls,
    required this.currentQuality,
    this.server,
    this.metadata,
  })  : status = StreamingStatus.initializing,
        lastActivity = DateTime.now();
}

// Quality profile model
class QualityProfile {
  final String name;
  final String resolution;
  final int bitrate;
  final int fps;
  final String codec;
  final double minBandwidth;

  QualityProfile({
    required this.name,
    required this.resolution,
    required this.bitrate,
    required this.fps,
    required this.codec,
    required this.minBandwidth,
  });
}

// Streaming server model
class StreamingServer {
  final String id;
  final String name;
  final String url;
  final int priority;
  final String region;
  final bool isActive;
  final int maxBitrate;
  final List<String> supportedCodecs;

  StreamingServer({
    required this.id,
    required this.name,
    required this.url,
    required this.priority,
    required this.region,
    required this.isActive,
    required this.maxBitrate,
    required this.supportedCodecs,
  });

  factory StreamingServer.fromRecord(dynamic record) => StreamingServer(
        id: record.id,
        name: record.data['name'],
        url: record.data['url'],
        priority: record.data['priority'],
        region: record.data['region'],
        isActive: record.data['active'] ?? true,
        maxBitrate: record.data['max_bitrate'] ?? 25000,
        supportedCodecs:
            List<String>.from(record.data['supported_codecs'] ?? ['h264']),
      );
}

// Buffer status model
class BufferStatus {
  final String sessionId;
  double bufferLevel;
  final double targetBuffer;
  bool isBuffering;

  BufferStatus({
    required this.sessionId,
    required this.bufferLevel,
    required this.targetBuffer,
    required this.isBuffering,
  });
}

// DRM license model
class DrmLicense {
  final String sessionId;
  final String licenseData;
  final DateTime expiryTime;

  DrmLicense({
    required this.sessionId,
    required this.licenseData,
    required this.expiryTime,
  });

  bool get isExpired => DateTime.now().isAfter(expiryTime);
}

// Bandwidth sample model
class BandwidthSample {
  final int bytes;
  final Duration duration;
  final DateTime timestamp;

  BandwidthSample({
    required this.bytes,
    required this.duration,
    required this.timestamp,
  });
}

// Streaming event model
class StreamingEvent {
  final StreamingEventType type;
  final String sessionId;
  final String? contentId;
  final String? quality;
  final int? position;
  final double? bufferLevel;
  final String? message;

  StreamingEvent({
    required this.type,
    required this.sessionId,
    this.contentId,
    this.quality,
    this.position,
    this.bufferLevel,
    this.message,
  });
}

// Enums
enum StreamingStatus {
  initializing,
  buffering,
  playing,
  paused,
  stopped,
  error,
}

enum StreamingEventType {
  sessionStarted,
  sessionEnded,
  playing,
  paused,
  resumed,
  stopped,
  seeked,
  bufferingStarted,
  bufferingProgress,
  bufferingCompleted,
  qualityChanged,
  networkLost,
  networkRestored,
  error,
}
