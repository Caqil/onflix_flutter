import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onflix/features/admin/data/models/payment_history_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';

import '../../../../shared/models/pagination.dart';
import '../../../../shared/services/analytics_service.dart';
import '../../domain/repositories/admin_repository.dart';
import 'admin_auth_provider.dart';

part 'user_management_provider.g.dart';

// User Filter Parameters
class UserFilters {
  final String? status;
  final String? subscriptionType;
  final String? accountType;
  final String? search;
  final String? sort;
  final DateTime? registeredFrom;
  final DateTime? registeredTo;
  final DateTime? lastActiveFrom;
  final DateTime? lastActiveTo;

  const UserFilters({
    this.status,
    this.subscriptionType,
    this.accountType,
    this.search,
    this.sort,
    this.registeredFrom,
    this.registeredTo,
    this.lastActiveFrom,
    this.lastActiveTo,
  });

  UserFilters copyWith({
    String? status,
    String? subscriptionType,
    String? accountType,
    String? search,
    String? sort,
    DateTime? registeredFrom,
    DateTime? registeredTo,
    DateTime? lastActiveFrom,
    DateTime? lastActiveTo,
  }) {
    return UserFilters(
      status: status ?? this.status,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      accountType: accountType ?? this.accountType,
      search: search ?? this.search,
      sort: sort ?? this.sort,
      registeredFrom: registeredFrom ?? this.registeredFrom,
      registeredTo: registeredTo ?? this.registeredTo,
      lastActiveFrom: lastActiveFrom ?? this.lastActiveFrom,
      lastActiveTo: lastActiveTo ?? this.lastActiveTo,
    );
  }

  String? get filterString {
    final filters = <String>[];

    if (status != null && status!.isNotEmpty) {
      filters.add("status='$status'");
    }
    if (subscriptionType != null && subscriptionType!.isNotEmpty) {
      filters.add("subscription_type='$subscriptionType'");
    }
    if (accountType != null && accountType!.isNotEmpty) {
      filters.add("account_type='$accountType'");
    }
    if (search != null && search!.isNotEmpty) {
      filters.add("(name~'$search' || email~'$search' || username~'$search')");
    }
    if (registeredFrom != null) {
      filters.add("created>='${registeredFrom!.toIso8601String()}'");
    }
    if (registeredTo != null) {
      filters.add("created<='${registeredTo!.toIso8601String()}'");
    }
    if (lastActiveFrom != null) {
      filters.add("last_active>='${lastActiveFrom!.toIso8601String()}'");
    }
    if (lastActiveTo != null) {
      filters.add("last_active<='${lastActiveTo!.toIso8601String()}'");
    }

    return filters.isEmpty ? null : filters.join(' && ');
  }

  bool get hasActiveFilters {
    return status != null ||
        subscriptionType != null ||
        accountType != null ||
        (search != null && search!.isNotEmpty) ||
        registeredFrom != null ||
        registeredTo != null ||
        lastActiveFrom != null ||
        lastActiveTo != null;
  }
}

// User Pagination Parameters
class UserPaginationParams {
  final int page;
  final int perPage;

  const UserPaginationParams({
    this.page = 1,
    this.perPage = 20,
  });

  UserPaginationParams copyWith({
    int? page,
    int? perPage,
  }) {
    return UserPaginationParams(
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
    );
  }
}

// User Filters State Provider
@riverpod
class UserFiltersState extends _$UserFiltersState {
  @override
  UserFilters build() {
    return const UserFilters(sort: '-created');
  }

  void updateStatus(String? status) {
    state = state.copyWith(status: status);
  }

  void updateSubscriptionType(String? subscriptionType) {
    state = state.copyWith(subscriptionType: subscriptionType);
  }

  void updateAccountType(String? accountType) {
    state = state.copyWith(accountType: accountType);
  }

  void updateSearch(String? search) {
    state = state.copyWith(search: search);
  }

