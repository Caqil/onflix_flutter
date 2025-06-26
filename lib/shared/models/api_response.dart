import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final String? error;
  final int? statusCode;
  final Map<String, dynamic>? metadata;

  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
    this.statusCode,
    this.metadata,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);

  factory ApiResponse.success(T data,
      {String? message, Map<String, dynamic>? metadata}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      statusCode: 200,
      metadata: metadata,
    );
  }

  factory ApiResponse.error(String error,
      {int? statusCode, Map<String, dynamic>? metadata}) {
    return ApiResponse(
      success: false,
      error: error,
      statusCode: statusCode ?? 500,
      metadata: metadata,
    );
  }

  bool get isSuccess => success && error == null;
  bool get isError => !success || error != null;

  @override
  String toString() {
    if (isSuccess) {
      return 'ApiResponse.success(data: $data, message: $message)';
    } else {
      return 'ApiResponse.error(error: $error, statusCode: $statusCode)';
    }
  }
}
