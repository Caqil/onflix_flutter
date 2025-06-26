import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../shared/services/storage_service.dart';
import '../../shared/services/analytics_service.dart';

class CacheManager {
  static CacheManager? _instance;
  late Logger _logger;
  late StorageService _storageService;
  late AnalyticsService _analyticsService;

  // Cache directories
  String? _imageCacheDir;
  String? _videoCacheDir;
  String? _audioCacheDir;
  String? _dataCacheDir;

  // Cache policies
  final Map<CacheType, CachePolicy> _cachePolicies = {};

  // Cache statistics
  final Map<CacheType, CacheStats> _cacheStats = {};

  // Memory cache for frequently accessed small data
  final Map<String, MemoryCacheEntry> _memoryCache = {};
  int _memoryCacheSize = 0;
  final int _maxMemoryCacheSize = 50 * 1024 * 1024; // 50MB

  // Cleanup timer
  Timer? _cleanupTimer;

  // Cache locks to prevent concurrent access
  final Map<String, Completer<void>> _cacheLocks = {};

  CacheManager._() {
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
  }

  static CacheManager get instance {
    _instance ??= CacheManager._();
    return _instance!;
  }

  // Initialize the cache manager
  Future<void> initialize() async {
    try {
      _logger.i('Initializing Cache Manager...');

      await _setupCacheDirectories();
      _initializeCachePolicies();
      await _loadCacheStats();
      _setupCleanupTimer();

      _logger.i('Cache Manager initialized successfully');
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize Cache Manager',
          error: e, stackTrace: stackTrace);
      throw CacheException(
        message: 'Failed to initialize cache manager: $e',
        code: 'CACHE_INIT_ERROR',
        details: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Setup cache directories
  Future<void> _setupCacheDirectories() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final baseDir = Directory('${cacheDir.path}/onflix_cache');

      if (!await baseDir.exists()) {
        await baseDir.create(recursive: true);
      }

      _imageCacheDir = '${baseDir.path}/images';
      _videoCacheDir = '${baseDir.path}/videos';
      _audioCacheDir = '${baseDir.path}/audio';
      _dataCacheDir = '${baseDir.path}/data';

      for (final dir in [
        _imageCacheDir!,
        _videoCacheDir!,
        _audioCacheDir!,
        _dataCacheDir!
      ]) {
        final directory = Directory(dir);
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
      }

      _logger.d('Cache directories setup completed');
    } catch (e) {
      throw CacheException(
        message: 'Failed to setup cache directories: $e',
        code: 'CACHE_DIR_ERROR',
        details: e,
      );
    }
  }

  // Initialize cache policies
  void _initializeCachePolicies() {
    _cachePolicies[CacheType.image] = CachePolicy(
      maxSize: AppConstants.imageCacheMaxSize,
      maxAge: AppConstants.imageCacheExpiration,
      maxEntries: 10000,
      evictionStrategy: EvictionStrategy.lru,
    );

    _cachePolicies[CacheType.video] = CachePolicy(
      maxSize: AppConstants.videoCacheMaxSize,
      maxAge: AppConstants.videoCacheExpiration,
      maxEntries: 1000,
      evictionStrategy: EvictionStrategy.lru,
    );

    _cachePolicies[CacheType.audio] = CachePolicy(
      maxSize: AppConstants.audioCacheMaxSize,
      maxAge: const Duration(days: 7),
      maxEntries: 5000,
      evictionStrategy: EvictionStrategy.lru,
    );

    _cachePolicies[CacheType.data] = CachePolicy(
      maxSize: 100 * 1024 * 1024, // 100MB
      maxAge: AppConstants.cacheExpiration,
      maxEntries: 50000,
      evictionStrategy: EvictionStrategy.lru,
    );

    _logger.d('Cache policies initialized');
  }

  // Load cache statistics
  Future<void> _loadCacheStats() async {
    try {
      for (final type in CacheType.values) {
        final stats = await _calculateCacheStats(type);
        _cacheStats[type] = stats;
      }

      _logger.d('Cache statistics loaded');
    } catch (e) {
      _logger.w('Failed to load cache statistics: $e');

      // Initialize empty stats
      for (final type in CacheType.values) {
        _cacheStats[type] = CacheStats.empty();
      }
    }
  }

