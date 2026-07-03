import 'package:core_ui/core_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('menampilkan title tanpa message/action', (tester) async {
    await tester.pumpWidget(
      wrapWithApp(const AppEmptyView(title: 'Belum ada data')),
    );

    expect(find.text('Belum ada data'), findsOneWidget);
    expect(find.byType(AppButton), findsNothing);
  });

  testWidgets('menampilkan message kalau diisi', (tester) async {
    await tester.pumpWidget(
      wrapWithApp(
        const AppEmptyView(
          title: 'Belum ada data',
          message: 'Coba tambahkan data baru',
        ),
      ),
    );
    expect(find.text('Coba tambahkan data baru'), findsOneWidget);
  });

  testWidgets('action button memanggil onAction saat di-tap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      wrapWithApp(
        AppEmptyView(
          title: 'Belum ada data',
          actionLabel: 'Tambah',
          onAction: () => tapped = true,
        ),
      ),
    );

    expect(find.text('Tambah'), findsOneWidget);
    await tester.tap(find.text('Tambah'));
    expect(tapped, isTrue);
  });
}
