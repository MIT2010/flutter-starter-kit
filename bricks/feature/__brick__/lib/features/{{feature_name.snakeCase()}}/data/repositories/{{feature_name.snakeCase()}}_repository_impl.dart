import 'package:injectable/injectable.dart';

import '../../../../core/failure.dart';
import '../../../../core/result.dart';
import '../../domain/repositories/{{feature_name.snakeCase()}}_repository.dart';
import '../models/{{feature_name.snakeCase()}}_model.dart';

/// TODO: replace this stub with a real data source — a network call via the
/// shared Dio client (see example_feature for the pattern), local storage
/// via HiveClient, or another repository. Map every failure path onto
/// [Failure] here — never let a raw exception or backend string escape.
@LazySingleton(as: {{feature_name.pascalCase()}}Repository)
class {{feature_name.pascalCase()}}RepositoryImpl implements {{feature_name.pascalCase()}}Repository {
  @override
  Future<Result<Failure, {{feature_name.pascalCase()}}Item>> getData() async {
    // TODO: implement real data fetching.
    return const Result.success({{feature_name.pascalCase()}}Item(message: '{{feature_name.titleCase()}} works!'));
  }
}
