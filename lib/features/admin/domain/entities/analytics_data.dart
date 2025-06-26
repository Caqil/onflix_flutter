import 'package:equatable/equatable.dart';

class AnalyticsData extends Equatable {
  final String id;
  final String type;
  final DateTime startDate;
  final DateTime endDate;
  final String granularity;
  final UserMetrics userMetrics;
  final ContentMetrics contentMetrics;
  final RevenueMetrics revenueMetrics;
  final EngagementMetrics engagementMetrics;

  const AnalyticsData({
    required this.id,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.granularity,
    required this.userMetrics,
    required this.contentMetrics,
    required this.revenueMetrics,
    required this.engagementMetrics,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        startDate,
        endDate,
        granularity,
        userMetrics,
        contentMetrics,
        revenueMetrics,
        engagementMetrics
      ];
}

class UserMetrics extends Equatable {
  final int totalUsers;
  final int activeUsers;
  final int newUsers;

  const UserMetrics({
    required this.totalUsers,
    required this.activeUsers,
    required this.newUsers,
  });

  @override
  List<Object?> get props => [totalUsers, activeUsers, newUsers];
}

class ContentMetrics extends Equatable {
  final int totalContent;
  final int totalViews;
  final double averageViewDuration;

  const ContentMetrics({
    required this.totalContent,
    required this.totalViews,
    required this.averageViewDuration,
  });

  @override
  List<Object?> get props => [totalContent, totalViews, averageViewDuration];
}

class RevenueMetrics extends Equatable {
  final double totalRevenue;
  final double subscriptionRevenue;
  final double averageRevenuePerUser;

  const RevenueMetrics({
    required this.totalRevenue,
    required this.subscriptionRevenue,
    required this.averageRevenuePerUser,
  });

  @override
  List<Object?> get props =>
      [totalRevenue, subscriptionRevenue, averageRevenuePerUser];
}

class EngagementMetrics extends Equatable {
  final double averageSessionDuration;
  final int totalSessions;
  final int totalDownloads;

  const EngagementMetrics({
    required this.averageSessionDuration,
    required this.totalSessions,
    required this.totalDownloads,
  });

  @override
  List<Object?> get props =>
      [averageSessionDuration, totalSessions, totalDownloads];
}
