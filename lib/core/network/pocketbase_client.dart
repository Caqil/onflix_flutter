import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../shared/models/api_response.dart';
import '../../shared/models/pagination.dart';
import '../config/environment.dart';
import '../constants/storage_keys.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';

class PocketBaseClient {
  static PocketBaseClient? _instance;
  late PocketBase _pb;
  late Logger _logger;
  late SharedPreferences _prefs;

  // Auth state
  bool _isInitialized = false;
  StreamController<bool>? _authStateController;
  StreamController<RecordModel?>? _userController;
  StreamController<bool>? _adminAuthStateController;
  StreamController<RecordModel?>? _adminUserController;
  Timer? _tokenRefreshTimer;
  Timer? _adminTokenRefreshTimer;

  // Connection state
  bool _isOnline = true;
  late StreamSubscription _connectivitySubscription;

  // Request queue for offline support
  final List<QueuedRequest> _requestQueue = [];
  bool _isProcessingQueue = false;

  // Admin session tracking
  bool _isAdminMode = false;

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
  bool get isAuthenticated => _pb.authStore.isValid && !_isAdminMode;
  bool get isAdminAuthenticated => _pb.authStore.isValid && _isAdminMode;
  bool get isOnline => _isOnline;
  RecordModel? get currentUser => _isAdminMode ? null : _pb.authStore.model;
  RecordModel? get currentAdmin => _isAdminMode ? _pb.authStore.model : null;
  String? get authToken => _pb.authStore.token;
  bool get isAdminMode => _isAdminMode;

  // Auth state streams
  Stream<bool> get authStateStream =>
      _authStateController?.stream ?? const Stream.empty();
  Stream<RecordModel?> get userStream =>
      _userController?.stream ?? const Stream.empty();
  Stream<bool> get adminAuthStateStream =>
      _adminAuthStateController?.stream ?? const Stream.empty();
  Stream<RecordModel?> get adminUserStream =>
      _adminUserController?.stream ?? const Stream.empty();

  // HTTP client factory for custom configuration
  http.Client _createHttpClient() {
    return http.Client();
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
    _adminAuthStateController = StreamController<bool>.broadcast();
    _adminUserController = StreamController<RecordModel?>.broadcast();

    // Listen to auth store changes
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isInitialized) return;

      final isValid = _pb.authStore.isValid;
      final user = _pb.authStore.model;

      if (_isAdminMode) {
        _adminAuthStateController?.add(isValid);
        _adminUserController?.add(user);
        _authStateController?.add(false);
        _userController?.add(null);
      } else {
        _authStateController?.add(isValid);
        _userController?.add(user);
        _adminAuthStateController?.add(false);
        _adminUserController?.add(null);
      }

