
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' as multipartFile;
import 'package:onflix/shared/models/api_response.dart';
import 'package:onflix/shared/models/pagination.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../config/environment.dart';
import '../constants/storage_keys.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';

class PBResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final String? error;

  const PBResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
  });

  factory PBResponse.success(T data, {String? message}) {
    return PBResponse(
      success: true,
      data: data,
      message: message,
    );
  }

  factory PBResponse.error(String error) {
    return PBResponse(
      success: false,
      error: error,
    );
  }
}

// Simple pagination wrapper
class PBPaginatedResponse<T> {
  final int page;
  final int perPage;
  final int totalItems;
  final int totalPages;
  final List<T> items;

  const PBPaginatedResponse({
    required this.page,
    required this.perPage,
    required this.totalItems,
    required this.totalPages,
    required this.items,
  });

  bool get hasNextPage => page < totalPages;
  bool get hasPrevPage => page > 1;
}

class PocketBaseClient {
  static PocketBaseClient? _instance;
  late PocketBase _pb;
  late Logger _logger;
  late SharedPreferences _prefs;

  // Auth state
  bool _isInitialized = false;
  StreamController<bool>? _authStateController;
  StreamController<RecordModel?>? _userController;
  Timer? _tokenRefreshTimer;

  // Connection state
  bool _isOnline = true;
  late StreamSubscription _connectivitySubscription;

  // Request queue for offline support
  final List<QueuedRequest> _requestQueue = [];
  bool _isProcessingQueue = false;

