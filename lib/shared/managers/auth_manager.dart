import 'dart:async';
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/pocketbase_client.dart';
import '../../core/errors/exceptions.dart';
import '../../shared/services/storage_service.dart';
import '../../shared/services/analytics_service.dart';

class AuthManager {
  static AuthManager? _instance;
  late Logger _logger;
  late PocketBaseClient _pbClient;
  late StorageService _storageService;
  late AnalyticsService _analyticsService;
  late SharedPreferences _prefs;

  // Authentication state
  final StreamController<AuthState> _authStateController =
      StreamController<AuthState>.broadcast();
  AuthState _currentState = AuthState.initial;

  // User data
  UserData? _currentUser;
  UserSession? _currentSession;

  // Biometric authentication
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;

  // Auto-login and session management
  Timer? _sessionTimer;
  Timer? _tokenRefreshTimer;
  Duration _sessionTimeout = const Duration(hours: 24);
  Duration _inactivityTimeout = const Duration(minutes: 30);
  DateTime? _lastActivity;

  AuthManager._() {
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

  static AuthManager get instance {
    _instance ??= AuthManager._();
    return _instance!;
  }

  // Getters
  Stream<AuthState> get authStateStream => _authStateController.stream;
  AuthState get currentState => _currentState;
  UserData? get currentUser => _currentUser;
  UserSession? get currentSession => _currentSession;
  bool get isAuthenticated => _currentState == AuthState.authenticated;
  bool get isBiometricEnabled => _biometricEnabled;
  bool get isBiometricAvailable => _biometricAvailable;

  // Initialize the manager
  Future<void> initialize() async {
    try {
      _logger.i('Initializing Auth Manager...');

      _prefs = await SharedPreferences.getInstance();
      await _loadAuthSettings();
      await _checkBiometricAvailability();
      await _restoreSession();
      _setupSessionManagement();

      _logger.i('Auth Manager initialized successfully');
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize Auth Manager',
          error: e, stackTrace: stackTrace);
    }
  }

  // Load authentication settings
  Future<void> _loadAuthSettings() async {
    _biometricEnabled = _prefs.getBool(StorageKeys.biometricEnabled) ?? false;

    final timeoutMinutes =
        _prefs.getInt('session_timeout_minutes') ?? 1440; // 24 hours default
    _sessionTimeout = Duration(minutes: timeoutMinutes);

    final inactivityMinutes = _prefs.getInt('inactivity_timeout_minutes') ?? 30;
    _inactivityTimeout = Duration(minutes: inactivityMinutes);

    _logger.d('Auth settings loaded');
  }

  // Check biometric availability
  Future<void> _checkBiometricAvailability() async {
    try {
      _biometricAvailable = await _localAuth.canCheckBiometrics;
      if (_biometricAvailable) {
        final availableBiometrics = await _localAuth.getAvailableBiometrics();
        _biometricAvailable = availableBiometrics.isNotEmpty;
      }

      _logger.d('Biometric availability: $_biometricAvailable');
    } catch (e) {
      _logger.w('Failed to check biometric availability: $e');
      _biometricAvailable = false;
    }
  }

  // Restore previous session
  Future<void> _restoreSession() async {
    try {
      if (!_pbClient.isAuthenticated) {
        _updateAuthState(AuthState.unauthenticated);
        return;
      }

      // Load user data
      await _loadUserData();

      // Validate session
      final isValid = await _validateSession();
      if (isValid) {
        _updateAuthState(AuthState.authenticated);
        _startSessionTimer();
        _trackActivity();

        _analyticsService.setUserId(_currentUser!.id);
        _logger.i('Session restored for user: ${_currentUser!.email}');
      } else {
        await logout();
      }
    } catch (e) {
      _logger.w('Failed to restore session: $e');
      await _clearAuthData();
      _updateAuthState(AuthState.unauthenticated);
    }
  }

  // Load user data from storage
  Future<void> _loadUserData() async {
    try {
      final userJson =
          await _storageService.getSecureData<String>('current_user');
      if (userJson != null) {
        final userData = jsonDecode(userJson) as Map<String, dynamic>;
        _currentUser = UserData.fromJson(userData);
      }

      final sessionJson =
          await _storageService.getSecureData<String>('current_session');
      if (sessionJson != null) {
        final sessionData = jsonDecode(sessionJson) as Map<String, dynamic>;
        _currentSession = UserSession.fromJson(sessionData);
      }
    } catch (e) {
      _logger.w('Failed to load user data: $e');
    }
  }

