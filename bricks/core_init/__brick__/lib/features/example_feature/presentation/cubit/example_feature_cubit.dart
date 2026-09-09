import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/example_feature_repository.dart';
import 'example_feature_state.dart';

@injectable
class ExampleFeatureCubit extends Cubit<ExampleFeatureState> {
  ExampleFeatureCubit(this._repository)
    : super(const ExampleFeatureState.initial());

  final ExampleFeatureRepository _repository;

  Future<void> fetch() async {
    emit(const ExampleFeatureState.loading());
    final result = await _repository.getExampleItem();
    // The user can navigate away (disposing this cubit) before the await
    // above resolves. `emit()` after `close()` THROWS a StateError — it
    // does not no-op — so guard every emit that follows a real await.
    if (isClosed) return;
    emit(
      result.fold(
        onFailure: ExampleFeatureState.error,
        onSuccess: ExampleFeatureState.loaded,
      ),
    );
  }
}
