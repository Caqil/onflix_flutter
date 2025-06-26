// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$connectivityStreamHash() =>
    r'2c952c12db3f0711c598e7de7debba4b52894e04';

/// See also [connectivityStream].
@ProviderFor(connectivityStream)
final connectivityStreamProvider =
    AutoDisposeStreamProvider<ConnectivityResult>.internal(
  connectivityStream,
  name: r'connectivityStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$connectivityStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConnectivityStreamRef
    = AutoDisposeStreamProviderRef<ConnectivityResult>;
String _$connectionHelpersHash() => r'8df5895b0cf2d91e132167f9ba88a8c59decdba3';

/// See also [connectionHelpers].
@ProviderFor(connectionHelpers)
final connectionHelpersProvider =
    AutoDisposeProvider<ConnectionHelpers>.internal(
  connectionHelpers,
  name: r'connectionHelpersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$connectionHelpersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConnectionHelpersRef = AutoDisposeProviderRef<ConnectionHelpers>;
String _$connectivityStateHash() => r'a75977871054668553932904a77fb580ea746976';

/// See also [ConnectivityState].
@ProviderFor(ConnectivityState)
final connectivityStateProvider = AutoDisposeAsyncNotifierProvider<
    ConnectivityState, ConnectivityInfo>.internal(
  ConnectivityState.new,
  name: r'connectivityStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$connectivityStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ConnectivityState = AutoDisposeAsyncNotifier<ConnectivityInfo>;
String _$networkPreferencesHash() =>
    r'546c7c9eb1eea6f25aa0230b6d7519ce4fb82545';

/// See also [NetworkPreferences].
@ProviderFor(NetworkPreferences)
final networkPreferencesProvider = AutoDisposeAsyncNotifierProvider<
    NetworkPreferences, NetworkPreferencesState>.internal(
  NetworkPreferences.new,
  name: r'networkPreferencesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$networkPreferencesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NetworkPreferences
    = AutoDisposeAsyncNotifier<NetworkPreferencesState>;
String _$bandwidthMonitorHash() => r'617542822a99ff41e4ab9c8954e4bd9ba4240063';

/// See also [BandwidthMonitor].
@ProviderFor(BandwidthMonitor)
final bandwidthMonitorProvider =
    AutoDisposeNotifierProvider<BandwidthMonitor, BandwidthInfo>.internal(
  BandwidthMonitor.new,
  name: r'bandwidthMonitorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bandwidthMonitorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BandwidthMonitor = AutoDisposeNotifier<BandwidthInfo>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