  // Save user data to storage
  Future<void> _saveUserData() async {
    try {
      if (_currentUser != null) {
        await _storageService.setSecureData(
            'current_user', jsonEncode(_currentUser!.toJson()));
      }

      if (_currentSession != null) {
        await _storageService.setSecureData(
            'current_session', jsonEncode(_currentSession!.toJson()));
      }
    } catch (e) {
      _logger.e('Failed to save user data: $e');
    }
  }

  // Validate current session
  Future<bool> _validateSession() async {
    try {
      if (_currentSession == null) return false;

      // Check session expiry
      if (_currentSession!.isExpired) {
        _logger.w('Session expired');
        return false;
      }

      // Check inactivity timeout
      if (_lastActivity != null) {
        final inactivityDuration = DateTime.now().difference(_lastActivity!);
        if (inactivityDuration > _inactivityTimeout) {
          _logger.w('Session inactive for too long');
          return false;
        }
      }

      // Validate with server
      try {
        await _pbClient.client.collection('users').authRefresh();
        return true;
      } catch (e) {
        _logger.w('Server session validation failed: $e');
        return false;
      }
    } catch (e) {
      _logger.e('Session validation error: $e');
      return false;
    }
  }

  // Setup session management timers
  void _setupSessionManagement() {
    // Session timeout timer
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      if (_currentSession != null && _currentSession!.isExpired) {
        _logger.w('Session expired, logging out');
        await logout();
      }
    });

    // Token refresh timer
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer =
        Timer.periodic(const Duration(minutes: 15), (timer) async {
      if (isAuthenticated) {
        try {
          await _pbClient.refreshAuth();
          _logger.d('Token refreshed successfully');
        } catch (e) {
          _logger.w('Token refresh failed: $e');
          await logout();
        }
      }
    });
  }

  // Start session timer
  void _startSessionTimer() {
    _lastActivity = DateTime.now();

    if (_currentSession != null) {
      _currentSession!.lastActivity = _lastActivity!;
      _saveUserData();
    }
  }

  // Track user activity
  void _trackActivity() {
    _lastActivity = DateTime.now();

    if (_currentSession != null) {
      _currentSession!.lastActivity = _lastActivity!;
    }
  }

  // Update authentication state
  void _updateAuthState(AuthState newState) {
    if (_currentState != newState) {
      _currentState = newState;
      _authStateController.add(newState);
      _logger.d('Auth state changed: $newState');
    }
  }

  // Login with email and password
  Future<AuthResult> loginWithEmailPassword(
    String email,
    String password, {
    bool rememberMe = false,
  }) async {
    try {
      _updateAuthState(AuthState.authenticating);

      final response = await _pbClient.authenticateWithPassword(
        email,
        password,
        rememberMe: rememberMe,
      );

      if (response.isSuccess && response.data != null) {
        await _handleSuccessfulLogin(response.data!, rememberMe);

        _analyticsService.trackEvent('login_success', {
          'method': 'email_password',
          'remember_me': rememberMe,
        });

        return AuthResult.success('Login successful');
      } else {
        _updateAuthState(AuthState.unauthenticated);
        return AuthResult.failure(response.error ?? 'Login failed');
      }
    } catch (e) {
      _logger.e('Login failed: $e');
      _updateAuthState(AuthState.unauthenticated);

      _analyticsService.trackError('login_error', e.toString(),
          context: 'email_password');

      if (e is AuthException) {
        return AuthResult.failure(e.message);
      }
      return AuthResult.failure('Login failed: ${e.toString()}');
    }
  }

  // Handle successful login
  Future<void> _handleSuccessfulLogin(
      dynamic authRecord, bool rememberMe) async {
    try {
      // Create user data
      _currentUser = UserData.fromAuthRecord(authRecord);

      // Create session
      _currentSession = UserSession(
        id: _generateSessionId(),
        userId: _currentUser!.id,
        deviceId: await _getDeviceId(),
        startTime: DateTime.now(),
        expiryTime: DateTime.now().add(_sessionTimeout),
        lastActivity: DateTime.now(),
        rememberMe: rememberMe,
      );

      // Save data
      await _saveUserData();
      await _prefs.setBool(StorageKeys.rememberMe, rememberMe);
      await _prefs.setString(
          StorageKeys.lastLoginDate, DateTime.now().toIso8601String());

      // Setup session management
      _startSessionTimer();
      _trackActivity();

      // Set analytics user
      _analyticsService.setUserId(_currentUser!.id);
      _analyticsService.setUserProperties({
        'email': _currentUser!.email,
        'name': _currentUser!.name,
        'verified': _currentUser!.verified,
        'created_at': _currentUser!.created.toIso8601String(),
      });

      _updateAuthState(AuthState.authenticated);
      _logger.i('Login successful for user: ${_currentUser!.email}');
    } catch (e) {
      _logger.e('Failed to handle successful login: $e');
      rethrow;
    }
  }

  // Login with biometrics
  Future<AuthResult> loginWithBiometrics() async {
    try {
      if (!_biometricAvailable || !_biometricEnabled) {
        return AuthResult.failure('Biometric authentication not available');
      }

      // Check if we have stored credentials
      final storedEmail =
          await _storageService.getSecureData<String>('biometric_email');
      final storedToken =
          await _storageService.getSecureData<String>('biometric_token');

      if (storedEmail == null || storedToken == null) {
        return AuthResult.failure('No biometric credentials stored');
      }

      _updateAuthState(AuthState.authenticating);

      // Authenticate with biometrics
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your Onflix account',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (!isAuthenticated) {
        _updateAuthState(AuthState.unauthenticated);
        return AuthResult.failure('Biometric authentication failed');
      }

      // Use stored credentials to login
      return await loginWithEmailPassword(storedEmail, storedToken,
          rememberMe: true);
    } catch (e) {
      _logger.e('Biometric login failed: $e');
      _updateAuthState(AuthState.unauthenticated);

      _analyticsService.trackError('biometric_login_error', e.toString());
      return AuthResult.failure('Biometric login failed: ${e.toString()}');
    }
  }

  // Register new account
  Future<AuthResult> register({
    required String email,
    required String password,
    required String passwordConfirm,
    String? name,
    String? username,
  }) async {
    try {
      _updateAuthState(AuthState.authenticating);

      final response = await _pbClient.register(
        email: email,
        password: password,
        passwordConfirm: passwordConfirm,
        name: name,
        username: username,
      );

      if (response.isSuccess) {
        _updateAuthState(AuthState.unauthenticated);

        _analyticsService.trackEvent('registration_success', {
          'email': email,
          'has_name': name != null,
          'has_username': username != null,
        });

        return AuthResult.success(
            'Registration successful. Please check your email for verification.');
      } else {
        _updateAuthState(AuthState.unauthenticated);
        return AuthResult.failure(response.error ?? 'Registration failed');
      }
    } catch (e) {
      _logger.e('Registration failed: $e');
      _updateAuthState(AuthState.unauthenticated);

      _analyticsService.trackError('registration_error', e.toString());

      if (e is ValidationException) {
        return AuthResult.failure(e.message);
      }
      return AuthResult.failure('Registration failed: ${e.toString()}');
    }
  }

  // Request password reset
  Future<AuthResult> requestPasswordReset(String email) async {
    try {
      await _pbClient.requestPasswordReset(email);

      _analyticsService
          .trackEvent('password_reset_requested', {'email': email});

      return AuthResult.success(
          'Password reset instructions sent to your email');
    } catch (e) {
      _logger.e('Password reset request failed: $e');

      _analyticsService.trackError('password_reset_error', e.toString());
      return AuthResult.failure(
          'Failed to request password reset: ${e.toString()}');
    }
  }

  // Verify email
  Future<AuthResult> verifyEmail(String token) async {
    try {
      await _pbClient.confirmVerification(token);

      _analyticsService.trackEvent('email_verified');

      return AuthResult.success('Email verified successfully');
    } catch (e) {
      _logger.e('Email verification failed: $e');

      _analyticsService.trackError('email_verification_error', e.toString());
      return AuthResult.failure('Email verification failed: ${e.toString()}');
    }
  }

  // Enable biometric authentication
  Future<AuthResult> enableBiometricAuth(String password) async {
    try {
      if (!_biometricAvailable) {
        return AuthResult.failure('Biometric authentication not available');
      }

      if (!isAuthenticated || _currentUser == null) {
        return AuthResult.failure('Must be logged in to enable biometric auth');
      }

      // Verify current password
      final verifyResult =
          await loginWithEmailPassword(_currentUser!.email, password);
      if (!verifyResult.isSuccess) {
        return AuthResult.failure('Invalid password');
      }

      // Authenticate with biometrics to confirm setup
      final biometricAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Confirm biometric authentication setup',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (!biometricAuthenticated) {
        return AuthResult.failure('Biometric authentication setup cancelled');
      }

      // Store credentials securely
      await _storageService.setSecureData(
          'biometric_email', _currentUser!.email);
      await _storageService.setSecureData('biometric_token', password);

      _biometricEnabled = true;
      await _prefs.setBool(StorageKeys.biometricEnabled, true);

      _analyticsService.trackEvent('biometric_auth_enabled');

      return AuthResult.success('Biometric authentication enabled');
    } catch (e) {
      _logger.e('Failed to enable biometric auth: $e');

      _analyticsService.trackError('biometric_enable_error', e.toString());
      return AuthResult.failure(
          'Failed to enable biometric auth: ${e.toString()}');
    }
  }

  // Disable biometric authentication
  Future<void> disableBiometricAuth() async {
    try {
      await _storageService.removeSecureData('biometric_email');
      await _storageService.removeSecureData('biometric_token');

      _biometricEnabled = false;
      await _prefs.setBool(StorageKeys.biometricEnabled, false);

      _analyticsService.trackEvent('biometric_auth_disabled');
      _logger.i('Biometric authentication disabled');
    } catch (e) {
      _logger.e('Failed to disable biometric auth: $e');
    }
  }

  // Change password
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      if (!isAuthenticated || _currentUser == null) {
        return AuthResult.failure('Must be logged in to change password');
      }

      if (newPassword != confirmPassword) {
        return AuthResult.failure('New passwords do not match');
      }

      // Verify current password
      final verifyResult =
          await loginWithEmailPassword(_currentUser!.email, currentPassword);
      if (!verifyResult.isSuccess) {
        return AuthResult.failure('Current password is incorrect');
      }

      // Update password (this would need to be implemented based on your backend)
      // For now, we'll simulate the API call
      await _pbClient.updateRecord('users', _currentUser!.id, {
        'password': newPassword,
        'passwordConfirm': confirmPassword,
      });

      // Update biometric credentials if enabled
      if (_biometricEnabled) {
        await _storageService.setSecureData('biometric_token', newPassword);
      }

      _analyticsService.trackEvent('password_changed');

      return AuthResult.success('Password changed successfully');
    } catch (e) {
      _logger.e('Password change failed: $e');

      _analyticsService.trackError('password_change_error', e.toString());
      return AuthResult.failure('Failed to change password: ${e.toString()}');
    }
  }

  // Update user profile
  Future<AuthResult> updateProfile({
    String? name,
    String? username,
    String? avatar,
  }) async {
    try {
      if (!isAuthenticated || _currentUser == null) {
        return AuthResult.failure('Must be logged in to update profile');
      }

      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (username != null) updateData['username'] = username;
      if (avatar != null) updateData['avatar'] = avatar;

      if (updateData.isEmpty) {
        return AuthResult.success('No changes to update');
      }

      final response =
          await _pbClient.updateRecord('users', _currentUser!.id, updateData);

      if (response.isSuccess && response.data != null) {
        // Update local user data
        _currentUser = UserData.fromAuthRecord(response.data!);
        await _saveUserData();

        // Update analytics
        _analyticsService.setUserProperties({
          'name': _currentUser!.name,
          'username': _currentUser!.username,
        });

        _analyticsService.trackEvent('profile_updated', updateData);

        return AuthResult.success('Profile updated successfully');
      } else {
        return AuthResult.failure('Failed to update profile');
      }
    } catch (e) {
      _logger.e('Profile update failed: $e');

      _analyticsService.trackError('profile_update_error', e.toString());
      return AuthResult.failure('Failed to update profile: ${e.toString()}');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      _logger.i('Logging out user');

      // Track logout
      if (_currentUser != null) {
        _analyticsService.trackEvent('logout', {
          'session_duration': _currentSession?.duration.inMinutes ?? 0,
        });
      }

      // Clear timers
      _sessionTimer?.cancel();
      _tokenRefreshTimer?.cancel();

      // Clear auth data
      await _clearAuthData();

      // Logout from PocketBase
      await _pbClient.logout();

      _updateAuthState(AuthState.unauthenticated);
      _logger.i('Logout completed');
    } catch (e) {
      _logger.e('Logout failed: $e');
      // Still clear local data even if server logout fails
      await _clearAuthData();
      _updateAuthState(AuthState.unauthenticated);
    }
  }

  // Clear all authentication data
  Future<void> _clearAuthData() async {
    try {
      // Clear user data
      _currentUser = null;
      _currentSession = null;
      _lastActivity = null;

      // Clear secure storage
      await _storageService.removeSecureData('current_user');
      await _storageService.removeSecureData('current_session');

      // Clear shared preferences
      await _prefs.remove(StorageKeys.authToken);
      await _prefs.remove(StorageKeys.refreshToken);
      await _prefs.remove(StorageKeys.userId);
      await _prefs.remove(StorageKeys.userEmail);
      await _prefs.setBool(StorageKeys.isLoggedIn, false);

      _logger.d('Auth data cleared');
    } catch (e) {
      _logger.e('Failed to clear auth data: $e');
    }
  }

  // Check if auto-login should be performed
  Future<bool> shouldAutoLogin() async {
    try {
      final rememberMe = _prefs.getBool(StorageKeys.rememberMe) ?? false;
      if (!rememberMe) return false;

      final lastLoginStr = _prefs.getString(StorageKeys.lastLoginDate);
      if (lastLoginStr == null) return false;

      final lastLogin = DateTime.parse(lastLoginStr);
      final daysSinceLogin = DateTime.now().difference(lastLogin).inDays;

      // Auto-login if last login was within 30 days
      return daysSinceLogin <= 30;
    } catch (e) {
      _logger.w('Auto-login check failed: $e');
      return false;
    }
  }

  // Get device ID
  Future<String> _getDeviceId() async {
    return await _storageService.getString(StorageKeys.deviceId) ?? 'unknown';
  }

  // Generate session ID
  String _generateSessionId() {
    return 'sess_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  // Get auth summary
  Map<String, dynamic> getAuthSummary() {
    return {
      'isAuthenticated': isAuthenticated,
      'currentState': _currentState.toString(),
      'userId': _currentUser?.id,
      'userEmail': _currentUser?.email,
      'userName': _currentUser?.name,
      'sessionId': _currentSession?.id,
      'sessionExpiry': _currentSession?.expiryTime?.toIso8601String(),
      'lastActivity': _lastActivity?.toIso8601String(),
      'biometricAvailable': _biometricAvailable,
      'biometricEnabled': _biometricEnabled,
      'rememberMe': _prefs.getBool(StorageKeys.rememberMe) ?? false,
    };
  }

  // Dispose resources
  void dispose() {
    _sessionTimer?.cancel();
    _tokenRefreshTimer?.cancel();
    _authStateController.close();
  }
}

