import 'package:json_annotation/json_annotation.dart';
import 'package:onflix/shared/models/base_model.dart';


part 'analytics_model.g.dart';

@JsonSerializable()
class AnalyticsModel extends BaseModel {
  final String type;
  final DateTime startDate;
  final DateTime endDate;
  final String granularity;
  final UserMetrics userMetrics;
  final ContentMetrics contentMetrics;
  final RevenueMetrics revenueMetrics;
  final EngagementMetrics engagementMetrics;
  final Map<String, dynamic>? customMetrics;
  final Map<String, dynamic>? metadata;

  const AnalyticsModel({
    required super.id,
    super.collectionId,
    super.collectionName,
    required super.created,
    required super.updated,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.granularity,
    required this.userMetrics,
    required this.contentMetrics,
    required this.revenueMetrics,
    required this.engagementMetrics,
    this.customMetrics,
    this.metadata,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AnalyticsModelToJson(this);

  factory AnalyticsModel.fromRecord(dynamic record) {
    final data = record.data;

    return AnalyticsModel(
      id: record.id,
      collectionId: record.collectionId,
      collectionName: record.collectionName,
      created: DateTime.parse(record.created),
      updated: DateTime.parse(record.updated),
      type: data['type'] ?? 'general',
      startDate: DateTime.parse(data['start_date']),
      endDate: DateTime.parse(data['end_date']),
      granularity: data['granularity'] ?? 'daily',
      userMetrics: UserMetrics.fromJson(data['user_metrics'] ?? {}),
      contentMetrics: ContentMetrics.fromJson(data['content_metrics'] ?? {}),
      revenueMetrics: RevenueMetrics.fromJson(data['revenue_metrics'] ?? {}),
      engagementMetrics:
          EngagementMetrics.fromJson(data['engagement_metrics'] ?? {}),
      customMetrics: data['custom_metrics'],
      metadata: data['metadata'],
    );
  }

  // Utility methods
  Duration get dateRange => endDate.difference(startDate);
  int get daysInRange => dateRange.inDays + 1;

  double get totalGrowthRate {
    final userGrowth = userMetrics.growthRate ?? 0;
    final revenueGrowth = revenueMetrics.growthRate ?? 0;
    final engagementGrowth = engagementMetrics.growthRate ?? 0;

    return (userGrowth + revenueGrowth + engagementGrowth) / 3;
  }

  @override
  String toString() {
    return 'AnalyticsModel(id: $id, type: $type, period: ${startDate.toIso8601String().split('T')[0]} to ${endDate.toIso8601String().split('T')[0]})';
  }
}

@JsonSerializable()
class UserMetrics {
  final int totalUsers;
  final int activeUsers;
  final int newUsers;
  final int suspendedUsers;
  final int premiumUsers;
  final int freeUsers;
  final double? growthRate;
  final double? churnRate;
  final double? retentionRate;
  final Map<String, int>? usersByRegion;
  final Map<String, int>? usersByAge;
  final Map<String, int>? usersByDevice;
  final List<DailyMetric>? dailyMetrics;

  const UserMetrics({
    required this.totalUsers,
    required this.activeUsers,
    required this.newUsers,
    required this.suspendedUsers,
    required this.premiumUsers,
    required this.freeUsers,
    this.growthRate,
    this.churnRate,
    this.retentionRate,
    this.usersByRegion,
    this.usersByAge,
    this.usersByDevice,
    this.dailyMetrics,
  });

  factory UserMetrics.fromJson(Map<String, dynamic> json) =>
      _$UserMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$UserMetricsToJson(this);

  double get conversionRate {
    if (totalUsers == 0) return 0;
    return (premiumUsers / totalUsers) * 100;
  }

  double get activeUserRate {
    if (totalUsers == 0) return 0;
    return (activeUsers / totalUsers) * 100;
  }
}

@JsonSerializable()
class ContentMetrics {
  final int totalContent;
  final int publishedContent;
  final int draftContent;
  final int archivedContent;
  final int totalViews;
  final int uniqueViews;
  final double averageViewDuration;
  final double completionRate;
  final int totalLikes;
  final int totalShares;
  final int totalComments;
  final double? growthRate;
  final List<PopularContent>? topContent;
  final Map<String, int>? viewsByCategory;
  final Map<String, int>? viewsByDevice;
  final List<DailyMetric>? dailyMetrics;

  const ContentMetrics({
    required this.totalContent,
    required this.publishedContent,
    required this.draftContent,
    required this.archivedContent,
    required this.totalViews,
    required this.uniqueViews,
    required this.averageViewDuration,
    required this.completionRate,
    required this.totalLikes,
    required this.totalShares,
    required this.totalComments,
    this.growthRate,
    this.topContent,
    this.viewsByCategory,
    this.viewsByDevice,
    this.dailyMetrics,
  });

  factory ContentMetrics.fromJson(Map<String, dynamic> json) =>
      _$ContentMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$ContentMetricsToJson(this);

  double get engagementRate {
    if (totalViews == 0) return 0;
    return ((totalLikes + totalShares + totalComments) / totalViews) * 100;
  }

  double get contentUtilizationRate {
    if (totalContent == 0) return 0;
    return (publishedContent / totalContent) * 100;
  }
}

@JsonSerializable()
class RevenueMetrics {
  final double totalRevenue;
  final double subscriptionRevenue;
  final double adRevenue;
  final double otherRevenue;
  final double averageRevenuePerUser;
  final double monthlyRecurringRevenue;
  final int totalTransactions;
  final int refunds;
  final double refundRate;
  final double? growthRate;
  final Map<String, double>? revenueByPlan;
  final Map<String, double>? revenueByRegion;
  final List<DailyMetric>? dailyMetrics;

  const RevenueMetrics({
    required this.totalRevenue,
    required this.subscriptionRevenue,
    required this.adRevenue,
    required this.otherRevenue,
    required this.averageRevenuePerUser,
    required this.monthlyRecurringRevenue,
    required this.totalTransactions,
    required this.refunds,
    required this.refundRate,
    this.growthRate,
    this.revenueByPlan,
    this.revenueByRegion,
    this.dailyMetrics,
  });

  factory RevenueMetrics.fromJson(Map<String, dynamic> json) =>
      _$RevenueMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$RevenueMetricsToJson(this);

  double get subscriptionPercentage {
    if (totalRevenue == 0) return 0;
    return (subscriptionRevenue / totalRevenue) * 100;
  }

  double get adRevenuePercentage {
    if (totalRevenue == 0) return 0;
    return (adRevenue / totalRevenue) * 100;
  }
}

@JsonSerializable()
class EngagementMetrics {
  final double averageSessionDuration;
  final double averageWatchTime;
  final int totalSessions;
  final int uniqueSessions;
  final double bounceRate;
  final double returnRate;
  final int totalDownloads;
  final int totalWatchlistAdditions;
  final int totalRatings;
  final double averageRating;
  final double? growthRate;
  final Map<String, double>? engagementByContent;
  final Map<String, double>? engagementByDevice;
  final List<DailyMetric>? dailyMetrics;

  const EngagementMetrics({
    required this.averageSessionDuration,
    required this.averageWatchTime,
    required this.totalSessions,
    required this.uniqueSessions,
    required this.bounceRate,
    required this.returnRate,
    required this.totalDownloads,
    required this.totalWatchlistAdditions,
    required this.totalRatings,
    required this.averageRating,
    this.growthRate,
    this.engagementByContent,
    this.engagementByDevice,
    this.dailyMetrics,
  });

  factory EngagementMetrics.fromJson(Map<String, dynamic> json) =>
      _$EngagementMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$EngagementMetricsToJson(this);

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
}

@JsonSerializable()
class DailyMetric {
  final DateTime date;
  final double value;
  final String? label;
  final Map<String, dynamic>? metadata;

  const DailyMetric({
    required this.date,
    required this.value,
    this.label,
    this.metadata,
  });

  factory DailyMetric.fromJson(Map<String, dynamic> json) =>
      _$DailyMetricFromJson(json);

  Map<String, dynamic> toJson() => _$DailyMetricToJson(this);
}

@JsonSerializable()
class PopularContent {
  final String contentId;
  final String title;
  final String type;
  final int views;
  final double rating;
  final double engagementScore;
  final Map<String, dynamic>? metadata;

  const PopularContent({
    required this.contentId,
    required this.title,
    required this.type,
    required this.views,
    required this.rating,
    required this.engagementScore,
    this.metadata,
  });

  factory PopularContent.fromJson(Map<String, dynamic> json) =>
      _$PopularContentFromJson(json);

  Map<String, dynamic> toJson() => _$PopularContentToJson(this);
}

// Analytics types
class AnalyticsType {
  static const String general = 'general';
  static const String dashboard = 'dashboard';
  static const String userEngagement = 'user_engagement';
  static const String contentPerformance = 'content_performance';
  static const String revenue = 'revenue';
  static const String realtime = 'realtime';

  static const List<String> all = [
    general,
    dashboard,
    userEngagement,
    contentPerformance,
    revenue,
    realtime,
  ];
}

// Analytics granularity
class AnalyticsGranularity {
  static const String hourly = 'hourly';
  static const String daily = 'daily';
  static const String weekly = 'weekly';
  static const String monthly = 'monthly';
  static const String yearly = 'yearly';

  static const List<String> all = [
    hourly,
    daily,
    weekly,
    monthly,
    yearly,
  ];
}
