import 'package:freezed_annotation/freezed_annotation.dart';

part 'example_item_model.freezed.dart';
part 'example_item_model.g.dart';

/// Maps the example API's `/posts/{id}` response shape.
@freezed
abstract class ExampleItem with _$ExampleItem {
  const factory ExampleItem({
    required int id,
    required String title,
    required String body,
  }) = _ExampleItem;

  factory ExampleItem.fromJson(Map<String, dynamic> json) =>
      _$ExampleItemFromJson(json);
}
