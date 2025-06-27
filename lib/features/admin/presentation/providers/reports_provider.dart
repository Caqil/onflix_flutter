import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';

import '../../../../shared/models/pagination.dart';
import '../../../../shared/services/analytics_service.dart';
import '../../domain/entities/content_report.dart';
import '../../domain/repositories/admin_repository.dart';
import 'admin_auth_provider.dart';

part 'reports_provider.g.dart';

// Report Filter Parameters
class ReportFilters {
  final String? status;
  final String? reason;
  final String? priority;
  final String? search;
  final String? sort;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const ReportFilters({
    this.status,
    this.reason,
    this.priority,
    this.search,
    this.sort,
    this.dateFrom,
    this.dateTo,
  });

  ReportFilters copyWith({
    String? status,
    String? reason,
    String? priority,
    String? search,
    String? sort,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    return ReportFilters(
      status: status ?? this.status,
      reason: reason ?? this.reason,
      priority: priority ?? this.priority,
      search: search ?? this.search,
      sort: sort ?? this.sort,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
    );
  }

  String? get filterString {
    final filters = <String>[];

    if (status != null && status!.isNotEmpty) {
      filters.add("status='$status'");
    }
    if (reason != null && reason!.isNotEmpty) {
      filters.add("reason='$reason'");
    }
    if (priority != null && priority!.isNotEmpty) {
      filters.add("priority='$priority'");
    }
    if (search != null && search!.isNotEmpty) {
      filters.add(
          "(content_title~'$search' || description~'$search' || reporter_name~'$search')");
    }
    if (dateFrom != null) {
      filters.add("created>='${dateFrom!.toIso8601String()}'");
    }
    if (dateTo != null) {
      filters.add("created<='${dateTo!.toIso8601String()}'");
    }

    return filters.isEmpty ? null : filters.join(' && ');
  }

  bool get hasActiveFilters {
    return status != null ||
        reason != null ||
        priority != null ||
        (search != null && search!.isNotEmpty) ||
        dateFrom != null ||
        dateTo != null;
  }
}

// Report Pagination Parameters
class ReportPaginationParams {
  final int page;
  final int perPage;

  const ReportPaginationParams({
    this.page = 1,
    this.perPage = 20,
  });

  ReportPaginationParams copyWith({
    int? page,
    int? perPage,
  }) {
    return ReportPaginationParams(
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
    );
  }
}

// Report Filters State Provider
@riverpod
class ReportFiltersState extends _$ReportFiltersState {
  @override
  ReportFilters build() {
    return const ReportFilters(sort: '-created');
  }

  void updateStatus(String? status) {
    state = state.copyWith(status: status);
  }

  void updateReason(String? reason) {
    state = state.copyWith(reason: reason);
  }

  void updatePriority(String? priority) {
    state = state.copyWith(priority: priority);
  }

  void updateSearch(String? search) {
    state = state.copyWith(search: search);
  }

  void updateSort(String? sort) {
    state = state.copyWith(sort: sort);
  }

  void updateDateRange(DateTime? from, DateTime? to) {
    state = state.copyWith(dateFrom: from, dateTo: to);
  }

  void clearFilters() {
    state = const ReportFilters(sort: '-created');
  }

  void setQuickFilter(String filterType) {
    switch (filterType) {
      case 'pending':
        state = state.copyWith(status: 'pending');
        break;
      case 'in_progress':
        state = state.copyWith(status: 'in_progress');
        break;
      case 'high_priority':
        state = state.copyWith(priority: 'high');
        break;
      case 'today':
        final today = DateTime.now();
        final startOfDay = DateTime(today.year, today.month, today.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        state = state.copyWith(dateFrom: startOfDay, dateTo: endOfDay);
        break;
      case 'this_week':
        final now = DateTime.now();
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final startOfWeek =
            DateTime(weekStart.year, weekStart.month, weekStart.day);
        state = state.copyWith(dateFrom: startOfWeek, dateTo: now);
        break;
    }
  }
}

// Report Pagination State Provider
@riverpod
class ReportPaginationState extends _$ReportPaginationState {
  @override
  ReportPaginationParams build() {
    return const ReportPaginationParams();
  }

