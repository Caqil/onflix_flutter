import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_keys.dart';
import '../constants/app_constants.dart';
import '../config/environment.dart';
import 'pocketbase_client.dart';

// Logging Interceptor
class LoggingInterceptor extends Interceptor {
  final Logger logger;

  LoggingInterceptor(this.logger);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (Environment.isDebug) {
      logger.d('''
🚀 REQUEST
${options.method.toUpperCase()} ${options.uri}
Headers: ${options.headers}
Data: ${options.data}
''');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (Environment.isDebug) {
      logger.i('''
✅ RESPONSE
${response.statusCode} ${response.requestOptions.uri}
Headers: ${response.headers}
Data: ${response.data}
''');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (Environment.isDebug) {
      logger.e('''
❌ ERROR
${err.response?.statusCode} ${err.requestOptions.uri}
Message: ${err.message}
Response: ${err.response?.data}
''');
    }
    super.onError(err, handler);
  }
}

// Authentication Interceptor
class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Get auth token from storage
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(StorageKeys.authToken);

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Add API key if available
    if (Environment.apiKey.isNotEmpty) {
      options.headers['X-API-Key'] = Environment.apiKey;
    }

    // Add user agent
    options.headers['User-Agent'] =
        'Onflix/${AppConstants.appVersion} (Flutter)';

    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired or invalid, try to refresh
      final refreshed = await _tryRefreshToken();

      if (refreshed) {
        // Retry the original request
        final options = err.requestOptions;
        final prefs = await SharedPreferences.getInstance();
        final newToken = prefs.getString(StorageKeys.authToken);

        if (newToken != null) {
          options.headers['Authorization'] = 'Bearer $newToken';

          try {
            final dio = Dio();
            final response = await dio.fetch(options);
            return handler.resolve(response);
          } catch (e) {
            return handler.next(err);
          }
        }
      } else {
        // Refresh failed, clear tokens and redirect to login
        await _clearAuthTokens();
      }
    }

    super.onError(err, handler);
  }

  Future<bool> _tryRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(StorageKeys.refreshToken);

      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      final pb = PocketBaseClient.instance.client;
      await pb.collection('users').authRefresh();

      // Save new tokens
      final authRecord = pb.authStore.model;
      final newToken = pb.authStore.token;

      if (authRecord != null) {
        await prefs.setString(StorageKeys.authToken, newToken);
        await prefs.setString(StorageKeys.userId, authRecord.id);
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> _clearAuthTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.authToken);
    await prefs.remove(StorageKeys.refreshToken);
    await prefs.remove(StorageKeys.userId);
    await prefs.setBool(StorageKeys.isLoggedIn, false);

    // Clear PocketBase auth store
    PocketBaseClient.instance.client.authStore.clear();
  }
}

// Retry Interceptor
class RetryInterceptor extends Interceptor {
  static const int maxRetries = AppConstants.maxRetries;
  static const Duration retryDelay = AppConstants.retryDelay;

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;

      if (retryCount < maxRetries) {
        err.requestOptions.extra['retryCount'] = retryCount + 1;

        // Wait before retrying
        await Future.delayed(retryDelay * (retryCount + 1));

        try {
          final dio = Dio();
          final response = await dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (e) {
          return super.onError(err, handler);
        }
      }
    }

    super.onError(err, handler);
  }

  bool _shouldRetry(DioException err) {
    // Retry on network errors
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return true;
    }

    // Retry on specific HTTP status codes
    final statusCode = err.response?.statusCode;
    if (statusCode != null) {
      return statusCode >= 500 ||
          statusCode == 429; // Server errors or rate limiting
    }

    return false;
  }
}

// Error Interceptor
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Log error details
    _logError(err);

    // Add additional error context
    err.requestOptions.extra['timestamp'] = DateTime.now().toIso8601String();
    err.requestOptions.extra['errorType'] = err.type.toString();

    super.onError(err, handler);
  }

  void _logError(DioException err) {
    final logger = Logger();

    logger.e('''
🔥 NETWORK ERROR
Type: ${err.type}
Message: ${err.message}
URL: ${err.requestOptions.uri}
Method: ${err.requestOptions.method}
Status Code: ${err.response?.statusCode}
Response Data: ${err.response?.data}
''');
  }
}

// Cache Interceptor
class CacheInterceptor extends Interceptor {
  final Map<String, CacheEntry> _cache = {};
  final Duration defaultCacheDuration;

