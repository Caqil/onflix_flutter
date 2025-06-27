
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:onflix/core/constants/storage_keys.dart';
import 'package:onflix/core/errors/exceptions.dart';
import 'package:onflix/shared/services/analytics_service.dart';

import '../models/admin_user_model.dart';
import '../models/analytics_model.dart';
import '../models/content_report_model.dart';
import '../models/payment_history_model.dart';

abstract class AdminLocalDataSource {
  // Admin User operations
  Future<void> cacheAdminUser(AdminUserModel user);
  Future<AdminUserModel?> getCachedAdminUser();
  Future<void> clearAdminUserCache();

  // Analytics operations
  Future<void> cacheAnalyticsData(AnalyticsModel analytics);
  Future<AnalyticsModel?> getCachedAnalyticsData();
  Future<void> cacheAnalyticsHistory(List<AnalyticsModel> history);
  Future<List<AnalyticsModel>> getCachedAnalyticsHistory();

  // Content Reports operations
  Future<void> cacheContentReports(List<ContentReportModel> reports);
  Future<List<ContentReportModel>> getCachedContentReports();
  Future<void> addContentReportToCache(ContentReportModel report);
  Future<void> updateContentReportInCache(ContentReportModel report);
  Future<void> removeContentReportFromCache(String reportId);

  // Payment History operations
  Future<void> cachePaymentHistory(List<PaymentHistoryModel> payments);
  Future<List<PaymentHistoryModel>> getCachedPaymentHistory();

  // Admin Preferences
  Future<void> saveAdminPreferences(Map<String, dynamic> preferences);
  Future<Map<String, dynamic>> getAdminPreferences();

  // Session management
  Future<void> saveAdminSession(String sessionId, DateTime expiryTime);
  Future<String?> getAdminSessionId();
  Future<DateTime?> getAdminSessionExpiry();
  Future<void> clearAdminSession();

  // Dashboard cache
  Future<void> saveDashboardCache(Map<String, dynamic> dashboardData);
  Future<Map<String, dynamic>?> getDashboardCache();
  Future<void> clearDashboardCache();
}

class AdminLocalDataSourceImpl implements AdminLocalDataSource {
  final Logger _logger = Logger();
  final AnalyticsService _analyticsService = AnalyticsService.instance;

  // Box names
  static const String _adminUserBox = 'admin_user';
  static const String _analyticsBox = 'analytics';
  static const String _contentReportsBox = 'content_reports';
  static const String _paymentHistoryBox = 'payment_history';
  static const String _adminPreferencesBox = 'admin_preferences';
  static const String _adminSessionBox = 'admin_session';
  static const String _dashboardCacheBox = 'dashboard_cache';

  // Admin User operations
  @override
  Future<void> cacheAdminUser(AdminUserModel user) async {
    try {
      final box = await Hive.openBox(_adminUserBox);
      await box.put(StorageKeys.adminUser, user.toJson());

      _logger.d('Admin user cached successfully');
     
    } catch (e) {
      _logger.e('Failed to cache admin user: $e');
      throw CacheException(
        message: 'Failed to cache admin user: $e',
        code: 'ADMIN_USER_CACHE_ERROR',
        details: e,
      );
    }
  }

  @override
  Future<AdminUserModel?> getCachedAdminUser() async {
    try {
      final box = await Hive.openBox(_adminUserBox);
      final userData = box.get(StorageKeys.adminUser);

      if (userData == null) return null;

      return AdminUserModel.fromJson(Map<String, dynamic>.from(userData));
    } catch (e) {
      _logger.e('Failed to get cached admin user: $e');
      return null;
    }
  }

  @override
  Future<void> clearAdminUserCache() async {
    try {
      final box = await Hive.openBox(_adminUserBox);
      await box.delete(StorageKeys.adminUser);

      _logger.d('Admin user cache cleared');
      _analyticsService.trackEvent('admin_user_cache_cleared');
    } catch (e) {
      _logger.e('Failed to clear admin user cache: $e');
      throw CacheException(
        message: 'Failed to clear admin user cache: $e',
        code: 'ADMIN_USER_CACHE_CLEAR_ERROR',
        details: e,
      );
    }
  }

  // Analytics operations
  @override
  Future<void> cacheAnalyticsData(AnalyticsModel analytics) async {
    try {
      final box = await Hive.openBox(_analyticsBox);
      await box.put('current_analytics', analytics.toJson());

      _logger.d('Analytics data cached successfully');
    } catch (e) {
      _logger.e('Failed to cache analytics data: $e');
      throw CacheException(
        message: 'Failed to cache analytics data: $e',
        code: 'ANALYTICS_CACHE_ERROR',
        details: e,
      );
    }
  }

