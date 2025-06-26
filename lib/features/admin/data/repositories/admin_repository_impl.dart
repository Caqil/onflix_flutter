import 'package:onflix/shared/models/api_response.dart';
import 'package:onflix/shared/models/pagination.dart';
import '../models/admin_user_model.dart';
import '../models/analytics_model.dart';
import '../models/content_report_model.dart';
import '../models/payment_history_model.dart';

abstract class AdminRepository {
  // Authentication
  Future<ApiResponse<AdminUserModel>> loginAdmin(String email, String password);
  Future<ApiResponse<void>> logoutAdmin();
  Future<ApiResponse<AdminUserModel>> getCurrentAdmin();
  Future<ApiResponse<AdminUserModel>> refreshAdminToken();

  // Admin Users Management
  Future<ApiResponse<PaginatedResponse<AdminUserModel>>> getAdminUsers({
    int page = 1,
    int perPage = 20,
    String? filter,
    String? sort,
  });
  Future<ApiResponse<AdminUserModel>> getAdminUser(String id);
  Future<ApiResponse<AdminUserModel>> createAdminUser(
      Map<String, dynamic> data);
  Future<ApiResponse<AdminUserModel>> updateAdminUser(
      String id, Map<String, dynamic> data);
  Future<ApiResponse<void>> deleteAdminUser(String id);

  // Analytics
  Future<ApiResponse<AnalyticsModel>> getAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? granularity,
  });
  Future<ApiResponse<List<AnalyticsModel>>> getAnalyticsHistory({
    int page = 1,
    int perPage = 50,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<ApiResponse<Map<String, dynamic>>> getDashboardStats();
  Future<ApiResponse<List<Map<String, dynamic>>>> getUserEngagementMetrics({
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<ApiResponse<List<Map<String, dynamic>>>> getContentPerformanceMetrics({
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<ApiResponse<List<Map<String, dynamic>>>> getRevenueMetrics({
    DateTime? startDate,
    DateTime? endDate,
  });

  // Content Reports
  Future<ApiResponse<PaginatedResponse<ContentReportModel>>> getContentReports({
    int page = 1,
    int perPage = 20,
    String? status,
    String? sort,
  });
  Future<ApiResponse<ContentReportModel>> getContentReport(String id);
  Future<ApiResponse<ContentReportModel>> updateContentReportStatus(
    String id,
    String status,
    String? resolution,
  );
  Future<ApiResponse<void>> deleteContentReport(String id);
  Future<ApiResponse<List<Map<String, dynamic>>>> getReportStatistics();

  // Payment History
  Future<ApiResponse<PaginatedResponse<PaymentHistoryModel>>>
      getPaymentHistory({
    int page = 1,
    int perPage = 20,
    String? status,
    String? sort,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<ApiResponse<PaymentHistoryModel>> getPaymentDetails(String id);
  Future<ApiResponse<List<Map<String, dynamic>>>> getPaymentStatistics({
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<ApiResponse<void>> refundPayment(String paymentId, double amount);

  // User Management
  Future<ApiResponse<PaginatedResponse<Map<String, dynamic>>>> getUsers({
    int page = 1,
    int perPage = 20,
    String? filter,
    String? sort,
  });
  Future<ApiResponse<Map<String, dynamic>>> getUserDetails(String userId);
  Future<ApiResponse<void>> suspendUser(String userId, String reason);
  Future<ApiResponse<void>> activateUser(String userId);
  Future<ApiResponse<void>> deleteUserAccount(String userId);

  // Content Management
  Future<ApiResponse<PaginatedResponse<Map<String, dynamic>>>> getContent({
    int page = 1,
    int perPage = 20,
    String? filter,
    String? sort,
  });
  Future<ApiResponse<Map<String, dynamic>>> updateContentStatus(
    String contentId,
    String status,
  );
  Future<ApiResponse<void>> deleteContent(String contentId);

  // System Settings
  Future<ApiResponse<Map<String, dynamic>>> getSystemSettings();
  Future<ApiResponse<void>> updateSystemSettings(Map<String, dynamic> settings);

  // Notifications
  Future<ApiResponse<void>> sendNotificationToUsers({
    required String title,
    required String message,
    List<String>? userIds,
    String? userType,
  });
  Future<ApiResponse<void>> sendSystemAnnouncement({
    required String title,
    required String message,
    String? priority,
  });

  // Admin Preferences
  Future<ApiResponse<void>> saveAdminPreferences(
      Map<String, dynamic> preferences);
  Future<ApiResponse<Map<String, dynamic>>> getAdminPreferences();

  // Session Management
  Future<ApiResponse<bool>> isSessionValid();
  Future<ApiResponse<void>> clearAllCache();
}
