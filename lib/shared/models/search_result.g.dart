// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchResult<T> _$SearchResultFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    SearchResult<T>(
      results: (json['results'] as List<dynamic>).map(fromJsonT).toList(),
      query: json['query'] as String,
      totalCount: (json['totalCount'] as num).toInt(),
      searchTime: Duration(microseconds: (json['searchTime'] as num).toInt()),
      facets: (json['facets'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
      suggestions: (json['suggestions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$SearchResultToJson<T>(
  SearchResult<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'results': instance.results.map(toJsonT).toList(),
      'query': instance.query,
      'totalCount': instance.totalCount,
      'searchTime': instance.searchTime.inMicroseconds,
      'facets': instance.facets,
      'suggestions': instance.suggestions,
    };