// Authentication state enum
enum AuthState {
  initial,
  authenticating,
  authenticated,
  unauthenticated,
  error,
}

// Authentication result class
class AuthResult {
  final bool isSuccess;
  final String message;
  final dynamic data;

  AuthResult._({
    required this.isSuccess,
    required this.message,
    this.data,
  });

  factory AuthResult.success(String message, {dynamic data}) {
    return AuthResult._(
      isSuccess: true,
      message: message,
      data: data,
    );
  }

  factory AuthResult.failure(String message) {
    return AuthResult._(
      isSuccess: false,
      message: message,
    );
  }
}

// User data model
class UserData {
  final String id;
  final String email;
  final String? name;
  final String? username;
  final String? avatar;
  final bool verified;
  final DateTime created;
  final DateTime updated;

  UserData({
    required this.id,
    required this.email,
    this.name,
    this.username,
    this.avatar,
    required this.verified,
    required this.created,
    required this.updated,
  });

  factory UserData.fromAuthRecord(dynamic record) {
    return UserData(
      id: record.id,
      email: record.data['email'],
      name: record.data['name'],
      username: record.data['username'],
      avatar: record.data['avatar'],
      verified: record.data['verified'] ?? false,
      created: DateTime.parse(record.data['created']),
      updated: DateTime.parse(record.data['updated']),
    );
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      username: json['username'],
      avatar: json['avatar'],
      verified: json['verified'],
      created: DateTime.parse(json['created']),
      updated: DateTime.parse(json['updated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'username': username,
      'avatar': avatar,
      'verified': verified,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }
}

// User session model
class UserSession {
  final String id;
  final String userId;
  final String deviceId;
  final DateTime startTime;
  final DateTime expiryTime;
  DateTime lastActivity;
  final bool rememberMe;

  UserSession({
    required this.id,
    required this.userId,
    required this.deviceId,
    required this.startTime,
    required this.expiryTime,
    required this.lastActivity,
    required this.rememberMe,
  });

  bool get isExpired => DateTime.now().isAfter(expiryTime);
  Duration get duration => DateTime.now().difference(startTime);
  Duration get timeUntilExpiry => expiryTime.difference(DateTime.now());

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      id: json['id'],
      userId: json['userId'],
      deviceId: json['deviceId'],
      startTime: DateTime.parse(json['startTime']),
      expiryTime: DateTime.parse(json['expiryTime']),
      lastActivity: DateTime.parse(json['lastActivity']),
      rememberMe: json['rememberMe'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'deviceId': deviceId,
      'startTime': startTime.toIso8601String(),
      'expiryTime': expiryTime.toIso8601String(),
      'lastActivity': lastActivity.toIso8601String(),
      'rememberMe': rememberMe,
    };
  }
}
