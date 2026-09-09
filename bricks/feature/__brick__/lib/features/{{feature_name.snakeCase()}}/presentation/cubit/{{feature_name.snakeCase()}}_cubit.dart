import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/{{feature_name.snakeCase()}}_repository.dart';
import '{{feature_name.snakeCase()}}_state.dart';

@injectable
class {{feature_name.pascalCase()}}Cubit extends Cubit<{{feature_name.pascalCase()}}State> {
  {{feature_name.pascalCase()}}Cubit(this._repository) : super(const {{feature_name.pascalCase()}}State.initial());

  final {{feature_name.pascalCase()}}Repository _repository;

  Future<void> fetch() async {
    emit(const {{feature_name.pascalCase()}}State.loading());
    final result = await _repository.getData();
    // The user can navigate away (disposing this cubit) before the await
    // above resolves. `emit()` after `close()` THROWS a StateError — it
    // does not no-op — so guard every emit that follows a real await.
    if (isClosed) return;
    emit(
      result.fold(
        onFailure: {{feature_name.pascalCase()}}State.error,
        onSuccess: {{feature_name.pascalCase()}}State.loaded,
      ),
    );
  }
}