  void updateSort(String? sort) {
    state = state.copyWith(sort: sort);
  }

  void updateRegistrationDateRange(DateTime? from, DateTime? to) {
    state = state.copyWith(registeredFrom: from, registeredTo: to);
  }

  void updateLastActiveDateRange(DateTime? from, DateTime? to) {
    state = state.copyWith(lastActiveFrom: from, lastActiveTo: to);
  }

  void clearFilters() {
    state = const UserFilters(sort: '-created');
  }

  void setQuickFilter(String filterType) {
    switch (filterType) {
      case 'active':
        state = state.copyWith(status: 'active');
        break;
      case 'suspended':
        state = state.copyWith(status: 'suspended');
        break;
      case 'premium':
        state = state.copyWith(subscriptionType: 'premium');
        break;
      case 'free':
        state = state.copyWith(subscriptionType: 'free');
        break;
      case 'new_today':
        final today = DateTime.now();
        final startOfDay = DateTime(today.year, today.month, today.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        state =
            state.copyWith(registeredFrom: startOfDay, registeredTo: endOfDay);
        break;
      case 'new_this_week':
        final now = DateTime.now();
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final startOfWeek =
            DateTime(weekStart.year, weekStart.month, weekStart.day);
        state = state.copyWith(registeredFrom: startOfWeek, registeredTo: now);
        break;
      case 'inactive_30_days':
        final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
        state = state.copyWith(lastActiveTo: thirtyDaysAgo);
        break;
    }
  }
}

// User Pagination State Provider
@riverpod
class UserPaginationState extends _$UserPaginationState {
  @override
  UserPaginationParams build() {
    return const UserPaginationParams();
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
    state = const UserPaginationParams();
  }
}

// Users List Provider
@riverpod
class UsersList extends _$UsersList {
  final Logger _logger = Logger();

  @override
  Future<PaginatedResponse<Map<String, dynamic>>> build() async {
    // Only fetch if admin is authenticated
    final isAuthenticated = ref.watch(isAdminAuthenticatedProvider);
    if (!isAuthenticated) {
      return PaginatedResponse.empty();
    }

    return await _fetchUsers();
  }

  Future<PaginatedResponse<Map<String, dynamic>>> _fetchUsers() async {
    try {
      final repository = ref.read(adminRepositoryProvider);
      final filters = ref.read(userFiltersStateProvider);
      final pagination = ref.read(userPaginationStateProvider);

      final result = await repository.getUsers(
        page: pagination.page,
        perPage: pagination.perPage,
        filter: filters.filterString,
        sort: filters.sort,
      );

      return result.fold(
        (failure) {
          _logger.e('Failed to fetch users: ${failure.message}');
          state = AsyncValue.error(failure, StackTrace.current);
          return PaginatedResponse.empty();
        },
        (usersList) => usersList,
      );
    } catch (e, stackTrace) {
      _logger.e('Users fetch error: $e');
      state = AsyncValue.error(e, stackTrace);
      return PaginatedResponse.empty();
    }
  }

  Future<void> refreshUsers() async {
    state = const AsyncValue.loading();
    await _fetchUsers();
  }

  Future<void> loadPage(int page) async {
    ref.read(userPaginationStateProvider.notifier).updatePage(page);
    await refreshUsers();
  }

  Future<void> applyFilters() async {
    ref.read(userPaginationStateProvider.notifier).reset();
    await refreshUsers();
  }
}

// User Details Provider
@riverpod
class UserDetails extends _$UserDetails {
  final Logger _logger = Logger();

  @override
  Future<Map<String, dynamic>?> build(String userId) async {
    // Only fetch if admin is authenticated
    final isAuthenticated = ref.watch(isAdminAuthenticatedProvider);
    if (!isAuthenticated) return null;

    return await _fetchUserDetails(userId);
  }

