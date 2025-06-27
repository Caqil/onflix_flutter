import 'package:dartz/dartz.dart';
import 'package:onflix/core/errors/failures.dart';
import 'package:onflix/shared/models/pagination.dart';
import '../../data/models/payment_history_model.dart';
import '../../domain/entities/admin_user.dart';
import '../../domain/entities/analytics_data.dart';
import '../../domain/entities/content_report.dart';

abstract class AdminRepository {
  // Authentication
  Future<Either<Failure, AdminUser>> loginAdmin(String email, String password);
  Future<Either<Failure, void>> logoutAdmin();
  Future<Either<Failure, AdminUser>> refreshAdminToken();
  Future<Either<Failure, bool>> isAdminAuthenticated();

  // Admin Users Management
  Future<Either<Failure, PaginatedResponse<AdminUser>>> getAdminUsers({
    int page = 1,
    int perPage = 20,
    String? filter,
    String? sort,
  });
  Future<Either<Failure, AdminUser>> getAdminUser(String id);
  Future<Either<Failure, AdminUser>> createAdminUser({
    required String email,
    required String password,
    required String passwordConfirm,
  });
  Future<Either<Failure, AdminUser>> updateAdminUser(
    String id,
    Map<String, dynamic> data,
  );
  Future<Either<Failure, void>> deleteAdminUser(String id);

  // Analytics
  Future<Either<Failure, AnalyticsData>> getAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? granularity,
  });
  Future<Either<Failure, List<AnalyticsData>>> getAnalyticsHistory({
    int page = 1,
    int perPage = 50,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<Either<Failure, Map<String, dynamic>>> getDashboardStats();
  Future<Either<Failure, List<Map<String, dynamic>>>> getUserEngagementMetrics({
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<Either<Failure, List<Map<String, dynamic>>>>
      getContentPerformanceMetrics({
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<Either<Failure, List<Map<String, dynamic>>>> getRevenueMetrics({
    DateTime? startDate,
    DateTime? endDate,
  });

  // Content Reports
  Future<Either<Failure, PaginatedResponse<ContentReport>>> getContentReports({
    int page = 1,
    int perPage = 20,
    String? status,
    String? sort,
  });
  Future<Either<Failure, ContentReport>> getContentReport(String id);
  Future<Either<Failure, ContentReport>> updateContentReportStatus(
    String id,
    String status,
    String? resolution,
  );
  Future<Either<Failure, void>> deleteContentReport(String id);
  Future<Either<Failure, List<Map<String, dynamic>>>> getReportStatistics();

  // Payment History
  Future<Either<Failure, PaginatedResponse<PaymentHistoryModel>>>
      getPaymentHistory({
    int page = 1,
    int perPage = 20,
    String? status,
    String? sort,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<Either<Failure, PaymentHistoryModel>> getPaymentDetails(String id);
  Future<Either<Failure, List<Map<String, dynamic>>>> getPaymentStatistics({
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<Either<Failure, void>> refundPayment(String paymentId, double amount);

  // User Management
  Future<Either<Failure, PaginatedResponse<Map<String, dynamic>>>> getUsers({
    int page = 1,
    int perPage = 20,
    String? filter,
    String? sort,
  });
  Future<Either<Failure, Map<String, dynamic>>> getUserDetails(String userId);
  Future<Either<Failure, void>> suspendUser(String userId, String reason);
  Future<Either<Failure, void>> activateUser(String userId);
  Future<Either<Failure, void>> deleteUserAccount(String userId);

  // Content Management
  Future<Either<Failure, PaginatedResponse<Map<String, dynamic>>>> getContent({
    int page = 1,
    int perPage = 20,
    String? filter,
    String? sort,
  });
  Future<Either<Failure, Map<String, dynamic>>> updateContentStatus(
    String contentId,
    String status,
  );
  Future<Either<Failure, void>> deleteContent(String contentId);

  // System Settings
  Future<Either<Failure, Map<String, dynamic>>> getSystemSettings();
  Future<Either<Failure, void>> updateSystemSettings(
    Map<String, dynamic> settings,
  );

  // Notifications
  Future<Either<Failure, void>> sendNotificationToUsers({
    required String title,
    required String message,
    List<String>? userIds,
    String? userType,
  });
  Future<Either<Failure, void>> sendSystemAnnouncement({
    required String title,
    required String message,
    String? priority,
  });

  // Cache Management
  Future<Either<Failure, void>> clearCache();
  Future<Either<Failure, void>> refreshCache();
}
