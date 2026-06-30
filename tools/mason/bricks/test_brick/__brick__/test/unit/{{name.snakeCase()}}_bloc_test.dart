import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:feature_{{name.snakeCase()}}/feature_{{name.snakeCase()}}.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '{{name.snakeCase()}}_bloc_test.mocks.dart';

// ================================================================
// AUTO-GENERATED — edit sesuai BLoC yang ada di feature ini
// ================================================================

@GenerateMocks([
  Get{{name.pascalCase()}}UseCase,
  // TODO: tambahkan use case lain yang dipakai BLoC
])
void main() {
  late {{name.pascalCase()}}Bloc bloc;
  late MockGet{{name.pascalCase()}}UseCase mockGet{{name.pascalCase()}};

  // ── Test data ────────────────────────────────────────────────
  // TODO: sesuaikan dengan field di {{name.pascalCase()}}Entity
  final t{{name.pascalCase()}} = {{name.pascalCase()}}Entity(
    id: 'test-id-1',
  );

  setUp(() {
    mockGet{{name.pascalCase()}} = MockGet{{name.pascalCase()}}UseCase();

    // Provide dummy values untuk semua Either types yang dipakai
    provideDummy<Either<Failure, {{name.pascalCase()}}Entity>>(
      Either.right(t{{name.pascalCase()}}),
    );
    provideDummy<Either<Failure, List<{{name.pascalCase()}}Entity>>>(
      Either.right([t{{name.pascalCase()}}]),
    );

    bloc = {{name.pascalCase()}}Bloc(
      get{{name.pascalCase()}}: mockGet{{name.pascalCase()}},
      // TODO: tambahkan use case lain sesuai constructor BLoC
    );
  });

  tearDown(() => bloc.close());

  // ── Load{{name.pascalCase()}}Event ────────────────────────────────────────
  group('Load{{name.pascalCase()}}Event', () {
    blocTest<{{name.pascalCase()}}Bloc, {{name.pascalCase()}}State>(
      'emit [{{name.pascalCase()}}Loading, {{name.pascalCase()}}Loaded] saat data berhasil dimuat',
      build: () {
        when(mockGet{{name.pascalCase()}}(any))
            .thenAnswer((_) async => Either.right(t{{name.pascalCase()}}));
        return bloc;
      },
      act: (b) => b.add(Load{{name.pascalCase()}}Event(id: 'test-id-1')),
      expect: () => [
        {{name.pascalCase()}}Loading(),
        {{name.pascalCase()}}Loaded(t{{name.pascalCase()}}),
      ],
      verify: (_) {
        verify(mockGet{{name.pascalCase()}}(any));
      },
    );

    blocTest<{{name.pascalCase()}}Bloc, {{name.pascalCase()}}State>(
      'emit [{{name.pascalCase()}}Loading, {{name.pascalCase()}}Error] saat data tidak ditemukan',
      build: () {
        when(mockGet{{name.pascalCase()}}(any))
            .thenAnswer(
              (_) async => Either.left(const NotFoundFailure()),
            );
        return bloc;
      },
      act: (b) => b.add(Load{{name.pascalCase()}}Event(id: 'tidak-ada')),
      expect: () => [
        {{name.pascalCase()}}Loading(),
        {{name.pascalCase()}}Error('Data tidak ditemukan'),
      ],
    );

    blocTest<{{name.pascalCase()}}Bloc, {{name.pascalCase()}}State>(
      'emit [{{name.pascalCase()}}Loading, {{name.pascalCase()}}Error] saat tidak ada koneksi',
      build: () {
        when(mockGet{{name.pascalCase()}}(any))
            .thenAnswer(
              (_) async => Either.left(const NetworkFailure()),
            );
        return bloc;
      },
      act: (b) => b.add(Load{{name.pascalCase()}}Event(id: 'test-id-1')),
      expect: () => [
        {{name.pascalCase()}}Loading(),
        {{name.pascalCase()}}Error('Tidak ada koneksi internet'),
      ],
    );
  });

  // ── Refresh{{name.pascalCase()}}Event ──────────────────────────────────────
  group('Refresh{{name.pascalCase()}}Event', () {
    blocTest<{{name.pascalCase()}}Bloc, {{name.pascalCase()}}State>(
      'emit [{{name.pascalCase()}}Loaded] saat refresh berhasil',
      build: () {
        when(mockGet{{name.pascalCase()}}(any))
            .thenAnswer((_) async => Either.right(t{{name.pascalCase()}}));
        return bloc;
      },
      act: (b) => b.add(Refresh{{name.pascalCase()}}Event(id: 'test-id-1')),
      expect: () => [
        {{name.pascalCase()}}Loaded(t{{name.pascalCase()}}),
      ],
    );

    blocTest<{{name.pascalCase()}}Bloc, {{name.pascalCase()}}State>(
      'emit [{{name.pascalCase()}}Loading, {{name.pascalCase()}}Error] saat refresh gagal',
      build: () {
        when(mockGet{{name.pascalCase()}}(any))
            .thenAnswer(
              (_) async => Either.left(
                const ServerFailure(message: 'Server error'),
              ),
            );
        return bloc;
      },
      act: (b) => b.add(Refresh{{name.pascalCase()}}Event(id: 'test-id-1')),
      expect: () => [
        {{name.pascalCase()}}Error('Server error'),
      ],
    );
  });

  // ================================================================
  // TODO: Tambahkan group test untuk event lain jika ada
  // ================================================================
}
