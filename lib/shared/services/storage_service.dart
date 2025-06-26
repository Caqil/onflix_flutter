import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';

class StorageService {
  static StorageService? _instance;
  late Logger _logger;
  late SharedPreferences _prefs;

  // Hive boxes for different data types
  Box<dynamic>? _cacheBox;
  Box<dynamic>? _userDataBox;
  Box<dynamic>? _settingsBox;
  Box<dynamic>? _analyticsBox;
  Box<dynamic>? _offlineBox;
  Box<dynamic>? _secureBox;

  // Storage management
  String? _storageDirectory;
  String? _cacheDirectory;
  String? _dataDirectory;
  String? _tempDirectory;
  int _totalStorageUsed = 0;
  final Map<String, int> _boxSizes = {};

  // Cache management
  final Map<String, CacheEntry> _memoryCache = {};
  Timer? _cleanupTimer;
  static const int _maxMemoryCacheSize = 50 * 1024 * 1024; // 50MB
  int _memoryCacheSize = 0;

  // Encryption
  static const String _encryptionKey = 'onflix_secure_key_2024';
  late List<int> _keyBytes;

  // File management
  final Map<String, StreamSubscription> _fileWatchers = {};

  // Statistics
  int _cacheHits = 0;
  int _cacheMisses = 0;
  int _secureOperations = 0;
  DateTime? _lastCleanup;

