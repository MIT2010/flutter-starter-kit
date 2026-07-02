import 'package:core/core.dart';
import 'package:core_network/core_network.dart';
import '../../domain/entities/{{name.snakeCase()}}_entity.dart';
import '../../domain/repositories/{{name.snakeCase()}}_repository.dart';
import '../datasources/{{name.snakeCase()}}_local_datasource.dart';
import '../datasources/{{name.snakeCase()}}_remote_datasource.dart';

class {{name.pascalCase()}}RepositoryImpl implements {{name.pascalCase()}}Repository {
  const {{name.pascalCase()}}RepositoryImpl({
    required {{name.pascalCase()}}RemoteDataSource remoteDataSource,
    required {{name.pascalCase()}}LocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  })  : _remote = remoteDataSource,
        _local = localDataSource,
        _networkInfo = networkInfo;

  final {{name.pascalCase()}}RemoteDataSource _remote;
  final {{name.pascalCase()}}LocalDataSource _local;
  final NetworkInfo _networkInfo;

  @override
  FutureEither<{{name.pascalCase()}}Entity> get{{name.pascalCase()}}(String id) async {
    if (!await _networkInfo.isConnected) {
      // Offline — coba cache lokal dulu sebelum menyerah.
      final cached = await _local.getCached{{name.pascalCase()}}(id);
      if (cached != null) return Either.right(cached.toEntity());
      return Either.left(const NetworkFailure());
    }
    try {
      final model = await _remote.get{{name.pascalCase()}}(id);
      await _local.cache{{name.pascalCase()}}(model);
      return Either.right(model.toEntity());
    } on UnauthorizedException catch (e) {
      return Either.left(UnauthorizedFailure(message: e.message));
    } on ServerException catch (e) {
      return Either.left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      AppLogger.error('{{name.pascalCase()}}Repository error', e);
      return Either.left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  FutureEither<List<{{name.pascalCase()}}Entity>> getAll{{name.pascalCase()}}s() async {
    if (!await _networkInfo.isConnected) {
      return Either.left(const NetworkFailure());
    }
    try {
      // TODO: implementasi getAll{{name.pascalCase()}}s — panggil datasource yang sesuai.
      return Either.right(const []);
    } on UnauthorizedException catch (e) {
      return Either.left(UnauthorizedFailure(message: e.message));
    } on ServerException catch (e) {
      return Either.left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      AppLogger.error('{{name.pascalCase()}}Repository error', e);
      return Either.left(UnknownFailure(message: e.toString()));
    }
  }
}
