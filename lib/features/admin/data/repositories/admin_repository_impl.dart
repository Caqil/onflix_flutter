import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import 'package:onflix/core/errors/exceptions.dart';
import 'package:onflix/core/errors/failures.dart';
import 'package:onflix/core/network/network_info.dart';
import 'package:onflix/shared/models/pagination.dart';
import 'package:onflix/shared/services/analytics_service.dart';

import '../../domain/entities/admin_user.dart';
import '../../domain/entities/analytics_data.dart';
import '../../domain/entities/content_report.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_local_datasource.dart';
import '../datasources/admin_remote_datasource.dart';
import '../models/admin_user_model.dart';
import '../models/analytics_model.dart'
    hide UserMetrics, ContentMetrics, RevenueMetrics, EngagementMetrics;
import '../models/content_report_model.dart';
import '../models/payment_history_model.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;
  final AdminLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final Logger _logger = Logger();
  final AnalyticsService _analyticsService = AnalyticsService.instance;

  AdminRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  // Helper method to handle repository calls with error handling
  Future<Either<Failure, T>> _handleRepositoryCall<T>(
    Future<T> Function() call, {
    String? operation,
  }) async {
    try {
      final result = await call();
      return Right(result);
    } on AuthException catch (e) {
      _logger.e('Auth error in ${operation ?? 'repository'}: $e');
      _analyticsService.trackEvent('admin_auth_error', {
        'operation': operation,
        'error': e.toString(),
      });
      return Left(AuthFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      _logger.e('Server error in ${operation ?? 'repository'}: $e');
      _analyticsService.trackEvent('admin_server_error', {
        'operation': operation,
        'error': e.toString(),
      });
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      _logger.e('Network error in ${operation ?? 'repository'}: $e');
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on CacheException catch (e) {
      _logger.e('Cache error in ${operation ?? 'repository'}: $e');
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      _logger.e('Unexpected error in ${operation ?? 'repository'}: $e');
      return Left(ServerFailure(
        message: 'An unexpected error occurred: $e',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  // Authentication
  @override
  Future<Either<Failure, AdminUser>> loginAdmin(
    String email,
    String password,
  ) async {
    return _handleRepositoryCall(
      () async {
        final adminUserModel =
            await remoteDataSource.loginAdmin(email, password);

        // Cache the admin user
        await localDataSource.cacheAdminUser(adminUserModel);

        final adminUser = _mapAdminUserModelToEntity(adminUserModel);

        _analyticsService.trackEvent('admin_login_success', {
          'admin_id': adminUser.id,
          'email': adminUser.email,
        });

        return adminUser;
      },
      operation: 'loginAdmin',
    );
  }

  @override
  Future<Either<Failure, void>> logoutAdmin() async {
    return _handleRepositoryCall(
      () async {
        await remoteDataSource.logoutAdmin();
        await localDataSource.clearAdminUserCache();
        await localDataSource.clearAdminSession();
        await localDataSource.clearDashboardCache();

        _analyticsService.trackEvent('admin_logout');
      },
      operation: 'logoutAdmin',
    );
  }

  @override
  Future<Either<Failure, AdminUser>> refreshAdminToken() async {
    return _handleRepositoryCall(
      () async {
        final adminUserModel = await remoteDataSource.refreshAdminToken();

        // Update cached admin user
        await localDataSource.cacheAdminUser(adminUserModel);

        return _mapAdminUserModelToEntity(adminUserModel);
      },
      operation: 'refreshAdminToken',
    );
  }

  @override
  Future<Either<Failure, bool>> isAdminAuthenticated() async {
    return _handleRepositoryCall(
      () async {
        // Check if we have a cached admin user
        final cachedAdmin = await localDataSource.getCachedAdminUser();
        if (cachedAdmin == null) return false;

        // Check session expiry
        final sessionExpiry = await localDataSource.getAdminSessionExpiry();
        if (sessionExpiry != null && DateTime.now().isAfter(sessionExpiry)) {
          await localDataSource.clearAdminSession();
          await localDataSource.clearAdminUserCache();
          return false;
        }

        return true;
      },
      operation: 'isAdminAuthenticated',
    );
  }

  // Admin Users Management
  @override
  Future<Either<Failure, PaginatedResponse<AdminUser>>> getAdminUsers({
    int page = 1,
    int perPage = 20,
    String? filter,
    String? sort,
  }) async {
    return _handleRepositoryCall(
      () async {
        final response = await remoteDataSource.getAdminUsers(
          page: page,
          perPage: perPage,
          filter: filter,
          sort: sort,
        );

        final adminUsers = response.items
            .map((model) => _mapAdminUserModelToEntity(model))
            .toList();

        return PaginatedResponse<AdminUser>(
          page: response.page,
          perPage: response.perPage,
          totalItems: response.totalItems,
          totalPages: response.totalPages,
          items: adminUsers,
        );
      },
      operation: 'getAdminUsers',
    );
  }

  @override
  Future<Either<Failure, AdminUser>> getAdminUser(String id) async {
    return _handleRepositoryCall(
      () async {
        final adminUserModel = await remoteDataSource.getAdminUser(id);
        return _mapAdminUserModelToEntity(adminUserModel);
      },
      operation: 'getAdminUser',
    );
  }

  @override
  Future<Either<Failure, AdminUser>> createAdminUser({
    required String email,
    required String password,
    required String passwordConfirm,
  }) async {
    return _handleRepositoryCall(
      () async {
        final data = {
          'email': email,
          'password': password,
          'passwordConfirm': passwordConfirm,
        };

        final adminUserModel = await remoteDataSource.createAdminUser(data);

        _analyticsService.trackEvent('admin_user_created', {
          'created_by': adminUserModel.id,
          'email': email,
        });

        return _mapAdminUserModelToEntity(adminUserModel);
      },
      operation: 'createAdminUser',
    );
  }

  @override
  Future<Either<Failure, AdminUser>> updateAdminUser(
    String id,
    Map<String, dynamic> data,
  ) async {
    return _handleRepositoryCall(
      () async {
        final adminUserModel = await remoteDataSource.updateAdminUser(id, data);

        _analyticsService.trackEvent('admin_user_updated', {
          'admin_id': id,
          'updated_fields': data.keys.toList(),
        });

        return _mapAdminUserModelToEntity(adminUserModel);
      },
      operation: 'updateAdminUser',
    );
  }

  @override
  Future<Either<Failure, void>> deleteAdminUser(String id) async {
    return _handleRepositoryCall(
      () async {
        await remoteDataSource.deleteAdminUser(id);

        _analyticsService.trackEvent('admin_user_deleted', {
          'admin_id': id,
        });
      },
      operation: 'deleteAdminUser',
    );
  }

  // Analytics
  @override
  Future<Either<Failure, AnalyticsData>> getAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? granularity,
  }) async {
    return _handleRepositoryCall(
      () async {
        final analyticsModel = await remoteDataSource.getAnalytics(
          startDate: startDate,
          endDate: endDate,
          granularity: granularity,
        );

        // Cache the analytics data
        await localDataSource.cacheAnalyticsData(analyticsModel);

        return _mapAnalyticsModelToEntity(analyticsModel);
      },
      operation: 'getAnalytics',
    );
  }

  @override
  Future<Either<Failure, List<AnalyticsData>>> getAnalyticsHistory({
    int page = 1,
    int perPage = 50,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return _handleRepositoryCall(
      () async {
        final analyticsModels = await remoteDataSource.getAnalyticsHistory(
          page: page,
          perPage: perPage,
          startDate: startDate,
          endDate: endDate,
        );

        // Cache the analytics history
        await localDataSource.cacheAnalyticsHistory(analyticsModels);

        return analyticsModels
            .map((model) => _mapAnalyticsModelToEntity(model))
            .toList();
      },
      operation: 'getAnalyticsHistory',
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDashboardStats() async {
    return _handleRepositoryCall(
      () async {
        if (await networkInfo.isConnected) {
          final stats = await remoteDataSource.getDashboardStats();

          // Cache dashboard stats
          await localDataSource.saveDashboardCache(stats);

          return stats;
        } else {
          // Return cached data if offline
          final cachedStats = await localDataSource.getDashboardCache();
          if (cachedStats != null) {
            return cachedStats;
          }
          throw NetworkException(
            message: 'No internet connection and no cached data available',
            code: 'NO_CACHED_DATA',
          );
        }
      },
      operation: 'getDashboardStats',
    );
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getUserEngagementMetrics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return _handleRepositoryCall(
      () async {
        return await remoteDataSource.getUserEngagementMetrics(
          startDate: startDate,
          endDate: endDate,
        );
      },
      operation: 'getUserEngagementMetrics',
    );
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>>
      getContentPerformanceMetrics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return _handleRepositoryCall(
      () async {
        return await remoteDataSource.getContentPerformanceMetrics(
          startDate: startDate,
          endDate: endDate,
        );
      },
      operation: 'getContentPerformanceMetrics',
    );
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getRevenueMetrics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return _handleRepositoryCall(
      () async {
        return await remoteDataSource.getRevenueMetrics(
          startDate: startDate,
          endDate: endDate,
        );
      },
      operation: 'getRevenueMetrics',
    );
  }

  // Content Reports
  @override
  Future<Either<Failure, PaginatedResponse<ContentReport>>> getContentReports({
    int page = 1,
    int perPage = 20,
    String? status,
    String? sort,
  }) async {
    return _handleRepositoryCall(
      () async {
        final response = await remoteDataSource.getContentReports(
          page: page,
          perPage: perPage,
          status: status,
          sort: sort,
        );

        // Cache content reports
        await localDataSource.cacheContentReports(response.items);

        final contentReports = response.items
            .map((model) => _mapContentReportModelToEntity(model))
            .toList();

        return PaginatedResponse<ContentReport>(
          page: response.page,
          perPage: response.perPage,
          totalItems: response.totalItems,
          totalPages: response.totalPages,
          items: contentReports,
        );
      },
      operation: 'getContentReports',
    );
  }

  @override
  Future<Either<Failure, ContentReport>> getContentReport(String id) async {
    return _handleRepositoryCall(
      () async {
        final contentReportModel = await remoteDataSource.getContentReport(id);
        return _mapContentReportModelToEntity(contentReportModel);
      },
      operation: 'getContentReport',
    );
  }

  @override
  Future<Either<Failure, ContentReport>> updateContentReportStatus(
    String id,
    String status,
    String? resolution,
  ) async {
    return _handleRepositoryCall(
      () async {
        final updatedReport = await remoteDataSource.updateContentReportStatus(
          id,
          status,
          resolution,
        );

        // Update cache
        await localDataSource.updateContentReportInCache(updatedReport);

        _analyticsService.trackEvent('content_report_status_updated', {
          'report_id': id,
          'status': status,
          'has_resolution': resolution != null,
        });

        return _mapContentReportModelToEntity(updatedReport);
      },
      operation: 'updateContentReportStatus',
    );
  }

  @override
  Future<Either<Failure, void>> deleteContentReport(String id) async {
    return _handleRepositoryCall(
      () async {
        await remoteDataSource.deleteContentReport(id);

        // Remove from cache
        await localDataSource.removeContentReportFromCache(id);

        _analyticsService.trackEvent('content_report_deleted', {
          'report_id': id,
        });
      },
      operation: 'deleteContentReport',
    );
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>>
      getReportStatistics() async {
    return _handleRepositoryCall(
      () async {
        return await remoteDataSource.getReportStatistics();
      },
      operation: 'getReportStatistics',
    );
  }

  // Payment History
  @override
  Future<Either<Failure, PaginatedResponse<PaymentHistoryModel>>>
      getPaymentHistory({
    int page = 1,
    int perPage = 20,
    String? status,
    String? sort,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return _handleRepositoryCall(
      () async {
        final response = await remoteDataSource.getPaymentHistory(
          page: page,
          perPage: perPage,
          status: status,
          sort: sort,
          startDate: startDate,
          endDate: endDate,
        );

        // Cache payment history
        await localDataSource.cachePaymentHistory(response.items);

        final paymentHistory = response.items
            .map((model) => _mapPaymentHistoryModelToEntity(model))
            .toList();

        return PaginatedResponse<PaymentHistoryModel>(
          page: response.page,
          perPage: response.perPage,
          totalItems: response.totalItems,
          totalPages: response.totalPages,
          items: paymentHistory,
        );
      },
      operation: 'getPaymentHistory',
    );
  }

  @override
  Future<Either<Failure, PaymentHistoryModel>> getPaymentDetails(
      String id) async {
    return _handleRepositoryCall(
      () async {
        final paymentModel = await remoteDataSource.getPaymentDetails(id);
        return _mapPaymentHistoryModelToEntity(paymentModel);
      },
      operation: 'getPaymentDetails',
    );
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getPaymentStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return _handleRepositoryCall(
      () async {
        return await remoteDataSource.getPaymentStatistics(
          startDate: startDate,
          endDate: endDate,
        );
      },
      operation: 'getPaymentStatistics',
    );
  }

  @override
  Future<Either<Failure, void>> refundPayment(
      String paymentId, double amount) async {
    return _handleRepositoryCall(
      () async {
        await remoteDataSource.refundPayment(paymentId, amount);

        _analyticsService.trackEvent('payment_refunded', {
          'payment_id': paymentId,
          'refund_amount': amount,
        });
      },
      operation: 'refundPayment',
    );
  }

  // User Management
  @override
  Future<Either<Failure, PaginatedResponse<Map<String, dynamic>>>> getUsers({
    int page = 1,
    int perPage = 20,
    String? filter,
    String? sort,
  }) async {
    return _handleRepositoryCall(
      () async {
        return await remoteDataSource.getUsers(
          page: page,
          perPage: perPage,
          filter: filter,
          sort: sort,
        );
      },
      operation: 'getUsers',
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserDetails(
      String userId) async {
    return _handleRepositoryCall(
      () async {
        return await remoteDataSource.getUserDetails(userId);
      },
      operation: 'getUserDetails',
    );
  }

  @override
  Future<Either<Failure, void>> suspendUser(
      String userId, String reason) async {
    return _handleRepositoryCall(
      () async {
        await remoteDataSource.suspendUser(userId, reason);

        _analyticsService.trackEvent('user_suspended', {
          'user_id': userId,
          'reason': reason,
        });
      },
      operation: 'suspendUser',
    );
  }

  @override
  Future<Either<Failure, void>> activateUser(String userId) async {
    return _handleRepositoryCall(
      () async {
        await remoteDataSource.activateUser(userId);

        _analyticsService.trackEvent('user_activated', {
          'user_id': userId,
        });
      },
      operation: 'activateUser',
    );
  }

  @override
  Future<Either<Failure, void>> deleteUserAccount(String userId) async {
    return _handleRepositoryCall(
      () async {
        await remoteDataSource.deleteUserAccount(userId);

        _analyticsService.trackEvent('user_account_deleted', {
          'user_id': userId,
        });
      },
      operation: 'deleteUserAccount',
    );
  }

  // Content Management
  @override
  Future<Either<Failure, PaginatedResponse<Map<String, dynamic>>>> getContent({
    int page = 1,
    int perPage = 20,
    String? filter,
    String? sort,
  }) async {
    return _handleRepositoryCall(
      () async {
        return await remoteDataSource.getContent(
          page: page,
          perPage: perPage,
          filter: filter,
          sort: sort,
        );
      },
      operation: 'getContent',
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updateContentStatus(
    String contentId,
    String status,
  ) async {
    return _handleRepositoryCall(
      () async {
        final result =
            await remoteDataSource.updateContentStatus(contentId, status);

        _analyticsService.trackEvent('content_status_updated', {
          'content_id': contentId,
          'status': status,
        });

        return result;
      },
      operation: 'updateContentStatus',
    );
  }

  @override
  Future<Either<Failure, void>> deleteContent(String contentId) async {
    return _handleRepositoryCall(
      () async {
        await remoteDataSource.deleteContent(contentId);

        _analyticsService.trackEvent('content_deleted', {
          'content_id': contentId,
        });
      },
      operation: 'deleteContent',
    );
  }

  // System Settings
  @override
  Future<Either<Failure, Map<String, dynamic>>> getSystemSettings() async {
    return _handleRepositoryCall(
      () async {
        return await remoteDataSource.getSystemSettings();
      },
      operation: 'getSystemSettings',
    );
  }

  @override
  Future<Either<Failure, void>> updateSystemSettings(
    Map<String, dynamic> settings,
  ) async {
    return _handleRepositoryCall(
      () async {
        await remoteDataSource.updateSystemSettings(settings);

        _analyticsService.trackEvent('system_settings_updated', {
          'settings_keys': settings.keys.toList(),
        });
      },
      operation: 'updateSystemSettings',
    );
  }

  // Notifications
  @override
  Future<Either<Failure, void>> sendNotificationToUsers({
    required String title,
    required String message,
    List<String>? userIds,
    String? userType,
  }) async {
    return _handleRepositoryCall(
      () async {
        await remoteDataSource.sendNotificationToUsers(
          title: title,
          message: message,
          userIds: userIds,
          userType: userType,
        );

        _analyticsService.trackEvent('notification_sent', {
          'title': title,
          'user_count': userIds?.length ?? 0,
          'user_type': userType,
        });
      },
      operation: 'sendNotificationToUsers',
    );
  }

  @override
  Future<Either<Failure, void>> sendSystemAnnouncement({
    required String title,
    required String message,
    String? priority,
  }) async {
    return _handleRepositoryCall(
      () async {
        await remoteDataSource.sendSystemAnnouncement(
          title: title,
          message: message,
          priority: priority,
        );

        _analyticsService.trackEvent('system_announcement_sent', {
          'title': title,
          'priority': priority,
        });
      },
      operation: 'sendSystemAnnouncement',
    );
  }

  // Cache Management
  @override
  Future<Either<Failure, void>> clearCache() async {
    return _handleRepositoryCall(
      () async {
        await localDataSource.clearAdminUserCache();
        await localDataSource.clearDashboardCache();

        _analyticsService.trackEvent('admin_cache_cleared');
      },
      operation: 'clearCache',
    );
  }

  @override
  Future<Either<Failure, void>> refreshCache() async {
    return _handleRepositoryCall(
      () async {
        // Clear existing cache
        await clearCache();

        // Refresh dashboard stats
        final stats = await remoteDataSource.getDashboardStats();
        await localDataSource.saveDashboardCache(stats);

        _analyticsService.trackEvent('admin_cache_refreshed');
      },
      operation: 'refreshCache',
    );
  }

  // Helper mapping methods
  AdminUser _mapAdminUserModelToEntity(AdminUserModel model) {
    return AdminUser(
      id: model.id,
      email: model.email,
      verified: model.verified,
      created: model.created,
      updated: model.updated,
    );
  }

  AnalyticsData _mapAnalyticsModelToEntity(AnalyticsModel model) {
    return AnalyticsData(
      id: model.id,
      type: model.type,
      startDate: model.startDate,
      endDate: model.endDate,
      granularity: model.granularity,
      userMetrics: UserMetrics(
        totalUsers: model.userMetrics.totalUsers,
        activeUsers: model.userMetrics.activeUsers,
        newUsers: model.userMetrics.newUsers,
      ),
      contentMetrics: ContentMetrics(
        totalContent: model.contentMetrics.totalContent,
        totalViews: model.contentMetrics.totalViews,
        averageViewDuration: model.contentMetrics.averageViewDuration,
      ),
      revenueMetrics: RevenueMetrics(
        totalRevenue: model.revenueMetrics.totalRevenue,
        subscriptionRevenue: model.revenueMetrics.subscriptionRevenue,
        averageRevenuePerUser: model.revenueMetrics.averageRevenuePerUser,
      ),
      engagementMetrics: EngagementMetrics(
        averageSessionDuration: model.engagementMetrics.averageSessionDuration,
        totalSessions: model.engagementMetrics.totalSessions,
        totalDownloads: model.engagementMetrics.totalDownloads,
      ),
    );
  }

  ContentReport _mapContentReportModelToEntity(ContentReportModel model) {
    return ContentReport(
      id: model.id,
      contentId: model.contentId,
      contentTitle: model.contentTitle,
      reporterId: model.reporterId,
      reporterName: model.reporterName,
      reason: model.reason,
      description: model.description,
      status: model.status,
      created: model.created,
      resolvedAt: model.resolvedAt,
    );
  }

  PaymentHistoryModel _mapPaymentHistoryModelToEntity(
      PaymentHistoryModel model) {
    return PaymentHistoryModel(
      id: model.id,
      userId: model.userId,
      userName: model.userName,
      userEmail: model.userEmail,
      transactionId: model.transactionId,
      paymentMethod: model.paymentMethod,
      paymentProvider: model.paymentProvider,
      amount: model.amount,
      currency: model.currency,
      status: model.status,
      type: model.type,
      subscriptionId: model.subscriptionId,
      subscriptionPlan: model.subscriptionPlan,
      description: model.description,
      processedAt: model.processedAt,
      refundedAt: model.refundedAt,
      refundAmount: model.refundAmount,
      refundReason: model.refundReason,
      failureReason: model.failureReason,
      created: model.created,
      updated: model.updated,
      retryCount: 3,
    );
  }
}
