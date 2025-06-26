import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../config/environment.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';
import 'interceptors.dart';

class ApiClient {
  static ApiClient? _instance;
  late Dio _dio;
  final Logger _logger = Logger();

  ApiClient._() {
    _dio = Dio(BaseOptions(
      baseUrl: Environment.pocketbaseUrl,
      connectTimeout:
          const Duration(milliseconds: AppConstants.connectionTimeout),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
      sendTimeout: const Duration(milliseconds: AppConstants.sendTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _setupInterceptors();
  }

  static ApiClient get instance {
    _instance ??= ApiClient._();
    return _instance!;
  }

  Dio get dio => _dio;

  void _setupInterceptors() {
    _dio.interceptors.addAll([
      LoggingInterceptor(_logger),
      AuthInterceptor(),
      RetryInterceptor(),
      ErrorInterceptor(),
    ]);
  }

  // GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  // POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  // PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  // PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  // DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  // Upload file
  Future<Response<T>> upload<T>(
    String path,
    FormData formData, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: formData,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  // Download file
  Future<Response> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Options? options,
  }) async {
    try {
      return await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        deleteOnError: deleteOnError,
        lengthHeader: lengthHeader,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  // Handle Dio exceptions
  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException.timeout();

      case DioExceptionType.badResponse:
        return _handleHttpError(e.response);

      case DioExceptionType.cancel:
        return const NetworkException(
          message: 'Request cancelled',
          code: 'REQUEST_CANCELLED',
        );

      case DioExceptionType.connectionError:
        return NetworkException.connectionFailed();

      case DioExceptionType.badCertificate:
        return const NetworkException(
          message: 'Certificate verification failed',
          code: 'CERTIFICATE_ERROR',
        );

      case DioExceptionType.unknown:
      default:
        return NetworkException.connectionFailed();
    }
  }

  Exception _handleHttpError(Response? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;

    switch (statusCode) {
      case 400:
        return ServerException.badRequest(
          data?['message'] ?? 'Bad request',
        );
      case 401:
        return AuthException.invalidToken();
      case 403:
        return AuthException(
          message: data?['message'] ?? 'Access forbidden',
          code: 'FORBIDDEN',
        );
      case 404:
        return ServerException.notFound();
      case 422:
        return ValidationException(
          message: data?['message'] ?? 'Validation failed',
          fieldErrors: _parseFieldErrors(data),
        );
      case 429:
        return const ServerException(
          message: 'Too many requests',
          code: 'RATE_LIMITED',
          statusCode: 429,
        );
      case 500:
        return ServerException.internalError();
      case 502:
        return const ServerException(
          message: 'Bad gateway',
          code: 'BAD_GATEWAY',
          statusCode: 502,
        );
      case 503:
        return ServerException.serviceUnavailable();
      default:
        return ServerException(
          message: data?['message'] ?? 'Server error',
          statusCode: statusCode,
        );
    }
  }

  Map<String, List<String>>? _parseFieldErrors(dynamic data) {
    if (data is! Map<String, dynamic>) return null;

    final errors = data['errors'] ?? data['fieldErrors'];
    if (errors is! Map<String, dynamic>) return null;

    final result = <String, List<String>>{};
    errors.forEach((key, value) {
      if (value is List) {
        result[key] = value.map((e) => e.toString()).toList();
      } else if (value is String) {
        result[key] = [value];
      }
    });

    return result.isEmpty ? null : result;
  }

  // Update base options
  void updateBaseOptions({
    String? baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    Map<String, dynamic>? headers,
  }) {
    _dio.options = _dio.options.copyWith(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      headers: headers,
    );
  }

  // Add authorization header
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Remove authorization header
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  // Close the client
  void close({bool force = false}) {
    _dio.close(force: force);
  }
}