  // Calculate cache statistics for a type
  Future<CacheStats> _calculateCacheStats(CacheType type) async {
    try {
      final directory = _getCacheDirectory(type);
      if (!await Directory(directory).exists()) {
        return CacheStats.empty();
      }

      int totalSize = 0;
      int totalFiles = 0;
      DateTime? oldestFile;
      DateTime? newestFile;

      await for (final entity in Directory(directory).list()) {
        if (entity is File) {
          totalFiles++;
          final stat = await entity.stat();
          totalSize += stat.size;

          final modified = stat.modified;
          if (oldestFile == null || modified.isBefore(oldestFile)) {
            oldestFile = modified;
          }
          if (newestFile == null || modified.isAfter(newestFile)) {
            newestFile = modified;
          }
        }
      }

      return CacheStats(
        totalSize: totalSize,
        totalFiles: totalFiles,
        oldestEntry: oldestFile,
        newestEntry: newestFile,
        hitCount: 0, // Will be updated during runtime
        missCount: 0, // Will be updated during runtime
      );
    } catch (e) {
      _logger.w('Failed to calculate cache stats for $type: $e');
      return CacheStats.empty();
    }
  }

  // Setup cleanup timer
  void _setupCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      _performCleanup();
    });
  }

  // Get cache directory for type
  String _getCacheDirectory(CacheType type) {
    switch (type) {
      case CacheType.image:
        return _imageCacheDir!;
      case CacheType.video:
        return _videoCacheDir!;
      case CacheType.audio:
        return _audioCacheDir!;
      case CacheType.data:
        return _dataCacheDir!;
    }
  }

  // Generate cache key
  String _generateCacheKey(String url, {Map<String, String>? headers}) {
    final input = headers != null ? '$url${headers.toString()}' : url;
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Get file extension from URL
  String _getFileExtension(String url, CacheType type) {
    final uri = Uri.parse(url);
    final path = uri.path;
    final lastDot = path.lastIndexOf('.');

    if (lastDot != -1 && lastDot < path.length - 1) {
      return path.substring(lastDot);
    }

    // Default extensions based on type
    switch (type) {
      case CacheType.image:
        return '.jpg';
      case CacheType.video:
        return '.mp4';
      case CacheType.audio:
        return '.mp3';
      case CacheType.data:
        return '.json';
    }
  }

  // Cache file
  Future<String> cacheFile(
    String url,
    Uint8List data,
    CacheType type, {
    Map<String, String>? headers,
    Duration? customTtl,
  }) async {
    try {
      final cacheKey = _generateCacheKey(url, headers: headers);
      final extension = _getFileExtension(url, type);
      final fileName = '$cacheKey$extension';
      final directory = _getCacheDirectory(type);
      final filePath = '$directory/$fileName';

      // Check if we need to wait for an ongoing cache operation
      await _waitForCacheLock(cacheKey);

      // Create lock for this operation
      final completer = Completer<void>();
      _cacheLocks[cacheKey] = completer;

      try {
        // Check cache policy limits
        await _enforcePolicy(type, data.length);

        // Write file
        final file = File(filePath);
        await file.writeAsBytes(data);

        // Create metadata
        final metadata = CacheMetadata(
          url: url,
          cacheKey: cacheKey,
          filePath: filePath,
          size: data.length,
          type: type,
          cachedAt: DateTime.now(),
          expiresAt:
              DateTime.now().add(customTtl ?? _cachePolicies[type]!.maxAge),
          headers: headers,
        );

        await _saveCacheMetadata(cacheKey, metadata);

        // Update statistics
        final stats = _cacheStats[type]!;
        stats.totalSize += data.length;
        stats.totalFiles += 1;

        _logger.d('File cached: $url -> $filePath');

        _analyticsService.trackEvent('cache_write', {
          'type': type.toString(),
          'size': data.length,
          'url': url,
        });

        return filePath;
      } finally {
        // Release lock
        _cacheLocks.remove(cacheKey);
        completer.complete();
      }
    } catch (e) {
      _logger.e('Failed to cache file: $e');
      throw CacheException(
        message: 'Failed to cache file: $e',
        code: 'CACHE_WRITE_ERROR',
        details: e,
      );
    }
  }

  // Get cached file
  Future<CachedFile?> getCachedFile(
    String url,
    CacheType type, {
    Map<String, String>? headers,
  }) async {
    try {
      final cacheKey = _generateCacheKey(url, headers: headers);

      // Check memory cache first for small data
      if (type == CacheType.data) {
        final memoryEntry = _memoryCache[cacheKey];
        if (memoryEntry != null && !memoryEntry.isExpired) {
          _updateCacheStats(type, hit: true);
          _logger.d('Memory cache hit: $url');

          return CachedFile(
            data: memoryEntry.data,
            metadata: memoryEntry.metadata,
            source: CacheSource.memory,
          );
        }
      }

      // Wait for any ongoing cache operations
      await _waitForCacheLock(cacheKey);

      // Load metadata
      final metadata = await _loadCacheMetadata(cacheKey);
      if (metadata == null) {
        _updateCacheStats(type, hit: false);
        return null;
      }

      // Check if expired
      if (metadata.isExpired) {
        await _removeCacheEntry(cacheKey, metadata);
        _updateCacheStats(type, hit: false);
        return null;
      }

      // Check if file exists
      final file = File(metadata.filePath);
      if (!await file.exists()) {
        await _removeCacheMetadata(cacheKey);
        _updateCacheStats(type, hit: false);
        return null;
      }

      // Read file
      final data = await file.readAsBytes();

      // Update access time for LRU
      metadata.lastAccessed = DateTime.now();
      await _saveCacheMetadata(cacheKey, metadata);

      // Add to memory cache if small enough
      if (type == CacheType.data && data.length <= 1024 * 1024) {
        // 1MB limit
        _addToMemoryCache(cacheKey, data, metadata);
      }

      _updateCacheStats(type, hit: true);
      _logger.d('Disk cache hit: $url');

      _analyticsService.trackEvent('cache_read', {
        'type': type.toString(),
        'size': data.length,
        'url': url,
      });

      return CachedFile(
        data: data,
        metadata: metadata,
        source: CacheSource.disk,
      );
    } catch (e) {
      _logger.e('Failed to get cached file: $e');
      _updateCacheStats(type, hit: false);
      return null;
    }
  }

  // Check if file is cached
  Future<bool> isCached(
    String url,
    CacheType type, {
    Map<String, String>? headers,
  }) async {
    try {
      final cacheKey = _generateCacheKey(url, headers: headers);

      // Check memory cache
      if (type == CacheType.data) {
        final memoryEntry = _memoryCache[cacheKey];
        if (memoryEntry != null && !memoryEntry.isExpired) {
          return true;
        }
      }

      // Check disk cache
      final metadata = await _loadCacheMetadata(cacheKey);
      if (metadata == null || metadata.isExpired) {
        return false;
      }

      return await File(metadata.filePath).exists();
    } catch (e) {
      _logger.w('Failed to check cache status: $e');
      return false;
    }
  }

  // Remove cached file
  Future<void> removeCachedFile(
    String url,
    CacheType type, {
    Map<String, String>? headers,
  }) async {
    try {
      final cacheKey = _generateCacheKey(url, headers: headers);
      final metadata = await _loadCacheMetadata(cacheKey);

      if (metadata != null) {
        await _removeCacheEntry(cacheKey, metadata);
        _logger.d('Cache entry removed: $url');
      }
    } catch (e) {
      _logger.e('Failed to remove cached file: $e');
    }
  }

  // Clear cache by type
  Future<void> clearCache(CacheType type) async {
    try {
      final directory = Directory(_getCacheDirectory(type));
      if (await directory.exists()) {
        await directory.delete(recursive: true);
        await directory.create();
      }

      // Clear related memory cache entries
      if (type == CacheType.data) {
        _memoryCache.clear();
        _memoryCacheSize = 0;
      }

      // Reset statistics
      _cacheStats[type] = CacheStats.empty();

      _logger.i('Cache cleared for type: $type');

      _analyticsService.trackEvent('cache_cleared', {
        'type': type.toString(),
      });
    } catch (e) {
      _logger.e('Failed to clear cache: $e');
      throw CacheException(
        message: 'Failed to clear cache: $e',
        code: 'CACHE_CLEAR_ERROR',
        details: e,
      );
    }
  }

  // Clear all caches
  Future<void> clearAllCaches() async {
    try {
      for (final type in CacheType.values) {
        await clearCache(type);
      }

      _logger.i('All caches cleared');

      _analyticsService.trackEvent('all_caches_cleared');
    } catch (e) {
      _logger.e('Failed to clear all caches: $e');
      rethrow;
    }
  }

  // Wait for cache lock
  Future<void> _waitForCacheLock(String cacheKey) async {
    final existingLock = _cacheLocks[cacheKey];
    if (existingLock != null) {
      await existingLock.future;
    }
  }

  // Add to memory cache
  void _addToMemoryCache(
      String cacheKey, Uint8List data, CacheMetadata metadata) {
    try {
      // Check if we need to evict entries
      while (_memoryCacheSize + data.length > _maxMemoryCacheSize &&
          _memoryCache.isNotEmpty) {
        _evictOldestMemoryCacheEntry();
      }

      final entry = MemoryCacheEntry(
        data: data,
        metadata: metadata,
        addedAt: DateTime.now(),
      );

      _memoryCache[cacheKey] = entry;
      _memoryCacheSize += data.length;
    } catch (e) {
      _logger.w('Failed to add to memory cache: $e');
    }
  }

  // Evict oldest memory cache entry
  void _evictOldestMemoryCacheEntry() {
    if (_memoryCache.isEmpty) return;

    String? oldestKey;
    DateTime? oldestTime;

    for (final entry in _memoryCache.entries) {
      if (oldestTime == null || entry.value.addedAt.isBefore(oldestTime)) {
        oldestTime = entry.value.addedAt;
        oldestKey = entry.key;
      }
    }

    if (oldestKey != null) {
      final removed = _memoryCache.remove(oldestKey);
      if (removed != null) {
        _memoryCacheSize -= removed.data.length;
      }
    }
  }

  // Enforce cache policy
  Future<void> _enforcePolicy(CacheType type, int newEntrySize) async {
    try {
      final policy = _cachePolicies[type]!;
      final stats = _cacheStats[type]!;

      // Check size limit
      if (stats.totalSize + newEntrySize > policy.maxSize) {
        await _evictEntries(type, newEntrySize);
      }

      // Check entry count limit
      if (stats.totalFiles >= policy.maxEntries) {
        await _evictOldestEntries(
            type, stats.totalFiles - policy.maxEntries + 1);
      }
    } catch (e) {
      _logger.w('Failed to enforce cache policy: $e');
    }
  }

  // Evict entries to make space
  Future<void> _evictEntries(CacheType type, int requiredSpace) async {
    try {
      final directory = Directory(_getCacheDirectory(type));
      final stats = _cacheStats[type]!;
      int spaceFreed = 0;

      // Get all cache files sorted by last access time (LRU)
      final files = <File>[];
      await for (final entity in directory.list()) {
        if (entity is File) {
          files.add(entity);
        }
      }

      // Sort by modification time (proxy for last access)
      files.sort((a, b) {
        final aStat = a.statSync();
        final bStat = b.statSync();
        return aStat.modified.compareTo(bStat.modified);
      });

      // Remove oldest files until we have enough space
      for (final file in files) {
        if (spaceFreed >= requiredSpace) break;

        try {
          final int fileSize = await file.length(); // Explicitly type as int
          await file.delete();
          spaceFreed += fileSize;
          stats.totalSize -=
              fileSize; // Ensure stats.totalSize is int or cast if double
          stats.totalFiles -= 1;

          // Remove metadata
          final fileName = file.path.split('/').last;
          final cacheKey = fileName.split('.').first;
          await _removeCacheMetadata(cacheKey);
        } catch (e) {
          _logger.w('Failed to evict file ${file.path}: $e');
        }
      }

      _logger.d('Evicted $spaceFreed bytes for cache type: $type');
    } catch (e) {
      _logger.e('Failed to evict cache entries: $e');
    }
  }

  Future<void> _evictOldestEntries(CacheType type, int count) async {
    try {
      final directory = Directory(_getCacheDirectory(type));
      final stats = _cacheStats[type]!;
      int removed = 0;

      final files = <File>[];
      await for (final entity in directory.list()) {
        if (entity is File) {
          files.add(entity);
        }
      }

      // Sort by modification time
      files.sort((a, b) {
        final aStat = a.statSync();
        final bStat = b.statSync();
        return aStat.modified.compareTo(bStat.modified);
      });

      for (final file in files) {
        if (removed >= count) break;

        try {
          final int fileSize = await file.length(); // Get file size in bytes
          await file.delete();
          stats.totalSize -=
              fileSize; // Ensure stats.totalSize is int or cast if double
          stats.totalFiles -= 1;
          removed++;

          // Remove metadata
          final fileName = file.path.split('/').last;
          final cacheKey = fileName.split('.').first;
          await _removeCacheMetadata(cacheKey);
        } catch (e) {
          _logger.w('Failed to remove file ${file.path}: $e');
        }
      }

      _logger.d('Removed $removed old entries for cache type: $type');
    } catch (e) {
      _logger.e('Failed to evict oldest entries: $e');
    }
  }

  // Perform periodic cleanup
  Future<void> _performCleanup() async {
    try {
      _logger.d('Performing cache cleanup...');

      for (final type in CacheType.values) {
        await _cleanupExpiredEntries(type);
      }

      // Clean memory cache
      _cleanupMemoryCache();

      _logger.d('Cache cleanup completed');
    } catch (e) {
      _logger.e('Cache cleanup failed: $e');
    }
  }

  // Cleanup expired entries
  Future<void> _cleanupExpiredEntries(CacheType type) async {
    try {
      final directory = Directory(_getCacheDirectory(type));
      final stats = _cacheStats[type]!;
      int removedCount = 0;
      int removedSize = 0;

      await for (final entity in directory.list()) {
        if (entity is File) {
          final fileName = entity.path.split('/').last;
          final cacheKey = fileName.split('.').first;

          final metadata = await _loadCacheMetadata(cacheKey);
          if (metadata != null && metadata.isExpired) {
            try {
              final fileSize = await entity.length();
              await entity.delete();
              await _removeCacheMetadata(cacheKey);

              removedCount++;
              removedSize += fileSize;
              stats.totalFiles -= 1;
              stats.totalSize -= fileSize;
            } catch (e) {
              _logger.w('Failed to remove expired file: $e');
            }
          }
        }
      }

      if (removedCount > 0) {
        _logger.d(
            'Cleaned up $removedCount expired entries ($removedSize bytes) for $type');
      }
    } catch (e) {
      _logger.w('Failed to cleanup expired entries for $type: $e');
    }
  }

  // Cleanup memory cache
  void _cleanupMemoryCache() {
    final expiredKeys = <String>[];

    for (final entry in _memoryCache.entries) {
      if (entry.value.isExpired) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      final removed = _memoryCache.remove(key);
      if (removed != null) {
        _memoryCacheSize -= removed.data.length;
      }
    }

    if (expiredKeys.isNotEmpty) {
      _logger
          .d('Cleaned up ${expiredKeys.length} expired memory cache entries');
    }
  }

  // Update cache statistics
  void _updateCacheStats(CacheType type, {required bool hit}) {
    final stats = _cacheStats[type]!;
    if (hit) {
      stats.hitCount++;
    } else {
      stats.missCount++;
    }
  }

  // Save cache metadata
  Future<void> _saveCacheMetadata(
      String cacheKey, CacheMetadata metadata) async {
    try {
      await _storageService.setCache('cache_meta_$cacheKey', metadata.toJson());
    } catch (e) {
      _logger.w('Failed to save cache metadata: $e');
    }
  }

  // Load cache metadata
  Future<CacheMetadata?> _loadCacheMetadata(String cacheKey) async {
    try {
      final data = await _storageService
          .getCache<Map<String, dynamic>>('cache_meta_$cacheKey');
      if (data != null) {
        return CacheMetadata.fromJson(data);
      }
    } catch (e) {
      _logger.w('Failed to load cache metadata: $e');
    }
    return null;
  }

  // Remove cache metadata
  Future<void> _removeCacheMetadata(String cacheKey) async {
    try {
      await _storageService.removeCache('cache_meta_$cacheKey');
    } catch (e) {
      _logger.w('Failed to remove cache metadata: $e');
    }
  }

  // Remove cache entry
  Future<void> _removeCacheEntry(
      String cacheKey, CacheMetadata metadata) async {
    try {
      // Remove file
      final file = File(metadata.filePath);
      if (await file.exists()) {
        final fileSize = await file.length();
        await file.delete();

        // Update statistics
        final stats = _cacheStats[metadata.type]!;
        stats.totalSize -= fileSize;
        stats.totalFiles -= 1;
      }

      // Remove metadata
      await _removeCacheMetadata(cacheKey);

      // Remove from memory cache
      final memoryEntry = _memoryCache.remove(cacheKey);
      if (memoryEntry != null) {
        _memoryCacheSize -= memoryEntry.data.length;
      }
    } catch (e) {
      _logger.w('Failed to remove cache entry: $e');
    }
  }

  // Get cache statistics
  Map<String, dynamic> getCacheStatistics() {
    final totalStats = <String, dynamic>{
      'memory_cache_size': _memoryCacheSize,
      'memory_cache_entries': _memoryCache.length,
      'memory_cache_max_size': _maxMemoryCacheSize,
    };

    for (final entry in _cacheStats.entries) {
      final type = entry.key;
      final stats = entry.value;

      totalStats['${type.toString().split('.').last}'] = {
        'total_size': stats.totalSize,
        'total_files': stats.totalFiles,
        'hit_count': stats.hitCount,
        'miss_count': stats.missCount,
        'hit_rate': stats.hitRate,
        'oldest_entry': stats.oldestEntry?.toIso8601String(),
        'newest_entry': stats.newestEntry?.toIso8601String(),
      };
    }

    return totalStats;
  }

  // Dispose resources
  void dispose() {
    _cleanupTimer?.cancel();
    _memoryCache.clear();
    _memoryCacheSize = 0;
  }
}

