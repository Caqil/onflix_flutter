// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_management_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contentFiltersStateHash() =>
    r'57c95d6d71664b553cb5d7af63845d2434d28777';

/// See also [ContentFiltersState].
@ProviderFor(ContentFiltersState)
final contentFiltersStateProvider =
    AutoDisposeNotifierProvider<ContentFiltersState, ContentFilters>.internal(
  ContentFiltersState.new,
  name: r'contentFiltersStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$contentFiltersStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ContentFiltersState = AutoDisposeNotifier<ContentFilters>;
String _$contentPaginationStateHash() =>
    r'3b95931c8a7d43e3170a8b7ea74be3184e3740ef';

/// See also [ContentPaginationState].
@ProviderFor(ContentPaginationState)
final contentPaginationStateProvider = AutoDisposeNotifierProvider<
    ContentPaginationState, ContentPaginationParams>.internal(
  ContentPaginationState.new,
  name: r'contentPaginationStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$contentPaginationStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ContentPaginationState = AutoDisposeNotifier<ContentPaginationParams>;
String _$contentListHash() => r'05d87c9e3827ff018587c4ced8f84d05799e1a32';

/// See also [ContentList].
@ProviderFor(ContentList)
final contentListProvider = AutoDisposeAsyncNotifierProvider<ContentList,
    PaginatedResponse<Map<String, dynamic>>>.internal(
  ContentList.new,
  name: r'contentListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$contentListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ContentList
    = AutoDisposeAsyncNotifier<PaginatedResponse<Map<String, dynamic>>>;
String _$contentDetailsHash() => r'db82c79539f74d5a328133b498882d99e9af49ee';

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

abstract class _$ContentDetails
    extends BuildlessAutoDisposeAsyncNotifier<Map<String, dynamic>?> {
  late final String contentId;

  FutureOr<Map<String, dynamic>?> build(
    String contentId,
  );
}

/// See also [ContentDetails].
@ProviderFor(ContentDetails)
const contentDetailsProvider = ContentDetailsFamily();

/// See also [ContentDetails].
class ContentDetailsFamily extends Family<AsyncValue<Map<String, dynamic>?>> {
  /// See also [ContentDetails].
  const ContentDetailsFamily();

  /// See also [ContentDetails].
  ContentDetailsProvider call(
    String contentId,
  ) {
    return ContentDetailsProvider(
      contentId,
    );
  }

  @override
  ContentDetailsProvider getProviderOverride(
    covariant ContentDetailsProvider provider,
  ) {
    return call(
      provider.contentId,
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
  String? get name => r'contentDetailsProvider';
}

/// See also [ContentDetails].
class ContentDetailsProvider extends AutoDisposeAsyncNotifierProviderImpl<
    ContentDetails, Map<String, dynamic>?> {
  /// See also [ContentDetails].
  ContentDetailsProvider(
    String contentId,
  ) : this._internal(
          () => ContentDetails()..contentId = contentId,
          from: contentDetailsProvider,
          name: r'contentDetailsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$contentDetailsHash,
          dependencies: ContentDetailsFamily._dependencies,
          allTransitiveDependencies:
              ContentDetailsFamily._allTransitiveDependencies,
          contentId: contentId,
        );

  ContentDetailsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contentId,
  }) : super.internal();

  final String contentId;

  @override
  FutureOr<Map<String, dynamic>?> runNotifierBuild(
    covariant ContentDetails notifier,
  ) {
    return notifier.build(
      contentId,
    );
  }

  @override
  Override overrideWith(ContentDetails Function() create) {
    return ProviderOverride(
      origin: this,
      override: ContentDetailsProvider._internal(
        () => create()..contentId = contentId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        contentId: contentId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ContentDetails, Map<String, dynamic>?>
      createElement() {
    return _ContentDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContentDetailsProvider && other.contentId == contentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, contentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ContentDetailsRef
    on AutoDisposeAsyncNotifierProviderRef<Map<String, dynamic>?> {
  /// The parameter `contentId` of this provider.
  String get contentId;
}

class _ContentDetailsProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ContentDetails,
        Map<String, dynamic>?> with ContentDetailsRef {
  _ContentDetailsProviderElement(super.provider);

  @override
  String get contentId => (origin as ContentDetailsProvider).contentId;
}

String _$contentStatusUpdateHash() =>
    r'59a924e9d8c4344aa3bbd4e85a48db5577985ffb';

/// See also [ContentStatusUpdate].
@ProviderFor(ContentStatusUpdate)
final contentStatusUpdateProvider =
    AutoDisposeNotifierProvider<ContentStatusUpdate, bool>.internal(
  ContentStatusUpdate.new,
  name: r'contentStatusUpdateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$contentStatusUpdateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ContentStatusUpdate = AutoDisposeNotifier<bool>;
String _$contentDeletionHash() => r'43e8794b7a6b001a127cd39f92089a341d0163c9';

/// See also [ContentDeletion].
@ProviderFor(ContentDeletion)
final contentDeletionProvider =
    AutoDisposeNotifierProvider<ContentDeletion, bool>.internal(
  ContentDeletion.new,
  name: r'contentDeletionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$contentDeletionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ContentDeletion = AutoDisposeNotifier<bool>;
String _$bulkContentOperationsHash() =>
    r'2f4e4d4d07378bde988947ffe6a62015097d9c95';

/// See also [BulkContentOperations].
@ProviderFor(BulkContentOperations)
final bulkContentOperationsProvider = AutoDisposeNotifierProvider<
    BulkContentOperations, BulkOperationState>.internal(
  BulkContentOperations.new,
  name: r'bulkContentOperationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bulkContentOperationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BulkContentOperations = AutoDisposeNotifier<BulkOperationState>;
String _$contentStatisticsHash() => r'7e2193fbb1ef4920bc93bf3c81120c50f06af45f';

/// See also [ContentStatistics].
@ProviderFor(ContentStatistics)
final contentStatisticsProvider = AutoDisposeAsyncNotifierProvider<
    ContentStatistics, Map<String, dynamic>>.internal(
  ContentStatistics.new,
  name: r'contentStatisticsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$contentStatisticsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ContentStatistics = AutoDisposeAsyncNotifier<Map<String, dynamic>>;
String _$contentSearchHash() => r'd4f3c60c047a653464f7580ac8fc1be9fe008931';

/// See also [ContentSearch].
@ProviderFor(ContentSearch)
final contentSearchProvider =
    AutoDisposeNotifierProvider<ContentSearch, String>.internal(
  ContentSearch.new,
  name: r'contentSearchProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$contentSearchHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ContentSearch = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
