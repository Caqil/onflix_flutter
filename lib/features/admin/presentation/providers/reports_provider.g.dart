// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$reportFiltersStateHash() =>
    r'85abb33804903252790848046b5e7feb60144424';

/// See also [ReportFiltersState].
@ProviderFor(ReportFiltersState)
final reportFiltersStateProvider =
    AutoDisposeNotifierProvider<ReportFiltersState, ReportFilters>.internal(
  ReportFiltersState.new,
  name: r'reportFiltersStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reportFiltersStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ReportFiltersState = AutoDisposeNotifier<ReportFilters>;
String _$reportPaginationStateHash() =>
    r'2ef353983f69f374867cc686234c5e766225a882';

/// See also [ReportPaginationState].
@ProviderFor(ReportPaginationState)
final reportPaginationStateProvider = AutoDisposeNotifierProvider<
    ReportPaginationState, ReportPaginationParams>.internal(
  ReportPaginationState.new,
  name: r'reportPaginationStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reportPaginationStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ReportPaginationState = AutoDisposeNotifier<ReportPaginationParams>;
String _$contentReportsListHash() =>
    r'e0205cbaa3240bac068e8cedb198ba0ae25165be';

/// See also [ContentReportsList].
@ProviderFor(ContentReportsList)
final contentReportsListProvider = AutoDisposeAsyncNotifierProvider<
    ContentReportsList, PaginatedResponse<ContentReport>>.internal(
  ContentReportsList.new,
  name: r'contentReportsListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$contentReportsListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ContentReportsList
    = AutoDisposeAsyncNotifier<PaginatedResponse<ContentReport>>;
String _$contentReportDetailsHash() =>
    r'bb9f15023bd76d0adce48385b008af2357e7397a';

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

abstract class _$ContentReportDetails
    extends BuildlessAutoDisposeAsyncNotifier<ContentReport?> {
  late final String reportId;

  FutureOr<ContentReport?> build(
    String reportId,
  );
}

/// See also [ContentReportDetails].
@ProviderFor(ContentReportDetails)
const contentReportDetailsProvider = ContentReportDetailsFamily();

/// See also [ContentReportDetails].
class ContentReportDetailsFamily extends Family<AsyncValue<ContentReport?>> {
  /// See also [ContentReportDetails].
  const ContentReportDetailsFamily();

  /// See also [ContentReportDetails].
  ContentReportDetailsProvider call(
    String reportId,
  ) {
    return ContentReportDetailsProvider(
      reportId,
    );
  }

  @override
  ContentReportDetailsProvider getProviderOverride(
    covariant ContentReportDetailsProvider provider,
  ) {
    return call(
      provider.reportId,
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
  String? get name => r'contentReportDetailsProvider';
}

/// See also [ContentReportDetails].
class ContentReportDetailsProvider extends AutoDisposeAsyncNotifierProviderImpl<
    ContentReportDetails, ContentReport?> {
  /// See also [ContentReportDetails].
  ContentReportDetailsProvider(
    String reportId,
  ) : this._internal(
          () => ContentReportDetails()..reportId = reportId,
          from: contentReportDetailsProvider,
          name: r'contentReportDetailsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$contentReportDetailsHash,
          dependencies: ContentReportDetailsFamily._dependencies,
          allTransitiveDependencies:
              ContentReportDetailsFamily._allTransitiveDependencies,
          reportId: reportId,
        );

  ContentReportDetailsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.reportId,
  }) : super.internal();

  final String reportId;

  @override
  FutureOr<ContentReport?> runNotifierBuild(
    covariant ContentReportDetails notifier,
  ) {
    return notifier.build(
      reportId,
    );
  }

  @override
  Override overrideWith(ContentReportDetails Function() create) {
    return ProviderOverride(
      origin: this,
      override: ContentReportDetailsProvider._internal(
        () => create()..reportId = reportId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        reportId: reportId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ContentReportDetails, ContentReport?>
      createElement() {
    return _ContentReportDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContentReportDetailsProvider && other.reportId == reportId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, reportId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ContentReportDetailsRef
    on AutoDisposeAsyncNotifierProviderRef<ContentReport?> {
  /// The parameter `reportId` of this provider.
  String get reportId;
}

class _ContentReportDetailsProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ContentReportDetails,
        ContentReport?> with ContentReportDetailsRef {
  _ContentReportDetailsProviderElement(super.provider);

  @override
  String get reportId => (origin as ContentReportDetailsProvider).reportId;
}

String _$reportStatusUpdateHash() =>
    r'a2feda9aa878ed1f8d88bf51d809d4bea0555afc';

/// See also [ReportStatusUpdate].
@ProviderFor(ReportStatusUpdate)
final reportStatusUpdateProvider =
    AutoDisposeNotifierProvider<ReportStatusUpdate, bool>.internal(
  ReportStatusUpdate.new,
  name: r'reportStatusUpdateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reportStatusUpdateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ReportStatusUpdate = AutoDisposeNotifier<bool>;
String _$reportDeletionHash() => r'aa917556a0ecb043deeebce1684ca928abbfeb26';

/// See also [ReportDeletion].
@ProviderFor(ReportDeletion)
final reportDeletionProvider =
    AutoDisposeNotifierProvider<ReportDeletion, bool>.internal(
  ReportDeletion.new,
  name: r'reportDeletionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reportDeletionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ReportDeletion = AutoDisposeNotifier<bool>;
String _$bulkReportOperationsHash() =>
    r'86fb6ac5f9a3cea6d6f912490a08ac077ff58abb';

/// See also [BulkReportOperations].
@ProviderFor(BulkReportOperations)
final bulkReportOperationsProvider = AutoDisposeNotifierProvider<
    BulkReportOperations, BulkReportOperationState>.internal(
  BulkReportOperations.new,
  name: r'bulkReportOperationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bulkReportOperationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BulkReportOperations = AutoDisposeNotifier<BulkReportOperationState>;
String _$reportStatisticsHash() => r'8f6849509661efd0bb70f509ebeb01c2ece00862';

/// See also [ReportStatistics].
@ProviderFor(ReportStatistics)
final reportStatisticsProvider = AutoDisposeAsyncNotifierProvider<
    ReportStatistics, List<Map<String, dynamic>>>.internal(
  ReportStatistics.new,
  name: r'reportStatisticsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reportStatisticsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ReportStatistics
    = AutoDisposeAsyncNotifier<List<Map<String, dynamic>>>;
String _$reportSummaryHash() => r'cf6ce3b7eb4b15f157e6171a7c9ad4e262ee120f';

/// See also [ReportSummary].
@ProviderFor(ReportSummary)
final reportSummaryProvider = AutoDisposeAsyncNotifierProvider<ReportSummary,
    Map<String, dynamic>>.internal(
  ReportSummary.new,
  name: r'reportSummaryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reportSummaryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ReportSummary = AutoDisposeAsyncNotifier<Map<String, dynamic>>;
String _$reportSearchHash() => r'0da5e91a7da1ee067dab51344a8aac7885974c39';

/// See also [ReportSearch].
@ProviderFor(ReportSearch)
final reportSearchProvider =
    AutoDisposeNotifierProvider<ReportSearch, String>.internal(
  ReportSearch.new,
  name: r'reportSearchProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$reportSearchHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ReportSearch = AutoDisposeNotifier<String>;
String _$reportPriorityFilterHash() =>
    r'3a6baa4e4f8d3739678fa499d92ffd3c95356ec6';

/// See also [ReportPriorityFilter].
@ProviderFor(ReportPriorityFilter)
final reportPriorityFilterProvider =
    AutoDisposeNotifierProvider<ReportPriorityFilter, String?>.internal(
  ReportPriorityFilter.new,
  name: r'reportPriorityFilterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reportPriorityFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ReportPriorityFilter = AutoDisposeNotifier<String?>;
String _$reportStatusFilterHash() =>
    r'b0a4f16c465bdd4ce9ccd8b98b8452c499857e10';

/// See also [ReportStatusFilter].
@ProviderFor(ReportStatusFilter)
final reportStatusFilterProvider =
    AutoDisposeNotifierProvider<ReportStatusFilter, String?>.internal(
  ReportStatusFilter.new,
  name: r'reportStatusFilterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reportStatusFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ReportStatusFilter = AutoDisposeNotifier<String?>;
String _$reportAutoRefreshHash() => r'327499c2030bef6ab9595de3b0eca4ddd89f2f01';

/// See also [ReportAutoRefresh].
@ProviderFor(ReportAutoRefresh)
final reportAutoRefreshProvider =
    AutoDisposeNotifierProvider<ReportAutoRefresh, bool>.internal(
  ReportAutoRefresh.new,
  name: r'reportAutoRefreshProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reportAutoRefreshHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ReportAutoRefresh = AutoDisposeNotifier<bool>;
String _$reportFormStateHash() => r'4a17731f1f240968e6a96fb21c35857491d34350';

/// See also [ReportFormState].
@ProviderFor(ReportFormState)
final reportFormStateProvider =
    AutoDisposeNotifierProvider<ReportFormState, ReportForm>.internal(
  ReportFormState.new,
  name: r'reportFormStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reportFormStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ReportFormState = AutoDisposeNotifier<ReportForm>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
