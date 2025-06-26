// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalyticsModel _$AnalyticsModelFromJson(Map<String, dynamic> json) =>
    AnalyticsModel(
      id: json['id'] as String,
      collectionId: json['collectionId'] as String?,
      collectionName: json['collectionName'] as String?,
      created: DateTime.parse(json['created'] as String),
      updated: DateTime.parse(json['updated'] as String),
      type: json['type'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      granularity: json['granularity'] as String,
      userMetrics:
          UserMetrics.fromJson(json['userMetrics'] as Map<String, dynamic>),
      contentMetrics: ContentMetrics.fromJson(
          json['contentMetrics'] as Map<String, dynamic>),
      revenueMetrics: RevenueMetrics.fromJson(
          json['revenueMetrics'] as Map<String, dynamic>),
      engagementMetrics: EngagementMetrics.fromJson(
          json['engagementMetrics'] as Map<String, dynamic>),
      customMetrics: json['customMetrics'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$AnalyticsModelToJson(AnalyticsModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'collectionId': instance.collectionId,
      'collectionName': instance.collectionName,
      'created': instance.created.toIso8601String(),
      'updated': instance.updated.toIso8601String(),
      'type': instance.type,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'granularity': instance.granularity,
      'userMetrics': instance.userMetrics,
      'contentMetrics': instance.contentMetrics,
      'revenueMetrics': instance.revenueMetrics,
      'engagementMetrics': instance.engagementMetrics,
      'customMetrics': instance.customMetrics,
      'metadata': instance.metadata,
    };

UserMetrics _$UserMetricsFromJson(Map<String, dynamic> json) => UserMetrics(
      totalUsers: (json['totalUsers'] as num).toInt(),
      activeUsers: (json['activeUsers'] as num).toInt(),
      newUsers: (json['newUsers'] as num).toInt(),
      suspendedUsers: (json['suspendedUsers'] as num).toInt(),
      premiumUsers: (json['premiumUsers'] as num).toInt(),
      freeUsers: (json['freeUsers'] as num).toInt(),
      growthRate: (json['growthRate'] as num?)?.toDouble(),
      churnRate: (json['churnRate'] as num?)?.toDouble(),
      retentionRate: (json['retentionRate'] as num?)?.toDouble(),
      usersByRegion: (json['usersByRegion'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
      usersByAge: (json['usersByAge'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
      usersByDevice: (json['usersByDevice'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
      dailyMetrics: (json['dailyMetrics'] as List<dynamic>?)
          ?.map((e) => DailyMetric.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserMetricsToJson(UserMetrics instance) =>
    <String, dynamic>{
      'totalUsers': instance.totalUsers,
      'activeUsers': instance.activeUsers,
      'newUsers': instance.newUsers,
      'suspendedUsers': instance.suspendedUsers,
      'premiumUsers': instance.premiumUsers,
      'freeUsers': instance.freeUsers,
      'growthRate': instance.growthRate,
      'churnRate': instance.churnRate,
      'retentionRate': instance.retentionRate,
      'usersByRegion': instance.usersByRegion,
      'usersByAge': instance.usersByAge,
      'usersByDevice': instance.usersByDevice,
      'dailyMetrics': instance.dailyMetrics,
    };

ContentMetrics _$ContentMetricsFromJson(Map<String, dynamic> json) =>
    ContentMetrics(
      totalContent: (json['totalContent'] as num).toInt(),
      publishedContent: (json['publishedContent'] as num).toInt(),
      draftContent: (json['draftContent'] as num).toInt(),
      archivedContent: (json['archivedContent'] as num).toInt(),
      totalViews: (json['totalViews'] as num).toInt(),
      uniqueViews: (json['uniqueViews'] as num).toInt(),
      averageViewDuration: (json['averageViewDuration'] as num).toDouble(),
      completionRate: (json['completionRate'] as num).toDouble(),
      totalLikes: (json['totalLikes'] as num).toInt(),
      totalShares: (json['totalShares'] as num).toInt(),
      totalComments: (json['totalComments'] as num).toInt(),
      growthRate: (json['growthRate'] as num?)?.toDouble(),
      topContent: (json['topContent'] as List<dynamic>?)
          ?.map((e) => PopularContent.fromJson(e as Map<String, dynamic>))
          .toList(),
      viewsByCategory: (json['viewsByCategory'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
      viewsByDevice: (json['viewsByDevice'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
      dailyMetrics: (json['dailyMetrics'] as List<dynamic>?)
          ?.map((e) => DailyMetric.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ContentMetricsToJson(ContentMetrics instance) =>
    <String, dynamic>{
      'totalContent': instance.totalContent,
      'publishedContent': instance.publishedContent,
      'draftContent': instance.draftContent,
      'archivedContent': instance.archivedContent,
      'totalViews': instance.totalViews,
      'uniqueViews': instance.uniqueViews,
      'averageViewDuration': instance.averageViewDuration,
      'completionRate': instance.completionRate,
      'totalLikes': instance.totalLikes,
      'totalShares': instance.totalShares,
      'totalComments': instance.totalComments,
      'growthRate': instance.growthRate,
      'topContent': instance.topContent,
      'viewsByCategory': instance.viewsByCategory,
      'viewsByDevice': instance.viewsByDevice,
      'dailyMetrics': instance.dailyMetrics,
    };

RevenueMetrics _$RevenueMetricsFromJson(Map<String, dynamic> json) =>
    RevenueMetrics(
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      subscriptionRevenue: (json['subscriptionRevenue'] as num).toDouble(),
      adRevenue: (json['adRevenue'] as num).toDouble(),
      otherRevenue: (json['otherRevenue'] as num).toDouble(),
      averageRevenuePerUser: (json['averageRevenuePerUser'] as num).toDouble(),
      monthlyRecurringRevenue:
          (json['monthlyRecurringRevenue'] as num).toDouble(),
      totalTransactions: (json['totalTransactions'] as num).toInt(),
      refunds: (json['refunds'] as num).toInt(),
      refundRate: (json['refundRate'] as num).toDouble(),
      growthRate: (json['growthRate'] as num?)?.toDouble(),
      revenueByPlan: (json['revenueByPlan'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      revenueByRegion: (json['revenueByRegion'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      dailyMetrics: (json['dailyMetrics'] as List<dynamic>?)
          ?.map((e) => DailyMetric.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RevenueMetricsToJson(RevenueMetrics instance) =>
    <String, dynamic>{
      'totalRevenue': instance.totalRevenue,
      'subscriptionRevenue': instance.subscriptionRevenue,
      'adRevenue': instance.adRevenue,
      'otherRevenue': instance.otherRevenue,
      'averageRevenuePerUser': instance.averageRevenuePerUser,
      'monthlyRecurringRevenue': instance.monthlyRecurringRevenue,
      'totalTransactions': instance.totalTransactions,
      'refunds': instance.refunds,
      'refundRate': instance.refundRate,
      'growthRate': instance.growthRate,
      'revenueByPlan': instance.revenueByPlan,
      'revenueByRegion': instance.revenueByRegion,
      'dailyMetrics': instance.dailyMetrics,
    };

EngagementMetrics _$EngagementMetricsFromJson(Map<String, dynamic> json) =>
    EngagementMetrics(
      averageSessionDuration:
          (json['averageSessionDuration'] as num).toDouble(),
      averageWatchTime: (json['averageWatchTime'] as num).toDouble(),
      totalSessions: (json['totalSessions'] as num).toInt(),
      uniqueSessions: (json['uniqueSessions'] as num).toInt(),
      bounceRate: (json['bounceRate'] as num).toDouble(),
      returnRate: (json['returnRate'] as num).toDouble(),
      totalDownloads: (json['totalDownloads'] as num).toInt(),
      totalWatchlistAdditions: (json['totalWatchlistAdditions'] as num).toInt(),
      totalRatings: (json['totalRatings'] as num).toInt(),
      averageRating: (json['averageRating'] as num).toDouble(),
      growthRate: (json['growthRate'] as num?)?.toDouble(),
      engagementByContent:
          (json['engagementByContent'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      engagementByDevice:
          (json['engagementByDevice'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      dailyMetrics: (json['dailyMetrics'] as List<dynamic>?)
          ?.map((e) => DailyMetric.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EngagementMetricsToJson(EngagementMetrics instance) =>
    <String, dynamic>{
      'averageSessionDuration': instance.averageSessionDuration,
      'averageWatchTime': instance.averageWatchTime,
      'totalSessions': instance.totalSessions,
      'uniqueSessions': instance.uniqueSessions,
      'bounceRate': instance.bounceRate,
      'returnRate': instance.returnRate,
      'totalDownloads': instance.totalDownloads,
      'totalWatchlistAdditions': instance.totalWatchlistAdditions,
      'totalRatings': instance.totalRatings,
      'averageRating': instance.averageRating,
      'growthRate': instance.growthRate,
      'engagementByContent': instance.engagementByContent,
      'engagementByDevice': instance.engagementByDevice,
      'dailyMetrics': instance.dailyMetrics,
    };

DailyMetric _$DailyMetricFromJson(Map<String, dynamic> json) => DailyMetric(
      date: DateTime.parse(json['date'] as String),
      value: (json['value'] as num).toDouble(),
      label: json['label'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$DailyMetricToJson(DailyMetric instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'value': instance.value,
      'label': instance.label,
      'metadata': instance.metadata,
    };

PopularContent _$PopularContentFromJson(Map<String, dynamic> json) =>
    PopularContent(
      contentId: json['contentId'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      views: (json['views'] as num).toInt(),
      rating: (json['rating'] as num).toDouble(),
      engagementScore: (json['engagementScore'] as num).toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$PopularContentToJson(PopularContent instance) =>
    <String, dynamic>{
      'contentId': instance.contentId,
      'title': instance.title,
      'type': instance.type,
      'views': instance.views,
      'rating': instance.rating,
      'engagementScore': instance.engagementScore,
      'metadata': instance.metadata,
    };
