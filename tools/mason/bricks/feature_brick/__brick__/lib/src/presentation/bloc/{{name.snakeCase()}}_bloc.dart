import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/{{name.snakeCase()}}_entity.dart';
import '../../domain/usecases/get_{{name.snakeCase()}}_usecase.dart';

part '{{name.snakeCase()}}_event.dart';
part '{{name.snakeCase()}}_state.dart';

class {{name.pascalCase()}}Bloc extends Bloc<{{name.pascalCase()}}Event, {{name.pascalCase()}}State> {
  {{name.pascalCase()}}Bloc({
    required Get{{name.pascalCase()}}UseCase get{{name.pascalCase()}},
  })  : _get{{name.pascalCase()}} = get{{name.pascalCase()}},
        super({{name.pascalCase()}}Initial()) {
    on<Load{{name.pascalCase()}}Event>(_onLoad);
    on<Refresh{{name.pascalCase()}}Event>(_onRefresh);
  }

  final Get{{name.pascalCase()}}UseCase _get{{name.pascalCase()}};

  Future<void> _onLoad(
    Load{{name.pascalCase()}}Event event,
    Emitter<{{name.pascalCase()}}State> emit,
  ) async {
    emit({{name.pascalCase()}}Loading());
    await _fetch(event.id, emit);
  }

  Future<void> _onRefresh(
    Refresh{{name.pascalCase()}}Event event,
    Emitter<{{name.pascalCase()}}State> emit,
  ) async {
    await _fetch(event.id, emit);
  }

  Future<void> _fetch(String id, Emitter<{{name.pascalCase()}}State> emit) async {
    final result = await _get{{name.pascalCase()}}(Get{{name.pascalCase()}}Params(id: id));
    result.fold(
      (failure) => emit({{name.pascalCase()}}Error(failure.message)),
      (data) => emit({{name.pascalCase()}}Loaded(data)),
    );
  }
}
