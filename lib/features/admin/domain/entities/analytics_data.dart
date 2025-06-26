import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytics_data.freezed.dart';
part 'analytics_data.g.dart';

@freezed
class AnalyticsData with _$AnalyticsData {
  const factory AnalyticsData({
    required String id,
    required AnalyticsType type,
    required DateTime startDate,
    required DateTime endDate,
    required AnalyticsGranularity granularity,
    required UserAnalytics userAnalytics,
    required ContentAnalytics contentAnalytics,
    required RevenueAnalytics revenueAnalytics,
    required EngagementAnalytics engagementAnalytics,
    Map<String, dynamic>? customMetrics,
    Map<String, dynamic>? metadata,
    required DateTime created,
    required DateTime updated,
  }) = _AnalyticsData;

  factory AnalyticsData.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsDataFromJson(json);
}

@JsonEnum()
enum AnalyticsType {
  @JsonValue('general')
  general,
  @JsonValue('dashboard')
  dashboard,
  @JsonValue('user_engagement')
  userEngagement,
  @JsonValue('content_performance')
  contentPerformance,
  @JsonValue('revenue')
  revenue,
  @JsonValue('realtime')
  realtime,
}

@JsonEnum()
enum AnalyticsGranularity {
  @JsonValue('hourly')
  hourly,
  @JsonValue('daily')
  daily,
  @JsonValue('weekly')
  weekly,
  @JsonValue('monthly')
  monthly,
  @JsonValue('yearly')
  yearly,
}

// User Analytics
@freezed
class UserAnalytics with _$UserAnalytics {
  const factory UserAnalytics({
    required int totalUsers,
    required int activeUsers,
    required int newUsers,
    required int suspendedUsers,
    required int premiumUsers,
    required int freeUsers,
    double? growthRate,
    double? churnRate,
    double? retentionRate,
    Map<String, int>? usersByRegion,
    Map<String, int>? usersByAge,
    Map<String, int>? usersByDevice,
    List<DailyAnalyticMetric>? dailyMetrics,
  }) = _UserAnalytics;

  factory UserAnalytics.fromJson(Map<String, dynamic> json) =>
      _$UserAnalyticsFromJson(json);
}

// Content Analytics
@freezed
class ContentAnalytics with _$ContentAnalytics {
  const factory ContentAnalytics({
    required int totalContent,
    required int publishedContent,
    required int draftContent,
    required int archivedContent,
    required int totalViews,
    required int uniqueViews,
    required double averageViewDuration,
    required double completionRate,
    required int totalLikes,
    required int totalShares,
    required int totalComments,
    double? growthRate,
    List<PopularContentItem>? topContent,
    Map<String, int>? viewsByCategory,
    Map<String, int>? viewsByDevice,
    List<DailyAnalyticMetric>? dailyMetrics,
  }) = _ContentAnalytics;

  factory ContentAnalytics.fromJson(Map<String, dynamic> json) =>
      _$ContentAnalyticsFromJson(json);
}

// Revenue Analytics
@freezed
class RevenueAnalytics with _$RevenueAnalytics {
  const factory RevenueAnalytics({
    required double totalRevenue,
    required double subscriptionRevenue,
    required double adRevenue,
    required double otherRevenue,
    required double averageRevenuePerUser,
    required double monthlyRecurringRevenue,
    required int totalTransactions,
    required int refunds,
    required double refundRate,
    double? growthRate,
    Map<String, double>? revenueByPlan,
    Map<String, double>? revenueByRegion,
    List<DailyAnalyticMetric>? dailyMetrics,
  }) = _RevenueAnalytics;

  factory RevenueAnalytics.fromJson(Map<String, dynamic> json) =>
      _$RevenueAnalyticsFromJson(json);
}

// Engagement Analytics
@freezed
class EngagementAnalytics with _$EngagementAnalytics {
  const factory EngagementAnalytics({
    required double averageSessionDuration,
    required double averageWatchTime,
    required int totalSessions,
    required int uniqueSessions,
    required double bounceRate,
    required double returnRate,
    required int totalDownloads,
    required int totalWatchlistAdditions,
    required int totalRatings,
    required double averageRating,
    double? growthRate,
    Map<String, double>? engagementByContent,
    Map<String, double>? engagementByDevice,
    List<DailyAnalyticMetric>? dailyMetrics,
  }) = _EngagementAnalytics;

  factory EngagementAnalytics.fromJson(Map<String, dynamic> json) =>
      _$EngagementAnalyticsFromJson(json);
}

// Daily Metric
@freezed
class DailyAnalyticMetric with _$DailyAnalyticMetric {
  const factory DailyAnalyticMetric({
    required DateTime date,
    required double value,
    String? label,
    Map<String, dynamic>? metadata,
  }) = _DailyAnalyticMetric;

  factory DailyAnalyticMetric.fromJson(Map<String, dynamic> json) =>
      _$DailyAnalyticMetricFromJson(json);
}

