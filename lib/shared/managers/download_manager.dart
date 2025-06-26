import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../shared/services/storage_service.dart';
import '../../shared/services/analytics_service.dart';
import '../../shared/services/notification_service.dart';

class DownloadManager {
  static DownloadManager? _instance;
  late Logger _logger;
  late StorageService _storageService;
  late AnalyticsService _analyticsService;
  late NotificationService _notificationService;

  // Download management
  final Map<String, ManagedDownload> _activeDownloads = {};
  final Map<String, CompletedDownload> _completedDownloads = {};
  final List<DownloadTask> _downloadQueue = [];

  // Download engine
  late Dio _dio;
  final Map<String, CancelToken> _cancelTokens = {};
  final Map<String, Isolate> _downloadIsolates = {};

  // Network monitoring
  bool _isOnline = true;
  String _connectionType = 'unknown';
  late StreamSubscription _connectivitySubscription;

  // Storage management
  String? _downloadDirectory;
  int _currentStorageUsed = 0;
  int _maxStorageLimit = 0;

  // Settings
  int _maxConcurrentDownloads = AppConstants.maxConcurrentDownloads;
  bool _wifiOnlyDownloads = false;
  bool _autoRetryDownloads = true;
  int _maxRetryAttempts = 3;

  // Event streams
  final StreamController<DownloadEvent> _downloadEventController =
      StreamController<DownloadEvent>.broadcast();

  // Performance tracking
  final Map<String, DownloadPerformance> _performanceMetrics = {};
  Timer? _performanceTimer;

