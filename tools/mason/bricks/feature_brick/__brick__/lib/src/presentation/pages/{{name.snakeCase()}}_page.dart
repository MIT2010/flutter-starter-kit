import 'package:core_l10n/core_l10n.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/{{name.snakeCase()}}_bloc.dart';

class {{name.pascalCase()}}Page extends StatelessWidget {
  const {{name.pascalCase()}}Page({super.key, required this.id});

  static const routePath = '/{{name.snakeCase()}}';

  final String id;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => {{name.pascalCase()}}Bloc(
        get{{name.pascalCase()}}: context.read(),
      )..add(Load{{name.pascalCase()}}Event(id: id)),
      child: _{{name.pascalCase()}}View(id: id),
    );
  }
}

class _{{name.pascalCase()}}View extends StatelessWidget {
  const _{{name.pascalCase()}}View({required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // TODO: judul di bawah ini masih hardcode ("{{name.titleCase()}}")
      // karena Mason tidak bisa menebak terjemahan yang tepat untuk fitur
      // baru ini. Tambahkan key sendiri ke
      // core_l10n/lib/i18n/{id,en}.i18n.json, contoh:
      //   "{{name.camelCase()}}": { "title": "..." }
      // lalu ganti baris di bawah jadi context.t.{{name.camelCase()}}.title.
      appBar: AppBar(
        title: const Text('{{name.titleCase()}}'),
      ),
      body: BlocBuilder<{{name.pascalCase()}}Bloc, {{name.pascalCase()}}State>(
        builder: (context, state) {
          return switch (state) {
            {{name.pascalCase()}}Initial() => const SizedBox.shrink(),
            {{name.pascalCase()}}Loading() => const AppLoading(),
            {{name.pascalCase()}}Loaded(:final data) => Center(
                child: Text(data.id),
              ),
            // title & retryLabel WAJIB diisi — AppErrorView tidak punya
            // default hardcoded (lihat komentar di app_error_view.dart),
            // dan tombol retry hanya muncul kalau onRetry DAN retryLabel
            // sama-sama tidak null. Pakai key generik yang sudah ada
            // (bukan bikin key baru) — sudah cukup untuk error state umum.
            {{name.pascalCase()}}Error(:final message) => AppErrorView(
                title: context.t.error.generic,
                message: message,
                retryLabel: context.t.common.retry,
                onRetry: () => context
                    .read<{{name.pascalCase()}}Bloc>()
                    .add(Refresh{{name.pascalCase()}}Event(id: id)),
              ),
          };
        },
      ),
    );
  }
}
