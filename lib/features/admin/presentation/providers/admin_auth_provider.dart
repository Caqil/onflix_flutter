import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';

import '../../../../core/network/network_info.dart';
import '../../../../core/network/pocketbase_client.dart';
import '../../../../shared/services/analytics_service.dart';
import '../../data/datasources/admin_local_datasource.dart';
import '../../data/datasources/admin_remote_datasource.dart';
import '../../data/repositories/admin_repository_impl.dart';
import '../../domain/entities/admin_user.dart';
import '../../domain/repositories/admin_repository.dart';

part 'admin_auth_provider.g.dart';

// Data Source Providers
@riverpod
AdminRemoteDataSource adminRemoteDataSource(Ref ref) {
  final client = PocketBaseClient.instance;
  return AdminRemoteDataSourceImpl(client);
}

@riverpod
AdminLocalDataSource adminLocalDataSource(Ref ref) {
  return AdminLocalDataSourceImpl();
}

// Repository Provider
@riverpod
AdminRepository adminRepository(Ref ref) {
  final remoteDataSource = ref.read(adminRemoteDataSourceProvider);
  final localDataSource = ref.read(adminLocalDataSourceProvider);
  final networkInfo = NetworkInfoImpl(Connectivity());

  return AdminRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
    networkInfo: networkInfo,
  );
}

// Admin Authentication State Provider
@riverpod
class AdminAuthState extends _$AdminAuthState {
  Timer? _sessionCheckTimer;
  final Logger _logger = Logger();

  @override
  Future<AdminUser?> build() async {
    ref.onDispose(() {
      _sessionCheckTimer?.cancel();
    });

    // Check if admin is authenticated on initialization
    return await _checkAdminAuth();
  }

  // Check admin authentication status
  Future<AdminUser?> _checkAdminAuth() async {
    try {
      final repository = ref.read(adminRepositoryProvider);

      final result = await repository.isAdminAuthenticated();

      return result.fold(
        (failure) {
          _logger.w('Admin auth check failed: ${failure.message}');
          return null;
        },
        (isAuthenticated) {
          if (isAuthenticated) {
            _startSessionCheck();
            return _getCurrentAdmin();
          }
          return null;
        },
      );
    } catch (e) {
      _logger.e('Admin auth check error: $e');
      return null;
    }
  }

  // Get current admin user (from cache or refresh)
  Future<AdminUser?> _getCurrentAdmin() async {
    try {
      final repository = ref.read(adminRepositoryProvider);

      final result = await repository.refreshAdminToken();

      return result.fold(
        (failure) {
          _logger.w('Failed to get current admin: ${failure.message}');
          return null;
        },
        (adminUser) => adminUser,
      );
    } catch (e) {
      _logger.e('Get current admin error: $e');
      return null;
    }
  }

  // Login admin
  Future<void> loginAdmin(String email, String password) async {
    try {
      state = const AsyncValue.loading();

      final repository = ref.read(adminRepositoryProvider);
      final result = await repository.loginAdmin(email, password);

      result.fold(
        (failure) {
          state = AsyncValue.error(failure, StackTrace.current);

          // Track failed login
          AnalyticsService.instance.trackEvent('admin_login_failed', {
            'email': email,
            'error_code': failure.code,
            'error_message': failure.message,
          });
        },
        (adminUser) {
          state = AsyncValue.data(adminUser);
          _startSessionCheck();

          // Track successful login
          AnalyticsService.instance.trackEvent('admin_login_success', {
            'admin_id': adminUser.id,
            'email': adminUser.email,
          });

          _logger.i('Admin login successful: ${adminUser.email}');
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      _logger.e('Admin login error: $e');
    }
  }

  // Logout admin
  Future<void> logoutAdmin() async {
    try {
      _sessionCheckTimer?.cancel();

      final repository = ref.read(adminRepositoryProvider);
      final result = await repository.logoutAdmin();

      result.fold(
        (failure) {
          _logger.w('Admin logout warning: ${failure.message}');
        },
        (_) {
          _logger.i('Admin logout successful');
        },
      );

      // Always clear state regardless of logout result
      state = const AsyncValue.data(null);

      // Track logout
      AnalyticsService.instance.trackEvent('admin_logout');
    } catch (e) {
      _logger.e('Admin logout error: $e');
      // Still clear state on error
      state = const AsyncValue.data(null);
    }
  }

  // Refresh admin token
  Future<void> refreshToken() async {
    try {
      final repository = ref.read(adminRepositoryProvider);
      final result = await repository.refreshAdminToken();

      result.fold(
        (failure) {
          _logger.w('Token refresh failed: ${failure.message}');
          // If token refresh fails, logout
          state = const AsyncValue.data(null);
        },
        (adminUser) {
          state = AsyncValue.data(adminUser);
          _logger.d('Admin token refreshed successfully');
        },
      );
    } catch (e) {
      _logger.e('Token refresh error: $e');
      state = const AsyncValue.data(null);
    }
  }

  // Start session check timer
  void _startSessionCheck() {
    _sessionCheckTimer?.cancel();

    // Check session every 15 minutes
    _sessionCheckTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) => refreshToken(),
    );
  }
}

// Admin Authentication Status Provider (for convenience)
@riverpod
bool isAdminAuthenticated(Ref ref) {
  final adminState = ref.watch(adminAuthStateProvider);

  return adminState.when(
    data: (admin) => admin != null,
    loading: () => false,
    error: (_, __) => false,
  );
}

// Current Admin User Provider (for convenience)
@riverpod
AdminUser? currentAdminUser(Ref ref) {
  final adminState = ref.watch(adminAuthStateProvider);

  return adminState.when(
    data: (admin) => admin,
    loading: () => null,
    error: (_, __) => null,
  );
}

// Admin Authentication Loading State Provider
@riverpod
bool isAdminAuthLoading(Ref ref) {
  final adminState = ref.watch(adminAuthStateProvider);

  return adminState.when(
    data: (_) => false,
    loading: () => true,
    error: (_, __) => false,
  );
}

// Admin Authentication Error Provider
@riverpod
String? adminAuthError(Ref ref) {
  final adminState = ref.watch(adminAuthStateProvider);

  return adminState.when(
    data: (_) => null,
    loading: () => null,
    error: (error, _) => error.toString(),
  );
}

// Login Form State Provider
@riverpod
class AdminLoginFormState extends _$AdminLoginFormState {
  @override
  AdminLoginForm build() {
    return const AdminLoginForm();
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password);
  }

  void updateRememberMe(bool rememberMe) {
    state = state.copyWith(rememberMe: rememberMe);
  }

  void clearForm() {
    state = const AdminLoginForm();
  }

  bool get isValid {
    return state.email.isNotEmpty &&
        state.password.isNotEmpty &&
        state.email.contains('@');
  }
}

// Admin Login Form Model
class AdminLoginForm {
  final String email;
  final String password;
  final bool rememberMe;

  const AdminLoginForm({
    this.email = '',
    this.password = '',
    this.rememberMe = false,
  });

  AdminLoginForm copyWith({
    String? email,
    String? password,
    bool? rememberMe,
  }) {
    return AdminLoginForm(
      email: email ?? this.email,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }
}