  CacheInterceptor({
    this.defaultCacheDuration = const Duration(minutes: 5),
  });

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Only cache GET requests
    if (options.method.toUpperCase() != 'GET') {
      return super.onRequest(options, handler);
    }

    final cacheKey = _generateCacheKey(options);
    final cacheEntry = _cache[cacheKey];

    if (cacheEntry != null && !cacheEntry.isExpired) {
      // Return cached response
      final response = Response(
        requestOptions: options,
        data: cacheEntry.data,
        statusCode: 200,
        headers: Headers.fromMap({
          'x-cached': ['true']
        }),
      );
      return handler.resolve(response);
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Cache successful GET responses
    if (response.requestOptions.method.toUpperCase() == 'GET' &&
        response.statusCode == 200) {
      final cacheKey = _generateCacheKey(response.requestOptions);
      final cacheDuration = _getCacheDuration(response.requestOptions);

      _cache[cacheKey] = CacheEntry(
        data: response.data,
        timestamp: DateTime.now(),
        duration: cacheDuration,
      );

      // Clean up expired entries periodically
      _cleanupExpiredEntries();
    }

    super.onResponse(response, handler);
  }

  String _generateCacheKey(RequestOptions options) {
    final uri = options.uri.toString();
    final method = options.method.toUpperCase();
    return '$method:$uri';
  }

  Duration _getCacheDuration(RequestOptions options) {
    // Check if custom cache duration is specified
    final customDuration = options.extra['cacheDuration'] as Duration?;
    return customDuration ?? defaultCacheDuration;
  }

  void _cleanupExpiredEntries() {
    _cache.removeWhere((key, entry) => entry.isExpired);
  }

  void clearCache() {
    _cache.clear();
  }

  void removeCacheEntry(String pattern) {
    _cache.removeWhere((key, entry) => key.contains(pattern));
  }
}

class CacheEntry {
  final dynamic data;
  final DateTime timestamp;
  final Duration duration;

  CacheEntry({
    required this.data,
    required this.timestamp,
    required this.duration,
  });

  bool get isExpired => DateTime.now().isAfter(timestamp.add(duration));
}

// Rate Limiting Interceptor
class RateLimitInterceptor extends Interceptor {
  final Map<String, List<DateTime>> _requestHistory = {};
  final int maxRequestsPerMinute;
  final Duration timeWindow;

  RateLimitInterceptor({
    this.maxRequestsPerMinute = 60,
    this.timeWindow = const Duration(minutes: 1),
  });

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final endpoint = _getEndpoint(options);
    final now = DateTime.now();

    // Clean up old requests
    _requestHistory[endpoint]?.removeWhere(
      (timestamp) => now.difference(timestamp) > timeWindow,
    );

    final requests = _requestHistory[endpoint] ?? [];

    if (requests.length >= maxRequestsPerMinute) {
      // Rate limit exceeded
      final error = DioException(
        requestOptions: options,
        type: DioExceptionType.unknown,
        message: 'Rate limit exceeded',
      );
      return handler.reject(error);
    }

    // Record this request
    requests.add(now);
    _requestHistory[endpoint] = requests;

    super.onRequest(options, handler);
  }

  String _getEndpoint(RequestOptions options) {
    return '${options.method}:${options.path}';
  }
}

// Bandwidth Monitoring Interceptor
class BandwidthInterceptor extends Interceptor {
  int _totalBytesReceived = 0;
  int _totalBytesSent = 0;
  final List<BandwidthSample> _samples = [];

  int get totalBytesReceived => _totalBytesReceived;
  int get totalBytesSent => _totalBytesSent;

  double get averageDownloadSpeed {
    if (_samples.isEmpty) return 0.0;
    final totalBytes =
        _samples.fold<int>(0, (sum, sample) => sum + sample.bytes);
    final totalTime = _samples.fold<int>(
        0, (sum, sample) => sum + sample.duration.inMilliseconds);
    return totalTime > 0
        ? (totalBytes / totalTime) * 1000
        : 0.0; // bytes per second
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final contentLength = _getContentLength(response);
    if (contentLength > 0) {
      _totalBytesReceived += contentLength;

      // Add sample for speed calculation
      final duration = _getRequestDuration(response.requestOptions);
      if (duration.inMilliseconds > 0) {
        _samples.add(BandwidthSample(
          bytes: contentLength,
          duration: duration,
          timestamp: DateTime.now(),
        ));

        // Keep only recent samples
        final cutoff = DateTime.now().subtract(const Duration(minutes: 5));
        _samples.removeWhere((sample) => sample.timestamp.isBefore(cutoff));
      }
    }

    super.onResponse(response, handler);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['requestStartTime'] = DateTime.now();

    final contentLength = _getRequestContentLength(options);
    if (contentLength > 0) {
      _totalBytesSent += contentLength;
    }

    super.onRequest(options, handler);
  }

