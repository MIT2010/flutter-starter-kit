// ================================================================
// Buat app baru dalam satu monorepo (satu produk, banyak app) —
// dipanggil dari `melos run app:new`. Dart murni (dart:io saja)
// supaya bisa dijalankan langsung
// `dart run tools/scripts/create_app.dart` tanpa pubspec.yaml sendiri.
//
// Alur: flutter create (identitas platform benar dari awal) ->
// mason make app_brick (skeleton Dart, timpa default flutter create) ->
// rename (nama tampilan, lihat rename_helper.dart) ->
// daftarkan ke workspace + melos scripts root pubspec.yaml.
// ================================================================

import 'dart:io';

import 'rename_helper.dart';

Future<void> main() async {
  final detectedOrg = _detectOrgFromMain();

  String org;
  while (true) {
    final hint = detectedOrg != null ? ' [$detectedOrg]' : '';
    stdout.write('Org / reverse-domain$hint (contoh: id.nusatalent): ');
    final input = (stdin.readLineSync() ?? '').trim();
    if (input.isEmpty && detectedOrg != null) {
      org = detectedOrg;
      break;
    }
    if (isValidOrg(input)) {
      org = input;
      break;
    }
    print(
      'Format tidak valid — harus lowercase, minimal 2 segmen dipisah titik.',
    );
  }

  String appName;
  while (true) {
    stdout.write('Nama aplikasi (contoh: AkuJamin Biro): ');
    appName = (stdin.readLineSync() ?? '').trim();
    if (appName.isNotEmpty) break;
    print('Nama aplikasi tidak boleh kosong.');
  }

  final defaultSnake = toSnakeCase(appName);
  stdout.write('Nama folder/package, snake_case [$defaultSnake]: ');
  final snakeInput = (stdin.readLineSync() ?? '').trim();
  final snakeName = snakeInput.isEmpty ? defaultSnake : toSnakeCase(snakeInput);

  final appDir = 'apps/$snakeName';
  if (Directory(appDir).existsSync()) {
    print('❌ Error: $appDir sudah ada.');
    exitCode = 1;
    return;
  }

  final bundleId = '$org.$snakeName';

  print('');
  print('Akan membuat app baru:');
  print('  Folder        : $appDir');
  print('  Nama aplikasi : $appName');
  print('  Package/Bundle: $bundleId');
  print('');

  final flutterBin = await resolveExecutable('flutter') ?? 'flutter';
  print('▶ flutter create...');
  final createOk = await runProcess(flutterBin, [
    'create',
    '--project-name',
    snakeName,
    '--org',
    org,
    '--platforms=android,ios,web',
    appDir,
  ], workingDirectory: '.');
  if (!createOk) {
    print('❌ flutter create gagal — lihat pesan error di atas.');
    exitCode = 1;
    return;
  }

  // flutter create bikin test/widget_test.dart default — brick di bawah
  // menaruh smoke test di test/widget/widget_test.dart, jadi yang lama
  // (boilerplate counter test) dibuang supaya tidak dobel/basi.
  final defaultTest = File('$appDir/test/widget_test.dart');
  if (defaultTest.existsSync()) defaultTest.deleteSync();

  final masonBin = await resolveExecutable('mason');
  if (masonBin == null) {
    print('❌ Tool "mason" tidak ditemukan. Jalankan dulu:');
    print('   dart pub global activate mason_cli');
    exitCode = 1;
    return;
  }

  print('▶ mason make app_brick...');
  await runProcess(masonBin, ['get'], workingDirectory: 'tools/mason');

  final varsFile = File('${Directory.systemTemp.path}/app_brick_vars.json')
    ..writeAsStringSync('{"name": "$snakeName"}');
  final makeOk = await runProcess(masonBin, [
    'make',
    'app_brick',
    '--config-path',
    varsFile.path,
    '--output-dir',
    '../../$appDir',
    '--on-conflict',
    'overwrite',
  ], workingDirectory: 'tools/mason');
  varsFile.deleteSync();
  if (!makeOk) {
    print('❌ mason make app_brick gagal — lihat pesan error di atas.');
    exitCode = 1;
    return;
  }

  print('▶ Set nama aplikasi & bundle id...');
  final renamed = await renameApp(
    appDir: appDir,
    appName: appName,
    bundleId: bundleId,
    oldNamespace: readCurrentNamespace(appDir),
  );
  if (!renamed) {
    exitCode = 1;
    return;
  }

  _registerWorkspace(snakeName);
  _insertMelosScripts(snakeName);

  final dartBin = await resolveExecutable('dart') ?? 'dart';

  // pub get di root (workspace) — WAJIB sebelum flutter_native_splash:create
  // di bawah, karena appDir baru saja didaftarkan ke workspace: dan
  // dependency-nya (termasuk flutter_native_splash) belum ter-resolve
  // sama sekali sebelum ini.
  print('▶ dart pub get...');
  await runProcess(dartBin, ['pub', 'get'], workingDirectory: '.');

  // Icon + splash placeholder — app_brick sudah menyertakan
  // assets/icon/{icon,icon_foreground}.png generik (bukan branding asli),
  // supaya app baru langsung punya launcher icon & splash yang konsisten
  // alih-alih dibiarkan default Flutter. Ganti asset itu dengan punya
  // sendiri kapan saja, lalu jalankan ulang kedua command ini.
  print('▶ Generate launcher icon...');
  final iconsOk = await runProcess(dartBin, [
    'pub',
    'global',
    'run',
    'flutter_launcher_icons',
  ], workingDirectory: appDir);
  if (!iconsOk) {
    print(
      '⚠️  flutter_launcher_icons gagal (mungkin belum di-aktivasi: dart pub global activate flutter_launcher_icons) — lewati, bisa dijalankan manual nanti.',
    );
  }

  print('▶ Generate splash screen...');
  final splashOk = await runProcess(dartBin, [
    'run',
    'flutter_native_splash:create',
  ], workingDirectory: appDir);
  if (!splashOk) {
    print(
      '⚠️  flutter_native_splash gagal — lewati, bisa dijalankan manual nanti.',
    );
  }

  print('');
  print('✅ App baru dibuat di $appDir.');
  print('');
  print('📋 Langkah selanjutnya:');
  print('  1. melos run gen:l10n && melos run gen');
  print('  2. Copy config/*.example.json -> config/*.json kalau belum ada');
  print('  3. melos run run:$snakeName:dev:web (atau :android / :ios)');
  print('  4. Tambah fitur lewat melos run feature:new');
  print(
    '  5. Ganti assets/icon/*.png di $appDir dengan branding asli, lalu jalankan ulang:',
  );
  print('     dart pub global run flutter_launcher_icons (dari $appDir)');
  print('     dart run flutter_native_splash:create (dari $appDir)');
}

