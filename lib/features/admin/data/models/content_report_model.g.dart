// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_report_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContentReportModel _$ContentReportModelFromJson(Map<String, dynamic> json) =>
    ContentReportModel(
      id: json['id'] as String,
      collectionId: json['collectionId'] as String?,
      collectionName: json['collectionName'] as String?,
      created: DateTime.parse(json['created'] as String),
      updated: DateTime.parse(json['updated'] as String),
      contentId: json['contentId'] as String,
      contentTitle: json['contentTitle'] as String?,
      contentType: json['contentType'] as String?,
      reporterId: json['reporterId'] as String,
      reporterName: json['reporterName'] as String?,
      reporterEmail: json['reporterEmail'] as String?,
      reason: json['reason'] as String,
      description: json['description'] as String?,
      status: json['status'] as String,
      priority: json['priority'] as String,
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      category: json['category'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
      resolvedBy: json['resolvedBy'] as String?,
      resolution: json['resolution'] as String?,
      adminNotes: json['adminNotes'] as String?,
      actions: (json['actions'] as List<dynamic>?)
          ?.map((e) => ReportAction.fromJson(e as Map<String, dynamic>))
          .toList(),
      violationCount: (json['violationCount'] as num).toInt(),
      isAnonymous: json['isAnonymous'] as bool,
    );

Map<String, dynamic> _$ContentReportModelToJson(ContentReportModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'collectionId': instance.collectionId,
      'collectionName': instance.collectionName,
      'created': instance.created.toIso8601String(),
      'updated': instance.updated.toIso8601String(),
      'contentId': instance.contentId,
      'contentTitle': instance.contentTitle,
      'contentType': instance.contentType,
      'reporterId': instance.reporterId,
      'reporterName': instance.reporterName,
      'reporterEmail': instance.reporterEmail,
      'reason': instance.reason,
      'description': instance.description,
      'status': instance.status,
      'priority': instance.priority,
      'attachments': instance.attachments,
      'category': instance.category,
      'metadata': instance.metadata,
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
      'resolvedBy': instance.resolvedBy,
      'resolution': instance.resolution,
      'adminNotes': instance.adminNotes,
      'actions': instance.actions,
      'violationCount': instance.violationCount,
      'isAnonymous': instance.isAnonymous,
    };

ReportAction _$ReportActionFromJson(Map<String, dynamic> json) => ReportAction(
      action: json['action'] as String,
      performedBy: json['performedBy'] as String?,
      performedAt: DateTime.parse(json['performedAt'] as String),
      notes: json['notes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ReportActionToJson(ReportAction instance) =>
    <String, dynamic>{
      'action': instance.action,
      'performedBy': instance.performedBy,
      'performedAt': instance.performedAt.toIso8601String(),
      'notes': instance.notes,
      'metadata': instance.metadata,
    };
