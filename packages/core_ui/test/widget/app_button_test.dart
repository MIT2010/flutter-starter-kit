import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('menampilkan label dan memanggil onPressed saat di-tap', (
    tester,
  ) async {
    var pressed = false;
    await tester.pumpWidget(
      wrapWithApp(AppButton(label: 'Simpan', onPressed: () => pressed = true)),
    );

    expect(find.text('Simpan'), findsOneWidget);
    await tester.tap(find.text('Simpan'));
    expect(pressed, isTrue);
  });

  testWidgets('isDisabled tidak memanggil onPressed', (tester) async {
    var pressed = false;
    await tester.pumpWidget(
      wrapWithApp(
        AppButton(
          label: 'Nonaktif',
          onPressed: () => pressed = true,
          isDisabled: true,
        ),
      ),
    );

    await tester.tap(find.text('Nonaktif'), warnIfMissed: false);
    expect(pressed, isFalse);
  });

  testWidgets('isLoading menampilkan spinner, bukan label', (tester) async {
    await tester.pumpWidget(
      wrapWithApp(AppButton(label: 'Kirim', onPressed: () {}, isLoading: true)),
    );

    expect(find.text('Kirim'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('variant outline pakai OutlinedButton', (tester) async {
    await tester.pumpWidget(
      wrapWithApp(
        AppButton(
          label: 'Batal',
          onPressed: () {},
          variant: AppButtonVariant.outline,
        ),
      ),
    );
    expect(find.byType(OutlinedButton), findsOneWidget);
  });

  testWidgets('variant text pakai TextButton', (tester) async {
    await tester.pumpWidget(
      wrapWithApp(
        AppButton(
          label: 'Lewati',
          onPressed: () {},
          variant: AppButtonVariant.text,
        ),
      ),
    );
    expect(find.byType(TextButton), findsOneWidget);
  });
}
