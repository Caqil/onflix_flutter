import 'package:json_annotation/json_annotation.dart';
import 'package:onflix/shared/models/base_model.dart';


part 'content_report_model.g.dart';

@JsonSerializable()
class ContentReportModel extends BaseModel {
  final String contentId;
  final String? contentTitle;
  final String? contentType;
  final String reporterId;
  final String? reporterName;
  final String? reporterEmail;
  final String reason;
  final String? description;
  final String status;
  final String priority;
  final List<String>? attachments;
  final String? category;
  final Map<String, dynamic>? metadata;
  final DateTime? resolvedAt;
  final String? resolvedBy;
  final String? resolution;
  final String? adminNotes;
  final List<ReportAction>? actions;
  final int violationCount;
  final bool isAnonymous;

  const ContentReportModel({
    required super.id,
    super.collectionId,
    super.collectionName,
    required super.created,
    required super.updated,
    required this.contentId,
    this.contentTitle,
    this.contentType,
    required this.reporterId,
    this.reporterName,
    this.reporterEmail,
    required this.reason,
    this.description,
    required this.status,
    required this.priority,
    this.attachments,
    this.category,
    this.metadata,
    this.resolvedAt,
    this.resolvedBy,
    this.resolution,
    this.adminNotes,
    this.actions,
    required this.violationCount,
    required this.isAnonymous,
  });

  factory ContentReportModel.fromJson(Map<String, dynamic> json) =>
      _$ContentReportModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ContentReportModelToJson(this);

  factory ContentReportModel.fromRecord(dynamic record) {
    final data = record.data;
    
    return ContentReportModel(
      id: record.id,
      collectionId: record.collectionId,
      collectionName: record.collectionName,
      created: DateTime.parse(record.created),
      updated: DateTime.parse(record.updated),
      contentId: data['content_id'] ?? '',
      contentTitle: data['content_title'],
      contentType: data['content_type'],
      reporterId: data['reporter_id'] ?? '',
      reporterName: data['reporter_name'],
      reporterEmail: data['reporter_email'],
      reason: data['reason'] ?? '',
      description: data['description'],
      status: data['status'] ?? ContentReportStatus.pending,
      priority: data['priority'] ?? ContentReportPriority.medium,
      attachments: data['attachments'] != null 
          ? List<String>.from(data['attachments'])
          : null,
      category: data['category'],
      metadata: data['metadata'],
      resolvedAt: data['resolved_at'] != null 
          ? DateTime.parse(data['resolved_at'])
          : null,
      resolvedBy: data['resolved_by'],
      resolution: data['resolution'],
      adminNotes: data['admin_notes'],
      actions: data['actions'] != null
          ? (data['actions'] as List)
              .map((action) => ReportAction.fromJson(action))
              .toList()
          : null,
      violationCount: data['violation_count'] ?? 0,
      isAnonymous: data['is_anonymous'] ?? false,
    );
  }

  // Status checks
  bool get isPending => status == ContentReportStatus.pending;
  bool get isInProgress => status == ContentReportStatus.inProgress;
  bool get isResolved => status == ContentReportStatus.resolved;
  bool get isDismissed => status == ContentReportStatus.dismissed;
  bool get isEscalated => status == ContentReportStatus.escalated;

  // Priority checks
  bool get isLowPriority => priority == ContentReportPriority.low;
  bool get isMediumPriority => priority == ContentReportPriority.medium;
  bool get isHighPriority => priority == ContentReportPriority.high;
  bool get isCriticalPriority => priority == ContentReportPriority.critical;

  // Utility methods
  String get statusDisplayName => ContentReportStatus.getDisplayName(status);
  String get priorityDisplayName => ContentReportPriority.getDisplayName(priority);
  String get reasonDisplayName => ContentReportReason.getDisplayName(reason);
  
  Duration? get timeToResolve {
    if (resolvedAt == null) return null;
    return resolvedAt!.difference(created);
  }

  Duration get ageInDays => DateTime.now().difference(created);
  
  bool get isOverdue {
    final daysOld = ageInDays.inDays;
    switch (priority) {
      case ContentReportPriority.critical:
        return daysOld > 1;
      case ContentReportPriority.high:
        return daysOld > 3;
      case ContentReportPriority.medium:
        return daysOld > 7;
      case ContentReportPriority.low:
        return daysOld > 14;
      default:
        return false;
    }
  }

  String get reporterDisplayName {
    if (isAnonymous) return 'Anonymous';
    return reporterName ?? reporterEmail ?? 'Unknown';
  }

