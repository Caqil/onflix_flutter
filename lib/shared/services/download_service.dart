import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:onflix/core/constants/app_constants.dart';
import 'package:onflix/core/errors/exceptions.dart';
import 'package:onflix/core/network/pocketbase_client.dart';
import 'package:onflix/core/utils/helpers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';


class DownloadService {
  static DownloadService? _instance;
  late Logger _logger;
  late SharedPreferences _prefs;
  late PocketBaseClient _pbClient;
  late Dio _dio;

  // Download management
  final Map<String, DownloadTask> _activeDownloads = {};
  final Map<String, DownloadItem> _downloadedItems = {};
  final StreamController<DownloadEvent> _downloadEventController =
      StreamController<DownloadEvent>.broadcast();

  // Storage management
  String? _downloadDirectory;
  int _totalDownloadSize = 0;
  int _maxStorageSize = 0;

  // Download queue
  final List<DownloadRequest> _downloadQueue = [];
  bool _isProcessingQueue = false;
  int _maxConcurrentDownloads = AppConstants.maxConcurrentDownloads;

  DownloadService._() {
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
    _dio = Dio();
  }

  static DownloadService get instance {
    _instance ??= DownloadService._();
    return _instance!;
  }

  // Stream for download events
  Stream<DownloadEvent> get downloadEvents => _downloadEventController.stream;

  // Initialize the service
  Future<void> initialize() async {
    try {
      _logger.i('Initializing Download Service...');

      _prefs = await SharedPreferences.getInstance();
      await _setupDownloadDirectory();
      await _loadDownloadSettings();
      await _loadDownloadedItems();
      _setupDio();

      _logger.i('Download Service initialized successfully');
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize Download Service',
          error: e, stackTrace: stackTrace);
      throw DownloadException(
        message: 'Failed to initialize download service: $e',
        code: 'INITIALIZATION_ERROR',
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

      _logger.d('Download directory: $_downloadDirectory');
    } catch (e) {
      throw DownloadException(
        message: 'Failed to setup download directory: $e',
        code: 'DIRECTORY_SETUP_ERROR',
        details: e,
      );
    }
  }

  // Load download settings
  Future<void> _loadDownloadSettings() async {
    _maxStorageSize = _prefs.getInt('max_download_storage') ??
        (2 * 1024 * 1024 * 1024); // 2GB default
    _maxConcurrentDownloads = _prefs.getInt('max_concurrent_downloads') ??
        AppConstants.maxConcurrentDownloads;
  }

  // Load previously downloaded items
  Future<void> _loadDownloadedItems() async {
    try {
      final downloadedJson = _prefs.getString('downloaded_items');
      if (downloadedJson != null) {
        final Map<String, dynamic> data = jsonDecode(downloadedJson);

        for (final entry in data.entries) {
          final itemData = entry.value as Map<String, dynamic>;
          final item = DownloadItem.fromJson(itemData);

          // Verify file still exists
          final file = File(item.filePath);
          if (await file.exists()) {
            _downloadedItems[entry.key] = item;
            _totalDownloadSize += item.fileSize;
          }
        }
      }

      _logger.d('Loaded ${_downloadedItems.length} downloaded items');
    } catch (e) {
      _logger.w('Failed to load downloaded items: $e');
      _downloadedItems.clear();
    }
  }

  // Save downloaded items to storage
  Future<void> _saveDownloadedItems() async {
    try {
      final data = <String, dynamic>{};
      for (final entry in _downloadedItems.entries) {
        data[entry.key] = entry.value.toJson();
      }

      await _prefs.setString('downloaded_items', jsonEncode(data));
    } catch (e) {
      _logger.e('Failed to save downloaded items: $e');
    }
  }

  // Setup Dio for downloads
  void _setupDio() {
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(minutes: 10);
  }

