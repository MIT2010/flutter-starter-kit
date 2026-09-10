import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/auth_status_notifier.dart';
import '../../../../app/di.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/confirm_dialog.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../cubit/example_feature_cubit.dart';
import '../cubit/example_feature_state.dart';

/// The starter kit's own repo — shown on the welcome screen so a freshly
/// generated project points back at where its architecture is documented.
/// Replace or remove this along with the rest of `example_feature`.
const _starterKitRepo = 'github.com/MIT2010/flutter-starter-kit';

/// The `/` route: a "you're all set" landing that doubles as the reference
/// feature. It runs a real network call ([ExampleFeatureCubit]) and shows
/// the result, so a new project's first `flutter run` confirms the whole
/// data → domain → presentation → Result path works. Delete this feature
/// once the pattern is clear.
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
    final spacing = context.spacing;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _Hero(),
                SizedBox(height: spacing.xl),
                const _SetupCheckCard(),
                SizedBox(height: spacing.xl),
                const _NextSteps(),
                SizedBox(height: spacing.xl),
                const _Footer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final spacing = context.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.rocket_launch_outlined,
              color: colors.onPrimaryContainer,
            ),
          ),
        ),
        SizedBox(height: spacing.md),
        Text("You're all set", style: text.headlineSmall),
        SizedBox(height: spacing.sm),
        Text(
          'This screen is the example_feature reference — a full '
          'data → domain → presentation slice with a real network call and a '
          'Result-based cubit. The card below is that call, live.',
          style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// Renders the [ExampleFeatureCubit] result as a pass/fail setup check.
class _SetupCheckCard extends StatelessWidget {
  const _SetupCheckCard();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final spacing = context.spacing;
    return Container(
      padding: EdgeInsets.all(spacing.lg),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Live data',
                style: text.labelLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                'GET /posts/1',
                style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
          ),
          SizedBox(height: spacing.md),
          BlocBuilder<ExampleFeatureCubit, ExampleFeatureState>(
            builder: (context, state) {
              return switch (state) {
                ExampleFeatureInitial() || ExampleFeatureLoading() => Row(
                  children: [
                    const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: spacing.sm),
                    Text('Fetching…', style: text.bodyMedium),
                  ],
                ),
                ExampleFeatureLoaded(:final item) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 18,
                          color: colors.primary,
                        ),
                        SizedBox(width: spacing.sm),
                        Text(
                          'Network OK',
                          style: text.labelLarge?.copyWith(
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: spacing.md),
                    Text(item.title, style: text.titleMedium),
                    SizedBox(height: spacing.sm),
                    Text(
                      item.body,
                      style: text.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                ExampleFeatureError(:final failure) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 18,
                          color: colors.error,
                        ),
                        SizedBox(width: spacing.sm),
                        Expanded(
                          child: Text(
                            failure.message,
                            style: text.bodyMedium?.copyWith(
                              color: colors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: spacing.md),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton(
                        onPressed: () =>
                            context.read<ExampleFeatureCubit>().fetch(),
                        child: const Text('Retry'),
                      ),
                    ),
                  ],
                ),
              };
            },
          ),
        ],
      ),
    );
  }
}

class _NextSteps extends StatelessWidget {
  const _NextSteps();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final spacing = context.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Next', style: text.titleMedium),
        SizedBox(height: spacing.sm),
        const _StepRow(
          icon: Icons.architecture_outlined,
          title: 'Understand the structure',
          subtitle:
              'docs/ARCHITECTURE.md — what app/, core/ and features/ are for, '
              'and how they talk.',
        ),
        const _StepRow(
          icon: Icons.add_box_outlined,
          title: 'Add a feature',
          subtitle: 'mason make feature --feature_name <name>',
          copyText: 'mason make feature --feature_name <name>',
        ),
        const _StepRow(
          icon: Icons.auto_delete_outlined,
          title: 'Then delete this',
          subtitle:
              'lib/features/example_feature/ is a template — remove it once '
              'the pattern is clear.',
        ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.copyText,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  /// When set, the row is tappable and copies this string to the clipboard.
  final String? copyText;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final spacing = context.spacing;

    final content = Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colors.secondaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: colors.onSecondaryContainer),
            ),
          ),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text.titleSmall),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: text.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (copyText != null) ...[
            SizedBox(width: spacing.sm),
            Icon(
              Icons.content_copy_outlined,
              size: 18,
              color: colors.onSurfaceVariant,
            ),
          ],
        ],
      ),
    );

    if (copyText == null) return content;
    return Semantics(
      button: true,
      label: 'Copy command: $copyText',
      child: Tooltip(
        message: 'Copy to clipboard',
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Clipboard.setData(ClipboardData(text: copyText!));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Copied to clipboard')),
            );
          },
          child: content,
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(
          'Generated with the Flutter Starter Kit',
          style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        SelectableText(
          _starterKitRepo,
          style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}
