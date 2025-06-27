// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_management_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userFiltersStateHash() => r'2f6431d30892e7488ab280bfb10745bc5bc55fd4';

/// See also [UserFiltersState].
@ProviderFor(UserFiltersState)
final userFiltersStateProvider =
    AutoDisposeNotifierProvider<UserFiltersState, UserFilters>.internal(
  UserFiltersState.new,
  name: r'userFiltersStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userFiltersStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UserFiltersState = AutoDisposeNotifier<UserFilters>;
String _$userPaginationStateHash() =>
    r'26c83a087f2f85814971330f368beb6d301c1148';

/// See also [UserPaginationState].
@ProviderFor(UserPaginationState)
final userPaginationStateProvider = AutoDisposeNotifierProvider<
    UserPaginationState, UserPaginationParams>.internal(
  UserPaginationState.new,
  name: r'userPaginationStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userPaginationStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UserPaginationState = AutoDisposeNotifier<UserPaginationParams>;
String _$usersListHash() => r'd23867d5a60eafdb7699d744ceaaa5f29f56931e';

/// See also [UsersList].
@ProviderFor(UsersList)
final usersListProvider = AutoDisposeAsyncNotifierProvider<UsersList,
    PaginatedResponse<Map<String, dynamic>>>.internal(
  UsersList.new,
  name: r'usersListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$usersListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UsersList
    = AutoDisposeAsyncNotifier<PaginatedResponse<Map<String, dynamic>>>;
String _$userDetailsHash() => r'f85b09c1ba94c2bfe6bb607486ca0d960c123582';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$UserDetails
    extends BuildlessAutoDisposeAsyncNotifier<Map<String, dynamic>?> {
  late final String userId;

  FutureOr<Map<String, dynamic>?> build(
    String userId,
  );
}

/// See also [UserDetails].
@ProviderFor(UserDetails)
const userDetailsProvider = UserDetailsFamily();

/// See also [UserDetails].
class UserDetailsFamily extends Family<AsyncValue<Map<String, dynamic>?>> {
  /// See also [UserDetails].
  const UserDetailsFamily();

  /// See also [UserDetails].
  UserDetailsProvider call(
    String userId,
  ) {
    return UserDetailsProvider(
      userId,
    );
  }

  @override
  UserDetailsProvider getProviderOverride(
    covariant UserDetailsProvider provider,
  ) {
    return call(
      provider.userId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'userDetailsProvider';
}

/// See also [UserDetails].
class UserDetailsProvider extends AutoDisposeAsyncNotifierProviderImpl<
    UserDetails, Map<String, dynamic>?> {
  /// See also [UserDetails].
  UserDetailsProvider(
    String userId,
  ) : this._internal(
          () => UserDetails()..userId = userId,
          from: userDetailsProvider,
          name: r'userDetailsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$userDetailsHash,
          dependencies: UserDetailsFamily._dependencies,
          allTransitiveDependencies:
              UserDetailsFamily._allTransitiveDependencies,
          userId: userId,
        );

  UserDetailsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  FutureOr<Map<String, dynamic>?> runNotifierBuild(
    covariant UserDetails notifier,
  ) {
    return notifier.build(
      userId,
    );
  }

  @override
  Override overrideWith(UserDetails Function() create) {
    return ProviderOverride(
      origin: this,
      override: UserDetailsProvider._internal(
        () => create()..userId = userId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<UserDetails, Map<String, dynamic>?>
      createElement() {
    return _UserDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserDetailsProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserDetailsRef
    on AutoDisposeAsyncNotifierProviderRef<Map<String, dynamic>?> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _UserDetailsProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<UserDetails,
        Map<String, dynamic>?> with UserDetailsRef {
  _UserDetailsProviderElement(super.provider);

  @override
  String get userId => (origin as UserDetailsProvider).userId;
}

String _$userStatusUpdateHash() => r'7b98e160949c0939c2bd35b143643c900ba67c13';

/// See also [UserStatusUpdate].
@ProviderFor(UserStatusUpdate)
final userStatusUpdateProvider =
    AutoDisposeNotifierProvider<UserStatusUpdate, bool>.internal(
  UserStatusUpdate.new,
  name: r'userStatusUpdateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userStatusUpdateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UserStatusUpdate = AutoDisposeNotifier<bool>;
String _$userDeletionHash() => r'b805ff739f637173562a38e5539edb7dcb4ec24f';

/// See also [UserDeletion].
@ProviderFor(UserDeletion)
final userDeletionProvider =
    AutoDisposeNotifierProvider<UserDeletion, bool>.internal(
  UserDeletion.new,
  name: r'userDeletionProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$userDeletionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UserDeletion = AutoDisposeNotifier<bool>;
String _$userPaymentHistoryHash() =>
    r'487c21db6e5464d1155967d3006f2adf01865207';

abstract class _$UserPaymentHistory extends BuildlessAutoDisposeAsyncNotifier<
    PaginatedResponse<PaymentHistoryModel>> {
  late final String userId;

  FutureOr<PaginatedResponse<PaymentHistoryModel>> build(
    String userId,
  );
}

/// See also [UserPaymentHistory].
@ProviderFor(UserPaymentHistory)
const userPaymentHistoryProvider = UserPaymentHistoryFamily();

/// See also [UserPaymentHistory].
class UserPaymentHistoryFamily
    extends Family<AsyncValue<PaginatedResponse<PaymentHistoryModel>>> {
  /// See also [UserPaymentHistory].
  const UserPaymentHistoryFamily();

  /// See also [UserPaymentHistory].
  UserPaymentHistoryProvider call(
    String userId,
  ) {
    return UserPaymentHistoryProvider(
      userId,
    );
  }

  @override
  UserPaymentHistoryProvider getProviderOverride(
    covariant UserPaymentHistoryProvider provider,
  ) {
    return call(
      provider.userId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'userPaymentHistoryProvider';
}

/// See also [UserPaymentHistory].
class UserPaymentHistoryProvider extends AutoDisposeAsyncNotifierProviderImpl<
    UserPaymentHistory, PaginatedResponse<PaymentHistoryModel>> {
  /// See also [UserPaymentHistory].
  UserPaymentHistoryProvider(
    String userId,
  ) : this._internal(
          () => UserPaymentHistory()..userId = userId,
          from: userPaymentHistoryProvider,
          name: r'userPaymentHistoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$userPaymentHistoryHash,
          dependencies: UserPaymentHistoryFamily._dependencies,
          allTransitiveDependencies:
              UserPaymentHistoryFamily._allTransitiveDependencies,
          userId: userId,
        );

  UserPaymentHistoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  FutureOr<PaginatedResponse<PaymentHistoryModel>> runNotifierBuild(
    covariant UserPaymentHistory notifier,
  ) {
    return notifier.build(
      userId,
    );
  }

  @override
  Override overrideWith(UserPaymentHistory Function() create) {
    return ProviderOverride(
      origin: this,
      override: UserPaymentHistoryProvider._internal(
        () => create()..userId = userId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<UserPaymentHistory,
      PaginatedResponse<PaymentHistoryModel>> createElement() {
    return _UserPaymentHistoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserPaymentHistoryProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserPaymentHistoryRef on AutoDisposeAsyncNotifierProviderRef<
    PaginatedResponse<PaymentHistoryModel>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _UserPaymentHistoryProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<UserPaymentHistory,
        PaginatedResponse<PaymentHistoryModel>> with UserPaymentHistoryRef {
  _UserPaymentHistoryProviderElement(super.provider);

  @override
  String get userId => (origin as UserPaymentHistoryProvider).userId;
}

String _$paymentRefundHash() => r'5f40666610391cef687db0d32bb34d6932018b3d';

/// See also [PaymentRefund].
@ProviderFor(PaymentRefund)
final paymentRefundProvider =
    AutoDisposeNotifierProvider<PaymentRefund, bool>.internal(
  PaymentRefund.new,
  name: r'paymentRefundProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$paymentRefundHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PaymentRefund = AutoDisposeNotifier<bool>;
String _$bulkUserOperationsHash() =>
    r'f7ae7fd483d884d603e9abef8e5e3a7d978e39b0';

/// See also [BulkUserOperations].
@ProviderFor(BulkUserOperations)
final bulkUserOperationsProvider = AutoDisposeNotifierProvider<
    BulkUserOperations, BulkUserOperationState>.internal(
  BulkUserOperations.new,
  name: r'bulkUserOperationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bulkUserOperationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BulkUserOperations = AutoDisposeNotifier<BulkUserOperationState>;
String _$userStatisticsHash() => r'2d61fabbc6bbf5bc520761cd342f8329832afe84';

/// See also [UserStatistics].
@ProviderFor(UserStatistics)
final userStatisticsProvider = AutoDisposeAsyncNotifierProvider<UserStatistics,
    Map<String, dynamic>>.internal(
  UserStatistics.new,
  name: r'userStatisticsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userStatisticsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UserStatistics = AutoDisposeAsyncNotifier<Map<String, dynamic>>;
String _$userSearchHash() => r'4cb722bc8bc1cf210d562e777c5d0fa144cc76de';

/// See also [UserSearch].
@ProviderFor(UserSearch)
final userSearchProvider =
    AutoDisposeNotifierProvider<UserSearch, String>.internal(
  UserSearch.new,
  name: r'userSearchProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$userSearchHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UserSearch = AutoDisposeNotifier<String>;
String _$notificationSenderHash() =>
    r'6c474167da62d91e3d9e8706f6c7a7eef533dee7';

/// See also [NotificationSender].
@ProviderFor(NotificationSender)
final notificationSenderProvider =
    AutoDisposeNotifierProvider<NotificationSender, bool>.internal(
  NotificationSender.new,
  name: r'notificationSenderProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationSenderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NotificationSender = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