  Future<Map<String, dynamic>?> _fetchUserDetails(String userId) async {
    try {
      final repository = ref.read(adminRepositoryProvider);

      final result = await repository.getUserDetails(userId);

      return result.fold(
        (failure) {
          _logger.e('Failed to fetch user details: ${failure.message}');
          state = AsyncValue.error(failure, StackTrace.current);
          return null;
        },
        (userDetails) => userDetails,
      );
    } catch (e, stackTrace) {
      _logger.e('User details fetch error: $e');
      state = AsyncValue.error(e, stackTrace);
      return null;
    }
  }

  Future<void> refreshDetails() async {
    final currentUser = state.value;
    if (currentUser != null && currentUser['id'] != null) {
      await build(currentUser['id']);
    }
  }
}

// User Status Update Provider
@riverpod
class UserStatusUpdate extends _$UserStatusUpdate {
  final Logger _logger = Logger();

  @override
  bool build() => false;

  Future<bool> suspendUser(String userId, String reason) async {
    state = true;

    try {
      final repository = ref.read(adminRepositoryProvider);

      final result = await repository.suspendUser(userId, reason);

      final success = result.fold(
        (failure) {
          _logger.e('Failed to suspend user: ${failure.message}');
          return false;
        },
        (_) {
          AnalyticsService.instance.trackEvent('admin_user_suspended', {
            'user_id': userId,
            'reason': reason,
          });

          // Refresh the users list and details
          ref.invalidate(usersListProvider);
          ref.invalidate(userDetailsProvider);

          return true;
        },
      );

      return success;
    } catch (e) {
      _logger.e('User suspension error: $e');
      return false;
    } finally {
      state = false;
    }
  }

  Future<bool> activateUser(String userId) async {
    state = true;

    try {
      final repository = ref.read(adminRepositoryProvider);

      final result = await repository.activateUser(userId);

      final success = result.fold(
        (failure) {
          _logger.e('Failed to activate user: ${failure.message}');
          return false;
        },
        (_) {
          AnalyticsService.instance.trackEvent('admin_user_activated', {
            'user_id': userId,
          });

          // Refresh the users list and details
          ref.invalidate(usersListProvider);
          ref.invalidate(userDetailsProvider);

          return true;
        },
      );

      return success;
    } catch (e) {
      _logger.e('User activation error: $e');
      return false;
    } finally {
      state = false;
    }
  }
}

// User Deletion Provider
@riverpod
class UserDeletion extends _$UserDeletion {
  final Logger _logger = Logger();

  @override
  bool build() => false;

  Future<bool> deleteUser(String userId) async {
    state = true;

    try {
      final repository = ref.read(adminRepositoryProvider);

      final result = await repository.deleteUserAccount(userId);

      final success = result.fold(
        (failure) {
          _logger.e('Failed to delete user: ${failure.message}');
          return false;
        },
        (_) {
          AnalyticsService.instance.trackEvent('admin_user_deleted', {
            'user_id': userId,
          });

          // Refresh the users list
          ref.invalidate(usersListProvider);

          return true;
        },
      );

      return success;
    } catch (e) {
      _logger.e('User deletion error: $e');
      return false;
    } finally {
      state = false;
    }
  }
}

// Payment History Provider
@riverpod
class UserPaymentHistory extends _$UserPaymentHistory {
  final Logger _logger = Logger();

  @override
  Future<PaginatedResponse<PaymentHistoryModel>> build(String userId) async {
    // Only fetch if admin is authenticated
    final isAuthenticated = ref.watch(isAdminAuthenticatedProvider);
    if (!isAuthenticated) {
      return PaginatedResponse.empty();
    }

    return await _fetchPaymentHistory(userId);
  }

