import 'package:core/core.dart';
import 'package:feature_{{name.snakeCase()}}/feature_{{name.snakeCase()}}.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '{{name.snakeCase()}}_usecase_test.mocks.dart';

// ================================================================
// AUTO-GENERATED — edit sesuai use case yang ada di feature ini
// ================================================================

@GenerateMocks([{{name.pascalCase()}}Repository])
void main() {
  late Mock{{name.pascalCase()}}Repository mockRepository;

  // ── Test data ────────────────────────────────────────────────
  // TODO: sesuaikan dengan field di {{name.pascalCase()}}Entity
  final t{{name.pascalCase()}} = {{name.pascalCase()}}Entity(
    id: 'test-id-1',
  );

  setUp(() {
    mockRepository = Mock{{name.pascalCase()}}Repository();

    // Provide dummy values untuk semua Either types yang dipakai
    provideDummy<Either<Failure, {{name.pascalCase()}}Entity>>(
      Either.right(t{{name.pascalCase()}}),
    );
    provideDummy<Either<Failure, List<{{name.pascalCase()}}Entity>>>(
      Either.right([t{{name.pascalCase()}}]),
    );
    provideDummy<Either<Failure, Unit>>(
      Either.right(unit),
    );
  });

  // ── Get{{name.pascalCase()}}UseCase ──────────────────────────────────────
  group('Get{{name.pascalCase()}}UseCase', () {
    late Get{{name.pascalCase()}}UseCase useCase;

    setUp(() {
      useCase = Get{{name.pascalCase()}}UseCase(mockRepository);
    });

    test('harus mengembalikan {{name.pascalCase()}}Entity saat berhasil', () async {
      // Arrange
      when(mockRepository.get{{name.pascalCase()}}(any))
          .thenAnswer((_) async => Either.right(t{{name.pascalCase()}}));

      // Act
      final result = await useCase(
        Get{{name.pascalCase()}}Params(id: 'test-id-1'),
      );

      // Assert
      expect(result, Either.right(t{{name.pascalCase()}}));
      verify(mockRepository.get{{name.pascalCase()}}('test-id-1'));
      verifyNoMoreInteractions(mockRepository);
    });

    test('harus mengembalikan NotFoundFailure saat data tidak ada', () async {
      // Arrange
      when(mockRepository.get{{name.pascalCase()}}(any))
          .thenAnswer((_) async => Either.left(const NotFoundFailure()));

      // Act
      final result = await useCase(
        Get{{name.pascalCase()}}Params(id: 'tidak-ada'),
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NotFoundFailure>()),
        (_) => fail('Seharusnya gagal'),
      );
    });

    test('harus mengembalikan NetworkFailure saat tidak ada koneksi', () async {
      // Arrange
      when(mockRepository.get{{name.pascalCase()}}(any))
          .thenAnswer((_) async => Either.left(const NetworkFailure()));

      // Act
      final result = await useCase(
        Get{{name.pascalCase()}}Params(id: 'test-id-1'),
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Seharusnya gagal'),
      );
    });

    test('harus mengembalikan ServerFailure saat server error', () async {
      // Arrange
      when(mockRepository.get{{name.pascalCase()}}(any))
          .thenAnswer(
            (_) async => Either.left(
              const ServerFailure(message: 'Internal Server Error'),
            ),
          );

      // Act
      final result = await useCase(
        Get{{name.pascalCase()}}Params(id: 'test-id-1'),
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Internal Server Error');
        },
        (_) => fail('Seharusnya gagal'),
      );
    });
  });

  // ================================================================
  // TODO: Tambahkan group test untuk use case lain
  //
  // Pola yang sama untuk setiap use case:
  //
  // group('Create{{name.pascalCase()}}UseCase', () {
  //   late Create{{name.pascalCase()}}UseCase useCase;
  //
  //   setUp(() {
  //     useCase = Create{{name.pascalCase()}}UseCase(mockRepository);
  //   });
  //
  //   test('harus mengembalikan {{name.pascalCase()}}Entity saat berhasil', ...);
  //   test('harus mengembalikan ValidationFailure saat input kosong', ...);
  //   test('harus mengembalikan NetworkFailure saat tidak ada koneksi', ...);
  //   test('harus mengembalikan ServerFailure saat server error', ...);
  // });
  // ================================================================
}
