import 'package:json_annotation/json_annotation.dart';

part 'pagination.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class PaginatedResponse<T> {
  final int page;
  final int perPage;
  final int totalItems;
  final int totalPages;
  final List<T> items;

  const PaginatedResponse({
    required this.page,
    required this.perPage,
    required this.totalItems,
    required this.totalPages,
    required this.items,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$PaginatedResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$PaginatedResponseToJson(this, toJsonT);

  // Helper methods
  bool get hasNextPage => page < totalPages;
  bool get hasPrevPage => page > 1;
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  int get length => items.length;

  // Create empty response
  factory PaginatedResponse.empty() {
    return const PaginatedResponse(
      page: 1,
      perPage: 0,
      totalItems: 0,
      totalPages: 1,
      items: [],
    );
  }

  // Copy with new items (useful for pagination)
  PaginatedResponse<T> copyWith({
    int? page,
    int? perPage,
    int? totalItems,
    int? totalPages,
    List<T>? items,
  }) {
    return PaginatedResponse(
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      totalItems: totalItems ?? this.totalItems,
      totalPages: totalPages ?? this.totalPages,
      items: items ?? this.items,
    );
  }

  @override
  String toString() {
    return 'PaginatedResponse(page: $page/$totalPages, items: ${items.length}/$totalItems)';
  }
}
