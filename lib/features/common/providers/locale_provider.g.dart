// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$supportedLocalesHash() => r'5399d467bb472ede791827f9cf73eeb99061767c';

/// See also [supportedLocales].
@ProviderFor(supportedLocales)
final supportedLocalesProvider = AutoDisposeProvider<List<Locale>>.internal(
  supportedLocales,
  name: r'supportedLocalesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$supportedLocalesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SupportedLocalesRef = AutoDisposeProviderRef<List<Locale>>;
String _$localeDetailsHash() => r'7fc189f2b0784d873d7991725ed6b079cdcbe4b1';

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

/// See also [localeDetails].
@ProviderFor(localeDetails)
const localeDetailsProvider = LocaleDetailsFamily();

/// See also [localeDetails].
class LocaleDetailsFamily extends Family<LocaleDetails> {
  /// See also [localeDetails].
  const LocaleDetailsFamily();

  /// See also [localeDetails].
  LocaleDetailsProvider call(
    Locale locale,
  ) {
    return LocaleDetailsProvider(
      locale,
    );
  }

  @override
  LocaleDetailsProvider getProviderOverride(
    covariant LocaleDetailsProvider provider,
  ) {
    return call(
      provider.locale,
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
  String? get name => r'localeDetailsProvider';
}

/// See also [localeDetails].
class LocaleDetailsProvider extends AutoDisposeProvider<LocaleDetails> {
  /// See also [localeDetails].
  LocaleDetailsProvider(
    Locale locale,
  ) : this._internal(
          (ref) => localeDetails(
            ref as LocaleDetailsRef,
            locale,
          ),
          from: localeDetailsProvider,
          name: r'localeDetailsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$localeDetailsHash,
          dependencies: LocaleDetailsFamily._dependencies,
          allTransitiveDependencies:
              LocaleDetailsFamily._allTransitiveDependencies,
          locale: locale,
        );

  LocaleDetailsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.locale,
  }) : super.internal();

  final Locale locale;

  @override
  Override overrideWith(
    LocaleDetails Function(LocaleDetailsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LocaleDetailsProvider._internal(
        (ref) => create(ref as LocaleDetailsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        locale: locale,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<LocaleDetails> createElement() {
    return _LocaleDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LocaleDetailsProvider && other.locale == locale;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, locale.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LocaleDetailsRef on AutoDisposeProviderRef<LocaleDetails> {
  /// The parameter `locale` of this provider.
  Locale get locale;
}

class _LocaleDetailsProviderElement
    extends AutoDisposeProviderElement<LocaleDetails> with LocaleDetailsRef {
  _LocaleDetailsProviderElement(super.provider);

  @override
  Locale get locale => (origin as LocaleDetailsProvider).locale;
}

String _$currentLocaleDetailsHash() =>
    r'ef3c1c605394a7cb392c5cc19ae90dcfdecff5a7';

/// See also [currentLocaleDetails].
@ProviderFor(currentLocaleDetails)
final currentLocaleDetailsProvider =
    AutoDisposeFutureProvider<LocaleDetails>.internal(
  currentLocaleDetails,
  name: r'currentLocaleDetailsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentLocaleDetailsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentLocaleDetailsRef = AutoDisposeFutureProviderRef<LocaleDetails>;
String _$availableRegionsHash() => r'336c13f1c277fd9b0bce36065ad28c0d03227bd7';

/// See also [availableRegions].
@ProviderFor(availableRegions)
final availableRegionsProvider = AutoDisposeProvider<List<RegionInfo>>.internal(
  availableRegions,
  name: r'availableRegionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$availableRegionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AvailableRegionsRef = AutoDisposeProviderRef<List<RegionInfo>>;
String _$localeHelpersHash() => r'ff39702fcc2aa0eeaa9abf10ce642d71b16b8bb7';

/// See also [localeHelpers].
@ProviderFor(localeHelpers)
final localeHelpersProvider = AutoDisposeProvider<LocaleHelpers>.internal(
  localeHelpers,
  name: r'localeHelpersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$localeHelpersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocaleHelpersRef = AutoDisposeProviderRef<LocaleHelpers>;
String _$currentLocaleHash() => r'7270f94e56afb3329edbd4f0a18250556174e9ab';

/// See also [CurrentLocale].
@ProviderFor(CurrentLocale)
final currentLocaleProvider =
    AutoDisposeAsyncNotifierProvider<CurrentLocale, Locale>.internal(
  CurrentLocale.new,
  name: r'currentLocaleProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentLocaleHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CurrentLocale = AutoDisposeAsyncNotifier<Locale>;
String _$languagePreferencesHash() =>
    r'e3a170417725f07651723b59ecb0fab8ffe8917e';

/// See also [LanguagePreferences].
@ProviderFor(LanguagePreferences)
final languagePreferencesProvider = AutoDisposeAsyncNotifierProvider<
    LanguagePreferences, LanguagePreferencesState>.internal(
  LanguagePreferences.new,
  name: r'languagePreferencesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$languagePreferencesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LanguagePreferences
    = AutoDisposeAsyncNotifier<LanguagePreferencesState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
