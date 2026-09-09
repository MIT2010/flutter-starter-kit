import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/app/theme/app_spacing.dart';

void main() {
  group('AppSpacing.standard', () {
    test('is a 4-based step scale', () {
      const s = AppSpacing.standard();
      expect([s.xs, s.sm, s.md, s.lg, s.xl, s.xxl], [4, 8, 16, 24, 32, 48]);
    });
  });

  group('lerp', () {
    test('interpolates each step', () {
      const a = AppSpacing.standard();
      final b = a.copyWith(md: 32);
      final mid = a.lerp(b, 0.5);
      expect(mid.md, 24);
      expect(mid.xs, a.xs); // unchanged steps stay put
    });

    test('returns this when other is not an AppSpacing', () {
      const a = AppSpacing.standard();
      expect(a.lerp(null, 0.5), same(a));
    });
  });

  group('context.spacing', () {
    testWidgets('falls back to the standard scale with no theme extension', (
      tester,
    ) async {
      late AppSpacing resolved;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              resolved = context.spacing;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(resolved.md, 16);
    });

    testWidgets('returns the AppSpacing registered on the theme', (
      tester,
    ) async {
      final custom = const AppSpacing.standard().copyWith(md: 99);
      late AppSpacing resolved;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [custom]),
          home: Builder(
            builder: (context) {
              resolved = context.spacing;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(resolved.md, 99);
    });
  });
}