  // Add download to queue
  Future<String> downloadContent({
    required String contentId,
    required String title,
    required String contentType,
    required String quality,
    required String downloadUrl,
    String? thumbnailUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Check if already downloaded
      if (_downloadedItems.containsKey(contentId)) {
        throw const DownloadException(
          message: 'Content already downloaded',
          code: 'ALREADY_DOWNLOADED',
        );
      }

      // Check if already in queue or downloading
      if (_activeDownloads.containsKey(contentId) ||
          _downloadQueue.any((r) => r.contentId == contentId)) {
        throw const DownloadException(
          message: 'Download already in progress',
          code: 'DOWNLOAD_IN_PROGRESS',
        );
      }

      // Check download limit
      if (_downloadedItems.length >= AppConstants.maxDownloads) {
        throw DownloadException.downloadLimitReached();
      }

      // Create download request
      final request = DownloadRequest(
        id: Helpers.generateId(),
        contentId: contentId,
        title: title,
        contentType: contentType,
        quality: quality,
        downloadUrl: downloadUrl,
        thumbnailUrl: thumbnailUrl,
        metadata: metadata,
        requestTime: DateTime.now(),
      );

      _downloadQueue.add(request);
      _logger.i('Added download to queue: $title');

      // Process queue
      _processDownloadQueue();

      // Emit event
      _downloadEventController.add(DownloadEvent(
        type: DownloadEventType.queued,
        contentId: contentId,
        title: title,
      ));

      return request.id;
    } catch (e) {
      _logger.e('Failed to add download: $e');
      rethrow;
    }
  }

  // Process download queue
  Future<void> _processDownloadQueue() async {
    if (_isProcessingQueue) return;
    _isProcessingQueue = true;

    try {
      while (_downloadQueue.isNotEmpty &&
          _activeDownloads.length < _maxConcurrentDownloads) {
        final request = _downloadQueue.removeAt(0);
        await _startDownload(request);
      }
    } finally {
      _isProcessingQueue = false;
    }
  }

  // Start individual download
  Future<void> _startDownload(DownloadRequest request) async {
    try {
      // Check storage space
      await _checkStorageSpace(request.downloadUrl);

      // Create download task
      final task = DownloadTask(
        id: request.id,
        contentId: request.contentId,
        title: request.title,
        contentType: request.contentType,
        quality: request.quality,
        downloadUrl: request.downloadUrl,
        thumbnailUrl: request.thumbnailUrl,
        metadata: request.metadata,
        status: DownloadStatus.downloading,
        startTime: DateTime.now(),
      );

      _activeDownloads[request.contentId] = task;

      // Emit started event
      _downloadEventController.add(DownloadEvent(
        type: DownloadEventType.started,
        contentId: request.contentId,
        title: request.title,
      ));

      // Start download in isolate for better performance
      await _downloadFile(task);
    } catch (e) {
      _logger.e('Failed to start download: $e');
      await _handleDownloadError(request.contentId, e);
    }
  }

