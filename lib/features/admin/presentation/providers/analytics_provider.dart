import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';

import '../../../../shared/models/pagination.dart';
import '../../../../shared/services/analytics_service.dart';
import '../../domain/entities/analytics_data.dart';
import '../../domain/repositories/admin_repository.dart';
import 'admin_auth_provider.dart';

part 'analytics_provider.g.dart';

// Analytics Parameters
class AnalyticsParams {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? granularity;

  const AnalyticsParams({
    this.startDate,
    this.endDate,
    this.granularity,
  });

  AnalyticsParams copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? granularity,
  }) {
    return AnalyticsParams(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      granularity: granularity ?? this.granularity,
    );
  }
}

// Analytics Parameters State Provider
@riverpod
class AnalyticsParametersState extends _$AnalyticsParametersState {
  @override
  AnalyticsParams build() {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    return AnalyticsParams(
      startDate: thirtyDaysAgo,
      endDate: now,
      granularity: 'daily',
    );
  }

  void updateDateRange(DateTime startDate, DateTime endDate) {
    state = state.copyWith(startDate: startDate, endDate: endDate);
  }

  void updateGranularity(String granularity) {
    state = state.copyWith(granularity: granularity);
  }

  void setLastWeek() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    state = state.copyWith(startDate: weekAgo, endDate: now);
  }

  void setLastMonth() {
    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));
    state = state.copyWith(startDate: monthAgo, endDate: now);
  }

  void setLastQuarter() {
    final now = DateTime.now();
    final quarterAgo = now.subtract(const Duration(days: 90));
    state = state.copyWith(startDate: quarterAgo, endDate: now);
  }

  void setLastYear() {
    final now = DateTime.now();
    final yearAgo = now.subtract(const Duration(days: 365));
    state = state.copyWith(startDate: yearAgo, endDate: now);
  }
}

// Current Analytics Provider
@riverpod
class CurrentAnalytics extends _$CurrentAnalytics {
  Timer? _refreshTimer;
  final Logger _logger = Logger();

  @override
  Future<AnalyticsData?> build() async {
    ref.onDispose(() {
      _refreshTimer?.cancel();
    });

    // Only fetch if admin is authenticated
    final isAuthenticated = ref.watch(isAdminAuthenticatedProvider);
    if (!isAuthenticated) return null;

    return await _fetchAnalytics();
  }

  Future<AnalyticsData?> _fetchAnalytics() async {
    try {
      final repository = ref.read(adminRepositoryProvider);
      final params = ref.read(analyticsParametersStateProvider);

      final result = await repository.getAnalytics(
        startDate: params.startDate,
        endDate: params.endDate,
        granularity: params.granularity,
      );

      return result.fold(
        (failure) {
          _logger.e('Failed to fetch analytics: ${failure.message}');
          state = AsyncValue.error(failure, StackTrace.current);
          return null;
        },
        (analyticsData) {
          _startAutoRefresh();
          return analyticsData;
        },
      );
    } catch (e, stackTrace) {
      _logger.e('Analytics fetch error: $e');
      state = AsyncValue.error(e, stackTrace);
      return null;
    }
  }

  Future<void> refreshAnalytics() async {
    state = const AsyncValue.loading();
    await _fetchAnalytics();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();

    // Auto-refresh every 5 minutes
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => refreshAnalytics(),
    );
  }
}

// Dashboard Stats Provider
@riverpod
class DashboardStats extends _$DashboardStats {
  final Logger _logger = Logger();

  @override
  Future<Map<String, dynamic>?> build() async {
    // Only fetch if admin is authenticated
    final isAuthenticated = ref.watch(isAdminAuthenticatedProvider);
    if (!isAuthenticated) return null;

    return await _fetchDashboardStats();
  }

  Future<Map<String, dynamic>?> _fetchDashboardStats() async {
    try {
      final repository = ref.read(adminRepositoryProvider);

      final result = await repository.getDashboardStats();

      return result.fold(
        (failure) {
          _logger.e('Failed to fetch dashboard stats: ${failure.message}');
          state = AsyncValue.error(failure, StackTrace.current);
          return null;
        },
        (stats) => stats,
      );
    } catch (e, stackTrace) {
      _logger.e('Dashboard stats fetch error: $e');
      state = AsyncValue.error(e, stackTrace);
      return null;
    }
  }

  Future<void> refreshDashboardStats() async {
    state = const AsyncValue.loading();
    await _fetchDashboardStats();
  }
}

// Analytics History Provider
@riverpod
class AnalyticsHistory extends _$AnalyticsHistory {
  final Logger _logger = Logger();

