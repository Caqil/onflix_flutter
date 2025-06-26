import 'package:onflix/core/errors/exceptions.dart';

abstract class Failure {
  final String message;
  final String? code;
  final dynamic details;

  const Failure({
    required this.message,
    this.code,
    this.details,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure &&
        other.message == message &&
        other.code == code;
  }

  @override
  int get hashCode => message.hashCode ^ code.hashCode;

  @override
  String toString() => 'Failure: $message';
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
    super.details,
  });

  factory NetworkFailure.fromException(NetworkException exception) {
    return NetworkFailure(
      message: exception.message,
      code: exception.code,
      details: exception.details,
    );
  }
}

class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    required super.message,
    super.code,
    this.statusCode,
    super.details,
  });

  factory ServerFailure.fromException(ServerException exception) {
    return ServerFailure(
      message: exception.message,
      code: exception.code,
      statusCode: exception.statusCode,
      details: exception.details,
    );
  }
}

class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
    super.details,
  });

  factory AuthFailure.fromException(AuthException exception) {
    return AuthFailure(
      message: exception.message,
      code: exception.code,
      details: exception.details,
    );
  }
}

class ValidationFailure extends Failure {
  final Map<String, List<String>>? fieldErrors;

  const ValidationFailure({
    required super.message,
    super.code,
    this.fieldErrors,
    super.details,
  });

  factory ValidationFailure.fromException(ValidationException exception) {
    return ValidationFailure(
      message: exception.message,
      code: exception.code,
      fieldErrors: exception.fieldErrors,
      details: exception.details,
    );
  }
}

class ContentFailure extends Failure {
  const ContentFailure({
    required super.message,
    super.code,
    super.details,
  });

  factory ContentFailure.fromException(ContentException exception) {
    return ContentFailure(
      message: exception.message,
      code: exception.code,
      details: exception.details,
    );
  }
}

class DownloadFailure extends Failure {
  const DownloadFailure({
    required super.message,
    super.code,
    super.details,
  });

  factory DownloadFailure.fromException(DownloadException exception) {
    return DownloadFailure(
      message: exception.message,
      code: exception.code,
      details: exception.details,
    );
  }
}

class PlaybackFailure extends Failure {
  const PlaybackFailure({
    required super.message,
    super.code,
    super.details,
  });

  factory PlaybackFailure.fromException(PlaybackException exception) {
    return PlaybackFailure(
      message: exception.message,
      code: exception.code,
      details: exception.details,
    );
  }
}

class SubscriptionFailure extends Failure {
  const SubscriptionFailure({
    required super.message,
    super.code,
    super.details,
  });

  factory SubscriptionFailure.fromException(SubscriptionException exception) {
    return SubscriptionFailure(
      message: exception.message,
      code: exception.code,
      details: exception.details,
    );
  }
}

class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
    super.details,
  });

  factory CacheFailure.fromException(CacheException exception) {
    return CacheFailure(
      message: exception.message,
      code: exception.code,
      details: exception.details,
    );
  }
}
