import 'package:json_annotation/json_annotation.dart';

part 'base_model.g.dart';

@JsonSerializable()
class BaseModel {
  final String id;
  final String? collectionId;
  final String? collectionName;
  @JsonKey(name: 'created')
  final DateTime created;
  @JsonKey(name: 'updated')
  final DateTime updated;

  const BaseModel({
    required this.id,
    this.collectionId,
    this.collectionName,
    required this.created,
    required this.updated,
  });

  factory BaseModel.fromJson(Map<String, dynamic> json) =>
      _$BaseModelFromJson(json);

  Map<String, dynamic> toJson() => _$BaseModelToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaseModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'BaseModel(id: $id, collection: $collectionName)';
}
