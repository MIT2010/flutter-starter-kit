import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/auth_status_notifier.dart';
import '../../../../app/di.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/confirm_dialog.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../cubit/example_feature_cubit.dart';
import '../cubit/example_feature_state.dart';

class ExampleFeaturePage extends StatelessWidget {
  const ExampleFeaturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ExampleFeatureCubit>()..fetch(),
      child: const _ExampleFeatureView(),
    );
  }
}

class _ExampleFeatureView extends StatelessWidget {
  const _ExampleFeatureView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example feature'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            // Calls the repository + notifier directly rather than
            // getIt<AuthCubit>() — AuthCubit is factory-scoped for
            // LoginPage's own BlocProvider lifecycle; resolving a fresh
            // one here just to call logout() would create an instance
            // that's never provided to a BlocProvider and never closed.
            onPressed: () async {
              final confirmed = await confirmDialog(
                context,
                title: 'Log out?',
                message: 'You will need to sign in again to continue.',
                confirmLabel: 'Log out',
              );
              if (!confirmed || !context.mounted) return;
              await getIt<AuthRepository>().logout();
              await getIt<AuthStatusNotifier>().markUnauthenticated();
            },
          ),
        ],
      ),
      body: BlocBuilder<ExampleFeatureCubit, ExampleFeatureState>(
        builder: (context, state) {
          return switch (state) {
            ExampleFeatureInitial() || ExampleFeatureLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            ExampleFeatureLoaded(:final item) => Center(
              child: Padding(
                padding: EdgeInsets.all(context.spacing.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: context.spacing.sm),
                    Text(item.body),
                  ],
                ),
              ),
            ),
            ExampleFeatureError(:final failure) => Center(
              child: Padding(
                padding: EdgeInsets.all(context.spacing.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(failure.message, textAlign: TextAlign.center),
                    SizedBox(height: context.spacing.md),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<ExampleFeatureCubit>().fetch(),
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