  DownloadManager._() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 1,
        errorMethodCount: 3,
        lineLength: 80,
        colors: true,
        printEmojis: true,
      ),
    );
    _storageService = StorageService.instance;
    _analyticsService = AnalyticsService.instance;
    _notificationService = NotificationService.instance;
  }

  static DownloadManager get instance {
    _instance ??= DownloadManager._();
    return _instance!;
  }

  // Getters
  Stream<DownloadEvent> get downloadEvents => _downloadEventController.stream;
  bool get isOnline => _isOnline;
  String get connectionType => _connectionType;
  int get activeDownloadCount => _activeDownloads.length;
  int get queuedDownloadCount => _downloadQueue.length;
  int get completedDownloadCount => _completedDownloads.length;
  double get storageUsagePercentage => _maxStorageLimit > 0
      ? (_currentStorageUsed / _maxStorageLimit * 100)
      : 0.0;

  // Initialize the manager
  Future<void> initialize() async {
    try {
      _logger.i('Initializing Download Manager...');

      await _setupDownloadDirectory();
      await _loadSettings();
      await _loadCompletedDownloads();
      _setupDio();
      _setupNetworkMonitoring();
      _setupPerformanceTracking();
      await _calculateStorageUsage();

      _logger.i('Download Manager initialized successfully');
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize Download Manager',
          error: e, stackTrace: stackTrace);
      throw DownloadException(
        message: 'Failed to initialize download manager: $e',
        code: 'DOWNLOAD_INIT_ERROR',
        details: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Setup download directory
  Future<void> _setupDownloadDirectory() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      _downloadDirectory = '${appDir.path}/downloads';

      final dir = Directory(_downloadDirectory!);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Create subdirectories
      for (final subDir in ['videos', 'images', 'audio', 'temp']) {
        final directory = Directory('${_downloadDirectory!}/$subDir');
        if (!await directory.exists()) {
          await directory.create();
        }
      }

      _logger.d('Download directory setup: $_downloadDirectory');
    } catch (e) {
      throw DownloadException(
        message: 'Failed to setup download directory: $e',
        code: 'DOWNLOAD_DIR_ERROR',
        details: e,
      );
    }
  }

  // Load settings
  Future<void> _loadSettings() async {
    try {
      _maxConcurrentDownloads = _storageService.getInt(
        'max_concurrent_downloads',
        defaultValue: AppConstants.maxConcurrentDownloads,
      );

      _wifiOnlyDownloads = _storageService.getBool(
        StorageKeys.downloadOnlyOnWifi,
        defaultValue: false,
      );

      _autoRetryDownloads = _storageService.getBool(
        'auto_retry_downloads',
        defaultValue: true,
      );

      _maxRetryAttempts = _storageService.getInt(
        'max_retry_attempts',
        defaultValue: 3,
      );

      _maxStorageLimit = _storageService.getInt(
        'max_download_storage',
        defaultValue: 2 * 1024 * 1024 * 1024, // 2GB
      );

      _logger.d('Download settings loaded');
    } catch (e) {
      _logger.w('Failed to load download settings: $e');
    }
  }

  // Load completed downloads
  Future<void> _loadCompletedDownloads() async {
    try {
      final downloadsJson =
          await _storageService.getUserData<String>('completed_downloads');
      if (downloadsJson != null) {
        final Map<String, dynamic> data = jsonDecode(downloadsJson);

        for (final entry in data.entries) {
          final downloadData = entry.value as Map<String, dynamic>;
          final download = CompletedDownload.fromJson(downloadData);

          // Verify file still exists
          if (await File(download.localPath).exists()) {
            _completedDownloads[entry.key] = download;
          }
        }
      }

      _logger.d('Loaded ${_completedDownloads.length} completed downloads');
    } catch (e) {
      _logger.w('Failed to load completed downloads: $e');
    }
  }

  // Save completed downloads
  Future<void> _saveCompletedDownloads() async {
    try {
      final data = <String, dynamic>{};
      for (final entry in _completedDownloads.entries) {
        data[entry.key] = entry.value.toJson();
      }

      await _storageService.setUserData(
          'completed_downloads', jsonEncode(data));
    } catch (e) {
      _logger.e('Failed to save completed downloads: $e');
    }
  }

  // Setup Dio
  void _setupDio() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 10),
      headers: {
        'User-Agent': 'Onflix/${AppConstants.appVersion}',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        _logger.d('Download request: ${options.uri}');
        handler.next(options);
      },
      onError: (error, handler) {
        _logger.e('Download error: ${error.message}');
        handler.next(error);
      },
    ));
  }

  // Setup network monitoring
  void _setupNetworkMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (ConnectivityResult result) {
        final wasOnline = _isOnline;
        _isOnline = result == ConnectivityResult.wifi ||
            result == ConnectivityResult.mobile ||
            result == ConnectivityResult.ethernet;

        _connectionType = result.toString().split('.').last;

        _handleConnectivityChange(wasOnline, _isOnline);
      },
    );
  }

  // Handle connectivity changes
  void _handleConnectivityChange(bool wasOnline, bool isOnline) {
    if (!wasOnline && isOnline) {
      _logger.i('Network restored, resuming downloads');
      _resumeDownloadsAfterReconnect();
    } else if (wasOnline && !isOnline) {
      _logger.w('Network lost, pausing downloads');
      _pauseAllDownloads();
    }

    // Check WiFi-only restriction
    if (_wifiOnlyDownloads && _connectionType != 'wifi') {
      _pauseAllDownloads();
      _logger.i('WiFi-only mode enabled, pausing downloads on mobile');
    } else if (_wifiOnlyDownloads && _connectionType == 'wifi') {
      _resumeDownloadsAfterReconnect();
      _logger.i('WiFi detected, resuming downloads');
    }
  }

  // Setup performance tracking
  void _setupPerformanceTracking() {
    _performanceTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _updatePerformanceMetrics();
    });
  }

  // Calculate storage usage
  Future<void> _calculateStorageUsage() async {
    try {
      _currentStorageUsed = 0;

      if (_downloadDirectory != null) {
        final dir = Directory(_downloadDirectory!);
        if (await dir.exists()) {
          await for (final entity in dir.list(recursive: true)) {
            if (entity is File) {
              _currentStorageUsed += await entity.length();
            }
          }
        }
      }

      _logger.d('Current storage used: ${_formatBytes(_currentStorageUsed)}');
    } catch (e) {
      _logger.w('Failed to calculate storage usage: $e');
    }
  }

  // Add download to queue
  Future<String> addDownload({
    required String url,
    required String fileName,
    String? contentId,
    String? contentTitle,
    String? contentType,
    String? quality,
    Map<String, String>? headers,
    DownloadPriority priority = DownloadPriority.normal,
  }) async {
    try {
      // Check if already downloaded or downloading
      final existingDownload = _findExistingDownload(url);
      if (existingDownload != null) {
        throw const DownloadException(
          message: 'Download already exists',
          code: 'DOWNLOAD_EXISTS',
        );
      }

      // Check storage space
      await _checkStorageSpace(url);

      // Check network conditions
      if (!_canStartDownload()) {
        throw const DownloadException(
          message: 'Cannot start download due to network restrictions',
          code: 'NETWORK_RESTRICTED',
        );
      }

      // Create download task
      final task = DownloadTask(
        id: _generateDownloadId(),
        url: url,
        fileName: fileName,
        contentId: contentId,
        contentTitle: contentTitle,
        contentType: contentType,
        quality: quality,
        headers: headers,
        priority: priority,
        createdAt: DateTime.now(),
      );

      // Add to queue
      _downloadQueue.add(task);
      _sortQueueByPriority();

      _logger.i('Download added to queue: $fileName');

      // Emit event
      _downloadEventController.add(DownloadEvent(
        type: DownloadEventType.queued,
        downloadId: task.id,
        fileName: fileName,
        url: url,
      ));

      // Start processing queue
      _processDownloadQueue();

      // Track analytics
      _analyticsService.trackEvent('download_queued', {
        'url': url,
        'fileName': fileName,
        'contentType': contentType,
        'quality': quality,
      });

      return task.id;
    } catch (e) {
      _logger.e('Failed to add download: $e');
      rethrow;
    }
  }

  // Process download queue
  Future<void> _processDownloadQueue() async {
    try {
      while (_downloadQueue.isNotEmpty &&
          _activeDownloads.length < _maxConcurrentDownloads &&
          _canStartDownload()) {
        final task = _downloadQueue.removeAt(0);
        await _startDownload(task);
      }
    } catch (e) {
      _logger.e('Failed to process download queue: $e');
    }
  }

  // Start individual download
  Future<void> _startDownload(DownloadTask task) async {
    try {
      // Create managed download
      final managedDownload = ManagedDownload(
        task: task,
        status: DownloadStatus.starting,
        startTime: DateTime.now(),
        localPath:
            '${_downloadDirectory!}/${task.getSubDirectory()}/${task.fileName}',
      );

      _activeDownloads[task.id] = managedDownload;

      // Create cancel token
      final cancelToken = CancelToken();
      _cancelTokens[task.id] = cancelToken;

      // Emit started event
      _downloadEventController.add(DownloadEvent(
        type: DownloadEventType.started,
        downloadId: task.id,
        fileName: task.fileName,
        url: task.url,
      ));

      // Start download in isolate for better performance
      await _downloadInIsolate(managedDownload, cancelToken);
    } catch (e) {
      _logger.e('Failed to start download: $e');
      await _handleDownloadError(task.id, e);
    }
  }

  // Download in isolate
  Future<void> _downloadInIsolate(
      ManagedDownload download, CancelToken cancelToken) async {
    try {
      final receivePort = ReceivePort();
      final isolate = await Isolate.spawn(
        _downloadWorker,
        IsolateData(
          sendPort: receivePort.sendPort,
          url: download.task.url,
          localPath: download.localPath,
          headers: download.task.headers,
        ),
      );

      _downloadIsolates[download.task.id] = isolate;

      // Listen for progress updates
      receivePort.listen((message) {
        if (message is DownloadProgress) {
          _handleDownloadProgress(download.task.id, message);
        } else if (message is DownloadComplete) {
          _handleDownloadComplete(download.task.id, message);
        } else if (message is DownloadError) {
          _handleDownloadError(
              download.task.id,
              DownloadException(
                message: message.error,
                code: 'DOWNLOAD_ERROR',
              ));
        }
      });

      download.status = DownloadStatus.downloading;
    } catch (e) {
      _logger.e('Failed to start download isolate: $e');
      await _handleDownloadError(download.task.id, e);
    }
  }

  // Download worker (runs in isolate)
  static void _downloadWorker(IsolateData data) async {
    try {
      final dio = Dio();
      final file = File(data.localPath);

      // Ensure directory exists
      await file.parent.create(recursive: true);

      await dio.download(
        data.url,
        data.localPath,
        options: Options(headers: data.headers),
        onReceiveProgress: (received, total) {
          data.sendPort.send(DownloadProgress(
            received: received,
            total: total,
            percentage: total > 0 ? (received / total * 100).round() : 0,
          ));
        },
      );

      data.sendPort.send(DownloadComplete(
        localPath: data.localPath,
        fileSize: await file.length(),
      ));
    } catch (e) {
      data.sendPort.send(DownloadError(error: e.toString()));
    }
  }

  // Handle download progress
  void _handleDownloadProgress(String downloadId, DownloadProgress progress) {
    try {
      final download = _activeDownloads[downloadId];
      if (download == null) return;

      download.progress = progress.percentage;
      download.downloadedBytes = progress.received;
      download.totalBytes = progress.total;
      download.lastActivity = DateTime.now();

      // Calculate speed
      if (download.startTime != null) {
        final elapsed = DateTime.now().difference(download.startTime!);
        if (elapsed.inSeconds > 0) {
          download.downloadSpeed = progress.received / elapsed.inSeconds;
        }
      }

      // Emit progress event
      _downloadEventController.add(DownloadEvent(
        type: DownloadEventType.progress,
        downloadId: downloadId,
        fileName: download.task.fileName,
        url: download.task.url,
        progress: progress.percentage,
        downloadedBytes: progress.received,
        totalBytes: progress.total,
        speed: download.downloadSpeed,
      ));

      // Update performance metrics
      _updateDownloadPerformance(downloadId, progress);
    } catch (e) {
      _logger.e('Failed to handle download progress: $e');
    }
  }

  // Handle download completion
  void _handleDownloadComplete(
      String downloadId, DownloadComplete completion) async {
    try {
      final download = _activeDownloads.remove(downloadId);
      if (download == null) return;

      // Cleanup
      _cancelTokens.remove(downloadId);
      final isolate = _downloadIsolates.remove(downloadId);
      isolate?.kill();

      // Verify download
      final file = File(completion.localPath);
      if (!await file.exists()) {
        throw DownloadException.fileCorrupted();
      }

      // Create completed download
      final completedDownload = CompletedDownload(
        id: downloadId,
        url: download.task.url,
        fileName: download.task.fileName,
        localPath: completion.localPath,
        fileSize: completion.fileSize,
        contentId: download.task.contentId,
        contentTitle: download.task.contentTitle,
        contentType: download.task.contentType,
        quality: download.task.quality,
        downloadedAt: DateTime.now(),
      );

      _completedDownloads[downloadId] = completedDownload;
      await _saveCompletedDownloads();

      // Update storage usage
      _currentStorageUsed += completion.fileSize;

      // Emit completed event
      _downloadEventController.add(DownloadEvent(
        type: DownloadEventType.completed,
        downloadId: downloadId,
        fileName: download.task.fileName,
        url: download.task.url,
        localPath: completion.localPath,
      ));

      // Send notification
      await _notificationService.sendDownloadCompleteNotification(
        contentTitle: download.task.contentTitle ?? download.task.fileName,
        quality: download.task.quality ?? 'Unknown',
      );

      // Track analytics
      _analyticsService.trackDownload(
        download.task.contentId ?? downloadId,
        download.task.quality ?? 'unknown',
        completion.fileSize,
      );

      _logger.i('Download completed: ${download.task.fileName}');

      // Continue processing queue
      _processDownloadQueue();
    } catch (e) {
      _logger.e('Failed to handle download completion: $e');
      await _handleDownloadError(downloadId, e);
    }
  }

  // Handle download error
  Future<void> _handleDownloadError(String downloadId, dynamic error) async {
    try {
      final download = _activeDownloads[downloadId];
      if (download == null) return;

      download.status = DownloadStatus.failed;
      download.error = error.toString();
      download.endTime = DateTime.now();

      // Cleanup
      _cancelTokens.remove(downloadId);
      final isolate = _downloadIsolates.remove(downloadId);
      isolate?.kill();

      // Clean up partial file
      try {
        final file = File(download.localPath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        _logger.w('Failed to clean up partial file: $e');
      }

      // Check if should retry
      if (_autoRetryDownloads && download.retryCount < _maxRetryAttempts) {
        download.retryCount++;
        download.status = DownloadStatus.retrying;

        _logger.w(
            'Retrying download (${download.retryCount}/$_maxRetryAttempts): ${download.task.fileName}');

        // Add back to queue with delay
        Timer(Duration(seconds: download.retryCount * 5), () {
          _downloadQueue.insert(0, download.task); // Priority retry
          _processDownloadQueue();
        });

        _downloadEventController.add(DownloadEvent(
          type: DownloadEventType.retrying,
          downloadId: downloadId,
          fileName: download.task.fileName,
          url: download.task.url,
          retryCount: download.retryCount,
        ));
      } else {
        // Final failure
        _activeDownloads.remove(downloadId);

        _downloadEventController.add(DownloadEvent(
          type: DownloadEventType.failed,
          downloadId: downloadId,
          fileName: download.task.fileName,
          url: download.task.url,
          error: error.toString(),
        ));

        _analyticsService.trackError('download_failed', error.toString(),
            context: download.task.fileName);
      }

      // Continue processing queue
      _processDownloadQueue();
    } catch (e) {
      _logger.e('Failed to handle download error: $e');
    }
  }

  // Pause download
  Future<void> pauseDownload(String downloadId) async {
    try {
      final download = _activeDownloads[downloadId];
      if (download == null) return;

      // Cancel download
      final cancelToken = _cancelTokens.remove(downloadId);
      cancelToken?.cancel('Download paused');

      // Kill isolate
      final isolate = _downloadIsolates.remove(downloadId);
      isolate?.kill();

      download.status = DownloadStatus.paused;

      _downloadEventController.add(DownloadEvent(
        type: DownloadEventType.paused,
        downloadId: downloadId,
        fileName: download.task.fileName,
        url: download.task.url,
      ));

      _logger.i('Download paused: ${download.task.fileName}');
    } catch (e) {
      _logger.e('Failed to pause download: $e');
    }
  }

  // Resume download
  Future<void> resumeDownload(String downloadId) async {
    try {
      final download = _activeDownloads[downloadId];
      if (download?.status != DownloadStatus.paused) return;

      if (!_canStartDownload()) {
        throw const DownloadException(
          message: 'Cannot resume download due to network restrictions',
          code: 'NETWORK_RESTRICTED',
        );
      }

      // Check concurrent limit
      final activeCount = _activeDownloads.values
          .where((d) => d.status == DownloadStatus.downloading)
          .length;

      if (activeCount >= _maxConcurrentDownloads) {
        // Add back to queue
        _downloadQueue.insert(0, download!.task);
        _activeDownloads.remove(downloadId);
      } else {
        // Resume immediately
        await _startDownload(download!.task);
      }

      _logger.i('Download resumed: ${download.task.fileName}');
    } catch (e) {
      _logger.e('Failed to resume download: $e');
    }
  }

  // Cancel download
  Future<void> cancelDownload(String downloadId) async {
    try {
      // Remove from active downloads
      final download = _activeDownloads.remove(downloadId);

      // Remove from queue
      _downloadQueue.removeWhere((task) => task.id == downloadId);

      // Cancel token
      final cancelToken = _cancelTokens.remove(downloadId);
      cancelToken?.cancel('Download cancelled');

      // Kill isolate
      final isolate = _downloadIsolates.remove(downloadId);
      isolate?.kill();

      // Clean up partial file
      if (download != null) {
        try {
          final file = File(download.localPath);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          _logger.w('Failed to clean up cancelled download file: $e');
        }

        _downloadEventController.add(DownloadEvent(
          type: DownloadEventType.cancelled,
          downloadId: downloadId,
          fileName: download.task.fileName,
          url: download.task.url,
        ));
      }

      _logger.i('Download cancelled: $downloadId');

      // Continue processing queue
      _processDownloadQueue();
    } catch (e) {
      _logger.e('Failed to cancel download: $e');
    }
  }

  // Delete completed download
  Future<void> deleteDownload(String downloadId) async {
    try {
      final download = _completedDownloads.remove(downloadId);
      if (download == null) {
        throw const DownloadException(
          message: 'Download not found',
          code: 'DOWNLOAD_NOT_FOUND',
        );
      }

      // Delete file
      final file = File(download.localPath);
      if (await file.exists()) {
        final fileSize = await file.length();
        await file.delete();
        _currentStorageUsed -= fileSize;
      }

      await _saveCompletedDownloads();

      _downloadEventController.add(DownloadEvent(
        type: DownloadEventType.deleted,
        downloadId: downloadId,
        fileName: download.fileName,
        url: download.url,
      ));

      _logger.i('Download deleted: ${download.fileName}');
    } catch (e) {
      _logger.e('Failed to delete download: $e');
      rethrow;
    }
  }

  // Utility methods
  bool _canStartDownload() {
    if (!_isOnline) return false;
    if (_wifiOnlyDownloads && _connectionType != 'wifi') return false;
    return true;
  }

  String? _findExistingDownload(String url) {
    // Check active downloads
    for (final download in _activeDownloads.values) {
      if (download.task.url == url) return download.task.id;
    }

    // Check queue
    for (final task in _downloadQueue) {
      if (task.url == url) return task.id;
    }

    // Check completed downloads
    for (final download in _completedDownloads.values) {
      if (download.url == url) return download.id;
    }

    return null;
  }

  Future<void> _checkStorageSpace(String url) async {
    try {
      // Get content length
      final response = await _dio.head(url);
      final contentLength = response.headers.value('content-length');
      final fileSize = int.tryParse(contentLength ?? '0') ?? 0;

      if (_currentStorageUsed + fileSize > _maxStorageLimit) {
        throw DownloadException.insufficientStorage();
      }
    } catch (e) {
      if (e is DownloadException) rethrow;
      _logger.w('Could not check storage space: $e');
      // Continue without size check
    }
  }

  void _sortQueueByPriority() {
    _downloadQueue.sort((a, b) {
      final priorityCompare = b.priority.index.compareTo(a.priority.index);
      if (priorityCompare != 0) return priorityCompare;
      return a.createdAt.compareTo(b.createdAt);
    });
  }

  void _pauseAllDownloads() {
    for (final downloadId in _activeDownloads.keys.toList()) {
      pauseDownload(downloadId);
    }
  }

  void _resumeDownloadsAfterReconnect() {
    Future.delayed(const Duration(seconds: 2), () {
      for (final download in _activeDownloads.values) {
        if (download.status == DownloadStatus.paused) {
          resumeDownload(download.task.id);
        }
      }
    });
  }

  void _updatePerformanceMetrics() {
    for (final entry in _activeDownloads.entries) {
      final downloadId = entry.key;
      final download = entry.value;

      if (download.status == DownloadStatus.downloading &&
          download.downloadSpeed > 0) {
        final performance = _performanceMetrics.putIfAbsent(
          downloadId,
          () => DownloadPerformance(),
        );

        performance.addSample(download.downloadSpeed);
      }
    }
  }

  void _updateDownloadPerformance(
      String downloadId, DownloadProgress progress) {
    final performance = _performanceMetrics.putIfAbsent(
      downloadId,
      () => DownloadPerformance(),
    );

    final download = _activeDownloads[downloadId];
    if (download?.downloadSpeed != null) {
      performance.addSample(download!.downloadSpeed);
    }
  }

  String _generateDownloadId() {
    return 'dl_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var size = bytes.toDouble();
    var suffixIndex = 0;

    while (size >= 1024 && suffixIndex < suffixes.length - 1) {
      size /= 1024;
      suffixIndex++;
    }

    return '${size.toStringAsFixed(1)} ${suffixes[suffixIndex]}';
  }

  // Public getters
  List<ManagedDownload> getActiveDownloads() =>
      _activeDownloads.values.toList();
  List<CompletedDownload> getCompletedDownloads() =>
      _completedDownloads.values.toList();
  List<DownloadTask> getQueuedDownloads() => List.from(_downloadQueue);

  ManagedDownload? getActiveDownload(String downloadId) =>
      _activeDownloads[downloadId];
  CompletedDownload? getCompletedDownload(String downloadId) =>
      _completedDownloads[downloadId];

  // Settings
  Future<void> updateSettings({
    int? maxConcurrentDownloads,
    bool? wifiOnlyDownloads,
    bool? autoRetryDownloads,
    int? maxRetryAttempts,
    int? maxStorageLimit,
  }) async {
    if (maxConcurrentDownloads != null) {
      _maxConcurrentDownloads = maxConcurrentDownloads;
      await _storageService.setInt(
          'max_concurrent_downloads', maxConcurrentDownloads);
    }

    if (wifiOnlyDownloads != null) {
      _wifiOnlyDownloads = wifiOnlyDownloads;
      await _storageService.setBool(
          StorageKeys.downloadOnlyOnWifi, wifiOnlyDownloads);
    }

    if (autoRetryDownloads != null) {
      _autoRetryDownloads = autoRetryDownloads;
      await _storageService.setBool('auto_retry_downloads', autoRetryDownloads);
    }

    if (maxRetryAttempts != null) {
      _maxRetryAttempts = maxRetryAttempts;
      await _storageService.setInt('max_retry_attempts', maxRetryAttempts);
    }

    if (maxStorageLimit != null) {
      _maxStorageLimit = maxStorageLimit;
      await _storageService.setInt('max_download_storage', maxStorageLimit);
    }

    _logger.i('Download settings updated');
  }

  // Statistics
  Map<String, dynamic> getDownloadStatistics() {
    final stats = <String, dynamic>{
      'active_downloads': _activeDownloads.length,
      'queued_downloads': _downloadQueue.length,
      'completed_downloads': _completedDownloads.length,
      'storage_used': _currentStorageUsed,
      'storage_limit': _maxStorageLimit,
      'storage_usage_percentage': storageUsagePercentage,
      'is_online': _isOnline,
      'connection_type': _connectionType,
      'wifi_only_enabled': _wifiOnlyDownloads,
      'max_concurrent_downloads': _maxConcurrentDownloads,
    };

    // Add performance metrics
    double totalSpeed = 0;
    int activeCount = 0;

    for (final download in _activeDownloads.values) {
      if (download.status == DownloadStatus.downloading &&
          download.downloadSpeed > 0) {
        totalSpeed += download.downloadSpeed;
        activeCount++;
      }
    }

    stats['average_download_speed'] =
        activeCount > 0 ? totalSpeed / activeCount : 0;
    stats['total_download_speed'] = totalSpeed;

    return stats;
  }

  // Dispose resources
  void dispose() {
    _performanceTimer?.cancel();
    _connectivitySubscription.cancel();
    _downloadEventController.close();

    // Cancel all active downloads
    for (final downloadId in _activeDownloads.keys.toList()) {
      cancelDownload(downloadId);
    }
  }
}

