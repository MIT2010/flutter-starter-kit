import 'package:core_ui/core_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('title default "Terjadi Kesalahan" kalau tidak diisi', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapWithApp(const AppErrorView(message: 'Gagal memuat data')),
    );

    expect(find.text('Terjadi Kesalahan'), findsOneWidget);
    expect(find.text('Gagal memuat data'), findsOneWidget);
  });

  testWidgets('title custom menimpa default', (tester) async {
    await tester.pumpWidget(
      wrapWithApp(
        const AppErrorView(title: 'Koneksi Terputus', message: 'Cek internet'),
      ),
    );
    expect(find.text('Koneksi Terputus'), findsOneWidget);
    expect(find.text('Terjadi Kesalahan'), findsNothing);
  });

  testWidgets('tanpa onRetry tidak ada tombol', (tester) async {
    await tester.pumpWidget(wrapWithApp(const AppErrorView(message: 'Gagal')));
    expect(find.text('Coba Lagi'), findsNothing);
  });

  testWidgets('onRetry memanggil callback saat tombol di-tap', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      wrapWithApp(
        AppErrorView(message: 'Gagal', onRetry: () => retried = true),
      ),
    );

    await tester.tap(find.text('Coba Lagi'));
    expect(retried, isTrue);
  });
}
