import '../constants/app_constants.dart';

// Base exception class
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.details,
    this.stackTrace,
  });

  @override
  String toString() => 'AppException: $message';
}

// Network exceptions
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code = AppConstants.networkError,
    super.details,
    super.stackTrace,
  });

  factory NetworkException.noConnection() {
    return const NetworkException(
      message: 'No internet connection available',
      code: 'NO_CONNECTION',
    );
  }

  factory NetworkException.timeout() {
    return const NetworkException(
      message: 'Request timeout',
      code: 'TIMEOUT',
    );
  }

  factory NetworkException.connectionFailed() {
    return const NetworkException(
      message: 'Failed to connect to server',
      code: 'CONNECTION_FAILED',
    );
  }
}

// Server exceptions
class ServerException extends AppException {
  final int? statusCode;

  const ServerException({
    required super.message,
    super.code = AppConstants.serverError,
    this.statusCode,
    super.details,
    super.stackTrace,
  });

  factory ServerException.internalError() {
    return const ServerException(
      message: 'Internal server error',
      statusCode: 500,
      code: 'INTERNAL_ERROR',
    );
  }

  factory ServerException.badRequest(String message) {
    return ServerException(
      message: message,
      statusCode: 400,
      code: 'BAD_REQUEST',
    );
  }

  factory ServerException.unauthorized() {
    return const ServerException(
      message: 'Unauthorized access',
      statusCode: 401,
      code: 'UNAUTHORIZED',
    );
  }

  factory ServerException.forbidden() {
    return const ServerException(
      message: 'Access forbidden',
      statusCode: 403,
      code: 'FORBIDDEN',
    );
  }

  factory ServerException.notFound() {
    return const ServerException(
      message: 'Resource not found',
      statusCode: 404,
      code: 'NOT_FOUND',
    );
  }

  factory ServerException.serviceUnavailable() {
    return const ServerException(
      message: 'Service temporarily unavailable',
      statusCode: 503,
      code: 'SERVICE_UNAVAILABLE',
    );
  }
}

// Authentication exceptions
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code = AppConstants.authError,
    super.details,
    super.stackTrace,
  });

  factory AuthException.invalidCredentials() {
    return const AuthException(
      message: 'Invalid email or password',
      code: 'INVALID_CREDENTIALS',
    );
  }

  factory AuthException.userNotFound() {
    return const AuthException(
      message: 'User not found',
      code: 'USER_NOT_FOUND',
    );
  }

  factory AuthException.emailAlreadyExists() {
    return const AuthException(
      message: 'Email already exists',
      code: 'EMAIL_EXISTS',
    );
  }

  factory AuthException.usernameAlreadyExists() {
    return const AuthException(
      message: 'Username already exists',
      code: 'USERNAME_EXISTS',
    );
  }

  factory AuthException.tokenExpired() {
    return const AuthException(
      message: 'Session expired, please login again',
      code: 'TOKEN_EXPIRED',
    );
  }

  factory AuthException.invalidToken() {
    return const AuthException(
      message: 'Invalid authentication token',
      code: 'INVALID_TOKEN',
    );
  }

  factory AuthException.emailNotVerified() {
    return const AuthException(
      message: 'Please verify your email address',
      code: 'EMAIL_NOT_VERIFIED',
    );
  }

  factory AuthException.accountLocked() {
    return const AuthException(
      message: 'Account temporarily locked due to too many failed attempts',
      code: 'ACCOUNT_LOCKED',
    );
  }
}

// Validation exceptions
class ValidationException extends AppException {
  final Map<String, List<String>>? fieldErrors;

  const ValidationException({
    required super.message,
    super.code = AppConstants.validationError,
    this.fieldErrors,
    super.details,
    super.stackTrace,
  });

  factory ValidationException.field(String field, String error) {
    return ValidationException(
      message: error,
      fieldErrors: {
        field: [error]
      },
    );
  }

  factory ValidationException.multipleFields(Map<String, List<String>> errors) {
    return ValidationException(
      message: 'Validation failed',
      fieldErrors: errors,
    );
  }
}