// Enums and Models
enum DownloadStatus {
  queued,
  starting,
  downloading,
  paused,
  retrying,
  completed,
  failed,
  cancelled,
}

enum DownloadPriority {
  low,
  normal,
  high,
  urgent,
}

enum DownloadEventType {
  queued,
  started,
  progress,
  paused,
  resumed,
  retrying,
  completed,
  failed,
  cancelled,
  deleted,
}

// Data classes
class DownloadTask {
  final String id;
  final String url;
  final String fileName;
  final String? contentId;
  final String? contentTitle;
  final String? contentType;
  final String? quality;
  final Map<String, String>? headers;
  final DownloadPriority priority;
  final DateTime createdAt;

  DownloadTask({
    required this.id,
    required this.url,
    required this.fileName,
    this.contentId,
    this.contentTitle,
    this.contentType,
    this.quality,
    this.headers,
    required this.priority,
    required this.createdAt,
  });

  String getSubDirectory() {
    if (contentType?.toLowerCase().contains('video') == true) return 'videos';
    if (contentType?.toLowerCase().contains('audio') == true) return 'audio';
    if (contentType?.toLowerCase().contains('image') == true) return 'images';
    return 'temp';
  }
}

class ManagedDownload {
  final DownloadTask task;
  DownloadStatus status;
  final DateTime? startTime;
  DateTime? endTime;
  DateTime? lastActivity;
  final String localPath;

