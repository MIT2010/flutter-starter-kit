// ================================================================
// Helper bersama untuk rename_project.dart dan create_app.dart —
// keduanya butuh logic identik untuk mengubah identitas app
// (nama tampilan + package/bundle id) via tool `rename`, plus dua
// celah yang tidak ditangani tool itu (namespace Gradle dan lokasi
// package Kotlin) dan web/manifest.json.
//
// Dart murni (dart:io/dart:convert saja) — diimpor sebagai file
// lokal biasa (bukan lewat pubspec.yaml/package), supaya kedua
// script bisa dijalankan langsung `dart run tools/scripts/xxx.dart`
// tanpa resolusi package.
// ================================================================

import 'dart:convert';
import 'dart:io';

bool isValidOrg(String value) {
  if (value.isEmpty) return false;
  final segments = value.split('.');
  if (segments.length < 2) return false;
  final segmentPattern = RegExp(r'^[a-z][a-z0-9_]*$');
  return segments.every(segmentPattern.hasMatch);
}

/// Konversi "Toko Kita" -> "toko_kita".
String toSnakeCase(String input) {
  final cleaned = input
      .replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
  return cleaned.toLowerCase();
}

String? readCurrentNamespace(String appDir) {
  final gradleFile = File('$appDir/android/app/build.gradle.kts');
  if (!gradleFile.existsSync()) return null;
  final match = RegExp(
    r'namespace\s*=\s*"([^"]+)"',
  ).firstMatch(gradleFile.readAsStringSync());
  return match?.group(1);
}

/// Kalau folder `android`/`ios`/`web` di `appDir` hilang (mis. terhapus
/// manual), generate ulang lewat `flutter create --platforms=...` —
/// diverifikasi langsung: tanpa ini, `rename` cuma error ("Missing
/// build script...") dan folder yang hilang TETAP tidak ada setelahnya,
/// karena `rename` cuma mengedit file yang sudah ada, tidak pernah
/// membuatnya dari nol. `flutter create` terhadap project yang sudah
/// ada aman — hanya menambah platform yang belum ada, tidak menimpa
/// lib/ atau pubspec.yaml.
Future<void> ensurePlatformFolders(String appDir) async {
  var missing = [
    for (final platform in ['android', 'ios', 'web'])
      if (!Directory('$appDir/$platform').existsSync()) platform,
  ];
  if (missing.isEmpty) return;

  print(
    '⚠️  Folder platform hilang: ${missing.join(', ')} — mencoba restore dari git...',
  );

  // Kalau appDir bagian dari repo git yang sudah ter-commit (kasus apps/main
  // di starter kit ini), git HEAD adalah sumber PALING BENAR untuk isi folder
  // itu — sudah termasuk semua kustomisasi (signing scaffold di
  // build.gradle.kts, namespace, lokasi package Kotlin, dst), bukan cuma
  // template default Flutter. Coba ini duluan, baru `flutter create` sebagai
  // fallback untuk platform yang memang belum pernah ter-commit (mis. app
  // baru dari create_app.dart). Diverifikasi langsung: `flutter create` di
  // folder yang di-delete total menghasilkan build.gradle.kts TANPA blok
  // signingConfigs kustom — regresi kalau dibiarkan jadi satu-satunya cara.
  for (final platform in missing) {
    await Process.run('git', ['checkout', 'HEAD', '--', '$appDir/$platform']);
  }

  missing = [
    for (final platform in missing)
      if (!Directory('$appDir/$platform').existsSync()) platform,
  ];
  if (missing.isEmpty) {
    print('✅ Folder platform berhasil di-restore dari git.');
    return;
  }

  print(
    '   Belum pernah ter-commit, generate baru lewat flutter create: ${missing.join(', ')}...',
  );
  final flutterBin = await resolveExecutable('flutter') ?? 'flutter';
  final ok = await runProcess(flutterBin, [
    'create',
    '--platforms=${missing.join(',')}',
    '.',
  ], workingDirectory: appDir);
  if (!ok) {
    print('❌ flutter create gagal — lihat pesan error di atas.');
    return;
  }

  // flutter create bikin test/widget_test.dart default (boilerplate counter
  // test) — starter kit ini pakai test/widget/widget_test.dart, jadi yang
  // default dibuang supaya tidak dobel/basi.
  final defaultTest = File('$appDir/test/widget_test.dart');
  if (defaultTest.existsSync()) defaultTest.deleteSync();
}

/// Ubah identitas app di `appDir` (nama tampilan + bundle id) lewat
/// tool `rename`, plus perbaikan manual untuk 2 celah yang tidak
/// ditangani tool itu. Return `false` kalau salah satu langkah gagal —
/// diverifikasi langsung: `rename` keluar dengan exit code 1 (bukan
/// melempar exception Dart) kalau file yang diedit tidak ada, jadi
/// harus dicek manual, tidak cukup andalkan try/catch.
Future<bool> renameApp({
  required String appDir,
  required String appName,
  required String bundleId,
  required String? oldNamespace,
}) async {
  final renameBin = await resolveExecutable('rename');
  if (renameBin == null) {
    print('❌ Tool "rename" tidak ditemukan. Jalankan dulu:');
    print('   dart pub global activate rename');
    return false;
  }

  final setAppNameOk = await runProcess(renameBin, [
    'setAppName',
    '--targets',
    'ios,android,web',
    '--value',
    appName,
  ], workingDirectory: appDir);

  final setBundleIdOk = await runProcess(renameBin, [
    'setBundleId',
    '--targets',
    'ios,android',
    '--value',
    bundleId,
  ], workingDirectory: appDir);

  if (!setAppNameOk || !setBundleIdOk) {
    print('❌ Rename gagal — lihat pesan error di atas.');
    return false;
  }

  fixNamespaceAndKotlinPackage(
    appDir: appDir,
    newBundleId: bundleId,
    oldNamespace: oldNamespace,
  );

  updateWebManifest(appDir: appDir, appName: appName);
  return true;
}

