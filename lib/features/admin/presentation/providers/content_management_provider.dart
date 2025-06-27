import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';

import '../../../../shared/models/pagination.dart';
import '../../../../shared/services/analytics_service.dart';
import '../../domain/repositories/admin_repository.dart';
import 'admin_auth_provider.dart';

part 'content_management_provider.g.dart';

// Content Filter Parameters
class ContentFilters {
  final String? status;
  final String? category;
  final String? type;
  final String? search;
  final String? sort;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const ContentFilters({
    this.status,
    this.category,
    this.type,
    this.search,
    this.sort,
    this.dateFrom,
    this.dateTo,
  });

  ContentFilters copyWith({
    String? status,
    String? category,
    String? type,
    String? search,
    String? sort,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    return ContentFilters(
      status: status ?? this.status,
      category: category ?? this.category,
      type: type ?? this.type,
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
    if (category != null && category!.isNotEmpty) {
      filters.add("category='$category'");
    }
    if (type != null && type!.isNotEmpty) {
      filters.add("type='$type'");
    }
    if (search != null && search!.isNotEmpty) {
      filters.add("(title~'$search' || description~'$search')");
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
        category != null ||
        type != null ||
        (search != null && search!.isNotEmpty) ||
        dateFrom != null ||
        dateTo != null;
  }
}

// Content Pagination Parameters
class ContentPaginationParams {
  final int page;
  final int perPage;

  const ContentPaginationParams({
    this.page = 1,
    this.perPage = 20,
  });

  ContentPaginationParams copyWith({
    int? page,
    int? perPage,
  }) {
    return ContentPaginationParams(
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
    );
  }
}

// Content Filters State Provider
@riverpod
class ContentFiltersState extends _$ContentFiltersState {
  @override
  ContentFilters build() {
    return const ContentFilters(sort: '-created');
  }

  void updateStatus(String? status) {
    state = state.copyWith(status: status);
  }

  void updateCategory(String? category) {
    state = state.copyWith(category: category);
  }

  void updateType(String? type) {
    state = state.copyWith(type: type);
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
    state = const ContentFilters(sort: '-created');
  }
}

// Content Pagination State Provider
@riverpod
class ContentPaginationState extends _$ContentPaginationState {
  @override
  ContentPaginationParams build() {
    return const ContentPaginationParams();
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
    state = const ContentPaginationParams();
  }
}

// Content List Provider
@riverpod
class ContentList extends _$ContentList {
  final Logger _logger = Logger();

  @override
  Future<PaginatedResponse<Map<String, dynamic>>> build() async {
    // Only fetch if admin is authenticated
    final isAuthenticated = ref.watch(isAdminAuthenticatedProvider);
    if (!isAuthenticated) {
      return PaginatedResponse.empty();
    }

    return await _fetchContent();
  }

  Future<PaginatedResponse<Map<String, dynamic>>> _fetchContent() async {
    try {
      final repository = ref.read(adminRepositoryProvider);
      final filters = ref.read(contentFiltersStateProvider);
      final pagination = ref.read(contentPaginationStateProvider);

      final result = await repository.getContent(
        page: pagination.page,
        perPage: pagination.perPage,
        filter: filters.filterString,
        sort: filters.sort,
      );

      return result.fold(
        (failure) {
          _logger.e('Failed to fetch content: ${failure.message}');
          state = AsyncValue.error(failure, StackTrace.current);
          return PaginatedResponse.empty();
        },
        (contentList) => contentList,
      );
    } catch (e, stackTrace) {
      _logger.e('Content fetch error: $e');
      state = AsyncValue.error(e, stackTrace);
      return PaginatedResponse.empty();
    }
  }

  Future<void> refreshContent() async {
    state = const AsyncValue.loading();
    await _fetchContent();
  }

  Future<void> loadPage(int page) async {
    ref.read(contentPaginationStateProvider.notifier).updatePage(page);
    await refreshContent();
  }

  Future<void> applyFilters() async {
    ref.read(contentPaginationStateProvider.notifier).reset();
    await refreshContent();
  }
}

// Content Details Provider
@riverpod
class ContentDetails extends _$ContentDetails {
  final Logger _logger = Logger();

  @override
  Future<Map<String, dynamic>?> build(String contentId) async {
    // Only fetch if admin is authenticated
    final isAuthenticated = ref.watch(isAdminAuthenticatedProvider);
    if (!isAuthenticated) return null;

    return await _fetchContentDetails(contentId);
  }

  Future<Map<String, dynamic>?> _fetchContentDetails(String contentId) async {
    try {
      final repository = ref.read(adminRepositoryProvider);

      // Note: This would need to be implemented in the repository
      // For now, we'll simulate getting content details from the content list
      final contentList = ref.read(contentListProvider).value;
      if (contentList != null) {
        final content = contentList.items.firstWhere(
          (item) => item['id'] == contentId,
          orElse: () => <String, dynamic>{},
        );

        if (content.isNotEmpty) {
          return content;
        }
      }

      return null;
    } catch (e, stackTrace) {
      _logger.e('Content details fetch error: $e');
      state = AsyncValue.error(e, stackTrace);
      return null;
    }
  }

  Future<void> refreshDetails() async {
    await build(state.value?['id'] ?? '');
  }
}

// Content Status Update Provider
@riverpod
class ContentStatusUpdate extends _$ContentStatusUpdate {
  final Logger _logger = Logger();

  @override
  bool build() => false;

  Future<bool> updateContentStatus(String contentId, String status) async {
    state = true;

    try {
      final repository = ref.read(adminRepositoryProvider);

      final result = await repository.updateContentStatus(contentId, status);

      final success = result.fold(
        (failure) {
          _logger.e('Failed to update content status: ${failure.message}');
          return false;
        },
        (updatedContent) {
          AnalyticsService.instance.trackEvent('admin_content_status_updated', {
            'content_id': contentId,
            'new_status': status,
          });

          // Refresh the content list
          ref.invalidate(contentListProvider);

          return true;
        },
      );

      return success;
    } catch (e) {
      _logger.e('Content status update error: $e');
      return false;
    } finally {
      state = false;
    }
  }
}

// Content Deletion Provider
@riverpod
class ContentDeletion extends _$ContentDeletion {
  final Logger _logger = Logger();

  @override
  bool build() => false;

  Future<bool> deleteContent(String contentId) async {
    state = true;

    try {
      final repository = ref.read(adminRepositoryProvider);

      final result = await repository.deleteContent(contentId);

      final success = result.fold(
        (failure) {
          _logger.e('Failed to delete content: ${failure.message}');
          return false;
        },
        (_) {
          AnalyticsService.instance.trackEvent('admin_content_deleted', {
            'content_id': contentId,
          });

          // Refresh the content list
          ref.invalidate(contentListProvider);

          return true;
        },
      );

      return success;
    } catch (e) {
      _logger.e('Content deletion error: $e');
      return false;
    } finally {
      state = false;
    }
  }
}

// Bulk Content Operations Provider
@riverpod
class BulkContentOperations extends _$BulkContentOperations {
  final Logger _logger = Logger();

  @override
  BulkOperationState build() {
    return const BulkOperationState();
  }

  void selectContent(String contentId) {
    final currentSelected = Set<String>.from(state.selectedIds);
    currentSelected.add(contentId);
    state = state.copyWith(selectedIds: currentSelected);
  }

  void deselectContent(String contentId) {
    final currentSelected = Set<String>.from(state.selectedIds);
    currentSelected.remove(contentId);
    state = state.copyWith(selectedIds: currentSelected);
  }

  void selectAll(List<String> contentIds) {
    state = state.copyWith(selectedIds: Set<String>.from(contentIds));
  }

  void clearSelection() {
    state = state.copyWith(selectedIds: <String>{});
  }

  Future<bool> bulkUpdateStatus(String status) async {
    if (state.selectedIds.isEmpty) return false;

    state = state.copyWith(isProcessing: true);

    try {
      final repository = ref.read(adminRepositoryProvider);
      bool allSuccess = true;

      for (final contentId in state.selectedIds) {
        final result = await repository.updateContentStatus(contentId, status);
        result.fold(
          (failure) {
            _logger
                .e('Failed to update content $contentId: ${failure.message}');
            allSuccess = false;
          },
          (_) {},
        );
      }

      if (allSuccess) {
        AnalyticsService.instance
            .trackEvent('admin_bulk_content_status_updated', {
          'content_count': state.selectedIds.length,
          'new_status': status,
        });

        // Refresh the content list
        ref.invalidate(contentListProvider);
        clearSelection();
      }

      return allSuccess;
    } catch (e) {
      _logger.e('Bulk status update error: $e');
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

      for (final contentId in state.selectedIds) {
        final result = await repository.deleteContent(contentId);
        result.fold(
          (failure) {
            _logger
                .e('Failed to delete content $contentId: ${failure.message}');
            allSuccess = false;
          },
          (_) {},
        );
      }

      if (allSuccess) {
        AnalyticsService.instance.trackEvent('admin_bulk_content_deleted', {
          'content_count': state.selectedIds.length,
        });

        // Refresh the content list
        ref.invalidate(contentListProvider);
        clearSelection();
      }

      return allSuccess;
    } catch (e) {
      _logger.e('Bulk deletion error: $e');
      return false;
    } finally {
      state = state.copyWith(isProcessing: false);
    }
  }
}

// Bulk Operation State
class BulkOperationState {
  final Set<String> selectedIds;
  final bool isProcessing;

  const BulkOperationState({
    this.selectedIds = const <String>{},
    this.isProcessing = false,
  });

  BulkOperationState copyWith({
    Set<String>? selectedIds,
    bool? isProcessing,
  }) {
    return BulkOperationState(
      selectedIds: selectedIds ?? this.selectedIds,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }

  bool get hasSelection => selectedIds.isNotEmpty;
  int get selectedCount => selectedIds.length;
}

// Content Statistics Provider
@riverpod
class ContentStatistics extends _$ContentStatistics {
  final Logger _logger = Logger();

  @override
  Future<Map<String, dynamic>> build() async {
    // Only fetch if admin is authenticated
    final isAuthenticated = ref.watch(isAdminAuthenticatedProvider);
    if (!isAuthenticated) return {};

    return await _fetchContentStatistics();
  }

  Future<Map<String, dynamic>> _fetchContentStatistics() async {
    try {
      // This would typically come from a dedicated API endpoint
      // For now, we'll derive it from the content list
      final contentList = ref.read(contentListProvider).value;

      if (contentList == null) return {};

      final stats = <String, dynamic>{
        'total_content': contentList.totalItems,
        'published_content': 0,
        'draft_content': 0,
        'archived_content': 0,
        'by_category': <String, int>{},
        'by_type': <String, int>{},
      };

      for (final content in contentList.items) {
        final status = content['status'] as String? ?? '';
        final category = content['category'] as String? ?? 'uncategorized';
        final type = content['type'] as String? ?? 'unknown';

        // Count by status
        switch (status) {
          case 'published':
            stats['published_content'] =
                (stats['published_content'] as int) + 1;
            break;
          case 'draft':
            stats['draft_content'] = (stats['draft_content'] as int) + 1;
            break;
          case 'archived':
            stats['archived_content'] = (stats['archived_content'] as int) + 1;
            break;
        }

        // Count by category
        final categoryMap = stats['by_category'] as Map<String, int>;
        categoryMap[category] = (categoryMap[category] ?? 0) + 1;

        // Count by type
        final typeMap = stats['by_type'] as Map<String, int>;
        typeMap[type] = (typeMap[type] ?? 0) + 1;
      }

      return stats;
    } catch (e, stackTrace) {
      _logger.e('Content statistics fetch error: $e');
      state = AsyncValue.error(e, stackTrace);
      return {};
    }
  }

  Future<void> refreshStatistics() async {
    state = const AsyncValue.loading();
    await _fetchContentStatistics();
  }
}

// Content Search Provider
@riverpod
class ContentSearch extends _$ContentSearch {
  Timer? _debounceTimer;

  @override
  String build() => '';

  void updateSearchQuery(String query) {
    state = query;

    // Debounce search to avoid too many API calls
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      ref.read(contentFiltersStateProvider.notifier).updateSearch(query);
      ref.read(contentListProvider.notifier).applyFilters();
    });
  }

  void clearSearch() {
    _debounceTimer?.cancel();
    state = '';
    ref.read(contentFiltersStateProvider.notifier).updateSearch(null);
    ref.read(contentListProvider.notifier).applyFilters();
  }
}
