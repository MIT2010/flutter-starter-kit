import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:{{project_name}}/app/router.dart';

class _MockGoRouterState extends Mock implements GoRouterState {}

class _Args {
  const _Args();
}

void main() {
  late _MockGoRouterState state;

  setUp(() => state = _MockGoRouterState());

  group('requireExtra', () {
    test('returns null when extra is the expected type', () {
      when(() => state.extra).thenReturn(const _Args());
      expect(requireExtra<_Args>(state, fallback: '/'), isNull);
    });

    test('returns the fallback when extra is null', () {
      when(() => state.extra).thenReturn(null);
      expect(requireExtra<_Args>(state, fallback: '/'), '/');
    });

    test('returns the fallback when extra is a different type', () {
      when(() => state.extra).thenReturn('not the args object');
      expect(requireExtra<_Args>(state, fallback: '/home'), '/home');
    });
  });
}
