import 'package:core/core.dart';
import 'package:core_network/core_network.dart';
import 'package:fpdart/fpdart.dart';
import '../../domain/entities/{{name.snakeCase()}}_entity.dart';
import '../../domain/repositories/{{name.snakeCase()}}_repository.dart';
import '../datasources/{{name.snakeCase()}}_remote_datasource.dart';

class {{name.pascalCase()}}RepositoryImpl implements {{name.pascalCase()}}Repository {
  const {{name.pascalCase()}}RepositoryImpl({
    required {{name.pascalCase()}}RemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remote = remoteDataSource,
        _networkInfo = networkInfo;

  final {{name.pascalCase()}}RemoteDataSource _remote;
  final NetworkInfo _networkInfo;

  @override
  FutureEither<{{name.pascalCase()}}Entity> get{{name.pascalCase()}}(String id) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final model = await _remote.get{{name.pascalCase()}}(id);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      AppLogger.error('{{name.pascalCase()}}Repository error', e);
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  FutureEither<List<{{name.pascalCase()}}Entity>> getAll{{name.pascalCase()}}s() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      // TODO: implementasi getAll
      return const Right([]);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      AppLogger.error('{{name.pascalCase()}}Repository error', e);
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
