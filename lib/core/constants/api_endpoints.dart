class ApiEndpoints {
  static const String baseUrl = '/api';

  // Base endpoints
  static const String collections = '$baseUrl/collections';
  static const String files = '$baseUrl/files';
  static const String realtime = '$baseUrl/realtime';
  static const String health = '$baseUrl/health';
  static const String settings = '$baseUrl/settings';
  static const String logs = '$baseUrl/logs';
  static const String backups = '$baseUrl/backups';

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

  // Admin/Super User endpoints (PocketBase built-in)
  static const String superUsers = '$collections/_superusers';
  static const String superUserAuthWithPassword =
      '$superUsers/auth-with-password';
  static const String superUserAuthRefresh = '$superUsers/auth-refresh';
  static const String superUserRequestPasswordReset =
      '$superUsers/request-password-reset';
  static const String superUserConfirmPasswordReset =
      '$superUsers/confirm-password-reset';

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
  static const String adminUsers =
      '$collections/admin_users'; // Custom admin roles collection
  static const String contentModerationQueue =
      '$collections/content_moderation_queue';

  // Social endpoints
  static const String comments = '$collections/comments';
  static const String likes = '$collections/likes';
  static const String shares = '$collections/shares';
  static const String follows = '$collections/follows';
  static const String userActivity = '$collections/user_activity';

  // System administration
  static const String systemSettings = '$collections/system_settings';
  static const String emailTemplates = '$collections/email_templates';
  static const String auditLogs = '$collections/audit_logs';
  static const String backupSchedules = '$collections/backup_schedules';

  // File handling
  static String getFileUrl(
      String collection, String recordId, String filename) {
    return '$files/$collection/$recordId/$filename';
  }

  static String getThumbnailUrl(
      String collection, String recordId, String filename,
      {String? thumb}) {
    final baseUrl = getFileUrl(collection, recordId, filename);
    return thumb != null ? '$baseUrl?thumb=$thumb' : baseUrl;
  }

  // Real-time endpoints
  static String getRealtimeUrl(String collection) {
    return '$realtime/$collection';
  }
}