  @override
  Future<List<AnalyticsData>> build() async {
    // Only fetch if admin is authenticated
    final isAuthenticated = ref.watch(isAdminAuthenticatedProvider);
    if (!isAuthenticated) return [];

    return await _fetchAnalyticsHistory();
  }

  Future<List<AnalyticsData>> _fetchAnalyticsHistory() async {
    try {
      final repository = ref.read(adminRepositoryProvider);
      final params = ref.read(analyticsParametersStateProvider);

      final result = await repository.getAnalyticsHistory(
        page: 1,
        perPage: 50,
        startDate: params.startDate,
        endDate: params.endDate,
      );

      return result.fold(
        (failure) {
          _logger.e('Failed to fetch analytics history: ${failure.message}');
          state = AsyncValue.error(failure, StackTrace.current);
          return [];
        },
        (history) => history,
      );
    } catch (e, stackTrace) {
      _logger.e('Analytics history fetch error: $e');
      state = AsyncValue.error(e, stackTrace);
      return [];
    }
  }

  Future<void> refreshHistory() async {
    state = const AsyncValue.loading();
    await _fetchAnalyticsHistory();
  }
}

// User Engagement Metrics Provider
@riverpod
class UserEngagementMetrics extends _$UserEngagementMetrics {
  final Logger _logger = Logger();

  @override
  Future<List<Map<String, dynamic>>> build() async {
    // Only fetch if admin is authenticated
    final isAuthenticated = ref.watch(isAdminAuthenticatedProvider);
    if (!isAuthenticated) return [];

    return await _fetchUserEngagementMetrics();
  }

  Future<List<Map<String, dynamic>>> _fetchUserEngagementMetrics() async {
    try {
      final repository = ref.read(adminRepositoryProvider);
      final params = ref.read(analyticsParametersStateProvider);

      final result = await repository.getUserEngagementMetrics(
        startDate: params.startDate,
        endDate: params.endDate,
      );

      return result.fold(
        (failure) {
          _logger
              .e('Failed to fetch user engagement metrics: ${failure.message}');
          state = AsyncValue.error(failure, StackTrace.current);
          return [];
        },
        (metrics) => metrics,
      );
    } catch (e, stackTrace) {
      _logger.e('User engagement metrics fetch error: $e');
      state = AsyncValue.error(e, stackTrace);
      return [];
    }
  }

  Future<void> refreshMetrics() async {
    state = const AsyncValue.loading();
    await _fetchUserEngagementMetrics();
  }
}

// Content Performance Metrics Provider
@riverpod
class ContentPerformanceMetrics extends _$ContentPerformanceMetrics {
  final Logger _logger = Logger();

  @override
  Future<List<Map<String, dynamic>>> build() async {
    // Only fetch if admin is authenticated
    final isAuthenticated = ref.watch(isAdminAuthenticatedProvider);
    if (!isAuthenticated) return [];

    return await _fetchContentPerformanceMetrics();
  }

  Future<List<Map<String, dynamic>>> _fetchContentPerformanceMetrics() async {
    try {
      final repository = ref.read(adminRepositoryProvider);
      final params = ref.read(analyticsParametersStateProvider);

      final result = await repository.getContentPerformanceMetrics(
        startDate: params.startDate,
        endDate: params.endDate,
      );

      return result.fold(
        (failure) {
          _logger.e(
              'Failed to fetch content performance metrics: ${failure.message}');
          state = AsyncValue.error(failure, StackTrace.current);
          return [];
        },
        (metrics) => metrics,
      );
    } catch (e, stackTrace) {
      _logger.e('Content performance metrics fetch error: $e');
      state = AsyncValue.error(e, stackTrace);
      return [];
    }
  }

  Future<void> refreshMetrics() async {
    state = const AsyncValue.loading();
    await _fetchContentPerformanceMetrics();
  }
}

// Revenue Metrics Provider
@riverpod
class RevenueMetrics extends _$RevenueMetrics {
  final Logger _logger = Logger();

  @override
  Future<List<Map<String, dynamic>>> build() async {
    // Only fetch if admin is authenticated
    final isAuthenticated = ref.watch(isAdminAuthenticatedProvider);
    if (!isAuthenticated) return [];

    return await _fetchRevenueMetrics();
  }

  Future<List<Map<String, dynamic>>> _fetchRevenueMetrics() async {
    try {
      final repository = ref.read(adminRepositoryProvider);
      final params = ref.read(analyticsParametersStateProvider);

      final result = await repository.getRevenueMetrics(
        startDate: params.startDate,
        endDate: params.endDate,
      );

      return result.fold(
        (failure) {
          _logger.e('Failed to fetch revenue metrics: ${failure.message}');
          state = AsyncValue.error(failure, StackTrace.current);
          return [];
        },
        (metrics) => metrics,
      );
    } catch (e, stackTrace) {
      _logger.e('Revenue metrics fetch error: $e');
      state = AsyncValue.error(e, stackTrace);
      return [];
    }
  }

