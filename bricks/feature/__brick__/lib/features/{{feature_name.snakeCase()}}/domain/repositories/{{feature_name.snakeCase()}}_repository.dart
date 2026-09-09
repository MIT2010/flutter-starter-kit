import '../../../../core/failure.dart';
import '../../../../core/result.dart';
import '../../data/models/{{feature_name.snakeCase()}}_model.dart';

/// What the presentation layer depends on — never the concrete
/// implementation. Lets the cubit be unit-tested against a mock.
abstract class {{feature_name.pascalCase()}}Repository {
  Future<Result<Failure, {{feature_name.pascalCase()}}Item>> getData();
}