// Popular Content Item
@freezed
class PopularContentItem with _$PopularContentItem {
  const factory PopularContentItem({
    required String contentId,
    required String title,
    required String type,
    required int views,
    required double rating,
    required double engagementScore,
    String? thumbnail,
    String? category,
    Map<String, dynamic>? metadata,
  }) = _PopularContentItem;

  factory PopularContentItem.fromJson(Map<String, dynamic> json) =>
      _$PopularContentItemFromJson(json);
}

// Real-time Analytics
@freezed
class RealtimeAnalytics with _$RealtimeAnalytics {
  const factory RealtimeAnalytics({
    required int currentActiveUsers,
    required int currentViewers,
    required List<LiveContentMetric> liveContent,
    required Map<String, int> usersByRegion,
    required Map<String, int> viewsByContent,
    required List<RecentActivity> recentActivities,
    required DateTime lastUpdated,
  }) = _RealtimeAnalytics;

  factory RealtimeAnalytics.fromJson(Map<String, dynamic> json) =>
      _$RealtimeAnalyticsFromJson(json);
}

@freezed
class LiveContentMetric with _$LiveContentMetric {
  const factory LiveContentMetric({
    required String contentId,
    required String title,
    required int currentViewers,
    required int totalViews,
    required double avgWatchTime,
    required String type,
  }) = _LiveContentMetric;

  factory LiveContentMetric.fromJson(Map<String, dynamic> json) =>
      _$LiveContentMetricFromJson(json);
}

@freezed
class RecentActivity with _$RecentActivity {
  const factory RecentActivity({
    required String type,
    required String description,
    required DateTime timestamp,
    String? userId,
    String? contentId,
    Map<String, dynamic>? metadata,
  }) = _RecentActivity;

  factory RecentActivity.fromJson(Map<String, dynamic> json) =>
      _$RecentActivityFromJson(json);
}

// Analytics Summary
@freezed
class AnalyticsSummary with _$AnalyticsSummary {
  const factory AnalyticsSummary({
    required DateTime period,
    required AnalyticsGranularity granularity,
    required SummaryMetrics metrics,
    required List<TrendingItem> trending,
    required List<PerformanceAlert> alerts,
    required ComparisonData comparison,
  }) = _AnalyticsSummary;

  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsSummaryFromJson(json);
}

@freezed
class SummaryMetrics with _$SummaryMetrics {
  const factory SummaryMetrics({
    required MetricValue totalUsers,
    required MetricValue activeUsers,
    required MetricValue revenue,
    required MetricValue contentViews,
    required MetricValue engagement,
  }) = _SummaryMetrics;

  factory SummaryMetrics.fromJson(Map<String, dynamic> json) =>
      _$SummaryMetricsFromJson(json);
}

@freezed
class MetricValue with _$MetricValue {
  const factory MetricValue({
    required double current,
    required double previous,
    required double changePercent,
    required ChangeDirection direction,
    String? formattedValue,
  }) = _MetricValue;

  factory MetricValue.fromJson(Map<String, dynamic> json) =>
      _$MetricValueFromJson(json);
}

@JsonEnum()
enum ChangeDirection {
  @JsonValue('up')
  up,
  @JsonValue('down')
  down,
  @JsonValue('stable')
  stable,
}

@freezed
class TrendingItem with _$TrendingItem {
  const factory TrendingItem({
    required String id,
    required String title,
    required String type,
    required double score,
    required int rank,
    String? thumbnail,
    Map<String, dynamic>? metadata,
  }) = _TrendingItem;

  factory TrendingItem.fromJson(Map<String, dynamic> json) =>
      _$TrendingItemFromJson(json);
}

@freezed
class PerformanceAlert with _$PerformanceAlert {
  const factory PerformanceAlert({
    required String id,
    required AlertType type,
    required AlertSeverity severity,
    required String title,
    required String message,
    required DateTime createdAt,
    String? actionUrl,
    bool? acknowledged,
  }) = _PerformanceAlert;

  factory PerformanceAlert.fromJson(Map<String, dynamic> json) =>
      _$PerformanceAlertFromJson(json);
}

@JsonEnum()
enum AlertType {
  @JsonValue('performance')
  performance,
  @JsonValue('anomaly')
  anomaly,
  @JsonValue('threshold')
  threshold,
  @JsonValue('system')
  system,
}

@JsonEnum()
enum AlertSeverity {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('critical')
  critical,
}

@freezed
class ComparisonData with _$ComparisonData {
  const factory ComparisonData({
    required DateTime currentPeriodStart,
    required DateTime currentPeriodEnd,
    required DateTime previousPeriodStart,
    required DateTime previousPeriodEnd,
    required Map<String, double> currentMetrics,
    required Map<String, double> previousMetrics,
    required Map<String, double> changePercentages,
  }) = _ComparisonData;

  factory ComparisonData.fromJson(Map<String, dynamic> json) =>
      _$ComparisonDataFromJson(json);
}

