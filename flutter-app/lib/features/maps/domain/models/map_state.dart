import 'package:freezed_annotation/freezed_annotation.dart';

part 'map_state.freezed.dart';
part 'map_state.g.dart';

@freezed
class MapState with _$MapState {
  const factory MapState({
    @Default(37.5666805) double centerLatitude,
    @Default(126.9784147) double centerLongitude,
    @Default(15.0) double zoomLevel,
    @Default([]) List<SearchResult> searchResults,
  }) = _MapState;
  
  factory MapState.fromJson(Map<String, dynamic> json) =>
      _$MapStateFromJson(json);
}

@freezed
class SearchResult with _$SearchResult {
  const factory SearchResult({
    required String id,
    required String title,
    required String address,
    required double latitude,
    required double longitude,
    String? category,
    String? phone,
  }) = _SearchResult;
  
  factory SearchResult.fromJson(Map<String, dynamic> json) =>
      _$SearchResultFromJson(json);
}