  void updatePage(int page) {
    state = state.copyWith(page: page);
  }

  void updatePerPage(int perPage) {
    state = state.copyWith(page: 1, perPage: perPage); // Reset to first page
  }

  void nextPage() {
    state = state.copyWith(page: state.page + 1);
  }

  void previousPage() {
    if (state.page > 1) {
      state = state.copyWith(page: state.page - 1);
    }
  }

  void reset() {
    state = const ReportPaginationParams();
  }
}

// Content Reports List Provider
@riverpod
class ContentReportsList extends _$ContentReportsList {
  final Logger _logger = Logger();

  @override
  Future<PaginatedResponse<ContentReport>> build() async {
    // Only fetch if admin is authenticated
    final isAuthenticated = ref.watch(isAdminAuthenticatedProvider);
    if (!isAuthenticated) {
      return PaginatedResponse.empty();
    }

    return await _fetchReports();
  }

  Future<PaginatedResponse<ContentReport>> _fetchReports() async {
    try {
      final repository = ref.read(adminRepositoryProvider);
      final filters = ref.read(reportFiltersStateProvider);
      final pagination = ref.read(reportPaginationStateProvider);

      final result = await repository.getContentReports(
        page: pagination.page,
        perPage: pagination.perPage,
        status: filters.status,
        sort: filters.sort,
      );

      return result.fold(
        (failure) {
          _logger.e('Failed to fetch content reports: ${failure.message}');
          state = AsyncValue.error(failure, StackTrace.current);
          return PaginatedResponse.empty();
        },
        (reportsList) => reportsList,
      );
    } catch (e, stackTrace) {
      _logger.e('Content reports fetch error: $e');
      state = AsyncValue.error(e, stackTrace);
      return PaginatedResponse.empty();
    }
  }

  Future<void> refreshReports() async {
    state = const AsyncValue.loading();
    await _fetchReports();
  }

  Future<void> loadPage(int page) async {
    ref.read(reportPaginationStateProvider.notifier).updatePage(page);
    await refreshReports();
  }

  Future<void> applyFilters() async {
    ref.read(reportPaginationStateProvider.notifier).reset();
    await refreshReports();
  }
}

// Individual Report Provider
@riverpod
class ContentReportDetails extends _$ContentReportDetails {
  final Logger _logger = Logger();

  @override
  Future<ContentReport?> build(String reportId) async {
    // Only fetch if admin is authenticated
    final isAuthenticated = ref.watch(isAdminAuthenticatedProvider);
    if (!isAuthenticated) return null;

    return await _fetchReportDetails(reportId);
  }

  Future<ContentReport?> _fetchReportDetails(String reportId) async {
    try {
      final repository = ref.read(adminRepositoryProvider);

      final result = await repository.getContentReport(reportId);

      return result.fold(
        (failure) {
          _logger.e('Failed to fetch report details: ${failure.message}');
          state = AsyncValue.error(failure, StackTrace.current);
          return null;
        },
        (report) => report,
      );
    } catch (e, stackTrace) {
      _logger.e('Report details fetch error: $e');
      state = AsyncValue.error(e, stackTrace);
      return null;
    }
  }

  Future<void> refreshDetails() async {
    final currentReport = state.value;
    if (currentReport != null) {
      await build(currentReport.id);
    }
  }
}

// Report Status Update Provider
@riverpod
class ReportStatusUpdate extends _$ReportStatusUpdate {
  final Logger _logger = Logger();

  @override
  bool build() => false;