// Cache types
enum CacheType {
  image,
  video,
  audio,
  data,
}

// Cache source
enum CacheSource {
  memory,
  disk,
}

// Eviction strategies
enum EvictionStrategy {
  lru, // Least Recently Used
  lfu, // Least Frequently Used
  fifo, // First In, First Out
}

// Cache policy
class CachePolicy {
  final int maxSize;
  final Duration maxAge;
  final int maxEntries;
  final EvictionStrategy evictionStrategy;

  CachePolicy({
    required this.maxSize,
    required this.maxAge,
    required this.maxEntries,
    required this.evictionStrategy,
  });
}

// Cache statistics
class CacheStats {
  int totalSize;
  int totalFiles;
  int hitCount;
  int missCount;
  DateTime? oldestEntry;
  DateTime? newestEntry;

  CacheStats({
    required this.totalSize,
    required this.totalFiles,
    required this.hitCount,
    required this.missCount,
    this.oldestEntry,
    this.newestEntry,
  });

  factory CacheStats.empty() {
    return CacheStats(
      totalSize: 0,
      totalFiles: 0,
      hitCount: 0,
      missCount: 0,
    );
  }

  double get hitRate {
    final total = hitCount + missCount;
    return total > 0 ? hitCount / total : 0.0;
  }
}