  int progress = 0;
  int downloadedBytes = 0;
  int totalBytes = 0;
  double downloadSpeed = 0;
  int retryCount = 0;
  String? error;

  ManagedDownload({
    required this.task,
    required this.status,
    this.startTime,
    this.endTime,
    this.lastActivity,
    required this.localPath,
  });

  Duration? get duration => startTime != null
      ? (endTime ?? DateTime.now()).difference(startTime!)
      : null;

  String get formattedSpeed => _formatSpeed(downloadSpeed);
  String get formattedProgress => '$progress%';
  String get formattedDownloaded => _formatBytes(downloadedBytes);
  String get formattedTotal =>
      totalBytes > 0 ? _formatBytes(totalBytes) : 'Unknown';

  static String _formatSpeed(double bytesPerSecond) {
    if (bytesPerSecond <= 0) return '0 B/s';
    const suffixes = ['B/s', 'KB/s', 'MB/s', 'GB/s'];
    var speed = bytesPerSecond;
    var suffixIndex = 0;

    while (speed >= 1024 && suffixIndex < suffixes.length - 1) {
      speed /= 1024;
      suffixIndex++;
    }

    return '${speed.toStringAsFixed(1)} ${suffixes[suffixIndex]}';
  }

  static String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var size = bytes.toDouble();
    var suffixIndex = 0;

