import 'package:logger/logger.dart';
import 'package:onflix/core/constants/api_endpoints.dart';
import 'package:onflix/core/errors/exceptions.dart';
import 'package:onflix/core/network/pocketbase_client.dart';
import 'package:onflix/shared/models/pagination.dart';
import 'package:onflix/shared/services/analytics_service.dart';

import '../models/admin_user_model.dart';
import '../models/analytics_model.dart';
import '../models/content_report_model.dart';
import '../models/payment_history_model.dart';

abstract class AdminRemoteDataSource {
  // Authentication
  Future<AdminUserModel> loginAdmin(String email, String password);
  Future<void> logoutAdmin();
  Future<AdminUserModel> refreshAdminToken();

  // Admin Users Management
  Future<PaginatedResponse<AdminUserModel>> getAdminUsers({
    int page = 1,
    int perPage = 20,
    String? filter,
    String? sort,
  });
  Future<AdminUserModel> getAdminUser(String id);
  Future<AdminUserModel> createAdminUser(Map<String, dynamic> data);
  Future<AdminUserModel> updateAdminUser(String id, Map<String, dynamic> data);
  Future<void> deleteAdminUser(String id);

  // Analytics
  Future<AnalyticsModel> getAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? granularity,
  });
  Future<List<AnalyticsModel>> getAnalyticsHistory({
    int page = 1,
    int perPage = 50,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<Map<String, dynamic>> getDashboardStats();
  Future<List<Map<String, dynamic>>> getUserEngagementMetrics({
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<List<Map<String, dynamic>>> getContentPerformanceMetrics({
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<List<Map<String, dynamic>>> getRevenueMetrics({
    DateTime? startDate,
    DateTime? endDate,
  });

  // Content Reports
  Future<PaginatedResponse<ContentReportModel>> getContentReports({
    int page = 1,
    int perPage = 20,
    String? status,
    String? sort,
  });
  Future<ContentReportModel> getContentReport(String id);
  Future<ContentReportModel> updateContentReportStatus(
    String id,
    String status,
    String? resolution,
  );
  Future<void> deleteContentReport(String id);
  Future<List<Map<String, dynamic>>> getReportStatistics();

  // Payment History
  Future<PaginatedResponse<PaymentHistoryModel>> getPaymentHistory({
    int page = 1,
    int perPage = 20,
    String? status,
    String? sort,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<PaymentHistoryModel> getPaymentDetails(String id);
  Future<List<Map<String, dynamic>>> getPaymentStatistics({
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<void> refundPayment(String paymentId, double amount);

  // User Management
  Future<PaginatedResponse<Map<String, dynamic>>> getUsers({
    int page = 1,
    int perPage = 20,
    String? filter,
    String? sort,
  });
  Future<Map<String, dynamic>> getUserDetails(String userId);
  Future<void> suspendUser(String userId, String reason);
  Future<void> activateUser(String userId);
  Future<void> deleteUserAccount(String userId);

  // Content Management
  Future<PaginatedResponse<Map<String, dynamic>>> getContent({
    int page = 1,
    int perPage = 20,
    String? filter,
    String? sort,
  });
  Future<Map<String, dynamic>> updateContentStatus(
    String contentId,
    String status,
  );
  Future<void> deleteContent(String contentId);

  // System Settings
  Future<Map<String, dynamic>> getSystemSettings();
  Future<void> updateSystemSettings(Map<String, dynamic> settings);

  // Notifications
  Future<void> sendNotificationToUsers({
    required String title,
    required String message,
    List<String>? userIds,
    String? userType,
  });
  Future<void> sendSystemAnnouncement({
    required String title,
    required String message,
    String? priority,
  });
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final PocketBaseClient _client;
  final Logger _logger = Logger();
  final AnalyticsService _analyticsService = AnalyticsService.instance;

  AdminRemoteDataSourceImpl(this._client);

  // Authentication
  @override
  Future<AdminUserModel> loginAdmin(String email, String password) async {
    try {
      _logger.d('Attempting admin login for: $email');

      final response = await _client.authenticateAdmin(email, password);

      if (!response.success || response.data == null) {
        throw AuthException(
          message: response.error ?? 'Invalid credentials',
          code: 'ADMIN_LOGIN_FAILED',
        );
      }

      final adminUser = AdminUserModel.fromRecord(response.data!);

      return adminUser;
    } catch (e) {
      _logger.e('Admin login failed: $e');
      _analyticsService.trackEvent('admin_login_failed', {
        'email': email,
        'error': e.toString(),
      });

      if (e is AuthException) rethrow;
      throw AuthException(
        message: 'Admin login failed: $e',
        code: 'ADMIN_LOGIN_ERROR',
        details: e,
      );
    }
  }

  @override
  Future<void> logoutAdmin() async {
    try {
      await _client.logoutAdmin();

      _analyticsService.trackEvent('admin_logout');
      _logger.d('Admin logout successful');
    } catch (e) {
      _logger.e('Admin logout failed: $e');
      throw AuthException(
        message: 'Admin logout failed: $e',
        code: 'ADMIN_LOGOUT_ERROR',
        details: e,
      );
    }
  }

  @override
  Future<AdminUserModel> refreshAdminToken() async {
    try {
      final response = await _client.refreshAdminAuth();

      if (!response.success || response.data == null) {
        throw const AuthException(
          message: 'Token refresh failed',
          code: 'TOKEN_REFRESH_FAILED',
        );
      }

      return AdminUserModel.fromRecord(response.data!);
    } catch (e) {
      _logger.e('Admin token refresh failed: $e');
      throw AuthException(
        message: 'Token refresh failed: $e',
        code: 'TOKEN_REFRESH_ERROR',
        details: e,
      );
    }
  }

  // Admin Users Management (Super Users)
  @override
  Future<PaginatedResponse<AdminUserModel>> getAdminUsers({
    int page = 1,
    int perPage = 20,
    String? filter,
    String? sort,
  }) async {
    try {
      final response = await _client.getRecords(
        ApiEndpoints.superUsers,
        page: page,
        perPage: perPage,
        filter: filter,
        sort: sort ?? '-created',
      );

      if (!response.success || response.data == null) {
        throw ServerException(
          message: response.error ?? 'Failed to fetch admin users',
          code: 'ADMIN_USERS_FETCH_ERROR',
        );
      }

      final adminUsers = response.data!.items
          .map((record) => AdminUserModel.fromRecord(record))
          .toList();

      return PaginatedResponse(
        page: response.data!.page,
        perPage: response.data!.perPage,
        totalItems: response.data!.totalItems,
        totalPages: response.data!.totalPages,
        items: adminUsers,
      );
    } catch (e) {
      _logger.e('Failed to get admin users: $e');
      throw ServerException(
        message: 'Failed to fetch admin users: $e',
        code: 'ADMIN_USERS_FETCH_ERROR',
        details: e,
      );
    }
  }

  @override
  Future<AdminUserModel> getAdminUser(String id) async {
    try {
      final response = await _client.getRecord(ApiEndpoints.superUsers, id);

      if (!response.success || response.data == null) {
        throw ServerException(
          message: response.error ?? 'Admin user not found',
          code: 'ADMIN_USER_NOT_FOUND',
        );
      }

      return AdminUserModel.fromRecord(response.data!);
    } catch (e) {
      _logger.e('Failed to get admin user: $e');
      throw ServerException(
        message: 'Failed to fetch admin user: $e',
        code: 'ADMIN_USER_FETCH_ERROR',
        details: e,
      );
    }
  }

  @override
  Future<AdminUserModel> createAdminUser(Map<String, dynamic> data) async {
    try {
      final response =
          await _client.createRecord(ApiEndpoints.superUsers, data);

      if (!response.success || response.data == null) {
        throw ServerException(
          message: response.error ?? 'Failed to create admin user',
          code: 'ADMIN_USER_CREATE_ERROR',
        );
      }

      final adminUser = AdminUserModel.fromRecord(response.data!);

      return adminUser;
    } catch (e) {
      _logger.e('Failed to create admin user: $e');
      throw ServerException(
        message: 'Failed to create admin user: $e',
        code: 'ADMIN_USER_CREATE_ERROR',
        details: e,
      );
    }
  }

  @override
  Future<AdminUserModel> updateAdminUser(
      String id, Map<String, dynamic> data) async {
    try {
      final response =
          await _client.updateRecord(ApiEndpoints.superUsers, id, data);

      if (!response.success || response.data == null) {
        throw ServerException(
          message: response.error ?? 'Failed to update admin user',
          code: 'ADMIN_USER_UPDATE_ERROR',
        );
      }

      final adminUser = AdminUserModel.fromRecord(response.data!);


      return adminUser;
    } catch (e) {
      _logger.e('Failed to update admin user: $e');
      throw ServerException(
        message: 'Failed to update admin user: $e',
        code: 'ADMIN_USER_UPDATE_ERROR',
        details: e,
      );
    }
  }

  @override
  Future<void> deleteAdminUser(String id) async {
    try {
      final response = await _client.deleteRecord(ApiEndpoints.superUsers, id);

      if (!response.success) {
        throw ServerException(
          message: response.error ?? 'Failed to delete admin user',
          code: 'ADMIN_USER_DELETE_ERROR',
        );
      }

      _analyticsService.trackEvent('admin_user_deleted', {
        'admin_id': id,
      });
    } catch (e) {
      _logger.e('Failed to delete admin user: $e');
      throw ServerException(
        message: 'Failed to delete admin user: $e',
        code: 'ADMIN_USER_DELETE_ERROR',
        details: e,
      );
    }
  }

  // Analytics
  @override
  Future<AnalyticsModel> getAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? granularity,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
        if (granularity != null) 'granularity': granularity,
      };

      final response = await _client.getRecords(
        ApiEndpoints.analytics,
        perPage: 1,
        query: queryParams,
      );

      if (!response.success ||
          response.data == null ||
          response.data!.items.isEmpty) {
        throw const ServerException(
          message: 'Analytics data not found',
          code: 'ANALYTICS_NOT_FOUND',
        );
      }

      return AnalyticsModel.fromRecord(response.data!.items.first);
    } catch (e) {
      _logger.e('Failed to get analytics: $e');
      throw ServerException(
        message: 'Failed to fetch analytics: $e',
        code: 'ANALYTICS_FETCH_ERROR',
        details: e,
      );
    }
  }

  @override
  Future<List<AnalyticsModel>> getAnalyticsHistory({
    int page = 1,
    int perPage = 50,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      };

      final response = await _client.getRecords(
        ApiEndpoints.analytics,
        page: page,
        perPage: perPage,
        sort: '-created',
        query: queryParams,
      );

      if (!response.success || response.data == null) {
        throw ServerException(
          message: response.error ?? 'Failed to fetch analytics history',
          code: 'ANALYTICS_HISTORY_FETCH_ERROR',
        );
      }

      return response.data!.items
          .map((record) => AnalyticsModel.fromRecord(record))
          .toList();
    } catch (e) {
      _logger.e('Failed to get analytics history: $e');
      throw ServerException(
        message: 'Failed to fetch analytics history: $e',
        code: 'ANALYTICS_HISTORY_FETCH_ERROR',
        details: e,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _client.getRecords(
        ApiEndpoints.analytics,
        perPage: 1,
        query: {'type': 'dashboard'},
      );

      if (!response.success ||
          response.data == null ||
          response.data!.items.isEmpty) {
        return {};
      }

      return response.data!.items.first.data;
    } catch (e) {
      _logger.e('Failed to get dashboard stats: $e');
      return {};
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUserEngagementMetrics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'type': 'user_engagement',
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      };

      final response = await _client.getRecords(
        ApiEndpoints.analytics,
        query: queryParams,
        sort: '-created',
      );

      if (!response.success || response.data == null) {
        return [];
      }

      return response.data!.items
          .map((record) => record.data)
          .toList();
    } catch (e) {
      _logger.e('Failed to get user engagement metrics: $e');
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getContentPerformanceMetrics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'type': 'content_performance',
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      };

      final response = await _client.getRecords(
        ApiEndpoints.analytics,
        query: queryParams,
        sort: '-created',
      );

      if (!response.success || response.data == null) {
        return [];
      }

      return response.data!.items
          .map((record) => record.data)
          .toList();
    } catch (e) {
      _logger.e('Failed to get content performance metrics: $e');
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getRevenueMetrics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'type': 'revenue',
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      };

      final response = await _client.getRecords(
        ApiEndpoints.analytics,
        query: queryParams,
        sort: '-created',
      );

      if (!response.success || response.data == null) {
        return [];
      }

      return response.data!.items
          .map((record) => record.data)
          .toList();
    } catch (e) {
      _logger.e('Failed to get revenue metrics: $e');
      return [];
    }
  }

  // Content Reports
  @override
  Future<PaginatedResponse<ContentReportModel>> getContentReports({
    int page = 1,
    int perPage = 20,
    String? status,
    String? sort,
  }) async {
    try {
      final filter = status != null ? 'status="$status"' : null;

      final response = await _client.getRecords(
        ApiEndpoints.contentReports,
        page: page,
        perPage: perPage,
        filter: filter,
        sort: sort ?? '-created',
      );

      if (!response.success || response.data == null) {
        throw ServerException(
          message: response.error ?? 'Failed to fetch content reports',
          code: 'CONTENT_REPORTS_FETCH_ERROR',
        );
      }

      final reports = response.data!.items
          .map((record) => ContentReportModel.fromRecord(record))
          .toList();

      return PaginatedResponse(
        page: response.data!.page,
        perPage: response.data!.perPage,
        totalItems: response.data!.totalItems,
        totalPages: response.data!.totalPages,
        items: reports,
      );
    } catch (e) {
      _logger.e('Failed to get content reports: $e');
      throw ServerException(
        message: 'Failed to fetch content reports: $e',
        code: 'CONTENT_REPORTS_FETCH_ERROR',
        details: e,
      );
    }
  }

  @override
  Future<ContentReportModel> getContentReport(String id) async {
    try {
      final response = await _client.getRecord(ApiEndpoints.contentReports, id);

      if (!response.success || response.data == null) {
        throw ServerException(
          message: response.error ?? 'Content report not found',
          code: 'CONTENT_REPORT_NOT_FOUND',
        );
      }

      return ContentReportModel.fromRecord(response.data!);
    } catch (e) {
      _logger.e('Failed to get content report: $e');
      throw ServerException(
        message: 'Failed to fetch content report: $e',
        code: 'CONTENT_REPORT_FETCH_ERROR',
        details: e,
      );
    }
  }

  @override
  Future<ContentReportModel> updateContentReportStatus(
    String id,
    String status,
    String? resolution,
  ) async {
    try {
      final data = <String, dynamic>{
        'status': status,
        if (resolution != null) 'resolution': resolution,
        'resolved_at': DateTime.now().toIso8601String(),
      };

      final response = await _client.updateRecord(
        ApiEndpoints.contentReports,
        id,
        data,
      );

      if (!response.success || response.data == null) {
        throw ServerException(
          message: response.error ?? 'Failed to update content report',
          code: 'CONTENT_REPORT_UPDATE_ERROR',
        );
      }

      final report = ContentReportModel.fromRecord(response.data!);

      _analyticsService.trackEvent('content_report_updated', {
        'report_id': report.id,
        'status': status,
      });

      return report;
    } catch (e) {
      _logger.e('Failed to update content report status: $e');
      throw ServerException(
        message: 'Failed to update content report: $e',
        code: 'CONTENT_REPORT_UPDATE_ERROR',
        details: e,
      );
    }
  }

  @override
  Future<void> deleteContentReport(String id) async {
    try {
      final response =
          await _client.deleteRecord(ApiEndpoints.contentReports, id);

      if (!response.success) {
        throw ServerException(
          message: response.error ?? 'Failed to delete content report',
          code: 'CONTENT_REPORT_DELETE_ERROR',
        );
      }

      _analyticsService.trackEvent('content_report_deleted', {
        'report_id': id,
      });
    } catch (e) {
      _logger.e('Failed to delete content report: $e');
      throw ServerException(
        message: 'Failed to delete content report: $e',
        code: 'CONTENT_REPORT_DELETE_ERROR',
        details: e,
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getReportStatistics() async {
    try {
      final response = await _client.getRecords(
        ApiEndpoints.contentReports,
        query: {'get_stats': 'true'},
      );

      if (!response.success || response.data == null) {
        return [];
      }

      return response.data!.items
          .map((record) => record.data)
          .toList();
    } catch (e) {
      _logger.e('Failed to get report statistics: $e');
      return [];
    }
  }

  // Payment History
  @override
  Future<PaginatedResponse<PaymentHistoryModel>> getPaymentHistory({
    int page = 1,
    int perPage = 20,
    String? status,
    String? sort,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var filter = <String>[];

      if (status != null) filter.add('status="$status"');
      if (startDate != null) {
        filter.add('created>="${startDate.toIso8601String()}"');
      }
      if (endDate != null) {
        filter.add('created<="${endDate.toIso8601String()}"');
      }

      final response = await _client.getRecords(
        ApiEndpoints.paymentHistory,
        page: page,
        perPage: perPage,
        filter: filter.isNotEmpty ? filter.join(' && ') : null,
        sort: sort ?? '-created',
      );

      if (!response.success || response.data == null) {
        throw ServerException(
          message: response.error ?? 'Failed to fetch payment history',
          code: 'PAYMENT_HISTORY_FETCH_ERROR',
        );
      }

      final payments = response.data!.items
          .map((record) => PaymentHistoryModel.fromRecord(record))
          .toList();

      return PaginatedResponse(
        page: response.data!.page,
        perPage: response.data!.perPage,
        totalItems: response.data!.totalItems,
        totalPages: response.data!.totalPages,
        items: payments,
      );
    } catch (e) {
      _logger.e('Failed to get payment history: $e');
      throw ServerException(
        message: 'Failed to fetch payment history: $e',
        code: 'PAYMENT_HISTORY_FETCH_ERROR',
        details: e,
      );
    }
  }

  @override
  Future<PaymentHistoryModel> getPaymentDetails(String id) async {
    try {
      final response = await _client.getRecord(ApiEndpoints.paymentHistory, id);

      if (!response.success || response.data == null) {
        throw ServerException(
          message: response.error ?? 'Payment not found',
          code: 'PAYMENT_NOT_FOUND',
        );
      }

      return PaymentHistoryModel.fromRecord(response.data!);
    } catch (e) {
      _logger.e('Failed to get payment details: $e');
      throw ServerException(
        message: 'Failed to fetch payment details: $e',
        code: 'PAYMENT_FETCH_ERROR',
        details: e,
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPaymentStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'get_stats': 'true',
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      };

      final response = await _client.getRecords(
        ApiEndpoints.paymentHistory,
        query: queryParams,
      );

      if (!response.success || response.data == null) {
        return [];
      }

      return response.data!.items
          .map((record) => record.data)
          .toList();
    } catch (e) {
      _logger.e('Failed to get payment statistics: $e');
      return [];
    }
  }

  @override
  Future<void> refundPayment(String paymentId, double amount) async {
    try {
      final data = {
        'action': 'refund',
        'amount': amount,
        'refunded_at': DateTime.now().toIso8601String(),
      };

      final response = await _client.updateRecord(
        ApiEndpoints.paymentHistory,
        paymentId,
        data,
      );

      if (!response.success) {
        throw ServerException(
          message: response.error ?? 'Failed to refund payment',
          code: 'PAYMENT_REFUND_ERROR',
        );
      }

      _analyticsService.trackEvent('payment_refunded', {
        'payment_id': paymentId,
        'amount': amount,
      });
    } catch (e) {
      _logger.e('Failed to refund payment: $e');
      throw ServerException(
        message: 'Failed to refund payment: $e',
        code: 'PAYMENT_REFUND_ERROR',
        details: e,
      );
    }
  }

  // User Management
  @override
  Future<PaginatedResponse<Map<String, dynamic>>> getUsers({
    int page = 1,
    int perPage = 20,
    String? filter,
    String? sort,
  }) async {
    try {
      final response = await _client.getRecords(
        ApiEndpoints.users,
        page: page,
        perPage: perPage,
        filter: filter,
        sort: sort ?? '-created',
      );

      if (!response.success || response.data == null) {
        throw ServerException(
          message: response.error ?? 'Failed to fetch users',
          code: 'USERS_FETCH_ERROR',
        );
      }

      final users = response.data!.items
          .map((record) => record.data)
          .toList();

      return PaginatedResponse(
        page: response.data!.page,
        perPage: response.data!.perPage,
        totalItems: response.data!.totalItems,
        totalPages: response.data!.totalPages,
        items: users,
      );
    } catch (e) {
      _logger.e('Failed to get users: $e');
      throw ServerException(
        message: 'Failed to fetch users: $e',
        code: 'USERS_FETCH_ERROR',
        details: e,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getUserDetails(String userId) async {
    try {
      final response = await _client.getRecord(ApiEndpoints.users, userId);

      if (!response.success || response.data == null) {
        throw ServerException(
          message: response.error ?? 'User not found',
          code: 'USER_NOT_FOUND',
        );
      }

      return response.data!.data;
    } catch (e) {
      _logger.e('Failed to get user details: $e');
      throw ServerException(
        message: 'Failed to fetch user details: $e',
        code: 'USER_FETCH_ERROR',
        details: e,
      );
    }
  }

  @override
  Future<void> suspendUser(String userId, String reason) async {
    try {
      final data = {
        'status': 'suspended',
        'suspension_reason': reason,
        'suspended_at': DateTime.now().toIso8601String(),
      };

      final response =
          await _client.updateRecord(ApiEndpoints.users, userId, data);

      if (!response.success) {
        throw ServerException(
          message: response.error ?? 'Failed to suspend user',
          code: 'USER_SUSPEND_ERROR',
        );
      }

      _analyticsService.trackEvent('user_suspended', {
        'user_id': userId,
        'reason': reason,
      });
    } catch (e) {
      _logger.e('Failed to suspend user: $e');
      throw ServerException(
        message: 'Failed to suspend user: $e',
        code: 'USER_SUSPEND_ERROR',
        details: e,
      );
    }
  }

  @override
  Future<void> activateUser(String userId) async {
    try {
      final data = {
        'status': 'active',
        'suspension_reason': null,
        'suspended_at': null,
        'activated_at': DateTime.now().toIso8601String(),
      };

      final response =
          await _client.updateRecord(ApiEndpoints.users, userId, data);

      if (!response.success) {
        throw ServerException(
          message: response.error ?? 'Failed to activate user',
          code: 'USER_ACTIVATE_ERROR',
        );
      }

      _analyticsService.trackEvent('user_activated', {
        'user_id': userId,
      });
    } catch (e) {
      _logger.e('Failed to activate user: $e');
      throw ServerException(
        message: 'Failed to activate user: $e',
        code: 'USER_ACTIVATE_ERROR',
        details: e,
      );
    }
  }

  @override
  Future<void> deleteUserAccount(String userId) async {
    try {
      final response = await _client.deleteRecord(ApiEndpoints.users, userId);

      if (!response.success) {
        throw ServerException(
          message: response.error ?? 'Failed to delete user',
          code: 'USER_DELETE_ERROR',
        );
      }

      _analyticsService.trackEvent('user_deleted', {
        'user_id': userId,
      });
    } catch (e) {
      _logger.e('Failed to delete user: $e');
      throw ServerException(
        message: 'Failed to delete user: $e',
        code: 'USER_DELETE_ERROR',
        details: e,
      );
    }
  }

  // Content Management
  @override
  Future<PaginatedResponse<Map<String, dynamic>>> getContent({
    int page = 1,
    int perPage = 20,
    String? filter,
    String? sort,
  }) async {
    try {
      final response = await _client.getRecords(
        ApiEndpoints.content,
        page: page,
        perPage: perPage,
        filter: filter,
        sort: sort ?? '-created',
      );

      if (!response.success || response.data == null) {
        throw ServerException(
          message: response.error ?? 'Failed to fetch content',
          code: 'CONTENT_FETCH_ERROR',
        );
      }

      final content = response.data!.items
          .map((record) => record.data)
          .toList();

      return PaginatedResponse(
        page: response.data!.page,
        perPage: response.data!.perPage,
        totalItems: response.data!.totalItems,
        totalPages: response.data!.totalPages,
        items: content,
      );
    } catch (e) {
      _logger.e('Failed to get content: $e');
      throw ServerException(
        message: 'Failed to fetch content: $e',
        code: 'CONTENT_FETCH_ERROR',
        details: e,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> updateContentStatus(
    String contentId,
    String status,
  ) async {
    try {
      final data = {
        'status': status,
        'status_updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _client.updateRecord(
        ApiEndpoints.content,
        contentId,
        data,
      );

      if (!response.success || response.data == null) {
        throw ServerException(
          message: response.error ?? 'Failed to update content status',
          code: 'CONTENT_UPDATE_ERROR',
        );
      }

      _analyticsService.trackEvent('content_status_updated', {
        'content_id': contentId,
        'status': status,
      });

      return response.data!.data;
    } catch (e) {
      _logger.e('Failed to update content status: $e');
      throw ServerException(
        message: 'Failed to update content status: $e',
        code: 'CONTENT_UPDATE_ERROR',
        details: e,
      );
    }
  }

  @override
  Future<void> deleteContent(String contentId) async {
    try {
      final response =
          await _client.deleteRecord(ApiEndpoints.content, contentId);

      if (!response.success) {
        throw ServerException(
          message: response.error ?? 'Failed to delete content',
          code: 'CONTENT_DELETE_ERROR',
        );
      }

      _analyticsService.trackEvent('content_deleted', {
        'content_id': contentId,
      });
    } catch (e) {
      _logger.e('Failed to delete content: $e');
      throw ServerException(
        message: 'Failed to delete content: $e',
        code: 'CONTENT_DELETE_ERROR',
        details: e,
      );
    }
  }

  // System Settings
  @override
  Future<Map<String, dynamic>> getSystemSettings() async {
    try {
      final response = await _client.getRecords(
        ApiEndpoints.settings,
        perPage: 1,
      );

      if (!response.success ||
          response.data == null ||
          response.data!.items.isEmpty) {
        return {};
      }

      return response.data!.items.first.data;
    } catch (e) {
      _logger.e('Failed to get system settings: $e');
      return {};
    }
  }

  @override
  Future<void> updateSystemSettings(Map<String, dynamic> settings) async {
    try {
      final response = await _client.updateRecord(
        ApiEndpoints.settings,
        'system',
        settings,
      );

      if (!response.success) {
        throw ServerException(
          message: response.error ?? 'Failed to update system settings',
          code: 'SETTINGS_UPDATE_ERROR',
        );
      }

      _analyticsService.trackEvent('system_settings_updated', settings);
    } catch (e) {
      _logger.e('Failed to update system settings: $e');
      throw ServerException(
        message: 'Failed to update system settings: $e',
        code: 'SETTINGS_UPDATE_ERROR',
        details: e,
      );
    }
  }

  // Notifications
  @override
  Future<void> sendNotificationToUsers({
    required String title,
    required String message,
    List<String>? userIds,
    String? userType,
  }) async {
    try {
      final data = {
        'title': title,
        'message': message,
        'type': 'admin_notification',
        'created_at': DateTime.now().toIso8601String(),
        if (userIds != null) 'user_ids': userIds,
        if (userType != null) 'user_type': userType,
      };

      final response = await _client.createRecord(
        ApiEndpoints.notifications,
        data,
      );

      if (!response.success) {
        throw ServerException(
          message: response.error ?? 'Failed to send notification',
          code: 'NOTIFICATION_SEND_ERROR',
        );
      }

      _analyticsService.trackEvent('admin_notification_sent', {
        'title': title,
        'user_count': userIds?.length ?? 0,
        'user_type': userType,
      });
    } catch (e) {
      _logger.e('Failed to send notification: $e');
      throw ServerException(
        message: 'Failed to send notification: $e',
        code: 'NOTIFICATION_SEND_ERROR',
        details: e,
      );
    }
  }

  @override
  Future<void> sendSystemAnnouncement({
    required String title,
    required String message,
    String? priority,
  }) async {
    try {
      final data = {
        'title': title,
        'message': message,
        'type': 'system_announcement',
        'priority': priority ?? 'normal',
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _client.createRecord(
        ApiEndpoints.notifications,
        data,
      );

      if (!response.success) {
        throw ServerException(
          message: response.error ?? 'Failed to send announcement',
          code: 'ANNOUNCEMENT_SEND_ERROR',
        );
      }

      _analyticsService.trackEvent('system_announcement_sent', {
        'title': title,
        'priority': priority,
      });
    } catch (e) {
      _logger.e('Failed to send announcement: $e');
      throw ServerException(
        message: 'Failed to send announcement: $e',
        code: 'ANNOUNCEMENT_SEND_ERROR',
        details: e,
      );
    }
  }
}
