class ApiEndpoints {
  static const String baseUrl = '/api';

  // Base endpoints
  static const String collections = '$baseUrl/collections';
  static const String files = '$baseUrl/files';
  static const String realtime = '$baseUrl/realtime';
  static const String health = '$baseUrl/health';
  static const String settings = '$baseUrl/settings';

  // Authentication endpoints
  static const String users = '$collections/users';
  static const String authWithPassword = '$users/auth-with-password';
  static const String authWithOAuth2 = '$users/auth-with-oauth2';
  static const String authRefresh = '$users/auth-refresh';
  static const String requestPasswordReset = '$users/request-password-reset';
  static const String confirmPasswordReset = '$users/confirm-password-reset';
  static const String requestVerification = '$users/request-verification';
  static const String confirmVerification = '$users/confirm-verification';
  static const String requestEmailChange = '$users/request-email-change';
  static const String confirmEmailChange = '$users/confirm-email-change';

  // Content endpoints
  static const String content = '$collections/content';
  static const String categories = '$collections/categories';
  static const String collections_ = '$collections/collections';
  static const String series = '$collections/series';
  static const String seasons = '$collections/seasons';
  static const String episodes = '$collections/episodes';
  static const String contentViews = '$collections/content_views';

  // User data endpoints
  static const String profiles = '$collections/profiles';
  static const String watchlist = '$collections/watchlist';
  static const String watchHistory = '$collections/watchHistory';
  static const String ratings = '$collections/ratings';
  static const String downloads = '$collections/downloads';
  static const String recommendations = '$collections/recommendations';
  static const String userPreferences = '$collections/user_preferences';

  // Subscription endpoints
  static const String subscriptions = '$collections/subscriptions';
  static const String userSubscriptions = '$collections/userSubscriptions';
  static const String paymentHistory = '$collections/paymentHistory';
  static const String paymentMethods = '$collections/payment_methods';
  static const String subscriptionPlans = '$collections/subscription_plans';

  // Admin endpoints
  static const String analytics = '$collections/analytics';
  static const String contentReports = '$collections/contentReports';
  static const String notifications = '$collections/notifications';
  static const String systemLogs = '$collections/system_logs';
  static const String adminUsers = '$collections/admin_users';
  static const String contentModerationQueue =
      '$collections/content_moderation_queue';

  // Social features
  static const String comments = '$collections/comments';
  static const String reviews = '$collections/reviews';
  static const String likes = '$collections/likes';
  static const String shares = '$collections/shares';
  static const String userFollows = '$collections/user_follows';

  // Content management
  static const String contentMetadata = '$collections/content_metadata';
  static const String subtitles = '$collections/subtitles';
  static const String thumbnails = '$collections/thumbnails';
  static const String trailers = '$collections/trailers';

  // Search and discovery
  static const String searchHistory = '$collections/search_history';
  static const String trending = '$collections/trending';
  static const String featured = '$collections/featured';
  static const String newReleases = '$collections/new_releases';
  static const String comingSoon = '$collections/coming_soon';

  // Device management
  static const String userDevices = '$collections/user_devices';
  static const String deviceSessions = '$collections/device_sessions';
  static const String downloadQueue = '$collections/download_queue';

  // File endpoints
  static String getFileUrl(
      String collection, String recordId, String filename) {
    return '$files/$collection/$recordId/$filename';
  }

  static String getThumbnailUrl(
      String collection, String recordId, String filename,
      {String? size}) {
    final baseUrl = getFileUrl(collection, recordId, filename);
    return size != null ? '$baseUrl?thumb=$size' : baseUrl;
  }

  // Search endpoints
  static String searchContent(String query) {
    return '$content?filter=title~"$query"||description~"$query"';
  }

  static String getContentByCategory(String categoryId) {
    return '$content?filter=categories~"$categoryId"';
  }

  static String getContentByGenre(String genre) {
    return '$content?filter=genres~"$genre"';
  }

  // Pagination helpers
  static String addPagination(String endpoint,
      {int page = 1, int perPage = 20}) {
    final separator = endpoint.contains('?') ? '&' : '?';
    return '$endpoint${separator}page=$page&perPage=$perPage';
  }

  static String addSort(String endpoint, String sortBy,
      {bool descending = false}) {
    final separator = endpoint.contains('?') ? '&' : '?';
    final sortDirection = descending ? '-' : '+';
    return '$endpoint${separator}sort=$sortDirection$sortBy';
  }

  static String addExpand(String endpoint, List<String> relations) {
    if (relations.isEmpty) return endpoint;
    final separator = endpoint.contains('?') ? '&' : '?';
    return '$endpoint${separator}expand=${relations.join(',')}';
  }
}
