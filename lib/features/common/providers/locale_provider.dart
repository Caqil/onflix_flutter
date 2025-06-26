import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/services/storage_service.dart';
import '../../../shared/services/analytics_service.dart';

part 'locale_provider.g.dart';

// Supported locales provider
@riverpod
List<Locale> supportedLocales(Ref ref) {
  return AppConstants.supportedLanguages
      .map((lang) => Locale(lang['code'] as String))
      .toList();
}

// Current locale provider
@riverpod
class CurrentLocale extends _$CurrentLocale {
  @override
  Future<Locale> build() async {
    return await _loadSavedLocale();
  }

  // Load saved locale from storage
  Future<Locale> _loadSavedLocale() async {
    try {
      final storageService = StorageService.instance;
      final savedLocaleCode = await storageService.getSetting<String>(
        StorageKeys.locale,
      );

      if (savedLocaleCode != null) {
        // Validate if the saved locale is supported
        final supportedLanguages = AppConstants.supportedLanguages;
        final isSupported =
            supportedLanguages.any((lang) => lang['code'] == savedLocaleCode);

        if (isSupported) {
          return Locale(savedLocaleCode);
        }
      }

      // Fallback to device locale or default
      return _getDeviceLocaleOrDefault();
    } catch (e) {
      // Fallback to device locale or default if loading fails
      return _getDeviceLocaleOrDefault();
    }
  }

  // Get device locale or fallback to default
  Locale _getDeviceLocaleOrDefault() {
    final deviceLocale = PlatformDispatcher.instance.locale;
    final supportedLanguages = AppConstants.supportedLanguages;

    // Check if device locale is supported
    final isDeviceLocaleSupported = supportedLanguages
        .any((lang) => lang['code'] == deviceLocale.languageCode);

    if (isDeviceLocaleSupported) {
      return Locale(deviceLocale.languageCode);
    }

    // Default to English if device locale is not supported
    return const Locale('en');
  }

