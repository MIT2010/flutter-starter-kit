library feature_{{name.snakeCase()}};

// Domain
export 'src/domain/entities/{{name.snakeCase()}}_entity.dart';
export 'src/domain/repositories/{{name.snakeCase()}}_repository.dart';
export 'src/domain/usecases/get_{{name.snakeCase()}}_usecase.dart';

// Data
export 'src/data/datasources/{{name.snakeCase()}}_local_datasource.dart';
export 'src/data/datasources/{{name.snakeCase()}}_remote_datasource.dart';
export 'src/data/models/{{name.snakeCase()}}_model.dart';
export 'src/data/repositories/{{name.snakeCase()}}_repository_impl.dart';

// Presentation
export 'src/presentation/bloc/{{name.snakeCase()}}_bloc.dart';
export 'src/presentation/pages/{{name.snakeCase()}}_page.dart';