  PocketBaseClient._() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
    );

    _pb = PocketBase(
      Environment.pocketbaseUrl,
      lang: 'en-US',
      httpClientFactory: _createHttpClient,
    );

    _setupConnectivityListener();
    _setupAuthStateListener();
  }

  static PocketBaseClient get instance {
    _instance ??= PocketBaseClient._();
    return _instance!;
  }

  // Initialize the client
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _logger.i('Initializing PocketBase client...');

      _prefs = await SharedPreferences.getInstance();
      await _restoreAuthState();

      _isInitialized = true;
      _logger.i('PocketBase client initialized successfully');
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize PocketBase client',
          error: e, stackTrace: stackTrace);
      throw NetworkException(
        message: 'Failed to initialize PocketBase client: $e',
        code: 'INITIALIZATION_ERROR',
        details: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Getters
  PocketBase get client => _pb;
  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _pb.authStore.isValid;
  bool get isOnline => _isOnline;
  RecordModel? get currentUser => _pb.authStore.model;
  String? get authToken => _pb.authStore.token;

  // Auth state streams
  Stream<bool> get authStateStream =>
      _authStateController?.stream ?? const Stream.empty();
  Stream<RecordModel?> get userStream =>
      _userController?.stream ?? const Stream.empty();

  // HTTP client factory for custom configuration
  HttpClient _createHttpClient() {
    final client = HttpClient();
    client.connectionTimeout =
        const Duration(milliseconds: AppConstants.connectionTimeout);
    client.idleTimeout =
        const Duration(milliseconds: AppConstants.receiveTimeout);

    // Disable certificate verification in development
    if (Environment.isDebug) {
      client.badCertificateCallback = (cert, host, port) => true;
    }

    return client;
  }

  // Setup connectivity listener
  void _setupConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (ConnectivityResult result) {
        final wasOnline = _isOnline;
        _isOnline = result == ConnectivityResult.wifi ||
            result == ConnectivityResult.mobile ||
            result == ConnectivityResult.ethernet;

        if (!wasOnline && _isOnline) {
          _logger.i('Connection restored, processing queued requests');
          _processRequestQueue();
        } else if (wasOnline && !_isOnline) {
          _logger.w('Connection lost, requests will be queued');
        }
      },
      onError: (error) {
        _logger.e('Connectivity listener error: $error');
      },
    );
  }

  // Setup auth state listener
  void _setupAuthStateListener() {
    _authStateController = StreamController<bool>.broadcast();
    _userController = StreamController<RecordModel?>.broadcast();

    // Listen to auth store changes
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isInitialized) return;

      final isValid = _pb.authStore.isValid;
      final user = _pb.authStore.model;

      _authStateController?.add(isValid);
      _userController?.add(user);

      // Setup token refresh if authenticated
      if (isValid && _tokenRefreshTimer == null) {
        _setupTokenRefresh();
      } else if (!isValid && _tokenRefreshTimer != null) {
        _tokenRefreshTimer?.cancel();
        _tokenRefreshTimer = null;
      }
    });
  }

  // Setup automatic token refresh
  void _setupTokenRefresh() {
    _tokenRefreshTimer?.cancel();

    const refreshInterval = Duration(minutes: 15); // Refresh every 15 minutes
    _tokenRefreshTimer = Timer.periodic(refreshInterval, (timer) async {
      if (_pb.authStore.isValid) {
        try {
          await refreshAuth();
          _logger.d('Token refreshed automatically');
        } catch (e) {
          _logger.w('Failed to refresh token automatically: $e');
          // If refresh fails, clear auth state
          await logout();
        }
      } else {
        timer.cancel();
        _tokenRefreshTimer = null;
      }
    });
  }

  // Restore auth state from storage
  Future<void> _restoreAuthState() async {
    try {
      final token = _prefs.getString(StorageKeys.authToken);
      final userJson = _prefs.getString('auth_user');

      if (token != null && userJson != null) {
        final userData = jsonDecode(userJson);
        _pb.authStore.save(token, RecordModel.fromJson(userData));

        // Verify token is still valid
        try {
          await _pb.collection('users').authRefresh();
          await _saveAuthState();
          _logger.i('Auth state restored successfully');
        } catch (e) {
          _logger.w('Stored token invalid, clearing auth state');
          await _clearAuthState();
        }
      }
    } catch (e) {
      _logger.e('Failed to restore auth state: $e');
      await _clearAuthState();
    }
  }

  // Save auth state to storage
  Future<void> _saveAuthState() async {
    try {
      if (_pb.authStore.isValid) {
        await _prefs.setString(StorageKeys.authToken, _pb.authStore.token!);
        await _prefs.setString(StorageKeys.userId, _pb.authStore.model!.id);
        await _prefs.setString(
            'auth_user', jsonEncode(_pb.authStore.model!.toJson()));
        await _prefs.setBool(StorageKeys.isLoggedIn, true);
        await _prefs.setString(
            StorageKeys.lastLoginDate, DateTime.now().toIso8601String());
      }
    } catch (e) {
      _logger.e('Failed to save auth state: $e');
    }
  }

  // Clear auth state from storage
  Future<void> _clearAuthState() async {
    try {
      await _prefs.remove(StorageKeys.authToken);
      await _prefs.remove(StorageKeys.refreshToken);
      await _prefs.remove(StorageKeys.userId);
      await _prefs.remove('auth_user');
      await _prefs.setBool(StorageKeys.isLoggedIn, false);
      _pb.authStore.clear();
    } catch (e) {
      _logger.e('Failed to clear auth state: $e');
    }
  }

  // Authentication methods
  Future<PBResponse<RecordModel>> authenticateWithPassword(
    String email,
    String password, {
    bool rememberMe = false,
  }) async {
    try {
      _logger.i('Attempting authentication for: $email');

      final authData =
          await _pb.collection('users').authWithPassword(email, password);

      await _saveAuthState();

      if (rememberMe) {
        await _prefs.setBool(StorageKeys.rememberMe, true);
      }

      _logger.i('Authentication successful');
      return PBResponse.success(authData.record!, message: 'Login successful');
    } catch (e) {
      _logger.e('Authentication failed: $e');

      if (e.toString().contains('Failed to authenticate')) {
        throw AuthException.invalidCredentials();
      } else if (e.toString().contains('User not found')) {
        throw AuthException.userNotFound();
      } else if (e.toString().contains('email')) {
        throw AuthException.emailNotVerified();
      }

      throw AuthException(
        message: 'Authentication failed: $e',
        code: 'AUTH_FAILED',
        details: e,
      );
    }
  }

  Future<PBResponse<RecordModel>> register({
    required String email,
    required String password,
    required String passwordConfirm,
    String? name,
    String? username,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      _logger.i('Attempting registration for: $email');

      final data = {
        'email': email,
        'password': password,
        'passwordConfirm': passwordConfirm,
        if (name != null) 'name': name,
        if (username != null) 'username': username,
        'emailVisibility': false,
        ...?additionalData,
      };

      final record = await _pb.collection('users').create(body: data);

      _logger.i('Registration successful');
      return PBResponse.success(record, message: 'Registration successful');
    } catch (e) {
      _logger.e('Registration failed: $e');

      if (e.toString().contains('email')) {
        if (e.toString().contains('already exists')) {
          throw AuthException.emailAlreadyExists();
        }
      } else if (e.toString().contains('username')) {
        throw AuthException.usernameAlreadyExists();
      }

      throw ValidationException(
        message: 'Registration failed: $e',
        details: e,
      );
    }
  }

  Future<void> requestPasswordReset(String email) async {
    try {
      _logger.i('Requesting password reset for: $email');

      await _pb.collection('users').requestPasswordReset(email);

      _logger.i('Password reset requested successfully');
    } catch (e) {
      _logger.e('Password reset request failed: $e');
      throw AuthException(
        message: 'Failed to request password reset: $e',
        code: 'PASSWORD_RESET_FAILED',
        details: e,
      );
    }
  }

  Future<void> confirmPasswordReset({
    required String token,
    required String password,
    required String passwordConfirm,
  }) async {
    try {
      _logger.i('Confirming password reset');

      await _pb.collection('users').confirmPasswordReset(
            token,
            password,
            passwordConfirm,
          );

      _logger.i('Password reset confirmed successfully');
    } catch (e) {
      _logger.e('Password reset confirmation failed: $e');
      throw AuthException(
        message: 'Failed to confirm password reset: $e',
        code: 'PASSWORD_RESET_CONFIRM_FAILED',
        details: e,
      );
    }
  }

  Future<void> requestVerification(String email) async {
    try {
      _logger.i('Requesting email verification for: $email');

      await _pb.collection('users').requestVerification(email);

      _logger.i('Email verification requested successfully');
    } catch (e) {
      _logger.e('Email verification request failed: $e');
      throw AuthException(
        message: 'Failed to request email verification: $e',
        code: 'VERIFICATION_REQUEST_FAILED',
        details: e,
      );
    }
  }

  Future<void> confirmVerification(String token) async {
    try {
      _logger.i('Confirming email verification');

      await _pb.collection('users').confirmVerification(token);

      _logger.i('Email verification confirmed successfully');
    } catch (e) {
      _logger.e('Email verification confirmation failed: $e');
      throw AuthException(
        message: 'Failed to confirm email verification: $e',
        code: 'VERIFICATION_CONFIRM_FAILED',
        details: e,
      );
    }
  }

  Future<void> refreshAuth() async {
    try {
      if (!_pb.authStore.isValid) {
        throw AuthException.tokenExpired();
      }

      await _pb.collection('users').authRefresh();
      await _saveAuthState();

      _logger.d('Auth token refreshed successfully');
    } catch (e) {
      _logger.e('Auth refresh failed: $e');
      await logout();
      throw AuthException.tokenExpired();
    }
  }

  Future<void> logout() async {
    try {
      _logger.i('Logging out user');

      _tokenRefreshTimer?.cancel();
      _tokenRefreshTimer = null;

      await _clearAuthState();

      _logger.i('Logout successful');
    } catch (e) {
      _logger.e('Logout failed: $e');
    }
  }

  // Collection shortcuts with error handling
  Future<PBResponse<RecordModel>> createRecord(
    String collection,
    Map<String, dynamic> data, {
    Map<String, dynamic>? query,
    List<MultipartFile>? files,
  }) async {
    return _executeWithErrorHandling(() async {
      final record = await _pb.collection(collection).create(
            body: data,
            query: query!,
            files: files!,
          );
      return PBResponse.success(record);
    });
  }

  Future<PBResponse<RecordModel>> getRecord(
    String collection,
    String id, {
    Map<String, dynamic>? query,
  }) async {
    return _executeWithErrorHandling(() async {
      final record = await _pb.collection(collection).getOne(id, query: query!);
      return PBResponse.success(record);
    });
  }

  Future<PBResponse<PBPaginatedResponse<RecordModel>>> getRecords(
    String collection, {
    int page = 1,
    int perPage = 20,
    String? filter,
    String? sort,
    List<String>? expand,
    Map<String, dynamic>? query,
  }) async {
    return _executeWithErrorHandling(() async {
      final params = <String, dynamic>{
        'page': page,
        'perPage': perPage,
        if (filter != null) 'filter': filter,
        if (sort != null) 'sort': sort,
        if (expand != null) 'expand': expand.join(','),
        ...?query,
      };

      final result = await _pb.collection(collection).getList(query: params);

      final paginatedResponse = PBPaginatedResponse<RecordModel>(
        page: result.page,
        perPage: result.perPage,
        totalItems: result.totalItems,
        totalPages: result.totalPages,
        items: result.items,
      );

      return PBResponse.success(paginatedResponse);
    });
  }

  Future<PBResponse<RecordModel>> updateRecord(
    String collection,
    String id,
    Map<String, dynamic> data, {
    Map<String, dynamic>? query,
    List<MultipartFile>? files,
  }) async {
    return _executeWithErrorHandling(() async {
      final record = await _pb.collection(collection).update(
            id,
            body: data,
            query: query,
            files: files,
          );
      return PBResponse.success(record);
    });
  }

  Future<PBResponse<bool>> deleteRecord(
    String collection,
    String id, {
    Map<String, dynamic>? query,
  }) async {
    return _executeWithErrorHandling(() async {
      await _pb.collection(collection).delete(id, query: query!);
      return PBResponse.success(true);
    });
  }

  // Search functionality
  Future<PBResponse<PBPaginatedResponse<RecordModel>>> searchRecords(
    String collection,
    String searchTerm, {
    List<String> searchFields = const ['title', 'description'],
    int page = 1,
    int perPage = 20,
    String? additionalFilter,
    String? sort,
    List<String>? expand,
  }) async {
    return _executeWithErrorHandling(() async {
      final searchConditions =
          searchFields.map((field) => '$field~"$searchTerm"').join('||');

      final filter = additionalFilter != null
          ? '($searchConditions) && ($additionalFilter)'
          : searchConditions;

      return await getRecords(
        collection,
        page: page,
        perPage: perPage,
        filter: filter,
        sort: sort,
        expand: expand,
      );
    });
  }

  // File operations
  Future<String> getFileUrl(
    String collection,
    String recordId,
    String filename, {
    String? thumb,
  }) async {
    try {
      final baseUrl =
          '${_pb.baseUrl}/api/files/$collection/$recordId/$filename';
      return thumb != null ? '$baseUrl?thumb=$thumb' : baseUrl;
    } catch (e) {
      throw ContentException(
        message: 'Failed to generate file URL: $e',
        code: 'FILE_URL_ERROR',
        details: e,
      );
    }
  }

  Future<PBResponse<RecordModel>> uploadFile(
    String collection,
    String id,
    String fieldName,
    String filePath, {
    Map<String, dynamic>? additionalData,
  }) async {
    return _executeWithErrorHandling(() async {
      final file = MultipartFile.fromFileSync(filePath);
      final record = await _pb.collection(collection).update(
        id,
        body: additionalData ?? {},
        files: [file],
      );
      return PBResponse.success(record);
    });
  }

  // Real-time subscriptions
  Future<void> subscribe(
    String collection,
    void Function(RecordSubscriptionEvent) callback, {
    String? filter,
    List<String>? expand,
  }) async {
    try {
      await _pb.collection(collection).subscribe(
            '*',
            callback,
            filter: filter,
            expand: expand?.join(','),
          );
      _logger.d('Subscribed to $collection updates');
    } catch (e) {
      _logger.e('Failed to subscribe to $collection: $e');
      throw NetworkException(
        message: 'Failed to subscribe to real-time updates: $e',
        code: 'SUBSCRIPTION_ERROR',
        details: e,
      );
    }
  }

  Future<void> unsubscribe([String? collection]) async {
    try {
      if (collection != null) {
        await _pb.collection(collection).unsubscribe();
        _logger.d('Unsubscribed from $collection updates');
      } else {
        await _pb.realtime.unsubscribe();
        _logger.d('Unsubscribed from all real-time updates');
      }
    } catch (e) {
      _logger.e('Failed to unsubscribe: $e');
    }
  }

  // Offline support
  Future<T> _executeWithErrorHandling<T>(Future<T> Function() operation) async {
    if (!_isOnline) {
      // Queue the request for later
      final queuedRequest = QueuedRequest(
        operation: operation,
        timestamp: DateTime.now(),
      );
      _requestQueue.add(queuedRequest);

      throw NetworkException.noConnection();
    }

    try {
      return await operation();
    } catch (e) {
      _logger.e('Operation failed: $e');

      if (e is AuthException ||
          e is ValidationException ||
          e is ContentException) {
        rethrow;
      }

      // Convert to appropriate exception
      if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        throw NetworkException.connectionFailed();
      } else if (e.toString().contains('timeout')) {
        throw NetworkException.timeout();
      } else if (e.toString().contains('401')) {
        throw AuthException.tokenExpired();
      } else if (e.toString().contains('404')) {
        throw ServerException.notFound();
      } else if (e.toString().contains('500')) {
        throw ServerException.internalError();
      }

      throw ServerException(
        message: 'Operation failed: $e',
        details: e,
      );
    }
  }

  Future<void> _processRequestQueue() async {
    if (_isProcessingQueue || _requestQueue.isEmpty || !_isOnline) return;

    _isProcessingQueue = true;
    _logger.i('Processing ${_requestQueue.length} queued requests');

    final requestsToProcess = List<QueuedRequest>.from(_requestQueue);
    _requestQueue.clear();

    for (final request in requestsToProcess) {
      try {
        await request.operation();
        _logger.d('Queued request processed successfully');
      } catch (e) {
        _logger.w('Failed to process queued request: $e');
        // Re-queue if still relevant (not too old)
        if (DateTime.now().difference(request.timestamp).inMinutes < 60) {
          _requestQueue.add(request);
        }
      }
    }

    _isProcessingQueue = false;
  }

  // Health check
  Future<bool> healthCheck() async {
    try {
      await _pb.health.check();
      return true;
    } catch (e) {
      _logger.w('Health check failed: $e');
      return false;
    }
  }

  // Cleanup
  void dispose() {
    _logger.i('Disposing PocketBase client');

    _tokenRefreshTimer?.cancel();
    _connectivitySubscription.cancel();
    _authStateController?.close();
    _userController?.close();

    _requestQueue.clear();
    _pb.authStore.clear();
  }

  // Collection getters for convenience
  RecordService get users => _pb.collection('users');
  RecordService get content => _pb.collection('content');
  RecordService get profiles => _pb.collection('profiles');
  RecordService get watchlist => _pb.collection('watchlist');
  RecordService get watchHistory => _pb.collection('watchHistory');
  RecordService get ratings => _pb.collection('ratings');
  RecordService get downloads => _pb.collection('downloads');
  RecordService get subscriptions => _pb.collection('subscriptions');
  RecordService get userSubscriptions => _pb.collection('userSubscriptions');
  RecordService get categories => _pb.collection('categories');
  RecordService get collections => _pb.collection('collections');
  RecordService get series => _pb.collection('series');
  RecordService get seasons => _pb.collection('seasons');
  RecordService get episodes => _pb.collection('episodes');
  RecordService get notifications => _pb.collection('notifications');
  RecordService get analytics => _pb.collection('analytics');
  RecordService get contentReports => _pb.collection('contentReports');
  RecordService get paymentHistory => _pb.collection('paymentHistory');
  RecordService get recommendations => _pb.collection('recommendations');
}