    while (size >= 1024 && suffixIndex < suffixes.length - 1) {
      size /= 1024;
      suffixIndex++;
    }

    return '${size.toStringAsFixed(1)} ${suffixes[suffixIndex]}';
  }
}

class CompletedDownload {
  final String id;
  final String url;
  final String fileName;
  final String localPath;
  final int fileSize;
  final String? contentId;
  final String? contentTitle;
  final String? contentType;
  final String? quality;
  final DateTime downloadedAt;

  CompletedDownload({
    required this.id,
    required this.url,
    required this.fileName,
    required this.localPath,
    required this.fileSize,
    this.contentId,
    this.contentTitle,
    this.contentType,
    this.quality,
    required this.downloadedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'fileName': fileName,
        'localPath': localPath,
        'fileSize': fileSize,
        'contentId': contentId,
        'contentTitle': contentTitle,
        'contentType': contentType,
        'quality': quality,
        'downloadedAt': downloadedAt.toIso8601String(),
      };

  factory CompletedDownload.fromJson(Map<String, dynamic> json) =>
      CompletedDownload(
        id: json['id'],
        url: json['url'],
        fileName: json['fileName'],
        localPath: json['localPath'],
        fileSize: json['fileSize'],
        contentId: json['contentId'],
        contentTitle: json['contentTitle'],
        contentType: json['contentType'],
        quality: json['quality'],
        downloadedAt: DateTime.parse(json['downloadedAt']),
      );

  String get formattedSize => _formatBytes(fileSize);

  static String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var size = bytes.toDouble();
    var suffixIndex = 0;

    while (size >= 1024 && suffixIndex < suffixes.length - 1) {
      size /= 1024;
      suffixIndex++;
    }

    return '${size.toStringAsFixed(1)} ${suffixes[suffixIndex]}';
  }
}