/// Kalau `apps/main` masih ada, saran org default diambil dari
/// applicationId-nya (buang segmen terakhir) — app kedua dst dalam satu
/// produk biasanya satu org yang sama.
String? _detectOrgFromMain() {
  final gradleFile = File('apps/main/android/app/build.gradle.kts');
  if (!gradleFile.existsSync()) return null;
  final match = RegExp(
    r'applicationId\s*=\s*"([^"]+)"',
  ).firstMatch(gradleFile.readAsStringSync());
  final applicationId = match?.group(1);
  if (applicationId == null) return null;
  final segments = applicationId.split('.');
  if (segments.length < 2) return null;
  return segments.sublist(0, segments.length - 1).join('.');
}

/// Windows checkout git ini pakai CRLF (`\r\n`) — anchor match & insert
/// harus toleran ke line ending itu, diverifikasi langsung: match gagal
/// total kalau anchor di-hardcode pakai `\n` polos.
String _lineEnding(String content) => content.contains('\r\n') ? '\r\n' : '\n';

void _registerWorkspace(String snakeName) {
  final file = File('pubspec.yaml');
  final content = file.readAsStringSync();
  final eol = _lineEnding(content);
  final anchor = RegExp(r'  - apps/main\r?\n');
  if (!anchor.hasMatch(content)) {
    print(
      '⚠️  Tidak menemukan "- apps/main" di pubspec.yaml — daftarkan apps/$snakeName manual ke workspace.',
    );
    return;
  }
  file.writeAsStringSync(
    content.replaceFirstMapped(
      anchor,
      (m) => '${m.group(0)}  - apps/$snakeName$eol',
    ),
  );
}