// Helper class for queued requests
class QueuedRequest {
  final Future<dynamic> Function() operation;
  final DateTime timestamp;

  QueuedRequest({
    required this.operation,
    required this.timestamp,
  });
}

class PocketBaseClient {
  static PocketBaseClient? _instance;
  late PocketBase _pb;
  late Logger _logger;
  late SharedPreferences _prefs;

  // Auth state
  bool _isInitialized = false;
  StreamController<bool>? _authStateController;
  StreamController<RecordModel?>? _userController;
  Timer? _tokenRefreshTimer;

  // Connection state
  bool _isOnline = true;
  late StreamSubscription _connectivitySubscription;

  // Request queue for offline support
  final List<QueuedRequest> _requestQueue = [];
  bool _isProcessingQueue = false;

  PocketBaseClient._() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
    );

    _pb = PocketBase(
      Environment.pocketbaseUrl,
      lang: 'en-US',
      httpClientFactory: _createHttpClient,
    );

    _setupConnectivityListener();
    _setupAuthStateListener();
  }

  static PocketBaseClient get instance {
    _instance ??= PocketBaseClient._();
    return _instance!;
  }

  // Initialize the client
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _logger.i('Initializing PocketBase client...');

      _prefs = await SharedPreferences.getInstance();
      await _restoreAuthState();

      _isInitialized = true;
      _logger.i('PocketBase client initialized successfully');
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize PocketBase client',
          error: e, stackTrace: stackTrace);
      throw NetworkException(
        message: 'Failed to initialize PocketBase client: $e',
        code: 'INITIALIZATION_ERROR',
        details: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Getters
  PocketBase get client => _pb;
  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _pb.authStore.isValid;
  bool get isOnline => _isOnline;
  RecordModel? get currentUser => _pb.authStore.model;
  String? get authToken => _pb.authStore.token;

  // Auth state streams
  Stream<bool> get authStateStream =>
      _authStateController?.stream ?? const Stream.empty();
  Stream<RecordModel?> get userStream =>
      _userController?.stream ?? const Stream.empty();

  // HTTP client factory for custom configuration
  HttpClient _createHttpClient() {
    final client = HttpClient();
    client.connectionTimeout =
        const Duration(milliseconds: AppConstants.connectionTimeout);
    client.idleTimeout =
        const Duration(milliseconds: AppConstants.receiveTimeout);

    // Disable certificate verification in development
    if (Environment.isDebug) {
      client.badCertificateCallback = (cert, host, port) => true;
    }

    return client;
  }

  // Setup connectivity listener
  void _setupConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final wasOnline = _isOnline;
        _isOnline = results.any((result) =>
            result == ConnectivityResult.wifi ||
            result == ConnectivityResult.mobile ||
            result == ConnectivityResult.ethernet);

        if (!wasOnline && _isOnline) {
          _logger.i('Connection restored, processing queued requests');
          _processRequestQueue();
        } else if (wasOnline && !_isOnline) {
          _logger.w('Connection lost, requests will be queued');
        }
      },
      onError: (error) {
        _logger.e('Connectivity listener error: $error');
      },
    );
  }

  // Setup auth state listener
  void _setupAuthStateListener() {
    _authStateController = StreamController<bool>.broadcast();
    _userController = StreamController<RecordModel?>.broadcast();

    // Listen to auth store changes
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isInitialized) return;

      final isValid = _pb.authStore.isValid;
      final user = _pb.authStore.model;

      _authStateController?.add(isValid);
      _userController?.add(user);

      // Setup token refresh if authenticated
      if (isValid && _tokenRefreshTimer == null) {
        _setupTokenRefresh();
      } else if (!isValid && _tokenRefreshTimer != null) {
        _tokenRefreshTimer?.cancel();
        _tokenRefreshTimer = null;
      }
    });
  }

  // Setup automatic token refresh
  void _setupTokenRefresh() {
    _tokenRefreshTimer?.cancel();

    const refreshInterval = Duration(minutes: 15); // Refresh every 15 minutes
    _tokenRefreshTimer = Timer.periodic(refreshInterval, (timer) async {
      if (_pb.authStore.isValid) {
        try {
          await refreshAuth();
          _logger.d('Token refreshed automatically');
        } catch (e) {
          _logger.w('Failed to refresh token automatically: $e');
          // If refresh fails, clear auth state
          await logout();
        }
      } else {
        timer.cancel();
        _tokenRefreshTimer = null;
      }
    });
  }

  // Restore auth state from storage
  Future<void> _restoreAuthState() async {
    try {
      final token = _prefs.getString(StorageKeys.authToken);
      final userJson = _prefs.getString('auth_user');

      if (token != null && userJson != null) {
        final userData = jsonDecode(userJson);
        _pb.authStore.save(token, RecordModel.fromJson(userData));

        // Verify token is still valid
        try {
          await _pb.collection('users').authRefresh();
          await _saveAuthState();
          _logger.i('Auth state restored successfully');
        } catch (e) {
          _logger.w('Stored token invalid, clearing auth state');
          await _clearAuthState();
        }
      }
    } catch (e) {
      _logger.e('Failed to restore auth state: $e');
      await _clearAuthState();
    }
  }

  // Save auth state to storage
  Future<void> _saveAuthState() async {
    try {
      if (_pb.authStore.isValid) {
        await _prefs.setString(StorageKeys.authToken, _pb.authStore.token!);
        await _prefs.setString(StorageKeys.userId, _pb.authStore.model!.id);
        await _prefs.setString(
            'auth_user', jsonEncode(_pb.authStore.model!.toJson()));
        await _prefs.setBool(StorageKeys.isLoggedIn, true);
        await _prefs.setString(
            StorageKeys.lastLoginDate, DateTime.now().toIso8601String());
      }
    } catch (e) {
      _logger.e('Failed to save auth state: $e');
    }
  }

  // Clear auth state from storage
  Future<void> _clearAuthState() async {
    try {
      await _prefs.remove(StorageKeys.authToken);
      await _prefs.remove(StorageKeys.refreshToken);
      await _prefs.remove(StorageKeys.userId);
      await _prefs.remove('auth_user');
      await _prefs.setBool(StorageKeys.isLoggedIn, false);
      _pb.authStore.clear();
    } catch (e) {
      _logger.e('Failed to clear auth state: $e');
    }
  }

  // Authentication methods
  Future<ApiResponse<RecordModel>> authenticateWithPassword(
    String email,
    String password, {
    bool rememberMe = false,
  }) async {
    try {
      _logger.i('Attempting authentication for: $email');

      final authData =
          await _pb.collection('users').authWithPassword(email, password);

      await _saveAuthState();

      if (rememberMe) {
        await _prefs.setBool(StorageKeys.rememberMe, true);
      }

      _logger.i('Authentication successful');
      return ApiResponse.success(authData.record!, message: 'Login successful');
    } catch (e) {
      _logger.e('Authentication failed: $e');

      if (e.toString().contains('Failed to authenticate')) {
        throw AuthException.invalidCredentials();
      } else if (e.toString().contains('User not found')) {
        throw AuthException.userNotFound();
      } else if (e.toString().contains('email')) {
        throw AuthException.emailNotVerified();
      }

      throw AuthException(
        message: 'Authentication failed: $e',
        code: 'AUTH_FAILED',
        details: e,
      );
    }
  }

  Future<ApiResponse<RecordModel>> register({
    required String email,
    required String password,
    required String passwordConfirm,
    String? name,
    String? username,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      _logger.i('Attempting registration for: $email');

      final data = {
        'email': email,
        'password': password,
        'passwordConfirm': passwordConfirm,
        if (name != null) 'name': name,
        if (username != null) 'username': username,
        'emailVisibility': false,
        ...?additionalData,
      };

      final record = await _pb.collection('users').create(body: data);

      _logger.i('Registration successful');
      return ApiResponse.success(record, message: 'Registration successful');
    } catch (e) {
      _logger.e('Registration failed: $e');

      if (e.toString().contains('email')) {
        if (e.toString().contains('already exists')) {
          throw AuthException.emailAlreadyExists();
        }
      } else if (e.toString().contains('username')) {
        throw AuthException.usernameAlreadyExists();
      }

      throw ValidationException(
        message: 'Registration failed: $e',
        details: e,
      );
    }
  }

  Future<void> requestPasswordReset(String email) async {
    try {
      _logger.i('Requesting password reset for: $email');

      await _pb.collection('users').requestPasswordReset(email);

      _logger.i('Password reset requested successfully');
    } catch (e) {
      _logger.e('Password reset request failed: $e');
      throw AuthException(
        message: 'Failed to request password reset: $e',
        code: 'PASSWORD_RESET_FAILED',
        details: e,
      );
    }
  }

  Future<void> confirmPasswordReset({
    required String token,
    required String password,
    required String passwordConfirm,
  }) async {
    try {
      _logger.i('Confirming password reset');

      await _pb.collection('users').confirmPasswordReset(
            token,
            password,
            passwordConfirm,
          );

      _logger.i('Password reset confirmed successfully');
    } catch (e) {
      _logger.e('Password reset confirmation failed: $e');
      throw AuthException(
        message: 'Failed to confirm password reset: $e',
        code: 'PASSWORD_RESET_CONFIRM_FAILED',
        details: e,
      );
    }
  }

  Future<void> requestVerification(String email) async {
    try {
      _logger.i('Requesting email verification for: $email');

      await _pb.collection('users').requestVerification(email);

      _logger.i('Email verification requested successfully');
    } catch (e) {
      _logger.e('Email verification request failed: $e');
      throw AuthException(
        message: 'Failed to request email verification: $e',
        code: 'VERIFICATION_REQUEST_FAILED',
        details: e,
      );
    }
  }

  Future<void> confirmVerification(String token) async {
    try {
      _logger.i('Confirming email verification');

      await _pb.collection('users').confirmVerification(token);

      _logger.i('Email verification confirmed successfully');
    } catch (e) {
      _logger.e('Email verification confirmation failed: $e');
      throw AuthException(
        message: 'Failed to confirm email verification: $e',
        code: 'VERIFICATION_CONFIRM_FAILED',
        details: e,
      );
    }
  }

  Future<void> refreshAuth() async {
    try {
      if (!_pb.authStore.isValid) {
        throw AuthException.tokenExpired();
      }

      await _pb.collection('users').authRefresh();
      await _saveAuthState();

      _logger.d('Auth token refreshed successfully');
    } catch (e) {
      _logger.e('Auth refresh failed: $e');
      await logout();
      throw AuthException.tokenExpired();
    }
  }

  Future<void> logout() async {
    try {
      _logger.i('Logging out user');

      _tokenRefreshTimer?.cancel();
      _tokenRefreshTimer = null;

      await _clearAuthState();

      _logger.i('Logout successful');
    } catch (e) {
      _logger.e('Logout failed: $e');
    }
  }

  // Collection shortcuts with error handling
  Future<ApiResponse<RecordModel>> createRecord(
    String collection,
    Map<String, dynamic> data, {
    Map<String, dynamic>? query,
    List<MultipartFile>? files,
  }) async {
    return _executeWithErrorHandling(() async {
      final record = await _pb.collection(collection).create(
            body: data,
            query: query!,
            files: files,
          );
      return ApiResponse.success(record);
    });
  }

  Future<ApiResponse<RecordModel>> getRecord(
    String collection,
    String id, {
    Map<String, dynamic>? query,
  }) async {
    return _executeWithErrorHandling(() async {
      final record = await _pb.collection(collection).getOne(id, query: query!);
      return ApiResponse.success(record);
    });
  }

  Future<ApiResponse<PaginatedResponse<RecordModel>>> getRecords(
    String collection, {
    int page = 1,
    int perPage = 20,
    String? filter,
    String? sort,
    List<String>? expand,
    Map<String, dynamic>? query,
  }) async {
    return _executeWithErrorHandling(() async {
      final params = <String, dynamic>{
        'page': page,
        'perPage': perPage,
        if (filter != null) 'filter': filter,
        if (sort != null) 'sort': sort,
        if (expand != null) 'expand': expand.join(','),
        ...?query,
      };

      final result = await _pb.collection(collection).getList(query: params);

      final paginatedResponse = PaginatedResponse<RecordModel>(
        page: result.page,
        perPage: result.perPage,
        totalItems: result.totalItems,
        totalPages: result.totalPages,
        items: result.items,
      );

      return ApiResponse.success(paginatedResponse);
    });
  }

  Future<ApiResponse<RecordModel>> updateRecord(
    String collection,
    String id,
    Map<String, dynamic> data, {
    Map<String, dynamic>? query,
    List<MultipartFile>? files,
  }) async {
    return _executeWithErrorHandling(() async {
      final record = await _pb.collection(collection).update(
            id,
            body: data,
            query: query,
            files: files,
          );
      return ApiResponse.success(record);
    });
  }

  Future<ApiResponse<bool>> deleteRecord(
    String collection,
    String id, {
    Map<String, dynamic>? query,
  }) async {
    return _executeWithErrorHandling(() async {
      await _pb.collection(collection).delete(id, query: query);
      return ApiResponse.success(true);
    });
  }

  // Search functionality
  Future<ApiResponse<PaginatedResponse<RecordModel>>> searchRecords(
    String collection,
    String searchTerm, {
    List<String> searchFields = const ['title', 'description'],
    int page = 1,
    int perPage = 20,
    String? additionalFilter,
    String? sort,
    List<String>? expand,
  }) async {
    return _executeWithErrorHandling(() async {
      final searchConditions =
          searchFields.map((field) => '$field~"$searchTerm"').join('||');

      final filter = additionalFilter != null
          ? '($searchConditions) && ($additionalFilter)'
          : searchConditions;

      return await getRecords(
        collection,
        page: page,
        perPage: perPage,
        filter: filter,
        sort: sort,
        expand: expand,
      );
    });
  }

  // File operations
  Future<String> getFileUrl(
    String collection,
    String recordId,
    String filename, {
    String? thumb,
  }) async {
    try {
      final baseUrl =
          '${_pb.baseUrl}/api/files/$collection/$recordId/$filename';
      return thumb != null ? '$baseUrl?thumb=$thumb' : baseUrl;
    } catch (e) {
      throw ContentException(
        message: 'Failed to generate file URL: $e',
        code: 'FILE_URL_ERROR',
        details: e,
      );
    }
  }

  Future<ApiResponse<RecordModel>> uploadFile(
    String collection,
    String id,
    String fieldName,
    String filePath, {
    Map<String, dynamic>? additionalData,
  }) async {
    return _executeWithErrorHandling(() async {
      final file = MultipartFile.fromFileSync(filePath);
      final record = await _pb.collection(collection).update(
        id,
        body: additionalData ?? {},
        files: [file],
      );
      return ApiResponse.success(record);
    });
  }

  // Real-time subscriptions
  Future<void> subscribe(
    String collection,
    void Function(RecordSubscriptionEvent) callback, {
    String? filter,
    List<String>? expand,
  }) async {
    try {
      await _pb.collection(collection).subscribe(
            '*',
            callback,
            filter: filter,
            expand: expand?.join(','),
          );
      _logger.d('Subscribed to $collection updates');
    } catch (e) {
      _logger.e('Failed to subscribe to $collection: $e');
      throw NetworkException(
        message: 'Failed to subscribe to real-time updates: $e',
        code: 'SUBSCRIPTION_ERROR',
        details: e,
      );
    }
  }

  Future<void> unsubscribe([String? collection]) async {
    try {
      if (collection != null) {
        await _pb.collection(collection).unsubscribe();
        _logger.d('Unsubscribed from $collection updates');
      } else {
        await _pb.realtime.unsubscribe();
        _logger.d('Unsubscribed from all real-time updates');
      }
    } catch (e) {
      _logger.e('Failed to unsubscribe: $e');
    }
  }

  // Offline support
  Future<T> _executeWithErrorHandling<T>(Future<T> Function() operation) async {
    if (!_isOnline) {
      // Queue the request for later
      final queuedRequest = QueuedRequest(
        operation: operation,
        timestamp: DateTime.now(),
      );
      _requestQueue.add(queuedRequest);

      throw NetworkException.noConnection();
    }

    try {
      return await operation();
    } catch (e) {
      _logger.e('Operation failed: $e');

      if (e is AuthException ||
          e is ValidationException ||
          e is ContentException) {
        rethrow;
      }

      // Convert to appropriate exception
      if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        throw NetworkException.connectionFailed();
      } else if (e.toString().contains('timeout')) {
        throw NetworkException.timeout();
      } else if (e.toString().contains('401')) {
        throw AuthException.tokenExpired();
      } else if (e.toString().contains('404')) {
        throw ServerException.notFound();
      } else if (e.toString().contains('500')) {
        throw ServerException.internalError();
      }

      throw ServerException(
        message: 'Operation failed: $e',
        details: e,
      );
    }
  }

  Future<void> _processRequestQueue() async {
    if (_isProcessingQueue || _requestQueue.isEmpty || !_isOnline) return;

    _isProcessingQueue = true;
    _logger.i('Processing ${_requestQueue.length} queued requests');

    final requestsToProcess = List<QueuedRequest>.from(_requestQueue);
    _requestQueue.clear();

    for (final request in requestsToProcess) {
      try {
        await request.operation();
        _logger.d('Queued request processed successfully');
      } catch (e) {
        _logger.w('Failed to process queued request: $e');
        // Re-queue if still relevant (not too old)
        if (DateTime.now().difference(request.timestamp).inMinutes < 60) {
          _requestQueue.add(request);
        }
      }
    }

    _isProcessingQueue = false;
  }

  // Health check
  Future<bool> healthCheck() async {
    try {
      await _pb.health.check();
      return true;
    } catch (e) {
      _logger.w('Health check failed: $e');
      return false;
    }
  }

  // Cleanup
  void dispose() {
    _logger.i('Disposing PocketBase client');

    _tokenRefreshTimer?.cancel();
    _connectivitySubscription.cancel();
    _authStateController?.close();
    _userController?.close();

    _requestQueue.clear();
    _pb.authStore.clear();
  }

  // Collection getters for convenience
  RecordService get users => _pb.collection('users');
  RecordService get content => _pb.collection('content');
  RecordService get profiles => _pb.collection('profiles');
  RecordService get watchlist => _pb.collection('watchlist');
  RecordService get watchHistory => _pb.collection('watchHistory');
  RecordService get ratings => _pb.collection('ratings');
  RecordService get downloads => _pb.collection('downloads');
  RecordService get subscriptions => _pb.collection('subscriptions');
  RecordService get userSubscriptions => _pb.collection('userSubscriptions');
  RecordService get categories => _pb.collection('categories');
  RecordService get collections => _pb.collection('collections');
  RecordService get series => _pb.collection('series');
  RecordService get seasons => _pb.collection('seasons');
  RecordService get episodes => _pb.collection('episodes');
  RecordService get notifications => _pb.collection('notifications');
  RecordService get analytics => _pb.collection('analytics');
  RecordService get contentReports => _pb.collection('contentReports');
  RecordService get paymentHistory => _pb.collection('paymentHistory');
  RecordService get recommendations => _pb.collection('recommendations');
}

// Helper class for queued requests
class QueuedRequest {
  final Future<dynamic> Function() operation;
  final DateTime timestamp;

  QueuedRequest({
    required this.operation,
    required this.timestamp,
  });
}