  StorageService._() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 1,
        errorMethodCount: 3,
        lineLength: 80,
        colors: true,
        printEmojis: true,
      ),
    );
    _keyBytes = utf8.encode(_encryptionKey);
  }

  static StorageService get instance {
    _instance ??= StorageService._();
    return _instance!;
  }

  // Getters
  bool get isInitialized => _cacheBox != null;
  int get totalStorageUsed => _totalStorageUsed;
  int get memoryCacheSize => _memoryCacheSize;
  int get cacheHitCount => _cacheHits;
  int get cacheMissCount => _cacheMisses;
  double get cacheHitRatio => (_cacheHits + _cacheMisses) > 0
      ? _cacheHits / (_cacheHits + _cacheMisses)
      : 0.0;
  String? get storageDirectory => _storageDirectory;
  String? get cacheDirectory => _cacheDirectory;

  // Initialize the service
  Future<void> initialize() async {
    try {
      _logger.i('Initializing Storage Service...');

      await _setupDirectories();
      await _initializeHive();
      await _initializeSharedPreferences();
      await _calculateStorageUsage();
      _setupCleanupTimer();

      _logger.i('Storage Service initialized successfully');
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize Storage Service',
          error: e, stackTrace: stackTrace);
      throw CacheException(
        message: 'Failed to initialize storage service: $e',
        code: 'STORAGE_INITIALIZATION_ERROR',
        details: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Setup storage directories
  Future<void> _setupDirectories() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      _storageDirectory = appDir.path;

      // Create subdirectories
      _cacheDirectory = '${appDir.path}/cache';
      _dataDirectory = '${appDir.path}/data';
      _tempDirectory = '${appDir.path}/temp';

      final directories = [
        Directory(_cacheDirectory!),
        Directory(_dataDirectory!),
        Directory(_tempDirectory!),
        Directory('${_cacheDirectory!}/images'),
        Directory('${_cacheDirectory!}/videos'),
        Directory('${_cacheDirectory!}/audio'),
        Directory('${_dataDirectory!}/downloads'),
        Directory('${_dataDirectory!}/offline'),
      ];

      for (final dir in directories) {
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
      }

      _logger.d('Storage directories setup: $_storageDirectory');
    } catch (e) {
      throw CacheException(
        message: 'Failed to setup storage directories: $e',
        code: 'DIRECTORY_SETUP_ERROR',
        details: e,
      );
    }
  }

  // Initialize Hive database
  Future<void> _initializeHive() async {
    try {
      await Hive.initFlutter();

      // Register adapters if needed
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(CacheEntryAdapter());
      }

      // Open boxes for different data types
      _cacheBox = await Hive.openBox('cache');
      _userDataBox = await Hive.openBox('user_data');
      _settingsBox = await Hive.openBox('settings');
      _analyticsBox = await Hive.openBox('analytics');
      _offlineBox = await Hive.openBox('offline');
      _secureBox = await Hive.openBox('secure',
          encryptionCipher: HiveAesCipher(_keyBytes));

      _logger.d('Hive boxes initialized');
    } catch (e) {
      throw CacheException(
        message: 'Failed to initialize Hive: $e',
        code: 'HIVE_INITIALIZATION_ERROR',
        details: e,
      );
    }
  }

  // Initialize SharedPreferences
  Future<void> _initializeSharedPreferences() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _logger.d('SharedPreferences initialized');
    } catch (e) {
      throw CacheException(
        message: 'Failed to initialize SharedPreferences: $e',
        code: 'SHARED_PREFS_ERROR',
        details: e,
      );
    }
  }

  // Calculate current storage usage
  Future<void> _calculateStorageUsage() async {
    try {
      _totalStorageUsed = 0;
      _boxSizes.clear();

      // Calculate Hive box sizes
      final boxes = {
        'cache': _cacheBox,
        'user_data': _userDataBox,
        'settings': _settingsBox,
        'analytics': _analyticsBox,
        'offline': _offlineBox,
        'secure': _secureBox,
      };

      for (final entry in boxes.entries) {
        if (entry.value != null) {
          final size = await _calculateBoxSize(entry.value!);
          _boxSizes[entry.key] = size;
          _totalStorageUsed += size;
        }
      }

      // Calculate file storage usage
      if (_storageDirectory != null) {
        final directories = [
          _cacheDirectory!,
          _dataDirectory!,
          _tempDirectory!
        ];

        for (final dirPath in directories) {
          final dir = Directory(dirPath);
          if (await dir.exists()) {
            final size = await _calculateDirectorySize(dir);
            final dirName = dirPath.split('/').last;
            _boxSizes['dir_$dirName'] = size;
            _totalStorageUsed += size;
          }
        }
      }

      _logger.d('Total storage used: ${_formatBytes(_totalStorageUsed)}');
    } catch (e) {
      _logger.w('Failed to calculate storage usage: $e');
    }
  }

  // Calculate box size
  Future<int> _calculateBoxSize(Box box) async {
    try {
      int size = 0;
      for (final key in box.keys) {
        final value = box.get(key);
        if (value != null) {
          final jsonString = jsonEncode(value);
          size += jsonString.length;
        }
      }
      return size;
    } catch (e) {
      _logger.w('Failed to calculate box size: $e');
      return 0;
    }
  }

  // Calculate directory size
  Future<int> _calculateDirectorySize(Directory directory) async {
    try {
      int size = 0;
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File) {
          try {
            size += await entity.length();
          } catch (e) {
            // File might be deleted or inaccessible
            continue;
          }
        }
      }
      return size;
    } catch (e) {
      _logger.w('Failed to calculate directory size: $e');
      return 0;
    }
  }

  // Format bytes to human readable string
  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  // Setup cleanup timer
  void _setupCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      _performCleanup();
    });
  }

  // Perform periodic cleanup
  Future<void> _performCleanup() async {
    try {
      _logger.d('Performing storage cleanup...');

      // Clean expired cache entries
      await _cleanExpiredCache();

      // Clean memory cache
      _cleanMemoryCache();

      // Clean temporary files
      await _cleanTemporaryFiles();

      // Optimize storage if needed
      await _optimizeStorage();

      // Recalculate storage usage
      await _calculateStorageUsage();

      _lastCleanup = DateTime.now();
      _logger.d('Storage cleanup completed');
    } catch (e) {
      _logger.e('Storage cleanup failed: $e');
    }
  }

  // Clean expired cache entries
  Future<void> _cleanExpiredCache() async {
    try {
      if (_cacheBox == null) return;

      final keysToDelete = <String>[];

      for (final key in _cacheBox!.keys) {
        final data = _cacheBox!.get(key);
        if (data is Map) {
          final expiryStr = data['expiry'] as String?;
          if (expiryStr != null) {
            final expiry = DateTime.parse(expiryStr);
            if (expiry.isBefore(DateTime.now())) {
              keysToDelete.add(key as String);
            }
          }
        }
      }

      for (final key in keysToDelete) {
        await _cacheBox!.delete(key);
      }

      if (keysToDelete.isNotEmpty) {
        _logger.d('Cleaned ${keysToDelete.length} expired cache entries');
      }
    } catch (e) {
      _logger.w('Failed to clean expired cache: $e');
    }
  }

  // Clean memory cache
  void _cleanMemoryCache() {
    final now = DateTime.now();
    final keysToRemove = <String>[];

    for (final entry in _memoryCache.entries) {
      if (entry.value.isExpired(now)) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      final entry = _memoryCache.remove(key);
      if (entry != null) {
        _memoryCacheSize -= _estimateObjectSize(entry.value);
      }
    }

    if (keysToRemove.isNotEmpty) {
      _logger.d('Cleaned ${keysToRemove.length} expired memory cache entries');
    }

    // Check memory cache size limit
    if (_memoryCacheSize > _maxMemoryCacheSize) {
      _evictMemoryCache();
    }
  }

  // Evict memory cache entries when size limit exceeded
  void _evictMemoryCache() {
    final entries = _memoryCache.entries.toList();
    entries.sort((a, b) => a.value.created.compareTo(b.value.created));

    // Remove oldest entries until we're under the limit
    while (_memoryCacheSize > _maxMemoryCacheSize * 0.8 && entries.isNotEmpty) {
      final entry = entries.removeAt(0);
      final removedEntry = _memoryCache.remove(entry.key);
      if (removedEntry != null) {
        _memoryCacheSize -= _estimateObjectSize(removedEntry.value);
      }
    }

    _logger.d(
        'Evicted memory cache entries, new size: ${_formatBytes(_memoryCacheSize)}');
  }

  // Estimate object size for memory cache management
  int _estimateObjectSize(dynamic obj) {
    try {
      return jsonEncode(obj).length;
    } catch (e) {
      return 1024; // Default estimate
    }
  }

  // Clean temporary files
  Future<void> _cleanTemporaryFiles() async {
    try {
      if (_tempDirectory == null) return;

      final tempDir = Directory(_tempDirectory!);
      if (await tempDir.exists()) {
        await for (final entity in tempDir.list()) {
          if (entity is File) {
            try {
              final stat = await entity.stat();
              final age = DateTime.now().difference(stat.modified);

              // Delete files older than 24 hours
              if (age.inHours > 24) {
                await entity.delete();
              }
            } catch (e) {
              // File might be deleted or inaccessible
              continue;
            }
          }
        }
      }
    } catch (e) {
      _logger.w('Failed to clean temporary files: $e');
    }
  }

  // Optimize storage by compacting boxes
  Future<void> _optimizeStorage() async {
    try {
      final boxes = [
        _cacheBox,
        _userDataBox,
        _settingsBox,
        _analyticsBox,
        _offlineBox,
        _secureBox
      ];

      for (final box in boxes) {
        if (box != null) {
          await box.compact();
        }
      }

      _logger.d('Storage optimization completed');
    } catch (e) {
      _logger.w('Failed to optimize storage: $e');
    }
  }

  // Cache operations
  Future<void> setCache(
    String key,
    dynamic value, {
    Duration? ttl,
    bool useMemoryCache = true,
  }) async {
    try {
      final expiry = ttl != null
          ? DateTime.now().add(ttl)
          : DateTime.now().add(AppConstants.cacheExpiration);

      final cacheData = {
        'value': value,
        'expiry': expiry.toIso8601String(),
        'created': DateTime.now().toIso8601String(),
      };

      // Store in Hive
      await _cacheBox?.put(key, cacheData);

      // Store in memory cache if requested
      if (useMemoryCache) {
        final entry = CacheEntry(
          value: value,
          expiry: expiry,
          created: DateTime.now(),
        );
        _memoryCache[key] = entry;
        _memoryCacheSize += _estimateObjectSize(value);

        // Check memory cache size
        if (_memoryCacheSize > _maxMemoryCacheSize) {
          _evictMemoryCache();
        }
      }

      _logger.d('Cache set: $key');
    } catch (e) {
      _logger.e('Failed to set cache: $e');
      throw CacheException(
        message: 'Failed to set cache for key: $key',
        code: 'CACHE_SET_ERROR',
        details: e,
      );
    }
  }

  // Get cached data
  Future<T?> getCache<T>(String key, {bool useMemoryCache = true}) async {
    try {
      // Check memory cache first
      if (useMemoryCache && _memoryCache.containsKey(key)) {
        final entry = _memoryCache[key]!;
        if (!entry.isExpired(DateTime.now())) {
          _cacheHits++;
          _logger.d('Cache hit (memory): $key');
          return entry.value as T?;
        } else {
          final removedEntry = _memoryCache.remove(key);
          if (removedEntry != null) {
            _memoryCacheSize -= _estimateObjectSize(removedEntry.value);
          }
        }
      }

      // Check Hive cache
      final data = _cacheBox?.get(key);
      if (data is Map) {
        final expiryStr = data['expiry'] as String?;
        if (expiryStr != null) {
          final expiry = DateTime.parse(expiryStr);
          if (expiry.isAfter(DateTime.now())) {
            final value = data['value'] as T?;

            // Update memory cache
            if (useMemoryCache && value != null) {
              final entry = CacheEntry(
                value: value,
                expiry: expiry,
                created: DateTime.parse(data['created'] as String),
              );
              _memoryCache[key] = entry;
              _memoryCacheSize += _estimateObjectSize(value);
            }

            _cacheHits++;
            _logger.d('Cache hit (Hive): $key');
            return value;
          } else {
            // Expired, remove it
            await _cacheBox?.delete(key);
          }
        }
      }

      _cacheMisses++;
      _logger.d('Cache miss: $key');
      return null;
    } catch (e) {
      _cacheMisses++;
      _logger.e('Failed to get cache: $e');
      return null;
    }
  }

  // Check if cache exists and is valid
  Future<bool> hasValidCache(String key) async {
    try {
      // Check memory cache
      if (_memoryCache.containsKey(key)) {
        final entry = _memoryCache[key]!;
        return !entry.isExpired(DateTime.now());
      }

      // Check Hive cache
      final data = _cacheBox?.get(key);
      if (data is Map) {
        final expiryStr = data['expiry'] as String?;
        if (expiryStr != null) {
          final expiry = DateTime.parse(expiryStr);
          return expiry.isAfter(DateTime.now());
        }
      }

      return false;
    } catch (e) {
      _logger.e('Failed to check cache validity: $e');
      return false;
    }
  }

  // Remove cache entry
  Future<void> removeCache(String key) async {
    try {
      await _cacheBox?.delete(key);
      final removedEntry = _memoryCache.remove(key);
      if (removedEntry != null) {
        _memoryCacheSize -= _estimateObjectSize(removedEntry.value);
      }
      _logger.d('Cache removed: $key');
    } catch (e) {
      _logger.e('Failed to remove cache: $e');
    }
  }

  // Clear all cache
  Future<void> clearCache() async {
    try {
      await _cacheBox?.clear();
      _memoryCache.clear();
      _memoryCacheSize = 0;
      _logger.i('All cache cleared');
    } catch (e) {
      _logger.e('Failed to clear cache: $e');
      throw CacheException(
        message: 'Failed to clear cache',
        code: 'CACHE_CLEAR_ERROR',
        details: e,
      );
    }
  }

  // Encryption utilities
  String _generateKey(String input) {
    final bytes = utf8.encode(input + _encryptionKey);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Simple encryption for data
  String _encryptData(String data) {
    try {
      final key = _generateKey(data);
      final keyBytes = utf8.encode(key.substring(0, 32));
      final dataBytes = utf8.encode(data);

      // Simple XOR encryption (for demo purposes - use proper encryption in production)
      final encrypted = <int>[];
      for (int i = 0; i < dataBytes.length; i++) {
        encrypted.add(dataBytes[i] ^ keyBytes[i % keyBytes.length]);
      }

      return base64.encode(encrypted);
    } catch (e) {
      _logger.e('Encryption failed: $e');
      throw CacheException(
        message: 'Data encryption failed',
        code: 'ENCRYPTION_ERROR',
        details: e,
      );
    }
  }

  // Simple decryption for data
  String _decryptData(String encryptedData, String originalKey) {
    try {
      final key = _generateKey(originalKey);
      final keyBytes = utf8.encode(key.substring(0, 32));
      final encryptedBytes = base64.decode(encryptedData);

      // Simple XOR decryption
      final decrypted = <int>[];
      for (int i = 0; i < encryptedBytes.length; i++) {
        decrypted.add(encryptedBytes[i] ^ keyBytes[i % keyBytes.length]);
      }

      return utf8.decode(decrypted);
    } catch (e) {
      _logger.e('Decryption failed: $e');
      throw CacheException(
        message: 'Data decryption failed',
        code: 'DECRYPTION_ERROR',
        details: e,
      );
    }
  }

  // Secure storage operations
  Future<void> setSecureData(String key, dynamic value) async {
    try {
      _secureOperations++;

      // Use Hive's built-in encryption for secure box
      await _secureBox?.put(key, value);

      _logger.d('Secure data set: $key');
    } catch (e) {
      _logger.e('Failed to set secure data: $e');
      throw CacheException(
        message: 'Failed to set secure data for key: $key',
        code: 'SECURE_DATA_SET_ERROR',
        details: e,
      );
    }
  }

  // Get secure data
  Future<T?> getSecureData<T>(String key) async {
    try {
      _secureOperations++;

      final value = _secureBox?.get(key) as T?;

      _logger.d('Secure data retrieved: $key');
      return value;
    } catch (e) {
      _logger.e('Failed to get secure data: $e');
      return null;
    }
  }

  // Remove secure data
  Future<void> removeSecureData(String key) async {
    try {
      await _secureBox?.delete(key);
      _logger.d('Secure data removed: $key');
    } catch (e) {
      _logger.e('Failed to remove secure data: $e');
    }
  }

  // Clear all secure data
  Future<void> clearSecureData() async {
    try {
      await _secureBox?.clear();
      _logger.i('All secure data cleared');
    } catch (e) {
      _logger.e('Failed to clear secure data: $e');
      throw CacheException(
        message: 'Failed to clear secure data',
        code: 'SECURE_DATA_CLEAR_ERROR',
        details: e,
      );
    }
  }

  // User data operations
  Future<void> setUserData(String key, dynamic value) async {
    try {
      await _userDataBox?.put(key, value);
      _logger.d('User data set: $key');
    } catch (e) {
      _logger.e('Failed to set user data: $e');
      throw CacheException(
        message: 'Failed to set user data for key: $key',
        code: 'USER_DATA_SET_ERROR',
        details: e,
      );
    }
  }

  Future<T?> getUserData<T>(String key) async {
    try {
      final value = _userDataBox?.get(key) as T?;
      _logger.d('User data get: $key');
      return value;
    } catch (e) {
      _logger.e('Failed to get user data: $e');
      return null;
    }
  }

  Future<void> removeUserData(String key) async {
    try {
      await _userDataBox?.delete(key);
      _logger.d('User data removed: $key');
    } catch (e) {
      _logger.e('Failed to remove user data: $e');
    }
  }

  Future<void> clearUserData() async {
    try {
      await _userDataBox?.clear();
      _logger.i('All user data cleared');
    } catch (e) {
      _logger.e('Failed to clear user data: $e');
      throw CacheException(
        message: 'Failed to clear user data',
        code: 'USER_DATA_CLEAR_ERROR',
        details: e,
      );
    }
  }

  // Settings operations
  Future<void> setSetting(String key, dynamic value) async {
    try {
      await _settingsBox?.put(key, value);
      _logger.d('Setting set: $key');
    } catch (e) {
      _logger.e('Failed to set setting: $e');
    }
  }

  Future<T?> getSetting<T>(String key, {T? defaultValue}) async {
    try {
      final value = _settingsBox?.get(key, defaultValue: defaultValue) as T?;
      return value;
    } catch (e) {
      _logger.e('Failed to get setting: $e');
      return defaultValue;
    }
  }

  Future<void> removeSetting(String key) async {
    try {
      await _settingsBox?.delete(key);
      _logger.d('Setting removed: $key');
    } catch (e) {
      _logger.e('Failed to remove setting: $e');
    }
  }

  Future<void> clearSettings() async {
    try {
      await _settingsBox?.clear();
      _logger.i('All settings cleared');
    } catch (e) {
      _logger.e('Failed to clear settings: $e');
    }
  }

  // Analytics data operations
  Future<void> setAnalyticsData(String key, dynamic value) async {
    try {
      await _analyticsBox?.put(key, value);
      _logger.d('Analytics data set: $key');
    } catch (e) {
      _logger.e('Failed to set analytics data: $e');
    }
  }

  Future<T?> getAnalyticsData<T>(String key) async {
    try {
      final value = _analyticsBox?.get(key) as T?;
      return value;
    } catch (e) {
      _logger.e('Failed to get analytics data: $e');
      return null;
    }
  }

  Future<void> clearAnalyticsData() async {
    try {
      await _analyticsBox?.clear();
      _logger.i('Analytics data cleared');
    } catch (e) {
      _logger.e('Failed to clear analytics data: $e');
    }
  }

  // Offline data operations
  Future<void> setOfflineData(String key, dynamic value) async {
    try {
      await _offlineBox?.put(key, value);
      _logger.d('Offline data set: $key');
    } catch (e) {
      _logger.e('Failed to set offline data: $e');
    }
  }

  Future<T?> getOfflineData<T>(String key) async {
    try {
      final value = _offlineBox?.get(key) as T?;
      return value;
    } catch (e) {
      _logger.e('Failed to get offline data: $e');
      return null;
    }
  }

  Future<void> removeOfflineData(String key) async {
    try {
      await _offlineBox?.delete(key);
      _logger.d('Offline data removed: $key');
    } catch (e) {
      _logger.e('Failed to remove offline data: $e');
    }
  }

  Future<void> clearOfflineData() async {
    try {
      await _offlineBox?.clear();
      _logger.i('Offline data cleared');
    } catch (e) {
      _logger.e('Failed to clear offline data: $e');
    }
  }

  // SharedPreferences wrapper methods
  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String getString(String key, {String defaultValue = ''}) {
    return _prefs.getString(key) ?? defaultValue;
  }

  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  int getInt(String key, {int defaultValue = 0}) {
    return _prefs.getInt(key) ?? defaultValue;
  }

  Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  double getDouble(String key, {double defaultValue = 0.0}) {
    return _prefs.getDouble(key) ?? defaultValue;
  }

  Future<void> setStringList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }

  List<String> getStringList(String key, {List<String>? defaultValue}) {
    return _prefs.getStringList(key) ?? defaultValue ?? [];
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  Future<void> clear() async {
    await _prefs.clear();
  }

  // File operations
  Future<File> writeFile(String path, Uint8List data) async {
    try {
      final file = File(path);
      await file.create(recursive: true);
      await file.writeAsBytes(data);
      _logger.d('File written: $path');
      return file;
    } catch (e) {
      _logger.e('Failed to write file: $e');
      throw CacheException(
        message: 'Failed to write file: $path',
        code: 'FILE_WRITE_ERROR',
        details: e,
      );
    }
  }

  Future<Uint8List?> readFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        final data = await file.readAsBytes();
        _logger.d('File read: $path');
        return data;
      }
      return null;
    } catch (e) {
      _logger.e('Failed to read file: $e');
      return null;
    }
  }

  Future<bool> deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        _logger.d('File deleted: $path');
        return true;
      }
      return false;
    } catch (e) {
      _logger.e('Failed to delete file: $e');
      return false;
    }
  }

  Future<bool> fileExists(String path) async {
    try {
      final file = File(path);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  Future<int> getFileSize(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // Backup and restore operations
  Future<Map<String, dynamic>> exportData({
    bool includeCache = false,
    bool includeUserData = true,
    bool includeSettings = true,
    bool includeAnalytics = false,
  }) async {
    try {
      final exportData = <String, dynamic>{
        'version': '1.0',
        'timestamp': DateTime.now().toIso8601String(),
      };

      if (includeUserData && _userDataBox != null) {
        exportData['userData'] =
            Map<String, dynamic>.from(_userDataBox!.toMap());
      }

      if (includeSettings && _settingsBox != null) {
        exportData['settings'] =
            Map<String, dynamic>.from(_settingsBox!.toMap());
      }

      if (includeCache && _cacheBox != null) {
        exportData['cache'] = Map<String, dynamic>.from(_cacheBox!.toMap());
      }

      if (includeAnalytics && _analyticsBox != null) {
        exportData['analytics'] =
            Map<String, dynamic>.from(_analyticsBox!.toMap());
      }

      _logger.i('Data exported successfully');
      return exportData;
    } catch (e) {
      _logger.e('Failed to export data: $e');
      throw CacheException(
        message: 'Failed to export data',
        code: 'DATA_EXPORT_ERROR',
        details: e,
      );
    }
  }

  Future<void> importData(Map<String, dynamic> data) async {
    try {
      if (data['userData'] != null && _userDataBox != null) {
        await _userDataBox!.clear();
        await _userDataBox!.putAll(Map<String, dynamic>.from(data['userData']));
      }

      if (data['settings'] != null && _settingsBox != null) {
        await _settingsBox!.clear();
        await _settingsBox!.putAll(Map<String, dynamic>.from(data['settings']));
      }

      if (data['cache'] != null && _cacheBox != null) {
        await _cacheBox!.clear();
        await _cacheBox!.putAll(Map<String, dynamic>.from(data['cache']));
      }

      if (data['analytics'] != null && _analyticsBox != null) {
        await _analyticsBox!.clear();
        await _analyticsBox!
            .putAll(Map<String, dynamic>.from(data['analytics']));
      }

      _logger.i('Data imported successfully');
    } catch (e) {
      _logger.e('Failed to import data: $e');
      throw CacheException(
        message: 'Failed to import data',
        code: 'DATA_IMPORT_ERROR',
        details: e,
      );
    }
  }

  // Storage statistics
  Map<String, dynamic> getStorageStatistics() {
    return {
      'total_storage_used': _totalStorageUsed,
      'total_storage_formatted': _formatBytes(_totalStorageUsed),
      'memory_cache_size': _memoryCacheSize,
      'memory_cache_formatted': _formatBytes(_memoryCacheSize),
      'memory_cache_entries': _memoryCache.length,
      'cache_hits': _cacheHits,
      'cache_misses': _cacheMisses,
      'cache_hit_ratio': cacheHitRatio,
      'secure_operations': _secureOperations,
      'last_cleanup': _lastCleanup?.toIso8601String(),
      'box_sizes': _boxSizes.map((key, value) =>
          MapEntry(key, {'bytes': value, 'formatted': _formatBytes(value)})),
      'storage_directory': _storageDirectory,
      'cache_directory': _cacheDirectory,
      'data_directory': _dataDirectory,
      'temp_directory': _tempDirectory,
    };
  }

  // Manual cleanup trigger
  Future<void> performManualCleanup() async {
    await _performCleanup();
  }

  // Storage health check
  Future<Map<String, dynamic>> performHealthCheck() async {
    try {
      final health = <String, dynamic>{
        'timestamp': DateTime.now().toIso8601String(),
        'status': 'healthy',
        'issues': <String>[],
        'recommendations': <String>[],
      };

      // Check storage usage
      await _calculateStorageUsage();

      if (_totalStorageUsed > 1024 * 1024 * 1024) {
        // 1GB
        health['issues']
            .add('High storage usage: ${_formatBytes(_totalStorageUsed)}');
        health['recommendations']
            .add('Consider clearing cache or offline data');
      }

      // Check memory cache
      if (_memoryCacheSize > _maxMemoryCacheSize * 0.9) {
        health['issues'].add('Memory cache near limit');
        health['recommendations']
            .add('Memory cache will be automatically cleaned');
      }

      // Check cache hit ratio
      if (cacheHitRatio < 0.5 && (_cacheHits + _cacheMisses) > 100) {
        health['issues'].add(
            'Low cache hit ratio: ${(cacheHitRatio * 100).toStringAsFixed(1)}%');
        health['recommendations']
            .add('Cache configuration may need adjustment');
      }

      // Check for cleanup frequency
      if (_lastCleanup != null) {
        final timeSinceCleanup = DateTime.now().difference(_lastCleanup!);
        if (timeSinceCleanup.inHours > 24) {
          health['issues']
              .add('Last cleanup was ${timeSinceCleanup.inHours} hours ago');
          health['recommendations'].add('Consider running manual cleanup');
        }
      }

      if ((health['issues'] as List).isNotEmpty) {
        health['status'] = 'warning';
      }

      return health;
    } catch (e) {
      return {
        'timestamp': DateTime.now().toIso8601String(),
        'status': 'error',
        'error': e.toString(),
      };
    }
  }

  // Dispose resources
  Future<void> dispose() async {
    try {
      _cleanupTimer?.cancel();

      // Cancel file watchers
      for (final subscription in _fileWatchers.values) {
        await subscription.cancel();
      }
      _fileWatchers.clear();

      // Close Hive boxes
      await _cacheBox?.close();
      await _userDataBox?.close();
      await _settingsBox?.close();
      await _analyticsBox?.close();
      await _offlineBox?.close();
      await _secureBox?.close();

      // Clear memory cache
      _memoryCache.clear();
      _memoryCacheSize = 0;

      _logger.i('Storage Service disposed');
    } catch (e) {
      _logger.e('Error disposing Storage Service: $e');
    }
  }
}

// Cache entry model
class CacheEntry {
  final dynamic value;
  final DateTime expiry;
  final DateTime created;

  CacheEntry({
    required this.value,
    required this.expiry,
    required this.created,
  });

  bool isExpired(DateTime now) => now.isAfter(expiry);

  Duration get age => DateTime.now().difference(created);
  Duration get timeUntilExpiry => expiry.difference(DateTime.now());

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'expiry': expiry.toIso8601String(),
      'created': created.toIso8601String(),
    };
  }

  factory CacheEntry.fromJson(Map<String, dynamic> json) {
    return CacheEntry(
      value: json['value'],
      expiry: DateTime.parse(json['expiry']),
      created: DateTime.parse(json['created']),
    );
  }
}

// Hive adapter for CacheEntry
class CacheEntryAdapter extends TypeAdapter<CacheEntry> {
  @override
  final int typeId = 0;

  @override
  CacheEntry read(BinaryReader reader) {
    return CacheEntry(
      value: reader.read(),
      expiry: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      created: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, CacheEntry obj) {
    writer.write(obj.value);
    writer.writeInt(obj.expiry.millisecondsSinceEpoch);
    writer.writeInt(obj.created.millisecondsSinceEpoch);
  }
}
