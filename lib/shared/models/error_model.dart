import 'package:json_annotation/json_annotation.dart';

part 'error_model.g.dart';

@JsonSerializable()
class ErrorModel {
  final String message;
  final String? code;
  final String? field;
  final Map<String, dynamic>? details;
  final DateTime? timestamp;

  const ErrorModel({
    required this.message,
    this.code,
    this.field,
    this.details,
    this.timestamp,
  });

  factory ErrorModel.fromJson(Map<String, dynamic> json) =>
      _$ErrorModelFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorModelToJson(this);

  factory ErrorModel.create(
    String message, {
    String? code,
    String? field,
    Map<String, dynamic>? details,
  }) {
    return ErrorModel(
      message: message,
      code: code,
      field: field,
      details: details,
      timestamp: DateTime.now(),
    );
  }

  @override
  String toString() => message;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ErrorModel &&
        other.message == message &&
        other.code == code &&
        other.field == field;
  }

  @override
  int get hashCode => message.hashCode ^ code.hashCode ^ field.hashCode;
}
