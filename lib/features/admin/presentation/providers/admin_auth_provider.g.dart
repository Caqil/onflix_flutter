// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminRemoteDataSourceHash() =>
    r'f7a60b830f78dd0210436b9802815650bb25f529';

/// See also [adminRemoteDataSource].
@ProviderFor(adminRemoteDataSource)
final adminRemoteDataSourceProvider =
    AutoDisposeProvider<AdminRemoteDataSource>.internal(
  adminRemoteDataSource,
  name: r'adminRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminRemoteDataSourceRef
    = AutoDisposeProviderRef<AdminRemoteDataSource>;
String _$adminLocalDataSourceHash() =>
    r'fbd116ec88f8ad08f7b2adde34a84577fe25b372';

/// See also [adminLocalDataSource].
@ProviderFor(adminLocalDataSource)
final adminLocalDataSourceProvider =
    AutoDisposeProvider<AdminLocalDataSource>.internal(
  adminLocalDataSource,
  name: r'adminLocalDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminLocalDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminLocalDataSourceRef = AutoDisposeProviderRef<AdminLocalDataSource>;
String _$adminRepositoryHash() => r'2db182bd0427b30555f86bb61a69408ff1ba5380';

/// See also [adminRepository].
@ProviderFor(adminRepository)
final adminRepositoryProvider = AutoDisposeProvider<AdminRepository>.internal(
  adminRepository,
  name: r'adminRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminRepositoryRef = AutoDisposeProviderRef<AdminRepository>;
String _$isAdminAuthenticatedHash() =>
    r'94358aca0ab35a13173b4b116cc7269c12949359';

/// See also [isAdminAuthenticated].
@ProviderFor(isAdminAuthenticated)
final isAdminAuthenticatedProvider = AutoDisposeProvider<bool>.internal(
  isAdminAuthenticated,
  name: r'isAdminAuthenticatedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isAdminAuthenticatedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsAdminAuthenticatedRef = AutoDisposeProviderRef<bool>;
String _$currentAdminUserHash() => r'f6717bdbcb93c4424ba3e6867b8ae71049f7691f';

/// See also [currentAdminUser].
@ProviderFor(currentAdminUser)
final currentAdminUserProvider = AutoDisposeProvider<AdminUser?>.internal(
  currentAdminUser,
  name: r'currentAdminUserProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentAdminUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentAdminUserRef = AutoDisposeProviderRef<AdminUser?>;
String _$isAdminAuthLoadingHash() =>
    r'0a9b3d7ec54c2c4b85540ab9d385bd8508fff042';

/// See also [isAdminAuthLoading].
@ProviderFor(isAdminAuthLoading)
final isAdminAuthLoadingProvider = AutoDisposeProvider<bool>.internal(
  isAdminAuthLoading,
  name: r'isAdminAuthLoadingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isAdminAuthLoadingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsAdminAuthLoadingRef = AutoDisposeProviderRef<bool>;
String _$adminAuthErrorHash() => r'276d19071260c9f7afc24eadb2eeeb02931dd56b';

/// See also [adminAuthError].
@ProviderFor(adminAuthError)
final adminAuthErrorProvider = AutoDisposeProvider<String?>.internal(
  adminAuthError,
  name: r'adminAuthErrorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminAuthErrorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminAuthErrorRef = AutoDisposeProviderRef<String?>;
String _$adminAuthStateHash() => r'4945e38e3d6f9d6e160094d25b0de2b4a8fcd7d5';

/// See also [AdminAuthState].
@ProviderFor(AdminAuthState)
final adminAuthStateProvider =
    AutoDisposeAsyncNotifierProvider<AdminAuthState, AdminUser?>.internal(
  AdminAuthState.new,
  name: r'adminAuthStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminAuthStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AdminAuthState = AutoDisposeAsyncNotifier<AdminUser?>;
String _$adminLoginFormStateHash() =>
    r'71aadaaf55948618df3bac6a6d5eaf4a57e9e7ca';

/// See also [AdminLoginFormState].
@ProviderFor(AdminLoginFormState)
final adminLoginFormStateProvider =
    AutoDisposeNotifierProvider<AdminLoginFormState, AdminLoginForm>.internal(
  AdminLoginFormState.new,
  name: r'adminLoginFormStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminLoginFormStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AdminLoginFormState = AutoDisposeNotifier<AdminLoginForm>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
