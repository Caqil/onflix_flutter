class StorageKeys {
  // Authentication
  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String adminUser = 'admin_user';
  static const String userEmail = 'user_email';
  static const String isLoggedIn = 'is_logged_in';
  static const String lastLoginDate = 'last_login_date';
  static const String biometricEnabled = 'biometric_enabled';
  static const String rememberMe = 'remember_me';

  // User Preferences
  static const String selectedProfile = 'selected_profile';
  static const String selectedProfileId = 'selected_profile_id';
  static const String themeMode = 'theme_mode';
  static const String language = 'language';
  static const String locale = 'locale';
  static const String firstLaunch = 'first_launch';
  static const String onboardingCompleted = 'onboarding_completed';

  // Video Player Settings
  static const String autoPlay = 'auto_play';
  static const String autoPlayPreviews = 'auto_play_previews';
  static const String videoQuality = 'video_quality';
  static const String preferredAudioLanguage = 'preferred_audio_language';
  static const String preferredSubtitleLanguage = 'preferred_subtitle_language';
  static const String subtitlesEnabled = 'subtitles_enabled';
  static const String playbackSpeed = 'playback_speed';
  static const String volume = 'volume';
  static const String brightness = 'brightness';
  static const String skipIntro = 'skip_intro';
  static const String skipCredits = 'skip_credits';

  // Download Settings
  static const String downloadQuality = 'download_quality';
  static const String downloadOnlyOnWifi = 'download_only_on_wifi';
  static const String maxDownloads = 'max_downloads';
  static const String downloadLocation = 'download_location';
  static const String autoDeleteWatched = 'auto_delete_watched';
  static const String downloadExpiration = 'download_expiration';

  // Parental Controls
  static const String parentalControls = 'parental_controls';
  static const String parentalPin = 'parental_pin';
  static const String maturityLevel = 'maturity_level';
  static const String kidsMode = 'kids_mode';
  static const String restrictedContent = 'restricted_content';

  // Notifications
  static const String notificationSettings = 'notification_settings';
  static const String pushNotificationsEnabled = 'push_notifications_enabled';
  static const String emailNotificationsEnabled = 'email_notifications_enabled';
  static const String newContentNotifications = 'new_content_notifications';
  static const String recommendationNotifications =
      'recommendation_notifications';
  static const String downloadNotifications = 'download_notifications';
  static const String promotionalNotifications = 'promotional_notifications';

  // App State
  static const String lastSyncTime = 'last_sync_time';
  static const String offlineContent = 'offline_content';
  static const String cacheSize = 'cache_size';
  static const String lastUpdateCheck = 'last_update_check';
  static const String appVersion = 'app_version';
  static const String deviceId = 'device_id';
  static const String sessionId = 'session_id';

  // Search and History
  static const String searchHistory = 'search_history';
  static const String recentSearches = 'recent_searches';
  static const String watchHistory = 'watch_history';
  static const String browsHistory = 'browse_history';
  static const String continueWatching = 'continue_watching';

  // Analytics and Tracking
  static const String analyticsEnabled = 'analytics_enabled';
  static const String crashReportingEnabled = 'crash_reporting_enabled';
  static const String usageStatistics = 'usage_statistics';
  static const String performanceMetrics = 'performance_metrics';

  // Subscription and Billing
  static const String subscriptionStatus = 'subscription_status';
  static const String subscriptionPlan = 'subscription_plan';
  static const String subscriptionExpiryDate = 'subscription_expiry_date';
  static const String paymentMethod = 'payment_method';
  static const String billingCycle = 'billing_cycle';
  static const String autoRenew = 'auto_renew';

  // Content Preferences
  static const String favoriteGenres = 'favorite_genres';
  static const String dislikedGenres = 'disliked_genres';
  static const String contentLanguagePreference = 'content_language_preference';
  static const String regionPreference = 'region_preference';
  static const String ageRating = 'age_rating';

  // Network and Connectivity
  static const String dataUsageLimit = 'data_usage_limit';
  static const String wifiOnlyStreaming = 'wifi_only_streaming';
  static const String cellularStreamingQuality = 'cellular_streaming_quality';
  static const String preloadEnabled = 'preload_enabled';
  static const String adaptiveStreaming = 'adaptive_streaming';

  // Admin Panel (for admin users)
  static const String adminToken = 'admin_token';
  static const String adminPermissions = 'admin_permissions';
  static const String adminLastLogin = 'admin_last_login';
  static const String adminDashboardPreferences = 'admin_dashboard_preferences';

  // Security
  static const String encryptionKey = 'encryption_key';
  static const String securityQuestions = 'security_questions';
  static const String lastPasswordChange = 'last_password_change';
  static const String loginAttempts = 'login_attempts';
  static const String accountLocked = 'account_locked';

  // Utility methods
  static List<String> get authKeys => [
        authToken,
        refreshToken,
        userId,
        userEmail,
        isLoggedIn,
      ];

  static List<String> get userPreferenceKeys => [
        selectedProfile,
        themeMode,
        language,
        autoPlay,
        videoQuality,
        downloadQuality,
      ];

  static List<String> get securityKeys => [
        parentalPin,
        encryptionKey,
        securityQuestions,
        biometricEnabled,
      ];

  static List<String> get sensitiveKeys => [
        ...authKeys,
        ...securityKeys,
        adminToken,
        paymentMethod,
      ];
}