  Future<bool> updateReportStatus(
    String reportId,
    String status, {
    String? resolution,
  }) async {
    state = true;

    try {
      final repository = ref.read(adminRepositoryProvider);

      final result = await repository.updateContentReportStatus(
        reportId,
        status,
        resolution,
      );

      final success = result.fold(
        (failure) {
          _logger.e('Failed to update report status: ${failure.message}');
          return false;
        },
        (updatedReport) {
          AnalyticsService.instance.trackEvent('admin_report_status_updated', {
            'report_id': reportId,
            'new_status': status,
            'has_resolution': resolution != null,
          });

          // Refresh the reports list and details
          ref.invalidate(contentReportsListProvider);
          ref.invalidate(contentReportDetailsProvider);

          return true;
        },
      );

      return success;
    } catch (e) {
      _logger.e('Report status update error: $e');
      return false;
    } finally {
      state = false;
    }
  }

  Future<bool> resolveReport(String reportId, String resolution) async {
    return await updateReportStatus(reportId, 'resolved',
        resolution: resolution);
  }

  Future<bool> dismissReport(String reportId, String reason) async {
    return await updateReportStatus(reportId, 'dismissed', resolution: reason);
  }

  Future<bool> escalateReport(String reportId) async {
    return await updateReportStatus(reportId, 'escalated');
  }
}

// Report Deletion Provider
@riverpod
class ReportDeletion extends _$ReportDeletion {
  final Logger _logger = Logger();

  @override
  bool build() => false;

  Future<bool> deleteReport(String reportId) async {
    state = true;

    try {
      final repository = ref.read(adminRepositoryProvider);

      final result = await repository.deleteContentReport(reportId);

      final success = result.fold(
        (failure) {
          _logger.e('Failed to delete report: ${failure.message}');
          return false;
        },
        (_) {
          AnalyticsService.instance.trackEvent('admin_report_deleted', {
            'report_id': reportId,
          });

          // Refresh the reports list
          ref.invalidate(contentReportsListProvider);

          return true;
        },
      );

      return success;
    } catch (e) {
      _logger.e('Report deletion error: $e');
      return false;
    } finally {
      state = false;
    }
  }
}

// Bulk Report Operations Provider
@riverpod
class BulkReportOperations extends _$BulkReportOperations {
  final Logger _logger = Logger();

  @override
  BulkReportOperationState build() {
    return const BulkReportOperationState();
  }

  void selectReport(String reportId) {
    final currentSelected = Set<String>.from(state.selectedIds);
    currentSelected.add(reportId);
    state = state.copyWith(selectedIds: currentSelected);
  }

  void deselectReport(String reportId) {
    final currentSelected = Set<String>.from(state.selectedIds);
    currentSelected.remove(reportId);
    state = state.copyWith(selectedIds: currentSelected);
  }

  void selectAll(List<String> reportIds) {
    state = state.copyWith(selectedIds: Set<String>.from(reportIds));
  }

  void clearSelection() {
    state = state.copyWith(selectedIds: <String>{});
  }

  Future<bool> bulkUpdateStatus(String status, {String? resolution}) async {
    if (state.selectedIds.isEmpty) return false;

    state = state.copyWith(isProcessing: true);

    try {
      final repository = ref.read(adminRepositoryProvider);
      bool allSuccess = true;

      for (final reportId in state.selectedIds) {
        final result = await repository.updateContentReportStatus(
          reportId,
          status,
          resolution,
        );
        result.fold(
          (failure) {
            _logger.e('Failed to update report $reportId: ${failure.message}');
            allSuccess = false;
          },
          (_) {},
        );
      }

      if (allSuccess) {
        AnalyticsService.instance
            .trackEvent('admin_bulk_report_status_updated', {
          'report_count': state.selectedIds.length,
          'new_status': status,
          'has_resolution': resolution != null,
        });

        // Refresh the reports list
        ref.invalidate(contentReportsListProvider);
        clearSelection();
      }

      return allSuccess;
    } catch (e) {
      _logger.e('Bulk report status update error: $e');
      return false;
    } finally {
      state = state.copyWith(isProcessing: false);
    }
  }

