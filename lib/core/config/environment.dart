import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get fileName {
    const env = String.fromEnvironment('ENV', defaultValue: 'development');
    return '.env.$env';
  }

  static String get pocketbaseUrl => dotenv.env['POCKETBASE_URL'] ?? '';
  static String get apiKey => dotenv.env['API_KEY'] ?? '';
  static String get stripePublishableKey =>
      dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';
  static bool get isProduction => dotenv.env['ENV'] == 'production';
  static bool get isDebug => dotenv.env['DEBUG'] == 'true';
}

// lib/core/config/app_config.dart
class AppConfig {
  static const String appName = 'Onflix';
  static const String appVersion = '1.0.0';
  static const String supportEmail = 'support@onflix.com';

  // API Configuration
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int maxRetries = 3;

  // Video Configuration
  static const List<String> supportedVideoFormats = [
    'mp4',
    'mov',
    'avi',
    'mkv'
  ];
  static const List<String> videoQualities = [
    '360p',
    '480p',
    '720p',
    '1080p',
    '4K'
  ];
  static const int maxDownloads = 100;
  static const int videoPreloadDuration = 10; // seconds

  // UI Configuration
  static const int gridCrossAxisCount = 3;
  static const double cardAspectRatio = 16 / 9;
  static const double posterAspectRatio = 2 / 3;

  // Cache Configuration
  static const int imageCacheMaxSize = 100 * 1024 * 1024; // 100MB
  static const int videoCacheMaxSize = 1024 * 1024 * 1024; // 1GB
  static const Duration cacheExpiration = Duration(days: 7);
}