  // Copy with method
  ContentReportModel copyWith({
    String? contentId,
    String? contentTitle,
    String? contentType,
    String? reporterId,
    String? reporterName,
    String? reporterEmail,
    String? reason,
    String? description,
    String? status,
    String? priority,
    List<String>? attachments,
    String? category,
    Map<String, dynamic>? metadata,
    DateTime? resolvedAt,
    String? resolvedBy,
    String? resolution,
    String? adminNotes,
    List<ReportAction>? actions,
    int? violationCount,
    bool? isAnonymous,
  }) {
    return ContentReportModel(
      id: id,
      collectionId: collectionId,
      collectionName: collectionName,
      created: created,
      updated: updated,
      contentId: contentId ?? this.contentId,
      contentTitle: contentTitle ?? this.contentTitle,
      contentType: contentType ?? this.contentType,
      reporterId: reporterId ?? this.reporterId,
      reporterName: reporterName ?? this.reporterName,
      reporterEmail: reporterEmail ?? this.reporterEmail,
      reason: reason ?? this.reason,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      attachments: attachments ?? this.attachments,
      category: category ?? this.category,
      metadata: metadata ?? this.metadata,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      resolution: resolution ?? this.resolution,
      adminNotes: adminNotes ?? this.adminNotes,
      actions: actions ?? this.actions,
      violationCount: violationCount ?? this.violationCount,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }

  @override
  String toString() {
    return 'ContentReportModel(id: $id, contentId: $contentId, reason: $reason, status: $status)';
  }
}

@JsonSerializable()
class ReportAction {
  final String action;
  final String? performedBy;
  final DateTime performedAt;
  final String? notes;
  final Map<String, dynamic>? metadata;

  const ReportAction({
    required this.action,
    this.performedBy,
    required this.performedAt,
    this.notes,
    this.metadata,
  });

  factory ReportAction.fromJson(Map<String, dynamic> json) =>
      _$ReportActionFromJson(json);

  Map<String, dynamic> toJson() => _$ReportActionToJson(this);

  String get actionDisplayName => ContentReportAction.getDisplayName(action);
}

// Content report status constants
class ContentReportStatus {
  static const String pending = 'pending';
  static const String inProgress = 'in_progress';
  static const String resolved = 'resolved';
  static const String dismissed = 'dismissed';
  static const String escalated = 'escalated';

  static const List<String> all = [
    pending,
    inProgress,
    resolved,
    dismissed,
    escalated,
  ];

  static String getDisplayName(String status) {
    switch (status) {
      case pending:
        return 'Pending';
      case inProgress:
        return 'In Progress';
      case resolved:
        return 'Resolved';
      case dismissed:
        return 'Dismissed';
      case escalated:
        return 'Escalated';
      default:
        return 'Unknown';
    }
  }
}

// Content report priority constants
class ContentReportPriority {
  static const String low = 'low';
  static const String medium = 'medium';
  static const String high = 'high';
  static const String critical = 'critical';

  static const List<String> all = [
    low,
    medium,
    high,
    critical,
  ];

  static String getDisplayName(String priority) {
    switch (priority) {
      case low:
        return 'Low';
      case medium:
        return 'Medium';
      case high:
        return 'High';
      case critical:
        return 'Critical';
      default:
        return 'Unknown';
    }
  }
}

// Content report reason constants
class ContentReportReason {
  static const String inappropriate = 'inappropriate';
  static const String spam = 'spam';
  static const String harassment = 'harassment';
  static const String copyright = 'copyright';
  static const String violence = 'violence';
  static const String misinformation = 'misinformation';
  static const String adultContent = 'adult_content';
  static const String hateSpeech = 'hate_speech';
  static const String other = 'other';

  static const List<String> all = [
    inappropriate,
    spam,
    harassment,
    copyright,
    violence,
    misinformation,
    adultContent,
    hateSpeech,
    other,
  ];

  static String getDisplayName(String reason) {
    switch (reason) {
      case inappropriate:
        return 'Inappropriate Content';
      case spam:
        return 'Spam';
      case harassment:
        return 'Harassment';
      case copyright:
        return 'Copyright Violation';
      case violence:
        return 'Violence';
      case misinformation:
        return 'Misinformation';
      case adultContent:
        return 'Adult Content';
      case hateSpeech:
        return 'Hate Speech';
      case other:
        return 'Other';
      default:
        return 'Unknown';
    }
  }
}

// Content report action constants
class ContentReportAction {
  static const String created = 'created';
  static const String assigned = 'assigned';
  static const String statusChanged = 'status_changed';
  static const String priorityChanged = 'priority_changed';
  static const String noteAdded = 'note_added';
  static const String escalated = 'escalated';
  static const String resolved = 'resolved';
  static const String dismissed = 'dismissed';
  static const String contentRemoved = 'content_removed';
  static const String contentRestricted = 'content_restricted';
  static const String userWarned = 'user_warned';
  static const String userSuspended = 'user_suspended';

  static const List<String> all = [
    created,
    assigned,
    statusChanged,
    priorityChanged,
    noteAdded,
    escalated,
    resolved,
    dismissed,
    contentRemoved,
    contentRestricted,
    userWarned,
    userSuspended,
  ];

  static String getDisplayName(String action) {
    switch (action) {
      case created:
        return 'Report Created';
      case assigned:
        return 'Assigned';
      case statusChanged:
        return 'Status Changed';
      case priorityChanged:
        return 'Priority Changed';
      case noteAdded:
        return 'Note Added';
      case escalated:
        return 'Escalated';
      case resolved:
        return 'Resolved';
      case dismissed:
        return 'Dismissed';
      case contentRemoved:
        return 'Content Removed';
      case contentRestricted:
        return 'Content Restricted';
      case userWarned:
        return 'User Warned';
      case userSuspended:
        return 'User Suspended';
      default:
        return 'Unknown';
    }
  }
}