  // Download file
  Future<void> _downloadFile(DownloadTask task) async {
    try {
      final fileName = _generateFileName(task.contentId, task.quality);
      final filePath = '$_downloadDirectory/$fileName';

      task.filePath = filePath;

      // Download with progress tracking
      await _dio.download(
        task.downloadUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).round();
            task.progress = progress;
            task.downloadedBytes = received;
            task.totalBytes = total;

            _downloadEventController.add(DownloadEvent(
              type: DownloadEventType.progress,
              contentId: task.contentId,
              title: task.title,
              progress: progress,
              downloadedBytes: received,
              totalBytes: total,
            ));
          }
        },
        cancelToken: task.cancelToken,
      );

      // Download thumbnail if available
      if (task.thumbnailUrl != null) {
        await _downloadThumbnail(task);
      }

      // Verify download
      await _verifyDownload(task);

      // Create download item
      final downloadItem = DownloadItem(
        contentId: task.contentId,
        title: task.title,
        contentType: task.contentType,
        quality: task.quality,
        filePath: task.filePath!,
        thumbnailPath: task.thumbnailPath,
        fileSize: task.totalBytes ?? 0,
        downloadDate: DateTime.now(),
        metadata: task.metadata,
      );

      // Save to downloaded items
      _downloadedItems[task.contentId] = downloadItem;
      _totalDownloadSize += downloadItem.fileSize;
      await _saveDownloadedItems();

      // Update task status
      task.status = DownloadStatus.completed;
      task.endTime = DateTime.now();

      // Emit completed event
      _downloadEventController.add(DownloadEvent(
        type: DownloadEventType.completed,
        contentId: task.contentId,
        title: task.title,
      ));

      _logger.i('Download completed: ${task.title}');
    } catch (e) {
      await _handleDownloadError(task.contentId, e);
    } finally {
      _activeDownloads.remove(task.contentId);
      _processDownloadQueue(); // Process next in queue
    }
  }

  // Download thumbnail
  Future<void> _downloadThumbnail(DownloadTask task) async {
    try {
      if (task.thumbnailUrl == null) return;

      final thumbnailName = '${task.contentId}_thumb.jpg';
      final thumbnailPath = '$_downloadDirectory/$thumbnailName';

      await _dio.download(task.thumbnailUrl!, thumbnailPath);
      task.thumbnailPath = thumbnailPath;

      _logger.d('Thumbnail downloaded: $thumbnailName');
    } catch (e) {
      _logger.w('Failed to download thumbnail: $e');
      // Don't fail the entire download for thumbnail errors
    }
  }

  // Verify download integrity
  Future<void> _verifyDownload(DownloadTask task) async {
    try {
      final file = File(task.filePath!);

      if (!await file.exists()) {
        throw DownloadException.fileCorrupted();
      }

      final fileSize = await file.length();
      if (task.totalBytes != null && fileSize != task.totalBytes) {
        throw DownloadException.fileCorrupted();
      }

      // Additional verification can be added here (checksums, etc.)

      _logger.d('Download verification passed: ${task.title}');
    } catch (e) {
      _logger.e('Download verification failed: $e');
      throw DownloadException.fileCorrupted();
    }
  }

  // Handle download errors
  Future<void> _handleDownloadError(String contentId, dynamic error) async {
    final task = _activeDownloads[contentId];
    if (task != null) {
      task.status = DownloadStatus.failed;
      task.error = error.toString();
      task.endTime = DateTime.now();

      // Clean up partial file
      if (task.filePath != null) {
        try {
          final file = File(task.filePath!);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          _logger.w('Failed to clean up partial file: $e');
        }
      }

      _downloadEventController.add(DownloadEvent(
        type: DownloadEventType.failed,
        contentId: contentId,
        title: task.title,
        error: error.toString(),
      ));

      _activeDownloads.remove(contentId);
    }

    _logger.e('Download failed for $contentId: $error');
  }

  // Check available storage space
  Future<void> _checkStorageSpace(String downloadUrl) async {
    try {
      // Get file size from server
      final response = await _dio.head(downloadUrl);
      final contentLength = response.headers.value('content-length');
      final fileSize = int.tryParse(contentLength ?? '0') ?? 0;

      // Check if we have enough space
      if (_totalDownloadSize + fileSize > _maxStorageSize) {
        throw DownloadException.insufficientStorage();
      }
    } catch (e) {
      if (e is DownloadException) rethrow;

      _logger.w('Failed to check storage space: $e');
      // Continue with download if we can't check
    }
  }

  // Generate unique file name
  String _generateFileName(String contentId, String quality) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final hash = sha256.convert(utf8.encode('$contentId$quality')).toString();
    return '${contentId}_${quality}_${timestamp}_${hash.substring(0, 8)}.mp4';
  }

  // Cancel download
  Future<void> cancelDownload(String contentId) async {
    try {
      final task = _activeDownloads[contentId];
      if (task != null) {
        task.cancelToken.cancel('User cancelled download');
        task.status = DownloadStatus.cancelled;

        _downloadEventController.add(DownloadEvent(
          type: DownloadEventType.cancelled,
          contentId: contentId,
          title: task.title,
        ));

        _logger.i('Download cancelled: ${task.title}');
      }

      // Remove from queue if not started
      _downloadQueue.removeWhere((r) => r.contentId == contentId);
    } catch (e) {
      _logger.e('Failed to cancel download: $e');
    }
  }

  // Pause download (by cancelling and re-queuing)
  Future<void> pauseDownload(String contentId) async {
    try {
      final task = _activeDownloads[contentId];
      if (task != null) {
        task.cancelToken.cancel('Download paused');
        task.status = DownloadStatus.paused;

        // Create resume request
        final resumeRequest = DownloadRequest(
          id: task.id,
          contentId: task.contentId,
          title: task.title,
          contentType: task.contentType,
          quality: task.quality,
          downloadUrl: task.downloadUrl,
          thumbnailUrl: task.thumbnailUrl,
          metadata: task.metadata,
          requestTime: DateTime.now(),
        );

        _downloadQueue.insert(0, resumeRequest); // Add to front of queue

        _downloadEventController.add(DownloadEvent(
          type: DownloadEventType.paused,
          contentId: contentId,
          title: task.title,
        ));

        _logger.i('Download paused: ${task.title}');
      }
    } catch (e) {
      _logger.e('Failed to pause download: $e');
    }
  }

  // Resume download
  Future<void> resumeDownload(String contentId) async {
    try {
      _processDownloadQueue();

      _downloadEventController.add(DownloadEvent(
        type: DownloadEventType.resumed,
        contentId: contentId,
        title: getDownloadedItem(contentId)?.title ?? 'Unknown',
      ));

      _logger.i('Download resumed: $contentId');
    } catch (e) {
      _logger.e('Failed to resume download: $e');
    }
  }

  // Delete downloaded content
  Future<void> deleteDownload(String contentId) async {
    try {
      final item = _downloadedItems[contentId];
      if (item == null) {
        throw const DownloadException(
          message: 'Downloaded content not found',
          code: 'NOT_FOUND',
        );
      }

      // Delete files
      await _deleteDownloadFiles(item);

      // Remove from downloaded items
      _downloadedItems.remove(contentId);
      _totalDownloadSize -= item.fileSize;
      await _saveDownloadedItems();

      _downloadEventController.add(DownloadEvent(
        type: DownloadEventType.deleted,
        contentId: contentId,
        title: item.title,
      ));

      _logger.i('Download deleted: ${item.title}');
    } catch (e) {
      _logger.e('Failed to delete download: $e');
      rethrow;
    }
  }

  // Delete download files
  Future<void> _deleteDownloadFiles(DownloadItem item) async {
    try {
      // Delete main file
      final file = File(item.filePath);
      if (await file.exists()) {
        await file.delete();
      }

      // Delete thumbnail
      if (item.thumbnailPath != null) {
        final thumbFile = File(item.thumbnailPath!);
        if (await thumbFile.exists()) {
          await thumbFile.delete();
        }
      }
    } catch (e) {
      _logger.w('Failed to delete files for ${item.title}: $e');
    }
  }

  // Get downloaded item
  DownloadItem? getDownloadedItem(String contentId) {
    return _downloadedItems[contentId];
  }

  // Get all downloaded items
  List<DownloadItem> getAllDownloadedItems() {
    return _downloadedItems.values.toList();
  }

  // Get active downloads
  List<DownloadTask> getActiveDownloads() {
    return _activeDownloads.values.toList();
  }

  // Get download queue
  List<DownloadRequest> getDownloadQueue() {
    return List.from(_downloadQueue);
  }

  // Check if content is downloaded
  bool isContentDownloaded(String contentId) {
    return _downloadedItems.containsKey(contentId);
  }

  // Get download status
  DownloadStatus? getDownloadStatus(String contentId) {
    final task = _activeDownloads[contentId];
    if (task != null) return task.status;

    if (_downloadedItems.containsKey(contentId)) {
      return DownloadStatus.completed;
    }

    if (_downloadQueue.any((r) => r.contentId == contentId)) {
      return DownloadStatus.queued;
    }

    return null;
  }

  // Get storage info
  Map<String, dynamic> getStorageInfo() {
    return {
      'total_downloads': _downloadedItems.length,
      'total_size': _totalDownloadSize,
      'max_size': _maxStorageSize,
      'available_space': _maxStorageSize - _totalDownloadSize,
      'usage_percentage': (_totalDownloadSize / _maxStorageSize * 100).round(),
      'active_downloads': _activeDownloads.length,
      'queued_downloads': _downloadQueue.length,
    };
  }

  // Clear all downloads
  Future<void> clearAllDownloads() async {
    try {
      // Cancel active downloads
      for (final task in _activeDownloads.values) {
        task.cancelToken.cancel('Clearing all downloads');
      }
      _activeDownloads.clear();

      // Clear queue
      _downloadQueue.clear();

      // Delete all downloaded files
      for (final item in _downloadedItems.values) {
        await _deleteDownloadFiles(item);
      }

      // Clear downloaded items
      _downloadedItems.clear();
      _totalDownloadSize = 0;
      await _saveDownloadedItems();

      _downloadEventController.add(DownloadEvent(
        type: DownloadEventType.allCleared,
        contentId: '',
        title: '',
      ));

      _logger.i('All downloads cleared');
    } catch (e) {
      _logger.e('Failed to clear all downloads: $e');
      rethrow;
    }
  }

  // Update download settings
  Future<void> updateSettings({
    int? maxStorageSize,
    int? maxConcurrentDownloads,
  }) async {
    if (maxStorageSize != null) {
      _maxStorageSize = maxStorageSize;
      await _prefs.setInt('max_download_storage', maxStorageSize);
    }

    if (maxConcurrentDownloads != null) {
      _maxConcurrentDownloads = maxConcurrentDownloads;
      await _prefs.setInt('max_concurrent_downloads', maxConcurrentDownloads);
    }

    _logger.i('Download settings updated');
  }

  // Dispose resources
  void dispose() {
    for (final task in _activeDownloads.values) {
      task.cancelToken.cancel('Service disposed');
    }
    _activeDownloads.clear();
    _downloadQueue.clear();
    _downloadEventController.close();
  }
}

