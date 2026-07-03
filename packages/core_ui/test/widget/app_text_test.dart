import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('menampilkan teks untuk tiap named constructor', (tester) async {
    await tester.pumpWidget(
      wrapWithApp(
        const Column(
          children: [
            AppText.headingLg('Judul'),
            AppText.bodyMd('Isi'),
            AppText.caption('Catatan'),
          ],
        ),
      ),
    );

    expect(find.text('Judul'), findsOneWidget);
    expect(find.text('Isi'), findsOneWidget);
    expect(find.text('Catatan'), findsOneWidget);
  });

  testWidgets('color custom menimpa default', (tester) async {
    await tester.pumpWidget(
      wrapWithApp(const AppText.bodyMd('Berwarna', color: AppColors.error)),
    );
    final text = tester.widget<Text>(find.text('Berwarna'));
    expect(text.style?.color, AppColors.error);
  });

  testWidgets('maxLines diset -> overflow ellipsis', (tester) async {
    await tester.pumpWidget(
      wrapWithApp(const AppText.bodyMd('Panjang', maxLines: 1)),
    );
    final text = tester.widget<Text>(find.text('Panjang'));
    expect(text.maxLines, 1);
    expect(text.overflow, TextOverflow.ellipsis);
  });
}
