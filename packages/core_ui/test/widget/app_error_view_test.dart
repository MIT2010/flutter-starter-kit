import 'package:core_ui/core_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('menampilkan title dan message', (tester) async {
    await tester.pumpWidget(
      wrapWithApp(
        const AppErrorView(
          title: 'Terjadi Kesalahan',
          message: 'Gagal memuat data',
        ),
      ),
    );

    expect(find.text('Terjadi Kesalahan'), findsOneWidget);
    expect(find.text('Gagal memuat data'), findsOneWidget);
  });

  testWidgets('tanpa onRetry/retryLabel tidak ada tombol', (tester) async {
    await tester.pumpWidget(
      wrapWithApp(
        const AppErrorView(title: 'Terjadi Kesalahan', message: 'Gagal'),
      ),
    );
    expect(find.byType(AppButton), findsNothing);
  });

  testWidgets('onRetry tanpa retryLabel tidak menampilkan tombol', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapWithApp(
        AppErrorView(
          title: 'Terjadi Kesalahan',
          message: 'Gagal',
          onRetry: () {},
        ),
      ),
    );
    expect(find.byType(AppButton), findsNothing);
  });

  testWidgets('onRetry+retryLabel memanggil callback saat tombol di-tap', (
    tester,
  ) async {
    var retried = false;
    await tester.pumpWidget(
      wrapWithApp(
        AppErrorView(
          title: 'Terjadi Kesalahan',
          message: 'Gagal',
          retryLabel: 'Coba Lagi',
          onRetry: () => retried = true,
        ),
      ),
    );

    await tester.tap(find.text('Coba Lagi'));
    expect(retried, isTrue);
  });
}