void _insertMelosScripts(String snakeName) {
  final file = File('pubspec.yaml');
  final content = file.readAsStringSync();
  final eol = _lineEnding(content);
  final anchor = RegExp(r'      description: "Build PWA \(production\)"\r?\n');
  if (!anchor.hasMatch(content)) {
    print(
      '⚠️  Tidak menemukan anchor melos scripts di pubspec.yaml — tambahkan script run:$snakeName:*/build:$snakeName:* manual.',
    );
    return;
  }
  final block = _melosScriptsBlock(snakeName).replaceAll('\n', eol);
  file.writeAsStringSync(
    content.replaceFirstMapped(anchor, (m) => '${m.group(0)}$eol$block'),
  );
}

String _melosScriptsBlock(String name) {
  return '''
    run:$name:dev:
      run: >
        cd apps/$name &&
        flutter run
        --target lib/main.dart
        --dart-define-from-file=../../config/development.json
      description: "Jalankan $name di mode development"

    run:$name:dev:android:
      run: >
        cd apps/$name &&
        flutter run
        --target lib/main.dart
        --dart-define-from-file=../../config/development.json
        -d android
      description: "Jalankan $name di Android (development)"

    run:$name:dev:ios:
      run: >
        cd apps/$name &&
        flutter run
        --target lib/main.dart
        --dart-define-from-file=../../config/development.json
        -d ios
      description: "Jalankan $name di iOS (development)"

    run:$name:dev:web:
      run: >
        cd apps/$name &&
        flutter run
        --target lib/main.dart
        --dart-define-from-file=../../config/development.json
        -d chrome
      description: "Jalankan $name di Chrome (development)"

    run:$name:staging:
      run: >
        cd apps/$name &&
        flutter run
        --target lib/main_staging.dart
        --dart-define-from-file=../../config/staging.json
      description: "Jalankan $name di mode staging"

    build:$name:android:staging:
      run: >
        cd apps/$name &&
        flutter build apk
        --target lib/main_staging.dart
        --dart-define-from-file=../../config/staging.json
        --release
      description: "Build $name Android APK (staging, tanpa obfuscation)"

    build:$name:ios:staging:
      run: >
        cd apps/$name &&
        flutter build ipa
        --target lib/main_staging.dart
        --dart-define-from-file=../../config/staging.json
        --release
      description: "Build $name iOS IPA (staging, tanpa obfuscation)"

    build:$name:web:staging:
      run: >
        cd apps/$name &&
        flutter build web
        --target lib/main_staging.dart
        --dart-define-from-file=../../config/staging.json
        --release
      description: "Build $name PWA (staging)"

    build:$name:android:prod:
      run: >
        cd apps/$name &&
        flutter build apk
        --target lib/main_production.dart
        --dart-define-from-file=../../config/production.json
        --release
        --obfuscate
        --split-debug-info=build/symbols/$name-android
      description: "Build $name Android APK (production, dengan obfuscation)"

    build:$name:ios:prod:
      run: >
        cd apps/$name &&
        flutter build ipa
        --target lib/main_production.dart
        --dart-define-from-file=../../config/production.json
        --release
        --obfuscate
        --split-debug-info=build/symbols/$name-ios
      description: "Build $name iOS IPA (production, dengan obfuscation)"

    build:$name:web:prod:
      run: >
        cd apps/$name &&
        flutter build web
        --target lib/main_production.dart
        --dart-define-from-file=../../config/production.json
        --release
      description: "Build $name PWA (production)"
''';
}
