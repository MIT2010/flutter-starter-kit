import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('menampilkan label', (tester) async {
    await tester.pumpWidget(wrapWithApp(const AppTextField(label: 'Nama')));
    expect(find.text('Nama'), findsOneWidget);
  });

  testWidgets('mengetik memanggil onChanged dengan teks yang benar', (
    tester,
  ) async {
    String? changed;
    await tester.pumpWidget(
      wrapWithApp(
        AppTextField(label: 'Nama', onChanged: (value) => changed = value),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'Budi');
    expect(changed, 'Budi');
  });

  testWidgets('obscureText memaksa maxLines jadi 1', (tester) async {
    await tester.pumpWidget(
      wrapWithApp(
        const AppTextField(label: 'Password', obscureText: true, maxLines: 3),
      ),
    );
    final editableText = tester.widget<EditableText>(find.byType(EditableText));
    expect(editableText.maxLines, 1);
  });

  testWidgets('enabled: false menonaktifkan field', (tester) async {
    await tester.pumpWidget(
      wrapWithApp(const AppTextField(label: 'Nama', enabled: false)),
    );
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.enabled, isFalse);
  });
}
