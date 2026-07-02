import 'package:core/core.dart';
import 'package:core_network/core_network.dart';
import '../models/{{name.snakeCase()}}_model.dart';

abstract class {{name.pascalCase()}}RemoteDataSource {
  Future<{{name.pascalCase()}}Model> get{{name.pascalCase()}}(String id);
}

class {{name.pascalCase()}}RemoteDataSourceImpl implements {{name.pascalCase()}}RemoteDataSource {
  const {{name.pascalCase()}}RemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<{{name.pascalCase()}}Model> get{{name.pascalCase()}}(String id) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/{{name.snakeCase()}}s/$id',
      fromData: (json) => json as Map<String, dynamic>,
    );

    if (!response.isSuccess || response.data == null) {
      throw ServerException(message: response.errorText);
    }

    return {{name.pascalCase()}}Model.fromJson(response.data!);
  }
}