  Future<PaginatedResponse<PaymentHistoryModel>> _fetchPaymentHistory(
      String userId) async {
    try {
      final repository = ref.read(adminRepositoryProvider);

      final result = await repository.getPaymentHistory(
        page: 1,
        perPage: 50,
        sort: '-created',
      );

      return result.fold(
        (failure) {
          _logger.e('Failed to fetch payment history: ${failure.message}');
          state = AsyncValue.error(failure, StackTrace.current);
          return PaginatedResponse.empty();
        },
        (paymentHistory) {
          // Filter payments for the specific user
          final userPayments = paymentHistory.items
              .where((payment) => payment.userId == userId)
              .toList();

          return PaginatedResponse<PaymentHistoryModel>(
            page: paymentHistory.page,
            perPage: paymentHistory.perPage,
            totalItems: userPayments.length,
            totalPages: (userPayments.length / paymentHistory.perPage).ceil(),
            items: userPayments,
          );
        },
      );
    } catch (e, stackTrace) {
      _logger.e('Payment history fetch error: $e');
      state = AsyncValue.error(e, stackTrace);
      return PaginatedResponse.empty();
    }
  }

  Future<void> refreshPaymentHistory() async {
    final currentUserId = state.value?.items.first.userId;
    if (currentUserId != null) {
      await build(currentUserId);
    }
  }
}

// Payment Refund Provider
@riverpod
class PaymentRefund extends _$PaymentRefund {
  final Logger _logger = Logger();

  @override
  bool build() => false;

  Future<bool> refundPayment(String paymentId, double amount) async {
    state = true;

    try {
      final repository = ref.read(adminRepositoryProvider);

      final result = await repository.refundPayment(paymentId, amount);

      final success = result.fold(
        (failure) {
          _logger.e('Failed to refund payment: ${failure.message}');
          return false;
        },
        (_) {
          AnalyticsService.instance.trackEvent('admin_payment_refunded', {
            'payment_id': paymentId,
            'refund_amount': amount,
          });

          // Refresh payment history
          ref.invalidate(userPaymentHistoryProvider);

          return true;
        },
      );

      return success;
    } catch (e) {
      _logger.e('Payment refund error: $e');
      return false;
    } finally {
      state = false;
    }
  }
}

// Bulk User Operations Provider
@riverpod
class BulkUserOperations extends _$BulkUserOperations {
  final Logger _logger = Logger();

  @override
  BulkUserOperationState build() {
    return const BulkUserOperationState();
  }

  void selectUser(String userId) {
    final currentSelected = Set<String>.from(state.selectedIds);
    currentSelected.add(userId);
    state = state.copyWith(selectedIds: currentSelected);
  }

  void deselectUser(String userId) {
    final currentSelected = Set<String>.from(state.selectedIds);
    currentSelected.remove(userId);
    state = state.copyWith(selectedIds: currentSelected);
  }

  void selectAll(List<String> userIds) {
    state = state.copyWith(selectedIds: Set<String>.from(userIds));
  }

  void clearSelection() {
    state = state.copyWith(selectedIds: <String>{});
  }

  Future<bool> bulkSuspend(String reason) async {
    if (state.selectedIds.isEmpty) return false;

    state = state.copyWith(isProcessing: true);

    try {
      final repository = ref.read(adminRepositoryProvider);
      bool allSuccess = true;

      for (final userId in state.selectedIds) {
        final result = await repository.suspendUser(userId, reason);
        result.fold(
          (failure) {
            _logger.e('Failed to suspend user $userId: ${failure.message}');
            allSuccess = false;
          },
          (_) {},
        );
      }

      if (allSuccess) {
        AnalyticsService.instance.trackEvent('admin_bulk_user_suspended', {
          'user_count': state.selectedIds.length,
          'reason': reason,
        });

        // Refresh the users list
        ref.invalidate(usersListProvider);
        clearSelection();
      }

      return allSuccess;
    } catch (e) {
      _logger.e('Bulk user suspension error: $e');
      return false;
    } finally {
      state = state.copyWith(isProcessing: false);
    }
  }