// Analytics Filter
@freezed
class AnalyticsFilter with _$AnalyticsFilter {
  const factory AnalyticsFilter({
    DateTime? startDate,
    DateTime? endDate,
    AnalyticsGranularity? granularity,
    List<String>? regions,
    List<String>? devices,
    List<String>? contentTypes,
    List<String>? userTypes,
    String? metric,
    String? sortBy,
    SortOrder? sortOrder,
  }) = _AnalyticsFilter;

  factory AnalyticsFilter.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsFilterFromJson(json);
}

@JsonEnum()
enum SortOrder {
  @JsonValue('asc')
  ascending,
  @JsonValue('desc')
  descending,
}

// Analytics Export
@freezed
class AnalyticsExport with _$AnalyticsExport {
  const factory AnalyticsExport({
    required String id,
    required AnalyticsExportType type,
    required AnalyticsExportFormat format,
    required AnalyticsFilter filter,
    required AnalyticsExportStatus status,
    String? downloadUrl,
    String? filename,
    int? fileSize,
    DateTime? completedAt,
    String? error,
    required DateTime createdAt,
    required String createdBy,
  }) = _AnalyticsExport;

  factory AnalyticsExport.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsExportFromJson(json);
}

@JsonEnum()
enum AnalyticsExportType {
  @JsonValue('summary')
  summary,
  @JsonValue('detailed')
  detailed,
  @JsonValue('raw_data')
  rawData,
  @JsonValue('custom')
  custom,
}

@JsonEnum()
enum AnalyticsExportFormat {
  @JsonValue('csv')
  csv,
  @JsonValue('excel')
  excel,
  @JsonValue('pdf')
  pdf,
  @JsonValue('json')
  json,
}

@JsonEnum()
enum AnalyticsExportStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('processing')
  processing,
  @JsonValue('completed')
  completed,
  @JsonValue('failed')
  failed,
  @JsonValue('expired')
  expired,
}

// Extensions
extension AnalyticsDataExtension on AnalyticsData {
  Duration get dateRange => endDate.difference(startDate);

  int get daysInRange => dateRange.inDays + 1;

  double get totalGrowthRate {
    final userGrowth = userAnalytics.growthRate ?? 0;
    final revenueGrowth = revenueAnalytics.growthRate ?? 0;
    final engagementGrowth = engagementAnalytics.growthRate ?? 0;

    return (userGrowth + revenueGrowth + engagementGrowth) / 3;
  }

  bool get isRealtime => type == AnalyticsType.realtime;

  bool get isDashboard => type == AnalyticsType.dashboard;
}

extension UserAnalyticsExtension on UserAnalytics {
  double get conversionRate {
    if (totalUsers == 0) return 0;
    return (premiumUsers / totalUsers) * 100;
  }

  double get activeUserRate {
    if (totalUsers == 0) return 0;
    return (activeUsers / totalUsers) * 100;
  }

  double get suspensionRate {
    if (totalUsers == 0) return 0;
    return (suspendedUsers / totalUsers) * 100;
  }
}

extension ContentAnalyticsExtension on ContentAnalytics {
  double get engagementRate {
    if (totalViews == 0) return 0;
    return ((totalLikes + totalShares + totalComments) / totalViews) * 100;
  }

  double get contentUtilizationRate {
    if (totalContent == 0) return 0;
    return (publishedContent / totalContent) * 100;
  }

  double get viewsPerContent {
    if (publishedContent == 0) return 0;
    return totalViews / publishedContent;
  }
}

extension RevenueAnalyticsExtension on RevenueAnalytics {
  double get subscriptionPercentage {
    if (totalRevenue == 0) return 0;
    return (subscriptionRevenue / totalRevenue) * 100;
  }

  double get adRevenuePercentage {
    if (totalRevenue == 0) return 0;
    return (adRevenue / totalRevenue) * 100;
  }

  double get successfulTransactionRate {
    final successfulTransactions = totalTransactions - refunds;
    if (totalTransactions == 0) return 0;
    return (successfulTransactions / totalTransactions) * 100;
  }
}

extension EngagementAnalyticsExtension on EngagementAnalytics {
  double get sessionQuality {
    if (totalSessions == 0) return 0;
    return (1 - bounceRate) * returnRate * 100;
  }

  double get userEngagementScore {
    // Complex score based on various engagement factors
    final sessionScore = averageSessionDuration / 60; // minutes
    final watchScore = averageWatchTime / 60; // minutes
    final interactionScore =
        (totalDownloads + totalWatchlistAdditions + totalRatings) /
            totalSessions;

    return (sessionScore + watchScore + interactionScore) / 3;
  }

  double get downloadsPerSession {
    if (totalSessions == 0) return 0;
    return totalDownloads / totalSessions;
  }
}

extension MetricValueExtension on MetricValue {
  bool get isPositiveChange => direction == ChangeDirection.up;

  bool get isNegativeChange => direction == ChangeDirection.down;

  bool get isStable => direction == ChangeDirection.stable;

  bool get hasSignificantChange => changePercent.abs() >= 5.0; // 5% threshold
}
