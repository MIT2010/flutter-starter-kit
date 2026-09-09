# ADR-0001: Dependency injection via get_it + injectable

## Status

Accepted

## Context

The starter kit requires DI ceremony to come from a generator, never hand-typed
(`getIt.registerFactory(...)` calls scattered across feature code are exactly
the kind of ceremony this project wants to eliminate).

## Decision

Use `get_it` as the service locator and `injectable` as the code-generation
layer on top of it. Every injectable class is annotated (`@injectable`,
`@lazySingleton`, `@singleton`, or bound via `@LazySingleton(as: Interface)`),
and `dart run build_runner build` regenerates `lib/app/di.config.dart`, which
`lib/app/di.dart` calls via `configureDependencies()`.

`di.config.dart` is generated — never hand-edited.

## Alternatives considered

- **Riverpod** (as a DI mechanism, not just state management): would also
  satisfy "no hand-typed registration," but the starter kit defaults to
  `flutter_bloc`/Cubit for state management, and mixing two DI-adjacent
  paradigms (Riverpod providers + get_it) adds conceptual overhead without a
  clear benefit for a starter kit's baseline.
- **Manual `get_it` registration** (no `injectable`): rejected outright —
  this is precisely the ceremony-in-a-human's-hands pattern the project's
  ground rules prohibit.

## Consequences

- Adding any injectable class requires re-running build_runner — this is
  already true for `freezed`/`json_serializable`, so it doesn't introduce a
  new workflow step.
- `@module` classes (see `dio_client.dart`, `hive_client.dart`) are used for
  third-party types (`Dio`, `Box`) that can't carry `@injectable` annotations
  themselves.
