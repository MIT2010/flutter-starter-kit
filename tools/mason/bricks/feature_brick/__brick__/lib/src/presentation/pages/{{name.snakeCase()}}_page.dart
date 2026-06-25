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
      child: const _{{name.pascalCase()}}View(),
    );
  }
}

class _{{name.pascalCase()}}View extends StatelessWidget {
  const _{{name.pascalCase()}}View();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            {{name.pascalCase()}}Error(:final message) => AppErrorView(
                message: message,
                onRetry: () => context
                    .read<{{name.pascalCase()}}Bloc>()
                    .add(Refresh{{name.pascalCase()}}Event(id: data.id)),
              ),
          };
        },
      ),
    );
  }
}