  Future<bool> bulkDelete() async {
    if (state.selectedIds.isEmpty) return false;

    state = state.copyWith(isProcessing: true);

    try {
      final repository = ref.read(adminRepositoryProvider);
      bool allSuccess = true;

      for (final reportId in state.selectedIds) {
        final result = await repository.deleteContentReport(reportId);
        result.fold(
          (failure) {
            _logger.e('Failed to delete report $reportId: ${failure.message}');
            allSuccess = false;
          },
          (_) {},
        );
      }

      if (allSuccess) {
        AnalyticsService.instance.trackEvent('admin_bulk_report_deleted', {
          'report_count': state.selectedIds.length,
        });

        // Refresh the reports list
        ref.invalidate(contentReportsListProvider);
        clearSelection();
      }

      return allSuccess;
    } catch (e) {
      _logger.e('Bulk report deletion error: $e');
      return false;
    } finally {
      state = state.copyWith(isProcessing: false);
    }
  }
}

// Bulk Report Operation State
class BulkReportOperationState {
  final Set<String> selectedIds;
  final bool isProcessing;

  const BulkReportOperationState({
    this.selectedIds = const <String>{},
    this.isProcessing = false,
  });

  BulkReportOperationState copyWith({
    Set<String>? selectedIds,
    bool? isProcessing,
  }) {
    return BulkReportOperationState(
      selectedIds: selectedIds ?? this.selectedIds,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }

  bool get hasSelection => selectedIds.isNotEmpty;
  int get selectedCount => selectedIds.length;
}

// Report Statistics Provider
@riverpod
class ReportStatistics extends _$ReportStatistics {
  final Logger _logger = Logger();

  @override
  Future<List<Map<String, dynamic>>> build() async {
    // Only fetch if admin is authenticated
    final isAuthenticated = ref.watch(isAdminAuthenticatedProvider);
    if (!isAuthenticated) return [];

    return await _fetchReportStatistics();
  }

  Future<List<Map<String, dynamic>>> _fetchReportStatistics() async {
    try {
      final repository = ref.read(adminRepositoryProvider);

      final result = await repository.getReportStatistics();

      return result.fold(
        (failure) {
          _logger.e('Failed to fetch report statistics: ${failure.message}');
          state = AsyncValue.error(failure, StackTrace.current);
          return [];
        },
        (statistics) => statistics,
      );
    } catch (e, stackTrace) {
      _logger.e('Report statistics fetch error: $e');
      state = AsyncValue.error(e, stackTrace);
      return [];
    }
  }

  Future<void> refreshStatistics() async {
    state = const AsyncValue.loading();
    await _fetchReportStatistics();
  }
}

// Report Summary Provider
@riverpod
class ReportSummary extends _$ReportSummary {
  final Logger _logger = Logger();

  @override
  Future<Map<String, dynamic>> build() async {
    // Only fetch if admin is authenticated
    final isAuthenticated = ref.watch(isAdminAuthenticatedProvider);
    if (!isAuthenticated) return {};

    return await _generateReportSummary();
  }