/// `rename` tidak mengubah `namespace` di build.gradle.kts, dan tidak
/// memindahkan folder + `package` statement MainActivity.kt — diverifikasi
/// langsung lewat uji coba manual sebelum menulis fungsi ini.
void fixNamespaceAndKotlinPackage({
  required String appDir,
  required String newBundleId,
  required String? oldNamespace,
}) {
  final gradleFile = File('$appDir/android/app/build.gradle.kts');
  if (gradleFile.existsSync()) {
    final content = gradleFile.readAsStringSync();
    final updated = content.replaceFirst(
      RegExp(r'namespace\s*=\s*"[^"]+"'),
      'namespace = "$newBundleId"',
    );
    gradleFile.writeAsStringSync(updated);
  }

  if (oldNamespace == null || oldNamespace == newBundleId) return;

  final kotlinRoot = Directory('$appDir/android/app/src/main/kotlin');
  final oldPackageDir = Directory(
    '${kotlinRoot.path}/${oldNamespace.replaceAll('.', '/')}',
  );
  final mainActivity = File('${oldPackageDir.path}/MainActivity.kt');
  if (!mainActivity.existsSync()) return;

  final newPackageDir = Directory(
    '${kotlinRoot.path}/${newBundleId.replaceAll('.', '/')}',
  );
  newPackageDir.createSync(recursive: true);

  final content = mainActivity.readAsStringSync().replaceFirst(
    'package $oldNamespace',
    'package $newBundleId',
  );
  File('${newPackageDir.path}/MainActivity.kt').writeAsStringSync(content);
  mainActivity.deleteSync();

  // Bersihkan folder paket lama yang jadi kosong (mis. com/example/main_app
  // -> hapus main_app, example, com kalau semuanya kosong).
  var dir = oldPackageDir;
  while (dir.path.startsWith(kotlinRoot.path) && dir.path != kotlinRoot.path) {
    if (dir.listSync().isEmpty) {
      dir.deleteSync();
      dir = dir.parent;
    } else {
      break;
    }
  }
}

/// `rename` tidak menyentuh field `name`/`short_name` web/manifest.json.
void updateWebManifest({required String appDir, required String appName}) {
  final manifestFile = File('$appDir/web/manifest.json');
  if (!manifestFile.existsSync()) return;

  final json =
      jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;
  json['name'] = appName;
  json['short_name'] = appName;

  const encoder = JsonEncoder.withIndent('    ');
  manifestFile.writeAsStringSync('${encoder.convert(json)}\n');
}

/// Di Windows, tool seperti `flutter`/`dart pub global activate <x>`
/// menyediakan shim ".bat" — bare filename (tanpa ekstensi) yang
/// ke-resolve lewat `where` sering skrip gaya Unix (bukan Win32
/// executable asli), diverifikasi langsung: `Process.run` terhadap
/// bare "flutter" gagal ("%1 is not a valid Win32 application"), harus
/// PATH ABSOLUT ke ".bat"-nya. Jadi di Windows coba ".bat" DULU, baru
/// bare sebagai fallback. `where` (Windows) / `which` (Unix) dipakai
/// untuk resolve path absolut.
Future<String?> resolveExecutable(String name) async {
  final finder = Platform.isWindows ? 'where' : 'which';
  final candidates = [if (Platform.isWindows) '$name.bat', name];
  for (final candidate in candidates) {
    try {
      final result = await Process.run(finder, [candidate]);
      if (result.exitCode == 0) {
        final firstLine = (result.stdout as String)
            .split(RegExp(r'\r?\n'))
            .firstWhere((line) => line.trim().isNotEmpty, orElse: () => '');
        if (firstLine.isNotEmpty) return firstLine.trim();
      }
    } catch (_) {
      // coba kandidat berikutnya
    }
  }
  return null;
}

/// Return `true` kalau exit code 0. `rename` (dan tool CLI lain) sering
/// tidak melempar exception Dart saat gagal — cuma print pesan error dan
/// keluar dengan exit code bukan 0 — jadi ini WAJIB dicek pemanggilnya,
/// bukan cuma dianggap "kalau tidak crash berarti berhasil".
Future<bool> runProcess(
  String executable,
  List<String> args, {
  required String workingDirectory,
}) async {
  final result = await Process.run(
    executable,
    args,
    workingDirectory: workingDirectory,
  );
  stdout.write(result.stdout);
  if (result.exitCode != 0) {
    stderr.write(result.stderr);
    return false;
  }
  return true;
}