// Cache metadata
class CacheMetadata {
  final String url;
  final String cacheKey;
  final String filePath;
  final int size;
  final CacheType type;
  final DateTime cachedAt;
  final DateTime expiresAt;
  DateTime lastAccessed;
  final Map<String, String>? headers;

  CacheMetadata({
    required this.url,
    required this.cacheKey,
    required this.filePath,
    required this.size,
    required this.type,
    required this.cachedAt,
    required this.expiresAt,
    DateTime? lastAccessed,
    this.headers,
  }) : lastAccessed = lastAccessed ?? DateTime.now();

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'cacheKey': cacheKey,
      'filePath': filePath,
      'size': size,
      'type': type.toString(),
      'cachedAt': cachedAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'lastAccessed': lastAccessed.toIso8601String(),
      'headers': headers,
    };
  }

  factory CacheMetadata.fromJson(Map<String, dynamic> json) {
    return CacheMetadata(
      url: json['url'],
      cacheKey: json['cacheKey'],
      filePath: json['filePath'],
      size: json['size'],
      type: CacheType.values.firstWhere((e) => e.toString() == json['type']),
      cachedAt: DateTime.parse(json['cachedAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
      lastAccessed: DateTime.parse(json['lastAccessed']),
      headers: json['headers']?.cast<String, String>(),
    );
  }
}

// Memory cache entry
class MemoryCacheEntry {
  final Uint8List data;
  final CacheMetadata metadata;
  final DateTime addedAt;

  MemoryCacheEntry({
    required this.data,
    required this.metadata,
    required this.addedAt,
  });

  bool get isExpired => metadata.isExpired;
}

// Cached file result
class CachedFile {
  final Uint8List data;
  final CacheMetadata metadata;
  final CacheSource source;

  CachedFile({
    required this.data,
    required this.metadata,
    required this.source,
  });
}