class DownloadEvent {
  final DownloadEventType type;
  final String downloadId;
  final String fileName;
  final String url;
  final int? progress;
  final int? downloadedBytes;
  final int? totalBytes;
  final double? speed;
  final String? localPath;
  final String? error;
  final int? retryCount;

  DownloadEvent({
    required this.type,
    required this.downloadId,
    required this.fileName,
    required this.url,
    this.progress,
    this.downloadedBytes,
    this.totalBytes,
    this.speed,
    this.localPath,
    this.error,
    this.retryCount,
  });
}

class DownloadPerformance {
  final List<double> _speedSamples = [];
  final int _maxSamples = 10;

  void addSample(double speed) {
    _speedSamples.add(speed);
    if (_speedSamples.length > _maxSamples) {
      _speedSamples.removeAt(0);
    }
  }

  double get averageSpeed {
    if (_speedSamples.isEmpty) return 0;
    return _speedSamples.reduce((a, b) => a + b) / _speedSamples.length;
  }

  double get maxSpeed {
    if (_speedSamples.isEmpty) return 0;
    return _speedSamples.reduce((a, b) => a > b ? a : b);
  }
}

// Isolate data classes
class IsolateData {
  final SendPort sendPort;
  final String url;
  final String localPath;
  final Map<String, String>? headers;

  IsolateData({
    required this.sendPort,
    required this.url,
    required this.localPath,
    this.headers,
  });
}

class DownloadProgress {
  final int received;
  final int total;
  final int percentage;

  DownloadProgress({
    required this.received,
    required this.total,
    required this.percentage,
  });
}

class DownloadComplete {
  final String localPath;
  final int fileSize;

  DownloadComplete({
    required this.localPath,
    required this.fileSize,
  });
}

class DownloadError {
  final String error;

  DownloadError({required this.error});
}