  Future<void> refreshMetrics() async {
    state = const AsyncValue.loading();
    await _fetchRevenueMetrics();
  }
}

// Analytics Refresh All Provider
@riverpod
class AnalyticsRefreshController extends _$AnalyticsRefreshController {
  @override
  bool build() => false;

  Future<void> refreshAllAnalytics() async {
    state = true;

    try {
      // Refresh all analytics data
      await Future.wait([
        ref.read(currentAnalyticsProvider.notifier).refreshAnalytics(),
        ref.read(dashboardStatsProvider.notifier).refreshDashboardStats(),
        ref.read(analyticsHistoryProvider.notifier).refreshHistory(),
        ref.read(userEngagementMetricsProvider.notifier).refreshMetrics(),
        ref.read(contentPerformanceMetricsProvider.notifier).refreshMetrics(),
        ref.read(revenueMetricsProvider.notifier).refreshMetrics(),
      ]);

      AnalyticsService.instance.trackEvent('admin_analytics_refreshed');
    } catch (e) {
      Logger().e('Failed to refresh analytics: $e');
    } finally {
      state = false;
    }
  }
}

// Analytics Export Provider
@riverpod
class AnalyticsExport extends _$AnalyticsExport {
  final Logger _logger = Logger();

  @override
  bool build() => false;

  Future<Map<String, dynamic>?> exportAnalyticsData() async {
    state = true;

    try {
      final currentAnalytics = ref.read(currentAnalyticsProvider).value;
      final dashboardStats = ref.read(dashboardStatsProvider).value;
      final analyticsHistory = ref.read(analyticsHistoryProvider).value;
      final userEngagement = ref.read(userEngagementMetricsProvider).value;
      final contentPerformance =
          ref.read(contentPerformanceMetricsProvider).value;
      final revenueMetrics = ref.read(revenueMetricsProvider).value;
      final params = ref.read(analyticsParametersStateProvider);

      final exportData = {
        'export_date': DateTime.now().toIso8601String(),
        'parameters': {
          'start_date': params.startDate?.toIso8601String(),
          'end_date': params.endDate?.toIso8601String(),
          'granularity': params.granularity,
        },
        'current_analytics': currentAnalytics != null
            ? {
                'id': currentAnalytics.id,
                'type': currentAnalytics.type,
                'start_date': currentAnalytics.startDate.toIso8601String(),
                'end_date': currentAnalytics.endDate.toIso8601String(),
                'granularity': currentAnalytics.granularity,
                'user_metrics': {
                  'total_users': currentAnalytics.userMetrics.totalUsers,
                  'active_users': currentAnalytics.userMetrics.activeUsers,
                  'new_users': currentAnalytics.userMetrics.newUsers,
                },
                'content_metrics': {
                  'total_content': currentAnalytics.contentMetrics.totalContent,
                  'total_views': currentAnalytics.contentMetrics.totalViews,
                  'average_view_duration':
                      currentAnalytics.contentMetrics.averageViewDuration,
                },
                'revenue_metrics': {
                  'total_revenue': currentAnalytics.revenueMetrics.totalRevenue,
                  'subscription_revenue':
                      currentAnalytics.revenueMetrics.subscriptionRevenue,
                  'average_revenue_per_user':
                      currentAnalytics.revenueMetrics.averageRevenuePerUser,
                },
                'engagement_metrics': {
                  'average_session_duration':
                      currentAnalytics.engagementMetrics.averageSessionDuration,
                  'total_sessions':
                      currentAnalytics.engagementMetrics.totalSessions,
                  'total_downloads':
                      currentAnalytics.engagementMetrics.totalDownloads,
                },
              }
            : null,
        'dashboard_stats': dashboardStats,
        'user_engagement_metrics': userEngagement,
        'content_performance_metrics': contentPerformance,
        'revenue_metrics': revenueMetrics,
      };

      AnalyticsService.instance.trackEvent('admin_analytics_exported', {
        'data_types': exportData.keys.length,
        'start_date': params.startDate?.toIso8601String(),
        'end_date': params.endDate?.toIso8601String(),
      });

      return exportData;
    } catch (e, stackTrace) {
      _logger.e('Failed to export analytics data: $e', stackTrace: stackTrace);
      return null;
    } finally {
      state = false;
    }
  }
}