// Content exceptions
class ContentException extends AppException {
  const ContentException({
    required super.message,
    super.code = 'CONTENT_ERROR',
    super.details,
    super.stackTrace,
  });

  factory ContentException.notFound() {
    return const ContentException(
      message: 'Content not found',
      code: 'CONTENT_NOT_FOUND',
    );
  }

  factory ContentException.notAvailable() {
    return const ContentException(
      message: 'Content not available in your region',
      code: 'CONTENT_NOT_AVAILABLE',
    );
  }

  factory ContentException.restrictedAccess() {
    return const ContentException(
      message: 'Content restricted by parental controls',
      code: 'CONTENT_RESTRICTED',
    );
  }

  factory ContentException.subscriptionRequired() {
    return const ContentException(
      message: 'Subscription required to access this content',
      code: 'SUBSCRIPTION_REQUIRED',
    );
  }
}

// Download exceptions
class DownloadException extends AppException {
  const DownloadException({
    required super.message,
    super.code = AppConstants.downloadError,
    super.details,
    super.stackTrace,
  });

  factory DownloadException.insufficientStorage() {
    return const DownloadException(
      message: 'Insufficient storage space',
      code: 'INSUFFICIENT_STORAGE',
    );
  }

  factory DownloadException.downloadLimitReached() {
    return const DownloadException(
      message: 'Download limit reached',
      code: 'DOWNLOAD_LIMIT_REACHED',
    );
  }

  factory DownloadException.fileCorrupted() {
    return const DownloadException(
      message: 'Downloaded file is corrupted',
      code: 'FILE_CORRUPTED',
    );
  }

  factory DownloadException.downloadCancelled() {
    return const DownloadException(
      message: 'Download was cancelled',
      code: 'DOWNLOAD_CANCELLED',
    );
  }
}

// Playback exceptions
class PlaybackException extends AppException {
  const PlaybackException({
    required super.message,
    super.code = AppConstants.playbackError,
    super.details,
    super.stackTrace,
  });

  factory PlaybackException.formatNotSupported() {
    return const PlaybackException(
      message: 'Video format not supported',
      code: 'FORMAT_NOT_SUPPORTED',
    );
  }

  factory PlaybackException.streamingError() {
    return const PlaybackException(
      message: 'Error streaming video',
      code: 'STREAMING_ERROR',
    );
  }

  factory PlaybackException.qualityNotAvailable() {
    return const PlaybackException(
      message: 'Selected quality not available',
      code: 'QUALITY_NOT_AVAILABLE',
    );
  }

  factory PlaybackException.drmError() {
    return const PlaybackException(
      message: 'Digital rights management error',
      code: 'DRM_ERROR',
    );
  }
}

// Subscription exceptions
class SubscriptionException extends AppException {
  const SubscriptionException({
    required super.message,
    super.code = AppConstants.subscriptionError,
    super.details,
    super.stackTrace,
  });

  factory SubscriptionException.expired() {
    return const SubscriptionException(
      message: 'Subscription has expired',
      code: 'SUBSCRIPTION_EXPIRED',
    );
  }

  factory SubscriptionException.paymentFailed() {
    return const SubscriptionException(
      message: 'Payment failed',
      code: 'PAYMENT_FAILED',
    );
  }

  factory SubscriptionException.planNotFound() {
    return const SubscriptionException(
      message: 'Subscription plan not found',
      code: 'PLAN_NOT_FOUND',
    );
  }

  factory SubscriptionException.deviceLimitReached() {
    return const SubscriptionException(
      message: 'Device limit reached for your subscription',
      code: 'DEVICE_LIMIT_REACHED',
    );
  }
}

// Cache exceptions
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code = 'CACHE_ERROR',
    super.details,
    super.stackTrace,
  });

  factory CacheException.notFound() {
    return const CacheException(
      message: 'Data not found in cache',
      code: 'CACHE_NOT_FOUND',
    );
  }

  factory CacheException.expired() {
    return const CacheException(
      message: 'Cached data has expired',
      code: 'CACHE_EXPIRED',
    );
  }

  factory CacheException.corruptedData() {
    return const CacheException(
      message: 'Cached data is corrupted',
      code: 'CACHE_CORRUPTED',
    );
  }
}