  // Change locale
  Future<void> changeLocale(Locale newLocale) async {
    try {
      final storageService = StorageService.instance;

      // Save to storage
      await storageService.setSetting(
          StorageKeys.locale, newLocale.languageCode);

      // Update state
      state = AsyncValue.data(newLocale);

      // Track analytics
      final analyticsService = AnalyticsService.instance;
      analyticsService.trackEvent('locale_changed', {
        'from_locale': state.value?.languageCode ?? 'unknown',
        'to_locale': newLocale.languageCode,
      });
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Reset to device locale
  Future<void> resetToDeviceLocale() async {
    final deviceLocale = _getDeviceLocaleOrDefault();
    await changeLocale(deviceLocale);
  }

  // Reset to default locale
  Future<void> resetToDefault() async {
    await changeLocale(const Locale('en'));
  }
}

// Locale details provider
@riverpod
LocaleDetails localeDetails(Ref ref, Locale locale) {
  final supportedLanguages = AppConstants.supportedLanguages;
  final langData = supportedLanguages.firstWhere(
    (lang) => lang['code'] == locale.languageCode,
    orElse: () => supportedLanguages.first,
  );

  return LocaleDetails(
    locale: locale,
    name: langData['name'] as String,
    nativeName: langData['nativeName'] as String,
    code: langData['code'] as String,
  );
}

// Current locale details provider
@riverpod
Future<LocaleDetails> currentLocaleDetails(Ref ref) async {
  final currentLocale = await ref.watch(currentLocaleProvider.future);
  return ref.watch(localeDetailsProvider(currentLocale));
}

// Language preferences provider
@riverpod
class LanguagePreferences extends _$LanguagePreferences {
  @override
  Future<LanguagePreferencesState> build() async {
    return await _loadLanguagePreferences();
  }

  Future<LanguagePreferencesState> _loadLanguagePreferences() async {
    try {
      final storageService = StorageService.instance;

      final preferredAudioLanguage = await storageService.getSetting<String>(
        StorageKeys.preferredAudioLanguage,
        defaultValue: 'en',
      );

      final preferredSubtitleLanguage = await storageService.getSetting<String>(
        StorageKeys.preferredSubtitleLanguage,
        defaultValue: 'en',
      );

      final contentLanguagePreference = await storageService.getSetting<String>(
        StorageKeys.contentLanguagePreference,
        defaultValue: 'en',
      );

      final regionPreference = await storageService.getSetting<String>(
        StorageKeys.regionPreference,
        defaultValue: 'US',
      );

      return LanguagePreferencesState(
        preferredAudioLanguage: preferredAudioLanguage ?? 'en',
        preferredSubtitleLanguage: preferredSubtitleLanguage ?? 'en',
        contentLanguagePreference: contentLanguagePreference ?? 'en',
        regionPreference: regionPreference ?? 'US',
      );
    } catch (e) {
      // Return default preferences if loading fails
      return const LanguagePreferencesState(
        preferredAudioLanguage: 'en',
        preferredSubtitleLanguage: 'en',
        contentLanguagePreference: 'en',
        regionPreference: 'US',
      );
    }
  }

  // Update preferred audio language
  Future<void> updatePreferredAudioLanguage(String languageCode) async {
    try {
      final storageService = StorageService.instance;
      await storageService.setSetting(
        StorageKeys.preferredAudioLanguage,
        languageCode,
      );

      final currentState = state.value;
      if (currentState != null) {
        state = AsyncValue.data(
          currentState.copyWith(preferredAudioLanguage: languageCode),
        );
      }

      // Track analytics
      final analyticsService = AnalyticsService.instance;
      analyticsService.trackEvent('audio_language_changed', {
        'language_code': languageCode,
      });
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Update preferred subtitle language
  Future<void> updatePreferredSubtitleLanguage(String languageCode) async {
    try {
      final storageService = StorageService.instance;
      await storageService.setSetting(
        StorageKeys.preferredSubtitleLanguage,
        languageCode,
      );

      final currentState = state.value;
      if (currentState != null) {
        state = AsyncValue.data(
          currentState.copyWith(preferredSubtitleLanguage: languageCode),
        );
      }

      // Track analytics
      final analyticsService = AnalyticsService.instance;
      analyticsService.trackEvent('subtitle_language_changed', {
        'language_code': languageCode,
      });
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Update content language preference
  Future<void> updateContentLanguagePreference(String languageCode) async {
    try {
      final storageService = StorageService.instance;
      await storageService.setSetting(
        StorageKeys.contentLanguagePreference,
        languageCode,
      );

      final currentState = state.value;
      if (currentState != null) {
        state = AsyncValue.data(
          currentState.copyWith(contentLanguagePreference: languageCode),
        );
      }

      // Track analytics
      final analyticsService = AnalyticsService.instance;
      analyticsService.trackEvent('content_language_changed', {
        'language_code': languageCode,
      });
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Update region preference
  Future<void> updateRegionPreference(String regionCode) async {
    try {
      final storageService = StorageService.instance;
      await storageService.setSetting(
        StorageKeys.regionPreference,
        regionCode,
      );

      final currentState = state.value;
      if (currentState != null) {
        state = AsyncValue.data(
          currentState.copyWith(regionPreference: regionCode),
        );
      }

      // Track analytics
      final analyticsService = AnalyticsService.instance;
      analyticsService.trackEvent('region_changed', {
        'region_code': regionCode,
      });
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Update all preferences at once
  Future<void> updateAllPreferences({
    String? preferredAudioLanguage,
    String? preferredSubtitleLanguage,
    String? contentLanguagePreference,
    String? regionPreference,
  }) async {
    try {
      final storageService = StorageService.instance;
      final currentState = state.value;

      if (currentState == null) return;

      var updatedState = currentState;

      if (preferredAudioLanguage != null) {
        await storageService.setSetting(
          StorageKeys.preferredAudioLanguage,
          preferredAudioLanguage,
        );
        updatedState = updatedState.copyWith(
          preferredAudioLanguage: preferredAudioLanguage,
        );
      }

      if (preferredSubtitleLanguage != null) {
        await storageService.setSetting(
          StorageKeys.preferredSubtitleLanguage,
          preferredSubtitleLanguage,
        );
        updatedState = updatedState.copyWith(
          preferredSubtitleLanguage: preferredSubtitleLanguage,
        );
      }

      if (contentLanguagePreference != null) {
        await storageService.setSetting(
          StorageKeys.contentLanguagePreference,
          contentLanguagePreference,
        );
        updatedState = updatedState.copyWith(
          contentLanguagePreference: contentLanguagePreference,
        );
      }

      if (regionPreference != null) {
        await storageService.setSetting(
          StorageKeys.regionPreference,
          regionPreference,
        );
        updatedState = updatedState.copyWith(
          regionPreference: regionPreference,
        );
      }

      state = AsyncValue.data(updatedState);

      // Track analytics
      final analyticsService = AnalyticsService.instance;
      analyticsService.trackEvent('language_preferences_updated', {
        'audio_language': preferredAudioLanguage,
        'subtitle_language': preferredSubtitleLanguage,
        'content_language': contentLanguagePreference,
        'region': regionPreference,
      });
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Reset to defaults
  Future<void> resetToDefaults() async {
    await updateAllPreferences(
      preferredAudioLanguage: 'en',
      preferredSubtitleLanguage: 'en',
      contentLanguagePreference: 'en',
      regionPreference: 'US',
    );
  }
}

// Available regions provider
@riverpod
List<RegionInfo> availableRegions(Ref ref) {
  return [
    const RegionInfo(code: 'US', name: 'United States', flag: '🇺🇸'),
    const RegionInfo(code: 'GB', name: 'United Kingdom', flag: '🇬🇧'),
    const RegionInfo(code: 'CA', name: 'Canada', flag: '🇨🇦'),
    const RegionInfo(code: 'AU', name: 'Australia', flag: '🇦🇺'),
    const RegionInfo(code: 'DE', name: 'Germany', flag: '🇩🇪'),
    const RegionInfo(code: 'FR', name: 'France', flag: '🇫🇷'),
    const RegionInfo(code: 'ES', name: 'Spain', flag: '🇪🇸'),
    const RegionInfo(code: 'IT', name: 'Italy', flag: '🇮🇹'),
    const RegionInfo(code: 'JP', name: 'Japan', flag: '🇯🇵'),
    const RegionInfo(code: 'KR', name: 'South Korea', flag: '🇰🇷'),
    const RegionInfo(code: 'CN', name: 'China', flag: '🇨🇳'),
    const RegionInfo(code: 'IN', name: 'India', flag: '🇮🇳'),
    const RegionInfo(code: 'BR', name: 'Brazil', flag: '🇧🇷'),
    const RegionInfo(code: 'MX', name: 'Mexico', flag: '🇲🇽'),
    const RegionInfo(code: 'RU', name: 'Russia', flag: '🇷🇺'),
  ];
}

// Locale helper functions provider
@riverpod
LocaleHelpers localeHelpers(Ref ref) {
  return LocaleHelpers();
}

// Models
class LocaleDetails {
  final Locale locale;
  final String name;
  final String nativeName;
  final String code;

  const LocaleDetails({
    required this.locale,
    required this.name,
    required this.nativeName,
    required this.code,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocaleDetails &&
          runtimeType == other.runtimeType &&
          locale == other.locale &&
          name == other.name &&
          nativeName == other.nativeName &&
          code == other.code;

  @override
  int get hashCode =>
      locale.hashCode ^ name.hashCode ^ nativeName.hashCode ^ code.hashCode;

  @override
  String toString() {
    return 'LocaleDetails(locale: $locale, name: $name, nativeName: $nativeName, code: $code)';
  }
}

class LanguagePreferencesState {
  final String preferredAudioLanguage;
  final String preferredSubtitleLanguage;
  final String contentLanguagePreference;
  final String regionPreference;

  const LanguagePreferencesState({
    required this.preferredAudioLanguage,
    required this.preferredSubtitleLanguage,
    required this.contentLanguagePreference,
    required this.regionPreference,
  });

  LanguagePreferencesState copyWith({
    String? preferredAudioLanguage,
    String? preferredSubtitleLanguage,
    String? contentLanguagePreference,
    String? regionPreference,
  }) {
    return LanguagePreferencesState(
      preferredAudioLanguage:
          preferredAudioLanguage ?? this.preferredAudioLanguage,
      preferredSubtitleLanguage:
          preferredSubtitleLanguage ?? this.preferredSubtitleLanguage,
      contentLanguagePreference:
          contentLanguagePreference ?? this.contentLanguagePreference,
      regionPreference: regionPreference ?? this.regionPreference,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanguagePreferencesState &&
          runtimeType == other.runtimeType &&
          preferredAudioLanguage == other.preferredAudioLanguage &&
          preferredSubtitleLanguage == other.preferredSubtitleLanguage &&
          contentLanguagePreference == other.contentLanguagePreference &&
          regionPreference == other.regionPreference;

  @override
  int get hashCode =>
      preferredAudioLanguage.hashCode ^
      preferredSubtitleLanguage.hashCode ^
      contentLanguagePreference.hashCode ^
      regionPreference.hashCode;

  @override
  String toString() {
    return 'LanguagePreferencesState(preferredAudioLanguage: $preferredAudioLanguage, preferredSubtitleLanguage: $preferredSubtitleLanguage, contentLanguagePreference: $contentLanguagePreference, regionPreference: $regionPreference)';
  }
}

class RegionInfo {
  final String code;
  final String name;
  final String flag;

  const RegionInfo({
    required this.code,
    required this.name,
    required this.flag,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegionInfo &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          name == other.name &&
          flag == other.flag;

  @override
  int get hashCode => code.hashCode ^ name.hashCode ^ flag.hashCode;

  @override
  String toString() {
    return 'RegionInfo(code: $code, name: $name, flag: $flag)';
  }
}

// Helper class for locale-related utilities
class LocaleHelpers {
  // Get language name from code
  String getLanguageName(String languageCode) {
    final supportedLanguages = AppConstants.supportedLanguages;
    final langData = supportedLanguages.firstWhere(
      (lang) => lang['code'] == languageCode,
      orElse: () => {'name': 'Unknown'},
    );
    return langData['name'] as String;
  }

  // Get native language name from code
  String getNativeLanguageName(String languageCode) {
    final supportedLanguages = AppConstants.supportedLanguages;
    final langData = supportedLanguages.firstWhere(
      (lang) => lang['code'] == languageCode,
      orElse: () => {'nativeName': 'Unknown'},
    );
    return langData['nativeName'] as String;
  }

  // Check if locale is RTL
  bool isRTL(Locale locale) {
    const rtlLanguages = ['ar', 'he', 'fa', 'ur'];
    return rtlLanguages.contains(locale.languageCode);
  }

  // Get text direction for locale
  TextDirection getTextDirection(Locale locale) {
    return isRTL(locale) ? TextDirection.rtl : TextDirection.ltr;
  }

  // Format locale for display
  String formatLocaleForDisplay(Locale locale) {
    final name = getLanguageName(locale.languageCode);
    final nativeName = getNativeLanguageName(locale.languageCode);

    if (name == nativeName) {
      return name;
    }

    return '$name ($nativeName)';
  }

  // Get supported language codes
  List<String> getSupportedLanguageCodes() {
    return AppConstants.supportedLanguages
        .map((lang) => lang['code'] as String)
        .toList();
  }

  // Check if language is supported
  bool isLanguageSupported(String languageCode) {
    return getSupportedLanguageCodes().contains(languageCode);
  }

  // Get locale from language code
  Locale getLocaleFromCode(String languageCode) {
    return Locale(languageCode);
  }

  // Get default locale
  Locale getDefaultLocale() {
    return const Locale('en');
  }
}