  Future<Map<String, dynamic>> _generateReportSummary() async {
    try {
      final reportsList = ref.read(contentReportsListProvider).value;
      final statistics = ref.read(reportStatisticsProvider).value;

      if (reportsList == null) return {};

      final summary = <String, dynamic>{
        'total_reports': reportsList.totalItems,
        'pending_reports': 0,
        'in_progress_reports': 0,
        'resolved_reports': 0,
        'dismissed_reports': 0,
        'escalated_reports': 0,
        'by_reason': <String, int>{},
        'by_priority': <String, int>{},
        'recent_activity': <Map<String, dynamic>>[],
        'resolution_time_avg': 0.0,
        'top_reporters': <Map<String, dynamic>>[],
      };

      // Analyze current page reports
      for (final report in reportsList.items) {
        // Count by status
        switch (report.status) {
          case 'pending':
            summary['pending_reports'] =
                (summary['pending_reports'] as int) + 1;
            break;
          case 'in_progress':
            summary['in_progress_reports'] =
                (summary['in_progress_reports'] as int) + 1;
            break;
          case 'resolved':
            summary['resolved_reports'] =
                (summary['resolved_reports'] as int) + 1;
            break;
          case 'dismissed':
            summary['dismissed_reports'] =
                (summary['dismissed_reports'] as int) + 1;
            break;
          case 'escalated':
            summary['escalated_reports'] =
                (summary['escalated_reports'] as int) + 1;
            break;
        }

        // Count by reason
        final reasonMap = summary['by_reason'] as Map<String, int>;
        reasonMap[report.reason] = (reasonMap[report.reason] ?? 0) + 1;

        // Add to recent activity if created in last 7 days
        final daysSinceCreated =
            DateTime.now().difference(report.created).inDays;
        if (daysSinceCreated <= 7) {
          final activityList =
              summary['recent_activity'] as List<Map<String, dynamic>>;
          activityList.add({
            'id': report.id,
            'content_title': report.contentTitle ?? 'Unknown Content',
            'reason': report.reason,
            'status': report.status,
            'created': report.created.toIso8601String(),
            'reporter_name': report.reporterName ?? 'Anonymous',
          });
        }

        // Calculate resolution time for resolved reports
        if (report.status == 'resolved' && report.resolvedAt != null) {
          final resolutionTime =
              report.resolvedAt!.difference(report.created).inHours;
          summary['resolution_time_avg'] =
              ((summary['resolution_time_avg'] as double) + resolutionTime) / 2;
        }
      }

      // Sort recent activity by date
      final activityList =
          summary['recent_activity'] as List<Map<String, dynamic>>;
      activityList.sort((a, b) =>
          DateTime.parse(b['created']).compareTo(DateTime.parse(a['created'])));

      // Keep only top 10 recent activities
      if (activityList.length > 10) {
        summary['recent_activity'] = activityList.take(10).toList();
      }

      // Add statistics data if available
      if (statistics != null && statistics.isNotEmpty) {
        summary.addAll({
          'statistics': statistics,
          'has_detailed_stats': true,
        });
      }

      return summary;
    } catch (e, stackTrace) {
      _logger.e('Report summary generation error: $e');
      state = AsyncValue.error(e, stackTrace);
      return {};
    }
  }

  Future<void> refreshSummary() async {
    state = const AsyncValue.loading();
    await _generateReportSummary();
  }
}

// Report Search Provider
@riverpod
class ReportSearch extends _$ReportSearch {
  Timer? _debounceTimer;

  @override
  String build() => '';

  void updateSearchQuery(String query) {
    state = query;

    // Debounce search to avoid too many API calls
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      ref.read(reportFiltersStateProvider.notifier).updateSearch(query);
      ref.read(contentReportsListProvider.notifier).applyFilters();
    });
  }

  void clearSearch() {
    _debounceTimer?.cancel();
    state = '';
    ref.read(reportFiltersStateProvider.notifier).updateSearch(null);
    ref.read(contentReportsListProvider.notifier).applyFilters();
  }
}

// Report Priority Filter Provider
@riverpod
class ReportPriorityFilter extends _$ReportPriorityFilter {
  @override
  String? build() => null;

  void setPriority(String? priority) {
    state = priority;
    ref.read(reportFiltersStateProvider.notifier).updatePriority(priority);
    ref.read(contentReportsListProvider.notifier).applyFilters();
  }

  void clearPriority() {
    state = null;
    ref.read(reportFiltersStateProvider.notifier).updatePriority(null);
    ref.read(contentReportsListProvider.notifier).applyFilters();
  }
}

// Report Status Filter Provider
@riverpod
class ReportStatusFilter extends _$ReportStatusFilter {
  @override
  String? build() => null;

