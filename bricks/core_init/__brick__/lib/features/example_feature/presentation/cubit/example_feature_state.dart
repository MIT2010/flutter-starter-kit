import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/failure.dart';
import '../../data/models/example_item_model.dart';

part 'example_feature_state.freezed.dart';

@freezed
sealed class ExampleFeatureState with _$ExampleFeatureState {
  const factory ExampleFeatureState.initial() = ExampleFeatureInitial;
  const factory ExampleFeatureState.loading() = ExampleFeatureLoading;
  const factory ExampleFeatureState.loaded(ExampleItem item) =
      ExampleFeatureLoaded;
  const factory ExampleFeatureState.error(Failure failure) =
      ExampleFeatureError;
}
