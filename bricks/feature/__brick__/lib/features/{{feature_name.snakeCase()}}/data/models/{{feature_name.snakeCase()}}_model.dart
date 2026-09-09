import 'package:freezed_annotation/freezed_annotation.dart';

part '{{feature_name.snakeCase()}}_model.freezed.dart';

/// TODO: replace with this feature's real fields once its data shape is known.
@freezed
abstract class {{feature_name.pascalCase()}}Item with _${{feature_name.pascalCase()}}Item {
  const factory {{feature_name.pascalCase()}}Item({required String message}) = _{{feature_name.pascalCase()}}Item;
}
