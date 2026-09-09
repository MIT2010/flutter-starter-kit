import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di.dart';
import '../../../../app/theme/app_spacing.dart';
import '../cubit/{{feature_name.snakeCase()}}_cubit.dart';
import '../cubit/{{feature_name.snakeCase()}}_state.dart';

class {{feature_name.pascalCase()}}Page extends StatelessWidget {
  const {{feature_name.pascalCase()}}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<{{feature_name.pascalCase()}}Cubit>()..fetch(),
      child: const _{{feature_name.pascalCase()}}View(),
    );
  }
}

class _{{feature_name.pascalCase()}}View extends StatelessWidget {
  const _{{feature_name.pascalCase()}}View();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('{{feature_name.titleCase()}}')),
      body: BlocBuilder<{{feature_name.pascalCase()}}Cubit, {{feature_name.pascalCase()}}State>(
        builder: (context, state) {
          return switch (state) {
            {{feature_name.pascalCase()}}Initial() || {{feature_name.pascalCase()}}Loading() => const Center(
              child: CircularProgressIndicator(),
            ),
            {{feature_name.pascalCase()}}Loaded(:final item) => Center(child: Text(item.message)),
            {{feature_name.pascalCase()}}Error(:final failure) => Center(
              child: Padding(
                padding: EdgeInsets.all(context.spacing.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(failure.message, textAlign: TextAlign.center),
                    SizedBox(height: context.spacing.md),
                    ElevatedButton(
                      onPressed: () => context.read<{{feature_name.pascalCase()}}Cubit>().fetch(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          };
        },
      ),
    );
  }
}