  Future<bool> bulkActivate() async {
    if (state.selectedIds.isEmpty) return false;

    state = state.copyWith(isProcessing: true);

    try {
      final repository = ref.read(adminRepositoryProvider);
      bool allSuccess = true;

      for (final userId in state.selectedIds) {
        final result = await repository.activateUser(userId);
        result.fold(
          (failure) {
            _logger.e('Failed to activate user $userId: ${failure.message}');
            allSuccess = false;
          },
          (_) {},
        );
      }

      if (allSuccess) {
        AnalyticsService.instance.trackEvent('admin_bulk_user_activated', {
          'user_count': state.selectedIds.length,
        });

        // Refresh the users list
        ref.invalidate(usersListProvider);
        clearSelection();
      }

      return allSuccess;
    } catch (e) {
      _logger.e('Bulk user activation error: $e');
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

      for (final userId in state.selectedIds) {
        final result = await repository.deleteUserAccount(userId);
        result.fold(
          (failure) {
            _logger.e('Failed to delete user $userId: ${failure.message}');
            allSuccess = false;
          },
          (_) {},
        );
      }

      if (allSuccess) {
        AnalyticsService.instance.trackEvent('admin_bulk_user_deleted', {
          'user_count': state.selectedIds.length,
        });

        // Refresh the users list
        ref.invalidate(usersListProvider);
        clearSelection();
      }

      return allSuccess;
    } catch (e) {
      _logger.e('Bulk user deletion error: $e');
      return false;
    } finally {
      state = state.copyWith(isProcessing: false);
    }
  }
}

// Bulk User Operation State
class BulkUserOperationState {
  final Set<String> selectedIds;
  final bool isProcessing;

  const BulkUserOperationState({
    this.selectedIds = const <String>{},
    this.isProcessing = false,
  });

  BulkUserOperationState copyWith({
    Set<String>? selectedIds,
    bool? isProcessing,
  }) {
    return BulkUserOperationState(
      selectedIds: selectedIds ?? this.selectedIds,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }

  bool get hasSelection => selectedIds.isNotEmpty;
  int get selectedCount => selectedIds.length;
}

// User Statistics Provider
@riverpod
class UserStatistics extends _$UserStatistics {
  final Logger _logger = Logger();

  @override
  Future<Map<String, dynamic>> build() async {
    // Only fetch if admin is authenticated
    final isAuthenticated = ref.watch(isAdminAuthenticatedProvider);
    if (!isAuthenticated) return {};

    return await _generateUserStatistics();
  }

  Future<Map<String, dynamic>> _generateUserStatistics() async {
    try {
      final usersList = ref.read(usersListProvider).value;

      if (usersList == null) return {};

      final stats = <String, dynamic>{
        'total_users': usersList.totalItems,
        'active_users': 0,
        'suspended_users': 0,
        'premium_users': 0,
        'free_users': 0,
        'verified_users': 0,
        'unverified_users': 0,
        'new_users_today': 0,
        'new_users_this_week': 0,
        'new_users_this_month': 0,
        'by_subscription_type': <String, int>{},
        'by_registration_month': <String, int>{},
        'by_country': <String, int>{},
        'average_session_duration': 0.0,
        'most_active_users': <Map<String, dynamic>>[],
      };

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final monthStart = DateTime(now.year, now.month, 1);

      for (final user in usersList.items) {
        final status = user['status'] as String? ?? '';
        final subscriptionType = user['subscription_type'] as String? ?? 'free';
        final verified = user['verified'] as bool? ?? false;
        final createdAt =
            user['created'] != null ? DateTime.tryParse(user['created']) : null;

        // Count by status
        if (status == 'active') {
          stats['active_users'] = (stats['active_users'] as int) + 1;
        } else if (status == 'suspended') {
          stats['suspended_users'] = (stats['suspended_users'] as int) + 1;
        }

        // Count by subscription type
        if (subscriptionType == 'premium') {
          stats['premium_users'] = (stats['premium_users'] as int) + 1;
        } else {
          stats['free_users'] = (stats['free_users'] as int) + 1;
        }

        // Count by verification status
        if (verified) {
          stats['verified_users'] = (stats['verified_users'] as int) + 1;
        } else {
          stats['unverified_users'] = (stats['unverified_users'] as int) + 1;
        }

        // Count new users
        if (createdAt != null) {
          if (createdAt.isAfter(today)) {
            stats['new_users_today'] = (stats['new_users_today'] as int) + 1;
          }
          if (createdAt.isAfter(weekStart)) {
            stats['new_users_this_week'] =
                (stats['new_users_this_week'] as int) + 1;
          }
          if (createdAt.isAfter(monthStart)) {
            stats['new_users_this_month'] =
                (stats['new_users_this_month'] as int) + 1;
          }

          // Count by registration month
          final monthKey =
              '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}';
          final monthMap = stats['by_registration_month'] as Map<String, int>;
          monthMap[monthKey] = (monthMap[monthKey] ?? 0) + 1;
        }

        // Count by subscription type for detailed breakdown
        final subscriptionMap =
            stats['by_subscription_type'] as Map<String, int>;
        subscriptionMap[subscriptionType] =
            (subscriptionMap[subscriptionType] ?? 0) + 1;

        // Count by country if available
        final country = user['country'] as String? ?? 'Unknown';
        final countryMap = stats['by_country'] as Map<String, int>;
        countryMap[country] = (countryMap[country] ?? 0) + 1;
      }

      return stats;
    } catch (e, stackTrace) {
      _logger.e('User statistics generation error: $e');
      state = AsyncValue.error(e, stackTrace);
      return {};
    }
  }