  void setStatus(String? status) {
    state = status;
    ref.read(reportFiltersStateProvider.notifier).updateStatus(status);
    ref.read(contentReportsListProvider.notifier).applyFilters();
  }

  void clearStatus() {
    state = null;
    ref.read(reportFiltersStateProvider.notifier).updateStatus(null);
    ref.read(contentReportsListProvider.notifier).applyFilters();
  }
}

// Report Auto-Refresh Provider
@riverpod
class ReportAutoRefresh extends _$ReportAutoRefresh {
  Timer? _refreshTimer;
  final Logger _logger = Logger();

  @override
  bool build() {
    ref.onDispose(() {
      _refreshTimer?.cancel();
    });
    return false;
  }

  void enableAutoRefresh({Duration interval = const Duration(minutes: 2)}) {
    _refreshTimer?.cancel();

    state = true;
    _refreshTimer = Timer.periodic(interval, (_) {
      _logger.d('Auto-refreshing reports...');
      ref.read(contentReportsListProvider.notifier).refreshReports();
      ref.read(reportStatisticsProvider.notifier).refreshStatistics();
      ref.read(reportSummaryProvider.notifier).refreshSummary();
    });

    _logger.i(
        'Report auto-refresh enabled with ${interval.inMinutes} minute interval');
  }

  void disableAutoRefresh() {
    _refreshTimer?.cancel();
    state = false;
    _logger.i('Report auto-refresh disabled');
  }

  void toggleAutoRefresh() {
    if (state) {
      disableAutoRefresh();
    } else {
      enableAutoRefresh();
    }
  }
}

// Report Form State Provider (for creating/editing reports)
@riverpod
class ReportFormState extends _$ReportFormState {
  @override
  ReportForm build() {
    return const ReportForm();
  }

  void updateField(String field, dynamic value) {
    switch (field) {
      case 'contentId':
        state = state.copyWith(contentId: value as String?);
        break;
      case 'reason':
        state = state.copyWith(reason: value as String?);
        break;
      case 'description':
        state = state.copyWith(description: value as String?);
        break;
      case 'priority':
        state = state.copyWith(priority: value as String?);
        break;
      case 'resolution':
        state = state.copyWith(resolution: value as String?);
        break;
      case 'adminNotes':
        state = state.copyWith(adminNotes: value as String?);
        break;
    }
  }

  void clearForm() {
    state = const ReportForm();
  }

  void loadReport(ContentReport report) {
    state = ReportForm(
      id: report.id,
      contentId: report.contentId,
      reason: report.reason,
      description: report.description,
      resolution: '', // Initialize empty for admin to fill
      adminNotes: '',
    );
  }

  bool get isValid {
    return state.contentId?.isNotEmpty == true &&
        state.reason?.isNotEmpty == true;
  }
}

// Report Form Model
class ReportForm {
  final String? id;
  final String? contentId;
  final String? reason;
  final String? description;
  final String? priority;
  final String? resolution;
  final String? adminNotes;

  const ReportForm({
    this.id,
    this.contentId,
    this.reason,
    this.description,
    this.priority,
    this.resolution,
    this.adminNotes,
  });

  ReportForm copyWith({
    String? id,
    String? contentId,
    String? reason,
    String? description,
    String? priority,
    String? resolution,
    String? adminNotes,
  }) {
    return ReportForm(
      id: id ?? this.id,
      contentId: contentId ?? this.contentId,
      reason: reason ?? this.reason,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      resolution: resolution ?? this.resolution,
      adminNotes: adminNotes ?? this.adminNotes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (contentId != null) 'content_id': contentId,
      if (reason != null) 'reason': reason,
      if (description != null) 'description': description,
      if (priority != null) 'priority': priority,
      if (resolution != null) 'resolution': resolution,
      if (adminNotes != null) 'admin_notes': adminNotes,
    };
  }
}
