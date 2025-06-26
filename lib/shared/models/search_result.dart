import 'package:json_annotation/json_annotation.dart';

part 'search_result.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class SearchResult<T> {
  final List<T> results;
  final String query;
  final int totalCount;
  final Duration searchTime;
  final Map<String, int>? facets;
  final List<String>? suggestions;

  const SearchResult({
    required this.results,
    required this.query,
    required this.totalCount,
    required this.searchTime,
    this.facets,
    this.suggestions,
  });

  factory SearchResult.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$SearchResultFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$SearchResultToJson(this, toJsonT);

  bool get isEmpty => results.isEmpty;
  bool get isNotEmpty => results.isNotEmpty;
  int get length => results.length;

  factory SearchResult.empty(String query) {
    return SearchResult(
      results: [],
      query: query,
      totalCount: 0,
      searchTime: Duration.zero,
    );
  }

  @override
  String toString() {
    return 'SearchResult(query: "$query", results: ${results.length}/$totalCount, time: ${searchTime.inMilliseconds}ms)';
  }
}