  @override
  Future<AnalyticsModel?> getCachedAnalyticsData() async {
    try {
      final box = await Hive.openBox(_analyticsBox);
      final analyticsData = box.get('current_analytics');

      if (analyticsData == null) return null;

      return AnalyticsModel.fromJson(Map<String, dynamic>.from(analyticsData));
    } catch (e) {
      _logger.e('Failed to get cached analytics data: $e');
      return null;
    }
  }

  @override
  Future<void> cacheAnalyticsHistory(List<AnalyticsModel> history) async {
    try {
      final box = await Hive.openBox(_analyticsBox);
      final historyJson =
          history.map((analytics) => analytics.toJson()).toList();
      await box.put('analytics_history', historyJson);

      _logger.d('Analytics history cached: ${history.length} entries');
    } catch (e) {
      _logger.e('Failed to cache analytics history: $e');
      throw CacheException(
        message: 'Failed to cache analytics history: $e',
        code: 'ANALYTICS_HISTORY_CACHE_ERROR',
        details: e,
      );
    }
  }

  @override
  Future<List<AnalyticsModel>> getCachedAnalyticsHistory() async {
    try {
      final box = await Hive.openBox(_analyticsBox);
      final historyData = box.get('analytics_history');

      if (historyData == null) return [];

      final List<dynamic> historyList = List.from(historyData);
      return historyList
          .map((item) =>
              AnalyticsModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      _logger.e('Failed to get cached analytics history: $e');
      return [];
    }
  }

  // Content Reports operations
  @override
  Future<void> cacheContentReports(List<ContentReportModel> reports) async {
    try {
      final box = await Hive.openBox(_contentReportsBox);
      final reportsJson = reports.map((report) => report.toJson()).toList();
      await box.put('content_reports', reportsJson);

      _logger.d('Content reports cached: ${reports.length} reports');
    } catch (e) {
      _logger.e('Failed to cache content reports: $e');
      throw CacheException(
        message: 'Failed to cache content reports: $e',
        code: 'CONTENT_REPORTS_CACHE_ERROR',
        details: e,
      );
    }
  }

  @override
  Future<List<ContentReportModel>> getCachedContentReports() async {
    try {
      final box = await Hive.openBox(_contentReportsBox);
      final reportsData = box.get('content_reports');

      if (reportsData == null) return [];

      final List<dynamic> reportsList = List.from(reportsData);
      return reportsList
          .map((item) =>
              ContentReportModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      _logger.e('Failed to get cached content reports: $e');
      return [];
    }
  }

  @override
  Future<void> addContentReportToCache(ContentReportModel report) async {
    try {
      final reports = await getCachedContentReports();
      reports.add(report);
      await cacheContentReports(reports);

      _logger.d('Content report added to cache: ${report.id}');
    } catch (e) {
      _logger.e('Failed to add content report to cache: $e');
      throw CacheException(
        message: 'Failed to add content report to cache: $e',
        code: 'CONTENT_REPORT_ADD_CACHE_ERROR',
        details: e,
      );
    }
  }

  @override
  Future<void> updateContentReportInCache(ContentReportModel report) async {
    try {
      final reports = await getCachedContentReports();
      final index = reports.indexWhere((r) => r.id == report.id);

      if (index != -1) {
        reports[index] = report;
        await cacheContentReports(reports);
        _logger.d('Content report updated in cache: ${report.id}');
      }
    } catch (e) {
      _logger.e('Failed to update content report in cache: $e');
      throw CacheException(
        message: 'Failed to update content report in cache: $e',
        code: 'CONTENT_REPORT_UPDATE_CACHE_ERROR',
        details: e,
      );
    }
  }

  @override
  Future<void> removeContentReportFromCache(String reportId) async {
    try {
      final reports = await getCachedContentReports();
      reports.removeWhere((report) => report.id == reportId);
      await cacheContentReports(reports);

      _logger.d('Content report removed from cache: $reportId');
    } catch (e) {
      _logger.e('Failed to remove content report from cache: $e');
      throw CacheException(
        message: 'Failed to remove content report from cache: $e',
        code: 'CONTENT_REPORT_REMOVE_CACHE_ERROR',
        details: e,
      );
    }
  }

  // Payment History operations
  @override
  Future<void> cachePaymentHistory(List<PaymentHistoryModel> payments) async {
    try {
      final box = await Hive.openBox(_paymentHistoryBox);
      final paymentsJson = payments.map((payment) => payment.toJson()).toList();
      await box.put('payment_history', paymentsJson);

      _logger.d('Payment history cached: ${payments.length} payments');
    } catch (e) {
      _logger.e('Failed to cache payment history: $e');
      throw CacheException(
        message: 'Failed to cache payment history: $e',
        code: 'PAYMENT_HISTORY_CACHE_ERROR',
        details: e,
      );
    }
  }

  @override
  Future<List<PaymentHistoryModel>> getCachedPaymentHistory() async {
    try {
      final box = await Hive.openBox(_paymentHistoryBox);
      final paymentsData = box.get('payment_history');

      if (paymentsData == null) return [];

      final List<dynamic> paymentsList = List.from(paymentsData);
      return paymentsList
          .map((item) =>
              PaymentHistoryModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      _logger.e('Failed to get cached payment history: $e');
      return [];
    }
  }

  // Admin Preferences
  @override
  Future<void> saveAdminPreferences(Map<String, dynamic> preferences) async {
    try {
      final box = await Hive.openBox(_adminPreferencesBox);
      await box.put('admin_preferences', preferences);

      _logger.d('Admin preferences saved');
      _analyticsService.trackEvent('admin_preferences_saved', preferences);
    } catch (e) {
      _logger.e('Failed to save admin preferences: $e');
      throw CacheException(
        message: 'Failed to save admin preferences: $e',
        code: 'ADMIN_PREFERENCES_SAVE_ERROR',
        details: e,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getAdminPreferences() async {
    try {
      final box = await Hive.openBox(_adminPreferencesBox);
      final preferences = box.get('admin_preferences');

      return preferences != null
          ? Map<String, dynamic>.from(preferences)
          : <String, dynamic>{};
    } catch (e) {
      _logger.e('Failed to get admin preferences: $e');
      return <String, dynamic>{};
    }
  }

  // Session management
  @override
  Future<void> saveAdminSession(String sessionId, DateTime expiryTime) async {
    try {
      final box = await Hive.openBox(_adminSessionBox);
      await box.put('admin_session_id', sessionId);
      await box.put('admin_session_expiry', expiryTime.toIso8601String());

      _logger.d('Admin session saved');
    } catch (e) {
      _logger.e('Failed to save admin session: $e');
      throw CacheException(
        message: 'Failed to save admin session: $e',
        code: 'ADMIN_SESSION_SAVE_ERROR',
        details: e,
      );
    }
  }

  @override
  Future<String?> getAdminSessionId() async {
    try {
      final box = await Hive.openBox(_adminSessionBox);
      return box.get('admin_session_id');
    } catch (e) {
      _logger.e('Failed to get admin session ID: $e');
      return null;
    }
  }

  @override
  Future<DateTime?> getAdminSessionExpiry() async {
    try {
      final box = await Hive.openBox(_adminSessionBox);
      final expiryString = box.get('admin_session_expiry');

      return expiryString != null ? DateTime.parse(expiryString) : null;
    } catch (e) {
      _logger.e('Failed to get admin session expiry: $e');
      return null;
    }
  }

  @override
  Future<void> clearAdminSession() async {
    try {
      final box = await Hive.openBox(_adminSessionBox);
      await box.delete('admin_session_id');
      await box.delete('admin_session_expiry');

      _logger.d('Admin session cleared');
      _analyticsService.trackEvent('admin_session_cleared');
    } catch (e) {
      _logger.e('Failed to clear admin session: $e');
      throw CacheException(
        message: 'Failed to clear admin session: $e',
        code: 'ADMIN_SESSION_CLEAR_ERROR',
        details: e,
      );
    }
  }

  // Dashboard cache
  @override
  Future<void> saveDashboardCache(Map<String, dynamic> dashboardData) async {
    try {
      final box = await Hive.openBox(_dashboardCacheBox);
      await box.put('dashboard_data', dashboardData);
      await box.put('dashboard_cache_time', DateTime.now().toIso8601String());

      _logger.d('Dashboard data cached');
    } catch (e) {
      _logger.e('Failed to save dashboard cache: $e');
      throw CacheException(
        message: 'Failed to save dashboard cache: $e',
        code: 'DASHBOARD_CACHE_SAVE_ERROR',
        details: e,
      );
    }
  }

  @override
  Future<Map<String, dynamic>?> getDashboardCache() async {
    try {
      final box = await Hive.openBox(_dashboardCacheBox);
      final cacheTime = box.get('dashboard_cache_time');

      // Check if cache is still valid (15 minutes)
      if (cacheTime != null) {
        final cacheDateTime = DateTime.parse(cacheTime);
        final isExpired =
            DateTime.now().difference(cacheDateTime).inMinutes > 15;

        if (isExpired) {
          await clearDashboardCache();
          return null;
        }
      }

      final dashboardData = box.get('dashboard_data');
      return dashboardData != null
          ? Map<String, dynamic>.from(dashboardData)
          : null;
    } catch (e) {
      _logger.e('Failed to get dashboard cache: $e');
      return null;
    }
  }

  @override
  Future<void> clearDashboardCache() async {
    try {
      final box = await Hive.openBox(_dashboardCacheBox);
      await box.delete('dashboard_data');
      await box.delete('dashboard_cache_time');

      _logger.d('Dashboard cache cleared');
    } catch (e) {
      _logger.e('Failed to clear dashboard cache: $e');
      throw CacheException(
        message: 'Failed to clear dashboard cache: $e',
        code: 'DASHBOARD_CACHE_CLEAR_ERROR',
        details: e,
      );
    }
  }
}
