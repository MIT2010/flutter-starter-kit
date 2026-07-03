// ================================================================
// Rename starter kit ini untuk project baru — dipanggil dari
// `melos run setup`. Dart murni (dart:io saja, tanpa dependency
// eksternal) supaya bisa dijalankan langsung
// `dart run tools/scripts/rename_project.dart` tanpa pubspec.yaml
// sendiri.
//
// Menangani identitas apps/main: nama aplikasi (Android/iOS/Web) dan
// package/bundle id, lewat tool `rename` (https://pub.dev/packages/rename)
// plus dua celah yang tidak ditangani tool itu (namespace Gradle dan
// lokasi package Kotlin) dan web/manifest.json — lihat rename_helper.dart.
// ================================================================

import 'dart:io';

import 'rename_helper.dart';

const appDir = 'apps/main';

Future<void> main() async {
  // Selalu dicek, terlepas dari mau rename atau tidak — kalau
  // android/ios/web pernah terhapus manual, `rename` cuma akan error
  // ("Missing build script..."), tidak pernah membuat folder itu lagi.
  await ensurePlatformFolders(appDir);

  stdout.write('Rename starter kit ini untuk project kamu sekarang? (y/N): ');
  final proceed = stdin.readLineSync()?.trim().toLowerCase();
  if (proceed != 'y' && proceed != 'yes') {
    print('Dilewati — jalankan lagi kapan saja lewat `melos run setup`.');
    return;
  }

  String org;
  while (true) {
    stdout.write('Org / reverse-domain (contoh: com.tokokita): ');
    org = (stdin.readLineSync() ?? '').trim();
    if (isValidOrg(org)) break;
    print(
      'Format tidak valid — harus lowercase, minimal 2 segmen dipisah titik (contoh: com.tokokita).',
    );
  }

  String appName;
  while (true) {
    stdout.write('Nama aplikasi (contoh: Toko Kita): ');
    appName = (stdin.readLineSync() ?? '').trim();
    if (appName.isNotEmpty) break;
    print('Nama aplikasi tidak boleh kosong.');
  }

  final snakeName = toSnakeCase(appName);
  final bundleId = '$org.$snakeName';

  print('');
  print('Akan mengubah apps/main menjadi:');
  print('  Nama aplikasi : $appName');
  print('  Package/Bundle: $bundleId');
  print('');

  final ok = await renameApp(
    appDir: appDir,
    appName: appName,
    bundleId: bundleId,
    oldNamespace: readCurrentNamespace(appDir),
  );

  if (!ok) {
    exitCode = 1;
    return;
  }

  print('');
  print('✅ Rename selesai. Cek hasilnya dengan `melos run analyze`.');
}
