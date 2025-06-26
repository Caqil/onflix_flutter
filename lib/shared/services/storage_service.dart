import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:onflix/core/constants/app_constants.dart';
import 'package:onflix/core/errors/exceptions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';


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

  // Storage management
  String? _storageDirectory;
  int _totalStorageUsed = 0;
  final Map<String, int> _boxSizes = {};

  // Cache management
  final Map<String, CacheEntry> _memoryCache = {};
  Timer? _cleanupTimer;

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
  }

  static StorageService get instance {
    _instance ??= StorageService._();
    return _instance!;
  }

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
      final cacheDir = Directory('${appDir.path}/cache');
      final dataDir = Directory('${appDir.path}/data');
      final tempDir = Directory('${appDir.path}/temp');

      for (final dir in [cacheDir, dataDir, tempDir]) {
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

      // Open boxes for different data types
      _cacheBox = await Hive.openBox('cache');
      _userDataBox = await Hive.openBox('user_data');
      _settingsBox = await Hive.openBox('settings');
      _analyticsBox = await Hive.openBox('analytics');
      _offlineBox = await Hive.openBox('offline');

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
      for (final boxName in [
        'cache',
        'user_data',
        'settings',
        'analytics',
        'offline'
      ]) {
        final box = Hive.box(boxName);
        final size = await _calculateBoxSize(box);
        _boxSizes[boxName] = size;
        _totalStorageUsed += size;
      }

      // Calculate file storage usage
      if (_storageDirectory != null) {
        final cacheDir = Directory('$_storageDirectory/cache');
        if (await cacheDir.exists()) {
          final cacheSize = await _calculateDirectorySize(cacheDir);
          _boxSizes['file_cache'] = cacheSize;
          _totalStorageUsed += cacheSize;
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
          size += await entity.length();
        }
      }
      return size;
    } catch (e) {
      _logger.w('Failed to calculate directory size: $e');
      return 0;
    }
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

      // Recalculate storage usage
      await _calculateStorageUsage();

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
              keysToDelete.add(key);
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
      _memoryCache.remove(key);
    }

    if (keysToRemove.isNotEmpty) {
      _logger.d('Cleaned ${keysToRemove.length} expired memory cache entries');
    }
  }

  // Clean temporary files
  Future<void> _cleanTemporaryFiles() async {
    try {
      if (_storageDirectory == null) return;

      final tempDir = Directory('$_storageDirectory/temp');
      if (await tempDir.exists()) {
        await for (final entity in tempDir.list()) {
          if (entity is File) {
            final stat = await entity.stat();
            final age = DateTime.now().difference(stat.modified);

            // Delete files older than 24 hours
            if (age.inHours > 24) {
              await entity.delete();
            }
          }
        }
      }
    } catch (e) {
      _logger.w('Failed to clean temporary files: $e');
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
        _memoryCache[key] = CacheEntry(
          value: value,
          expiry: expiry,
          created: DateTime.now(),
        );
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
          _logger.d('Cache hit (memory): $key');
          return entry.value as T?;
        } else {
          _memoryCache.remove(key);
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
              _memoryCache[key] = CacheEntry(
                value: value,
                expiry: expiry,
                created: DateTime.parse(data['created']),
              );
            }

            _logger.d('Cache hit (Hive): $key');
            return value;
          } else {
            // Expired, remove it
            await _cacheBox?.delete(key);
          }
        }
      }

      _logger.d('Cache miss: $key');
      return null;
    } catch (e) {
      _logger.e('Failed to get cache: $e');
      return null;
    }
  }

  // Remove cache entry
  Future<void> removeCache(String key) async {
    try {
      await _cacheBox?.delete(key);
      _memoryCache.remove(key);
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

  // File operations
  Future<void> saveFile(String fileName, List<int> data) async {
    try {
      final file = File('$_storageDirectory/cache/$fileName');
      await file.writeAsBytes(data);
      _logger.d('File saved: $fileName');
    } catch (e) {
      _logger.e('Failed to save file: $e');
      throw CacheException(
        message: 'Failed to save file: $fileName',
        code: 'FILE_SAVE_ERROR',
        details: e,
      );
    }
  }

  Future<List<int>?> readFile(String fileName) async {
    try {
      final file = File('$_storageDirectory/cache/$fileName');
      if (await file.exists()) {
        final data = await file.readAsBytes();
        _logger.d('File read: $fileName');
        return data;
      }
      return null;
    } catch (e) {
      _logger.e('Failed to read file: $e');
      return null;
    }
  }

  Future<void> deleteFile(String fileName) async {
    try {
      final file = File('$_storageDirectory/cache/$fileName');
      if (await file.exists()) {
        await file.delete();
        _logger.d('File deleted: $fileName');
      }
    } catch (e) {
      _logger.e('Failed to delete file: $e');
    }
  }

  Future<bool> fileExists(String fileName) async {
    try {
      final file = File('$_storageDirectory/cache/$fileName');
      return await file.exists();
    } catch (e) {
      _logger.e('Failed to check file existence: $e');
      return false;
    }
  }

  // SharedPreferences shortcuts
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key, {String? defaultValue}) {
    return _prefs.getString(key) ?? defaultValue;
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs.getBool(key) ?? defaultValue;
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

  // Encryption utilities
  String _generateKey(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Secure storage operations
  Future<void> setSecureData(String key, dynamic value) async {
    try {
      final jsonString = jsonEncode(value);
      final encryptedData = _encryptData(jsonString);
      await _userDataBox?.put('secure_$key', encryptedData);
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
}