// Download request model
class DownloadRequest {
  final String id;
  final String contentId;
  final String title;
  final String contentType;
  final String quality;
  final String downloadUrl;
  final String? thumbnailUrl;
  final Map<String, dynamic>? metadata;
  final DateTime requestTime;

  DownloadRequest({
    required this.id,
    required this.contentId,
    required this.title,
    required this.contentType,
    required this.quality,
    required this.downloadUrl,
    this.thumbnailUrl,
    this.metadata,
    required this.requestTime,
  });
}

// Download task model
class DownloadTask {
  final String id;
  final String contentId;
  final String title;
  final String contentType;
  final String quality;
  final String downloadUrl;
  final String? thumbnailUrl;
  final Map<String, dynamic>? metadata;

  DownloadStatus status;
  int progress = 0;
  int downloadedBytes = 0;
  int? totalBytes;
  String? filePath;
  String? thumbnailPath;
  String? error;
  DateTime? startTime;
  DateTime? endTime;
  final CancelToken cancelToken = CancelToken();

  DownloadTask({
    required this.id,
    required this.contentId,
    required this.title,
    required this.contentType,
    required this.quality,
    required this.downloadUrl,
    this.thumbnailUrl,
    this.metadata,
    required this.status,
    this.startTime,
  });
}

// Download item model
class DownloadItem {
  final String contentId;
  final String title;
  final String contentType;
  final String quality;
  final String filePath;
  final String? thumbnailPath;
  final int fileSize;
  final DateTime downloadDate;
  final Map<String, dynamic>? metadata;