  Future<void> refreshStatistics() async {
    state = const AsyncValue.loading();
    await _generateUserStatistics();
  }
}

// User Search Provider
@riverpod
class UserSearch extends _$UserSearch {
  Timer? _debounceTimer;

  @override
  String build() => '';

  void updateSearchQuery(String query) {
    state = query;

    // Debounce search to avoid too many API calls
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      ref.read(userFiltersStateProvider.notifier).updateSearch(query);
      ref.read(usersListProvider.notifier).applyFilters();
    });
  }

  void clearSearch() {
    _debounceTimer?.cancel();
    state = '';
    ref.read(userFiltersStateProvider.notifier).updateSearch(null);
    ref.read(usersListProvider.notifier).applyFilters();
  }
}

// Notification Sending Provider
@riverpod
class NotificationSender extends _$NotificationSender {
  final Logger _logger = Logger();

  @override
  bool build() => false;

  Future<bool> sendNotificationToUsers({
    required String title,
    required String message,
    List<String>? userIds,
    String? userType,
  }) async {
    state = true;

    try {
      final repository = ref.read(adminRepositoryProvider);

      final result = await repository.sendNotificationToUsers(
        title: title,
        message: message,
        userIds: userIds,
        userType: userType,
      );

      final success = result.fold(
        (failure) {
          _logger.e('Failed to send notification: ${failure.message}');
          return false;
        },
        (_) {
          AnalyticsService.instance.trackEvent('admin_notification_sent', {
            'title': title,
            'user_count': userIds?.length ?? 0,
            'user_type': userType,
          });

          return true;
        },
      );

      return success;
    } catch (e) {
      _logger.e('Notification sending error: $e');
      return false;
    } finally {
      state = false;
    }
  }

  Future<bool> sendSystemAnnouncement({
    required String title,
    required String message,
    String? priority,
  }) async {
    state = true;

    try {
      final repository = ref.read(adminRepositoryProvider);

      final result = await repository.sendSystemAnnouncement(
        title: title,
        message: message,
        priority: priority,
      );

      final success = result.fold(
        (failure) {
          _logger.e('Failed to send system announcement: ${failure.message}');
          return false;
        },
        (_) {
          AnalyticsService.instance
              .trackEvent('admin_system_announcement_sent', {
            'title': title,
            'priority': priority,
          });

          return true;
        },
      );

      return success;
    } catch (e) {
      _logger.e('System announcement sending error: $e');
      return false;
    } finally {
      state = false;
    }
  }
}
