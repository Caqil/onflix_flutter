import 'package:equatable/equatable.dart';

class ContentReport extends Equatable {
  final String id;
  final String contentId;
  final String? contentTitle;
  final String reporterId;
  final String? reporterName;
  final String reason;
  final String? description;
  final String status;
  final DateTime created;
  final DateTime? resolvedAt;

  const ContentReport({
    required this.id,
    required this.contentId,
    this.contentTitle,
    required this.reporterId,
    this.reporterName,
    required this.reason,
    this.description,
    required this.status,
    required this.created,
    this.resolvedAt,
  });

  @override
  List<Object?> get props => [
        id,
        contentId,
        contentTitle,
        reporterId,
        reporterName,
        reason,
        description,
        status,
        created,
        resolvedAt
      ];
}