  int _getContentLength(Response response) {
    final contentLength = response.headers.value(Headers.contentLengthHeader);
    return int.tryParse(contentLength ?? '0') ?? 0;
  }

  int _getRequestContentLength(RequestOptions options) {
    if (options.data is String) {
      return (options.data as String).length;
    } else if (options.data is List<int>) {
      return (options.data as List<int>).length;
    }
    return 0;
  }

  Duration _getRequestDuration(RequestOptions options) {
    final startTime = options.extra['requestStartTime'] as DateTime?;
    if (startTime != null) {
      return DateTime.now().difference(startTime);
    }
    return Duration.zero;
  }

  void reset() {
    _totalBytesReceived = 0;
    _totalBytesSent = 0;
    _samples.clear();
  }
}

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

// Request/Response Transformation Interceptor
class TransformInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Transform request data if needed
    if (options.data is Map<String, dynamic>) {
      final data = Map<String, dynamic>.from(options.data);

      // Add timestamp to all requests
      data['timestamp'] = DateTime.now().toIso8601String();

      // Add client information
      data['clientInfo'] = {
        'platform': 'flutter',
        'version': AppConstants.appVersion,
      };

      options.data = data;
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Transform response data if needed
    if (response.data is Map<String, dynamic>) {
      final data = Map<String, dynamic>.from(response.data);

      // Add response processing timestamp
      data['processedAt'] = DateTime.now().toIso8601String();

      response.data = data;
    }

    super.onResponse(response, handler);
  }
}

// Network Quality Detection Interceptor
class NetworkQualityInterceptor extends Interceptor {
  NetworkQuality _currentQuality = NetworkQuality.unknown;
  final List<Duration> _latencySamples = [];

  NetworkQuality get currentQuality => _currentQuality;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['requestStartTime'] = DateTime.now();
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final startTime =
        response.requestOptions.extra['requestStartTime'] as DateTime?;
    if (startTime != null) {
      final latency = DateTime.now().difference(startTime);
      _updateNetworkQuality(latency);
    }

    super.onResponse(response, handler);
  }

  void _updateNetworkQuality(Duration latency) {
    _latencySamples.add(latency);

    // Keep only recent samples
    if (_latencySamples.length > 10) {
      _latencySamples.removeAt(0);
    }

    // Calculate average latency
    final totalMs = _latencySamples.fold<int>(
      0,
      (sum, duration) => sum + duration.inMilliseconds,
    );
    final averageMs = totalMs / _latencySamples.length;

    // Determine network quality based on latency
    if (averageMs < 100) {
      _currentQuality = NetworkQuality.excellent;
    } else if (averageMs < 300) {
      _currentQuality = NetworkQuality.good;
    } else if (averageMs < 600) {
      _currentQuality = NetworkQuality.fair;
    } else if (averageMs < 1000) {
      _currentQuality = NetworkQuality.poor;
    } else {
      _currentQuality = NetworkQuality.bad;
    }
  }
}

enum NetworkQuality {
  unknown,
  excellent,
  good,
  fair,
  poor,
  bad,
}

// Custom Headers Interceptor
class CustomHeadersInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add custom headers
    options.headers.addAll({
      'X-App-Name': AppConstants.appName,
      'X-App-Version': AppConstants.appVersion,
      'X-Platform': Platform.operatingSystem,
      'X-Platform-Version': Platform.operatingSystemVersion,
      'X-Request-ID': _generateRequestId(),
      'X-Timestamp': DateTime.now().toIso8601String(),
    });

    super.onRequest(options, handler);
  }

  String _generateRequestId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${_generateRandomString(8)}';
  }

  String _generateRandomString(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return String.fromCharCodes(
      Iterable.generate(
          length, (i) => chars.codeUnitAt((random + i) % chars.length)),
    );
  }
}