  DownloadItem({
    required this.contentId,
    required this.title,
    required this.contentType,
    required this.quality,
    required this.filePath,
    this.thumbnailPath,
    required this.fileSize,
    required this.downloadDate,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
        'contentId': contentId,
        'title': title,
        'contentType': contentType,
        'quality': quality,
        'filePath': filePath,
        'thumbnailPath': thumbnailPath,
        'fileSize': fileSize,
        'downloadDate': downloadDate.toIso8601String(),
        'metadata': metadata,
      };

  factory DownloadItem.fromJson(Map<String, dynamic> json) => DownloadItem(
        contentId: json['contentId'],
        title: json['title'],
        contentType: json['contentType'],
        quality: json['quality'],
        filePath: json['filePath'],
        thumbnailPath: json['thumbnailPath'],
        fileSize: json['fileSize'],
        downloadDate: DateTime.parse(json['downloadDate']),
        metadata: json['metadata'],
      );
}

// Download event model
class DownloadEvent {
  final DownloadEventType type;
  final String contentId;
  final String title;
  final int? progress;
  final int? downloadedBytes;
  final int? totalBytes;
  final String? error;

  DownloadEvent({
    required this.type,
    required this.contentId,
    required this.title,
    this.progress,
    this.downloadedBytes,
    this.totalBytes,
    this.error,
  });
}

// Enums
enum DownloadStatus {
  queued,
  downloading,
  paused,
  completed,
  failed,
  cancelled,
}

enum DownloadEventType {
  queued,
  started,
  progress,
  paused,
  resumed,
  completed,
  failed,
  cancelled,
  deleted,
  allCleared,
}