      // Setup token refresh if authenticated
      if (isValid && _isAdminMode && _adminTokenRefreshTimer == null) {
        _setupAdminTokenRefresh();
      } else if (isValid && !_isAdminMode && _tokenRefreshTimer == null) {
        _setupUserTokenRefresh();
      } else if (!isValid) {
        _tokenRefreshTimer?.cancel();
        _adminTokenRefreshTimer?.cancel();
        _tokenRefreshTimer = null;
        _adminTokenRefreshTimer = null;
      }
    });
  }

  // Setup automatic user token refresh
  void _setupUserTokenRefresh() {
    _tokenRefreshTimer?.cancel();

    const refreshInterval = Duration(minutes: 15);
    _tokenRefreshTimer = Timer.periodic(refreshInterval, (timer) async {
      if (_pb.authStore.isValid && !_isAdminMode) {
        try {
          await refreshAuth();
          _logger.d('User token refreshed automatically');
        } catch (e) {
          _logger.w('Failed to refresh user token automatically: $e');
          await logout();
        }
      } else {
        timer.cancel();
        _tokenRefreshTimer = null;
      }
    });
  }

  // Setup automatic admin token refresh
  void _setupAdminTokenRefresh() {
    _adminTokenRefreshTimer?.cancel();

    const refreshInterval = Duration(minutes: 10); // Shorter for admin sessions
    _adminTokenRefreshTimer = Timer.periodic(refreshInterval, (timer) async {
      if (_pb.authStore.isValid && _isAdminMode) {
        try {
          await refreshAdminAuth();
          _logger.d('Admin token refreshed automatically');
        } catch (e) {
          _logger.w('Failed to refresh admin token automatically: $e');
          await logoutAdmin();
        }
      } else {
        timer.cancel();
        _adminTokenRefreshTimer = null;
      }
    });
  }

  // Restore auth state from storage
  Future<void> _restoreAuthState() async {
    try {
      final token = _prefs.getString(StorageKeys.authToken);
      final refreshToken = _prefs.getString(StorageKeys.refreshToken);
      final userJson = _prefs.getString('auth_user');
      final isAdmin = _prefs.getBool('is_admin_mode') ?? false;

      if (token != null && userJson != null) {
        final userData = jsonDecode(userJson);
        _pb.authStore.save(token, userData);
        _isAdminMode = isAdmin;

        _logger.i('Auth state restored from storage');

        // Verify token is still valid
        try {
          if (_isAdminMode) {
            await refreshAdminAuth();
          } else {
            await refreshAuth();
          }
        } catch (e) {
          _logger.w('Stored token is invalid, clearing auth state: $e');
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
      if (_pb.authStore.isValid && _pb.authStore.model != null) {
        await _prefs.setString(StorageKeys.authToken, _pb.authStore.token);
        await _prefs.setString(StorageKeys.userId, _pb.authStore.model!.id);
        await _prefs.setString(
            'auth_user', jsonEncode(_pb.authStore.model!.toJson()));
        await _prefs.setBool(StorageKeys.isLoggedIn, !_isAdminMode);
        await _prefs.setBool('is_admin_mode', _isAdminMode);
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
      await _prefs.remove('is_admin_mode');
      await _prefs.setBool(StorageKeys.isLoggedIn, false);
      _pb.authStore.clear();
      _isAdminMode = false;
    } catch (e) {
      _logger.e('Failed to clear auth state: $e');
    }
  }

  // ======================
  // USER AUTHENTICATION
  // ======================

// User registration method
  Future<ApiResponse<RecordModel>> register({
    required String email,
    required String password,
    required String passwordConfirm,
    String? name,
    String? username,
  }) async {
    try {
      _logger.i('Attempting user registration for: $email');

      // Clear admin mode if registering as user
      _isAdminMode = false;

      final data = {
        'email': email,
        'password': password,
        'passwordConfirm': passwordConfirm,
      };

      if (name != null && name.isNotEmpty) {
        data['name'] = name;
      }
      if (username != null && username.isNotEmpty) {
        data['username'] = username;
      }

      final record = await _pb.collection('users').create(body: data);

      _logger.i('User registration successful');
      return ApiResponse.success(record,
          message:
              'Registration successful. Please check your email for verification.');
    } catch (e) {
      _logger.e('User registration failed: $e');

      // Handle specific PocketBase validation errors
      final errorMessage = e.toString();
      if (errorMessage.contains('email')) {
        if (errorMessage.contains('already exists')) {
          throw AuthException(
            message: 'This email address is already registered',
            code: 'EMAIL_EXISTS',
            details: e,
          );
        } else {
          throw AuthException(
            message: 'Please enter a valid email address',
            code: 'INVALID_EMAIL',
            details: e,
          );
        }
      } else if (errorMessage.contains('password')) {
        throw AuthException(
          message: 'Password must be at least 8 characters long',
          code: 'WEAK_PASSWORD',
          details: e,
        );
      } else if (errorMessage.contains('username')) {
        throw AuthException(
          message: 'This username is already taken',
          code: 'USERNAME_EXISTS',
          details: e,
        );
      }

      throw AuthException(
        message: 'Registration failed. Please try again.',
        code: 'REGISTRATION_FAILED',
        details: e,
      );
    }
  }

// Authenticate with password method (wrapper for existing authenticate method)
  Future<ApiResponse<RecordModel>> authenticateWithPassword(
    String email,
    String password, {
    bool rememberMe = false,
  }) async {
    return await authenticate('users', email, password, rememberMe: rememberMe);
  }

// Confirm email verification
  Future<void> confirmVerification(String token) async {
    try {
      _logger.i('Confirming email verification with token');
      await _pb.collection('users').confirmVerification(token);
      _logger.i('Email verification confirmed successfully');
    } catch (e) {
      _logger.e('Email verification confirmation failed: $e');

      final errorMessage = e.toString();
      if (errorMessage.contains('invalid') ||
          errorMessage.contains('expired')) {
        throw AuthException(
          message: 'Verification link is invalid or has expired',
          code: 'INVALID_VERIFICATION_TOKEN',
          details: e,
        );
      } else if (errorMessage.contains('already verified')) {
        throw AuthException(
          message: 'Email is already verified',
          code: 'ALREADY_VERIFIED',
          details: e,
        );
      }

      throw AuthException(
        message: 'Failed to verify email. Please try again.',
        code: 'VERIFICATION_FAILED',
        details: e,
      );
    }
  }

// Request email verification
  Future<void> requestVerification(String email) async {
    try {
      _logger.i('Requesting email verification for: $email');
      await _pb.collection('users').requestVerification(email);
      _logger.i('Email verification requested successfully');
    } catch (e) {
      _logger.e('Email verification request failed: $e');
      throw AuthException(
        message: 'Failed to send verification email: $e',
        code: 'VERIFICATION_REQUEST_FAILED',
        details: e,
      );
    }
  }

// Confirm password reset
  Future<void> confirmPasswordReset(
    String token,
    String password,
    String passwordConfirm,
  ) async {
    try {
      _logger.i('Confirming password reset with token');
      await _pb.collection('users').confirmPasswordReset(
            token,
            password,
            passwordConfirm,
          );
      _logger.i('Password reset confirmed successfully');
    } catch (e) {
      _logger.e('Password reset confirmation failed: $e');

      final errorMessage = e.toString();
      if (errorMessage.contains('invalid') ||
          errorMessage.contains('expired')) {
        throw AuthException(
          message: 'Password reset link is invalid or has expired',
          code: 'INVALID_RESET_TOKEN',
          details: e,
        );
      } else if (errorMessage.contains('password')) {
        throw AuthException(
          message: 'Passwords do not match or are too weak',
          code: 'PASSWORD_MISMATCH',
          details: e,
        );
      }

      throw AuthException(
        message: 'Failed to reset password. Please try again.',
        code: 'PASSWORD_RESET_FAILED',
        details: e,
      );
    }
  }

// ======================
// ADDITIONAL UTILITY METHODS
// ======================

// Check if email exists (used for validation)
  Future<bool> emailExists(String email) async {
    try {
      final result = await _pb.collection('users').getList(
            filter: 'email = "$email"',
            perPage: 1,
          );
      return result.items.isNotEmpty;
    } catch (e) {
      _logger.e('Email check failed: $e');
      return false;
    }
  }

// Check if username exists (used for validation)
  Future<bool> usernameExists(String username) async {
    try {
      final result = await _pb.collection('users').getList(
            filter: 'username = "$username"',
            perPage: 1,
          );
      return result.items.isNotEmpty;
    } catch (e) {
      _logger.e('Username check failed: $e');
      return false;
    }
  }

// Update user profile
  Future<ApiResponse<RecordModel>> updateProfile(
    Map<String, dynamic> data, {
    List<http.MultipartFile>? files,
  }) async {
    try {
      if (!isAuthenticated || currentUser == null) {
        throw const AuthException(
          message: 'User not authenticated',
          code: 'NOT_AUTHENTICATED',
        );
      }

      _logger.i('Updating user profile');

      final record = await _pb.collection('users').update(
            currentUser!.id,
            body: data,
            files: files ?? [],
          );

      // Update auth store with new user data
      _pb.authStore.save(_pb.authStore.token, record);
      await _saveAuthState();

      _logger.i('User profile updated successfully');
      return ApiResponse.success(record,
          message: 'Profile updated successfully');
    } catch (e) {
      _logger.e('Profile update failed: $e');
      throw AuthException(
        message: 'Failed to update profile: $e',
        code: 'PROFILE_UPDATE_FAILED',
        details: e,
      );
    }
  }

// Change password for authenticated user
  Future<void> changePassword(
    String oldPassword,
    String newPassword,
    String newPasswordConfirm,
  ) async {
    try {
      if (!isAuthenticated || currentUser == null) {
        throw const AuthException(
          message: 'User not authenticated',
          code: 'NOT_AUTHENTICATED',
        );
      }

      _logger.i('Changing user password');

      await _pb.collection('users').update(
        currentUser!.id,
        body: {
          'oldPassword': oldPassword,
          'password': newPassword,
          'passwordConfirm': newPasswordConfirm,
        },
      );

      _logger.i('Password changed successfully');
    } catch (e) {
      _logger.e('Password change failed: $e');

      final errorMessage = e.toString();
      if (errorMessage.contains('oldPassword')) {
        throw AuthException(
          message: 'Current password is incorrect',
          code: 'INVALID_OLD_PASSWORD',
          details: e,
        );
      } else if (errorMessage.contains('password')) {
        throw AuthException(
          message: 'New passwords do not match or are too weak',
          code: 'INVALID_NEW_PASSWORD',
          details: e,
        );
      }

      throw AuthException(
        message: 'Failed to change password: $e',
        code: 'PASSWORD_CHANGE_FAILED',
        details: e,
      );
    }
  }

// // ======================
// // OAUTH2 AUTHENTICATION (Optional)
// // ======================

// // Authenticate with OAuth2
//   Future<ApiResponse<RecordModel>> authenticateWithOAuth2({
//     required String provider,
//     required String code,
//     required String codeVerifier,
//     String? redirectUrl,
//   }) async {
//     try {
//       _logger.i('Attempting OAuth2 authentication with: $provider');

//       // Clear admin mode if authenticating as user
//       _isAdminMode = false;

//       final authData = await _pb.collection('users').authWithOAuth2(
//             provider,
//             code,
//             codeVerifier,
//             redirectUrl ?? '',
//           );

//       await _saveAuthState();

//       _logger.i('OAuth2 authentication successful');
//       return ApiResponse.success(authData.record!,
//           message: 'OAuth2 login successful');
//     } catch (e) {
//       _logger.e('OAuth2 authentication failed: $e');
//       _handleAuthException(e);
//     }
//   }

// ======================
// VALIDATION HELPERS
// ======================

// Validate email format
  bool isValidEmail(String email) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

// Validate password strength
  bool isValidPassword(String password) {
    // At least 8 characters
    if (password.length < 8) return false;

    // Contains at least one uppercase letter
    if (!password.contains(RegExp(r'[A-Z]'))) return false;

    // Contains at least one lowercase letter
    if (!password.contains(RegExp(r'[a-z]'))) return false;

    // Contains at least one number
    if (!password.contains(RegExp(r'[0-9]'))) return false;

    return true;
  }

// Get password strength score (0-4)
  int getPasswordStrength(String password) {
    int score = 0;

    // Length
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;

    // Character types
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    return score.clamp(0, 4);
  }

  // Regular user authentication
  Future<ApiResponse<RecordModel>> authenticate(
    String collection,
    String email,
    String password, {
    bool rememberMe = false,
  }) async {
    try {
      _logger.i('Attempting user authentication for: $email');

      // Clear admin mode if authenticating as user
      _isAdminMode = false;

      final authData =
          await _pb.collection(collection).authWithPassword(email, password);

      await _saveAuthState();

      if (rememberMe) {
        await _prefs.setBool(StorageKeys.rememberMe, true);
      }

      _logger.i('User authentication successful');
      return ApiResponse.success(authData.record!, message: 'Login successful');
    } catch (e) {
      _logger.e('User authentication failed: $e');
      _handleAuthException(e);
    }
  }

  // User password reset
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

  // User token refresh
  Future<ApiResponse<RecordModel>> refreshAuth() async {
    try {
      if (_isAdminMode) {
        throw const AuthException(
          message: 'Cannot refresh user token in admin mode',
          code: 'INVALID_AUTH_MODE',
        );
      }

      final authData = await _pb.collection('users').authRefresh();
      await _saveAuthState();

      return ApiResponse.success(authData.record!, message: 'Token refreshed');
    } catch (e) {
      _logger.e('User token refresh failed: $e');
      await _clearAuthState();
      _handleAuthException(e);
    }
  }

  // ======================
  // ADMIN AUTHENTICATION
  // ======================

  // Admin authentication with _superusers
  Future<ApiResponse<RecordModel>> authenticateAdmin(
    String email,
    String password,
  ) async {
    try {
      _logger.i('Attempting admin authentication for: $email');

      // Set admin mode
      _isAdminMode = true;

      final authData =
          await _pb.collection('_superusers').authWithPassword(email, password);

      await _saveAuthState();

      _logger.i('Admin authentication successful');
      return ApiResponse.success(authData.record!,
          message: 'Admin login successful');
    } catch (e) {
      _logger.e('Admin authentication failed: $e');
      _isAdminMode = false; // Reset admin mode on failure
      _handleAuthException(e);
    }
  }

  // Admin password reset
  Future<void> requestAdminPasswordReset(String email) async {
    try {
      _logger.i('Requesting admin password reset for: $email');
      await _pb.collection('_superusers').requestPasswordReset(email);
      _logger.i('Admin password reset requested successfully');
    } catch (e) {
      _logger.e('Admin password reset request failed: $e');
      throw AuthException(
        message: 'Failed to request admin password reset: $e',
        code: 'ADMIN_PASSWORD_RESET_FAILED',
        details: e,
      );
    }
  }

  // Admin token refresh
  Future<ApiResponse<RecordModel>> refreshAdminAuth() async {
    try {
      if (!_isAdminMode) {
        throw const AuthException(
          message: 'Cannot refresh admin token in user mode',
          code: 'INVALID_AUTH_MODE',
        );
      }

      final authData = await _pb.collection('_superusers').authRefresh();
      await _saveAuthState();

      return ApiResponse.success(authData.record!,
          message: 'Admin token refreshed');
    } catch (e) {
      _logger.e('Admin token refresh failed: $e');
      await _clearAuthState();
      _handleAuthException(e);
    }
  }

  // Admin logout
  Future<void> logoutAdmin() async {
    try {
      _logger.i('Admin logout initiated');

      _adminTokenRefreshTimer?.cancel();
      _adminTokenRefreshTimer = null;

      await _clearAuthState();

      _logger.i('Admin logout completed');
    } catch (e) {
      _logger.e('Admin logout failed: $e');
      // Force clear auth state even if logout fails
      await _clearAuthState();
    }
  }

  // ======================
  // COMMON METHODS
  // ======================

  // Regular user logout
  Future<void> logout() async {
    try {
      _logger.i('User logout initiated');

      _tokenRefreshTimer?.cancel();
      _tokenRefreshTimer = null;

      await _clearAuthState();

      _logger.i('User logout completed');
    } catch (e) {
      _logger.e('User logout failed: $e');
      // Force clear auth state even if logout fails
      await _clearAuthState();
    }
  }

  // Switch between user and admin modes
  Future<void> switchToUserMode() async {
    if (_isAdminMode) {
      await logoutAdmin();
    }
  }

  Future<void> switchToAdminMode() async {
    if (!_isAdminMode) {
      await logout();
    }
  }

  // Handle authentication exceptions
  Never _handleAuthException(dynamic e) {
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

  // ======================
  // CRUD OPERATIONS
  // ======================

  // Execute with error handling
  Future<T> _executeWithErrorHandling<T>(Future<T> Function() operation) async {
    if (!_isOnline) {
      throw NetworkException.connectionFailed();
    }

    try {
      return await operation();
    } on SocketException {
      throw NetworkException.connectionFailed();
    } on TimeoutException {
      throw NetworkException.timeout();
    } catch (e) {
      _logger.e('Operation failed: $e');
      rethrow;
    }
  }

  // Create record
  Future<ApiResponse<RecordModel>> createRecord(
    String collection,
    Map<String, dynamic> data, {
    List<http.MultipartFile>? files,
    Map<String, dynamic>? query,
  }) async {
    return _executeWithErrorHandling(() async {
      final record = await _pb.collection(collection).create(
            body: data,
            files: files ?? [],
            query: query ?? {},
          );
      return ApiResponse.success(record);
    });
  }

  // Get single record
  Future<ApiResponse<RecordModel>> getRecord(
    String collection,
    String id, {
    Map<String, dynamic>? query,
  }) async {
    return _executeWithErrorHandling(() async {
      final record =
          await _pb.collection(collection).getOne(id, query: query ?? {});
      return ApiResponse.success(record);
    });
  }

  // Get records with pagination
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

  // Update record
  Future<ApiResponse<RecordModel>> updateRecord(
    String collection,
    String id,
    Map<String, dynamic> data, {
    Map<String, dynamic>? query,
    List<http.MultipartFile>? files,
  }) async {
    return _executeWithErrorHandling(() async {
      final record = await _pb.collection(collection).update(
            id,
            body: data,
            query: query ?? {},
            files: files ?? [],
          );
      return ApiResponse.success(record);
    });
  }

  // Delete record
  Future<ApiResponse<bool>> deleteRecord(
    String collection,
    String id, {
    Map<String, dynamic>? query,
  }) async {
    return _executeWithErrorHandling(() async {
      await _pb.collection(collection).delete(id, query: query ?? {});
      return ApiResponse.success(true);
    });
  }

  // File operations
  String getFileUrl(
    String collection,
    String recordId,
    String filename, {
    String? thumb,
  }) {
    final baseUrl = '${_pb.baseUrl}/api/files/$collection/$recordId/$filename';
    return thumb != null ? '$baseUrl?thumb=$thumb' : baseUrl;
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
      } else {
        await _pb.realtime.unsubscribe();
      }
      _logger.d('Unsubscribed from ${collection ?? 'all'} updates');
    } catch (e) {
      _logger.e('Failed to unsubscribe: $e');
    }
  }

  // Request queue for offline support
  void _queueRequest(QueuedRequest request) {
    _requestQueue.add(request);
    _logger.d('Request queued: ${request.method} ${request.collection}');
  }

  Future<void> _processRequestQueue() async {
    if (_isProcessingQueue || _requestQueue.isEmpty) return;

    _isProcessingQueue = true;

    try {
      final requests = List<QueuedRequest>.from(_requestQueue);
      _requestQueue.clear();

      for (final request in requests) {
        try {
          switch (request.method) {
            case 'CREATE':
              await createRecord(request.collection, request.data);
              break;
            case 'UPDATE':
              await updateRecord(request.collection, request.id!, request.data);
              break;
            case 'DELETE':
              await deleteRecord(request.collection, request.id!);
              break;
          }

          _logger.d(
              'Queued request processed: ${request.method} ${request.collection}');
        } catch (e) {
          _logger.e('Failed to process queued request: $e');
          // Re-queue the request for retry
          _requestQueue.add(request);
        }
      }
    } finally {
      _isProcessingQueue = false;
    }
  }

  // Cleanup resources
  void dispose() {
    _tokenRefreshTimer?.cancel();
    _adminTokenRefreshTimer?.cancel();
    _connectivitySubscription.cancel();
    _authStateController?.close();
    _userController?.close();
    _adminAuthStateController?.close();
    _adminUserController?.close();
  }
}

// Queued request model for offline support
class QueuedRequest {
  final String method;
  final String collection;
  final String? id;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  QueuedRequest({
    required this.method,
    required this.collection,
    this.id,
    required this.data,
    required this.timestamp,
  });
}
