import 'dart:io';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'exceptions.dart';
import 'failures.dart';

class ErrorHandler {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  // Convert exceptions to failures
  static Failure handleException(Exception exception) {
    _logger.e('Handling exception: $exception');

    if (exception is AppException) {
      return _handleAppException(exception);
    }

    if (exception is DioException) {
      return _handleDioException(exception);
    }

    if (exception is SocketException) {
      return const NetworkFailure(
        message: 'No internet connection',
        code: 'NO_CONNECTION',
      );
    }

    if (exception is HttpException) {
      return ServerFailure(
        message: exception.message,
        code: 'HTTP_ERROR',
        statusCode: exception.uri != null ? null : 500,
      );
    }

    if (exception is FormatException) {
      return ValidationFailure(
        message: 'Invalid data format: ${exception.message}',
        code: 'FORMAT_ERROR',
      );
    }

    // Generic exception handling
    return ServerFailure(
      message: 'An unexpected error occurred: ${exception.toString()}',
      code: 'UNKNOWN_ERROR',
      statusCode: null,
    );
  }

  static Failure _handleAppException(AppException exception) {
    switch (exception.runtimeType) {
      case NetworkException _:
        return NetworkFailure.fromException(exception as NetworkException);
      case ServerException _:
        return ServerFailure.fromException(exception as ServerException);
      case AuthException _:
        return AuthFailure.fromException(exception as AuthException);
      case ValidationException _:
        return ValidationFailure.fromException(
            exception as ValidationException);
      case ContentException _:
        return ContentFailure.fromException(exception as ContentException);
      case DownloadException _:
        return DownloadFailure.fromException(exception as DownloadException);
      case PlaybackException _:
        return PlaybackFailure.fromException(exception as PlaybackException);
      case SubscriptionException _:
        return SubscriptionFailure.fromException(
            exception as SubscriptionException);
      case CacheException _:
        return CacheFailure.fromException(exception as CacheException);
      default:
        return ServerFailure(
          message: exception.message,
          code: exception.code,
          statusCode: null,
        );
    }
  }

  static Failure _handleDioException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(
          message: 'Connection timeout',
          code: 'TIMEOUT',
        );

      case DioExceptionType.badResponse:
        return _handleHttpStatusCode(exception.response?.statusCode);

      case DioExceptionType.cancel:
        return const NetworkFailure(
          message: 'Request was cancelled',
          code: 'REQUEST_CANCELLED',
        );

      case DioExceptionType.connectionError:
        return const NetworkFailure(
          message: 'Connection error',
          code: 'CONNECTION_ERROR',
        );

      case DioExceptionType.badCertificate:
        return const NetworkFailure(
          message: 'Certificate error',
          code: 'CERTIFICATE_ERROR',
        );

      case DioExceptionType.unknown:
      if (exception.error is SocketException) {
          return const NetworkFailure(
            message: 'No internet connection',
            code: 'NO_CONNECTION',
          );
        }
        return NetworkFailure(
          message: 'Network error: ${exception.message}',
          code: 'NETWORK_ERROR',
        );
    }
  }

  static Failure _handleHttpStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return const ServerFailure(
          message: 'Bad request',
          code: 'BAD_REQUEST',
          statusCode: 400,
        );
      case 401:
        return const AuthFailure(
          message: 'Unauthorized access',
          code: 'UNAUTHORIZED',
        );
      case 403:
        return const AuthFailure(
          message: 'Access forbidden',
          code: 'FORBIDDEN',
        );
      case 404:
        return const ServerFailure(
          message: 'Resource not found',
          code: 'NOT_FOUND',
          statusCode: 404,
        );
      case 409:
        return const ValidationFailure(
          message: 'Conflict - resource already exists',
          code: 'CONFLICT',
        );
      case 422:
        return const ValidationFailure(
          message: 'Validation failed',
          code: 'VALIDATION_ERROR',
        );
      case 429:
        return const ServerFailure(
          message: 'Too many requests',
          code: 'RATE_LIMITED',
          statusCode: 429,
        );
      case 500:
        return const ServerFailure(
          message: 'Internal server error',
          code: 'INTERNAL_ERROR',
          statusCode: 500,
        );
      case 502:
        return const ServerFailure(
          message: 'Bad gateway',
          code: 'BAD_GATEWAY',
          statusCode: 502,
        );
      case 503:
        return const ServerFailure(
          message: 'Service unavailable',
          code: 'SERVICE_UNAVAILABLE',
          statusCode: 503,
        );
      case 504:
        return const ServerFailure(
          message: 'Gateway timeout',
          code: 'GATEWAY_TIMEOUT',
          statusCode: 504,
        );
      default:
        return ServerFailure(
          message: 'Server error',
          code: 'SERVER_ERROR',
          statusCode: statusCode,
        );
    }
  }

  // Log error details
  static void logError(dynamic error, [StackTrace? stackTrace]) {
    if (error is Failure) {
      _logger.e(
        'Failure occurred',
        error: error.message,
        stackTrace: stackTrace,
      );
    } else if (error is Exception) {
      _logger.e(
        'Exception occurred',
        error: error.toString(),
        stackTrace: stackTrace,
      );
    } else {
      _logger.e(
        'Unknown error occurred',
        error: error.toString(),
        stackTrace: stackTrace,
      );
    }
  }

  // Get user-friendly error message
  static String getUserMessage(Failure failure) {
    switch (failure.code) {
      case 'NO_CONNECTION':
        return 'Please check your internet connection and try again.';
      case 'TIMEOUT':
        return 'Request timed out. Please try again.';
      case 'UNAUTHORIZED':
        return 'Please log in to continue.';
      case 'FORBIDDEN':
        return 'You don\'t have permission to access this resource.';
      case 'NOT_FOUND':
        return 'The requested content was not found.';
      case 'VALIDATION_ERROR':
        return 'Please check your input and try again.';
      case 'SUBSCRIPTION_EXPIRED':
        return 'Your subscription has expired. Please renew to continue.';
      case 'CONTENT_NOT_AVAILABLE':
        return 'This content is not available in your region.';
      case 'DOWNLOAD_LIMIT_REACHED':
        return 'You\'ve reached your download limit.';
      case 'INSUFFICIENT_STORAGE':
        return 'Not enough storage space for download.';
      case 'SERVICE_UNAVAILABLE':
        return 'Service is temporarily unavailable. Please try again later.';
      default:
        return failure.message;
    }
  }

  // Check if error is recoverable
  static bool isRecoverable(Failure failure) {
    const recoverableCodes = [
      'TIMEOUT',
      'CONNECTION_ERROR',
      'SERVICE_UNAVAILABLE',
      'RATE_LIMITED',
    ];
    return recoverableCodes.contains(failure.code);
  }

  // Check if error requires authentication
  static bool requiresAuth(Failure failure) {
    const authCodes = [
      'UNAUTHORIZED',
      'TOKEN_EXPIRED',
      'INVALID_TOKEN',
    ];
    return authCodes.contains(failure.code);
  }

  // Check if error is network related
  static bool isNetworkError(Failure failure) {
    return failure is NetworkFailure;
  }

  // Check if error is server related
  static bool isServerError(Failure failure) {
    return failure is ServerFailure;
  }
}
