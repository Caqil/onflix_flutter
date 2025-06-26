class AppConstants {
  // App Information
  static const String appName = 'Onflix';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  static const String supportEmail = 'support@onflix.com';
  static const String privacyPolicyUrl = 'https://onflix.com/privacy';
  static const String termsOfServiceUrl = 'https://onflix.com/terms';
  static const String helpCenterUrl = 'https://help.onflix.com';
  static const String feedbackUrl = 'https://onflix.com/feedback';

  // API Configuration
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 15000; // 15 seconds
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  static const int maxConcurrentDownloads = 3;

  // Video Configuration
  static const List<String> supportedVideoFormats = [
    'mp4',
    'mov',
    'avi',
    'mkv',
    'webm',
    'm4v',
    '3gp'
  ];
  static const List<String> supportedAudioFormats = [
    'mp3',
    'aac',
    'wav',
    'flac',
    'm4a',
    'ogg'
  ];
  static const List<String> supportedSubtitleFormats = [
    'srt',
    'vtt',
    'ass',
    'ssa',
    'sub'
  ];

  static const List<String> videoQualities = [
    'Auto',
    '240p',
    '360p',
    '480p',
    '720p',
    '1080p',
    '1440p',
    '2160p'
  ];
  static const Map<String, int> qualityBitrates = {
    '240p': 400,
    '360p': 700,
    '480p': 1200,
    '720p': 2500,
    '1080p': 5000,
    '1440p': 10000,
    '2160p': 20000,
  };

  static const List<double> playbackSpeeds = [
    0.25,
    0.5,
    0.75,
    1.0,
    1.25,
    1.5,
    1.75,
    2.0
  ];

  static const int maxDownloads = 100;
  static const int videoPreloadDuration = 10; // seconds
  static const int maxVideoQuality = 2160; // 4K
  static const Duration watchProgressSaveInterval = Duration(seconds: 5);

  // UI Configuration
  static const int gridCrossAxisCount = 3;
  static const double cardAspectRatio = 16 / 9;
  static const double posterAspectRatio = 2 / 3;
  static const double heroAspectRatio = 21 / 9;

  // Responsive breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 150);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  static const Duration veryLongAnimation = Duration(milliseconds: 800);

  // UI spacing and sizing
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;

  static const double defaultRadius = 8.0;
  static const double smallRadius = 4.0;
  static const double largeRadius = 12.0;
  static const double extraLargeRadius = 16.0;

  static const double defaultElevation = 2.0;
  static const double mediumElevation = 4.0;
  static const double highElevation = 8.0;

  // Content types
  static const String movieType = 'movie';
  static const String seriesType = 'series';
  static const String documentaryType = 'documentary';
  static const String shortType = 'short';
  static const String liveType = 'live';

  // Content status
  static const String publishedStatus = 'published';
  static const String draftStatus = 'draft';
  static const String archivedStatus = 'archived';
  static const String scheduledStatus = 'scheduled';
  static const String reviewStatus = 'review';

  // Subscription types
  static const String basicPlan = 'basic';
  static const String standardPlan = 'standard';
  static const String premiumPlan = 'premium';
  static const String familyPlan = 'family';
  static const String studentPlan = 'student';

  // ADD THIS: List of all subscription plans
  static const List<String> subscriptionPlans = [
    basicPlan,
    standardPlan,
    premiumPlan,
    familyPlan,
    studentPlan,
  ];

  // Rating types
  static const String likeRating = 'like';
  static const String dislikeRating = 'dislike';
  static const String thumbsUpRating = 'thumbs_up';
  static const String thumbsDownRating = 'thumbs_down';
  static const String starRating = 'star';

  // Download status
  static const String downloadPending = 'pending';
  static const String downloadInProgress = 'downloading';
  static const String downloadCompleted = 'completed';
  static const String downloadFailed = 'failed';
  static const String downloadPaused = 'paused';
  static const String downloadCancelled = 'cancelled';

  // Watch status
  static const String notStarted = 'not_started';
  static const String inProgress = 'in_progress';
  static const String completed = 'completed';
  static const String abandoned = 'abandoned';

  // Maturity ratings
  static const List<String> maturityRatings = [
    'G',
    'PG',
    'PG-13',
    'R',
    'NC-17',
    'TV-Y',
    'TV-Y7',
    'TV-G',
    'TV-PG',
    'TV-14',
    'TV-MA'
  ];

  // Languages
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English', 'nativeName': 'English'},
    {'code': 'es', 'name': 'Spanish', 'nativeName': 'Español'},
    {'code': 'fr', 'name': 'French', 'nativeName': 'Français'},
    {'code': 'de', 'name': 'German', 'nativeName': 'Deutsch'},
    {'code': 'it', 'name': 'Italian', 'nativeName': 'Italiano'},
    {'code': 'pt', 'name': 'Portuguese', 'nativeName': 'Português'},
    {'code': 'ja', 'name': 'Japanese', 'nativeName': '日本語'},
    {'code': 'ko', 'name': 'Korean', 'nativeName': '한국어'},
    {'code': 'zh', 'name': 'Chinese', 'nativeName': '中文'},
    {'code': 'ar', 'name': 'Arabic', 'nativeName': 'العربية'},
    {'code': 'hi', 'name': 'Hindi', 'nativeName': 'हिन्दी'},
    {'code': 'ru', 'name': 'Russian', 'nativeName': 'Русский'},
  ];

  // Cache configuration
  static const int imageCacheMaxSize = 100 * 1024 * 1024; // 100MB
  static const int videoCacheMaxSize = 1024 * 1024 * 1024; // 1GB
  static const int audioCacheMaxSize = 50 * 1024 * 1024; // 50MB
  static const Duration cacheExpiration = Duration(days: 7);
  static const Duration imageCacheExpiration = Duration(days: 30);
  static const Duration videoCacheExpiration = Duration(days: 3);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  static const int homePageSize = 10;
  static const int searchPageSize = 15;
  static const int watchlistPageSize = 25;

  // Search configuration
  static const int maxSearchHistoryItems = 10;
  static const int minSearchQueryLength = 2;
  static const Duration searchDebounceDelay = Duration(milliseconds: 500);

  // Notification types
  static const String newContentNotification = 'new_content';
  static const String recommendationNotification = 'recommendation';
  static const String downloadCompleteNotification = 'download_complete';
  static const String subscriptionNotification = 'subscription';
  static const String systemNotification = 'system';
  static const String promotionalNotification = 'promotional';

  // Error codes
  static const String networkError = 'NETWORK_ERROR';
  static const String authError = 'AUTH_ERROR';
  static const String validationError = 'VALIDATION_ERROR';
  static const String serverError = 'SERVER_ERROR';
  static const String notFoundError = 'NOT_FOUND_ERROR';
  static const String permissionError = 'PERMISSION_ERROR';
  static const String subscriptionError = 'SUBSCRIPTION_ERROR';
  static const String downloadError = 'DOWNLOAD_ERROR';
  static const String playbackError = 'PLAYBACK_ERROR';

  // Regular expressions
  static const String emailRegex =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phoneRegex = r'^\+?[1-9]\d{1,14}$';
  static const String passwordRegex =
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$';
  static const String usernameRegex = r'^[a-zA-Z0-9_]{3,20}$';

  // Feature flags
  static const bool enableOfflineMode = true;
  static const bool enableSocialFeatures = true;
  static const bool enableAdvancedAnalytics = true;
  static const bool enableBetaFeatures = false;
  static const bool enableDebugMode = false;

  // External URLs
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.onflix.app';
  static const String appStoreUrl =
      'https://apps.apple.com/app/onflix/id123456789';
  static const String websiteUrl = 'https://onflix.com';
  static const String socialMediaTwitter = 'https://twitter.com/onflix';
  static const String socialMediaFacebook = 'https://facebook.com/onflix';
  static const String socialMediaInstagram = 'https://instagram.com/onflix';

  // Device limits
  static const int maxDevicesPerAccount = 5;
  static const int maxConcurrentStreams = 3;
  static const int maxProfilesPerAccount = 5;

  // Content limits
  static const int maxWatchlistItems = 500;
  static const int maxDownloadedItems = 100;
  static const int maxSearchResults = 1000;
  static const int maxRecommendations = 50;

  // Time constants
  static const Duration sessionTimeout = Duration(hours: 24);
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);
  static const Duration watchProgressThreshold = Duration(seconds: 30);
  static const Duration inactivityTimeout = Duration(minutes: 30);
}
