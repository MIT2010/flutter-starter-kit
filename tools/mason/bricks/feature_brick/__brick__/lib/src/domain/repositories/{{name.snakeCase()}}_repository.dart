import 'package:core/core.dart';
import '../entities/{{name.snakeCase()}}_entity.dart';

abstract class {{name.pascalCase()}}Repository {
  FutureEither<{{name.pascalCase()}}Entity> get{{name.pascalCase()}}(String id);
  FutureEither<List<{{name.pascalCase()}}Entity>> getAll{{name.pascalCase()}}s();
}
