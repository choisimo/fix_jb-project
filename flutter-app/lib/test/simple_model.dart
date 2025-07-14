import 'package:freezed_annotation/freezed_annotation.dart';

part 'simple_model.freezed.dart';
part 'simple_model.g.dart';

@freezed
class SimpleModel with _$SimpleModel {
  const factory SimpleModel({
    required String id,
    required String name,
  }) = _SimpleModel;
  
  factory SimpleModel.fromJson(Map<String, dynamic> json) =>
      _$SimpleModelFromJson(json);
}
