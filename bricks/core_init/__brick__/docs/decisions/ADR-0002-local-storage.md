# ADR-0002: Local key-value storage via hive_ce

## Status

Accepted

## Context

The starter kit needs a maintained, lightweight key-value local storage
package (auth token storage, small cached values). The original `hive` /
`hive_flutter` packages are effectively unmaintained upstream — no recent
releases, open issues accumulating without response.

## Decision

Use `hive_ce` (`^2.19.3`) and `hive_ce_flutter` (`^2.3.4`) — the actively
maintained Community Edition fork (published under the IO Design Team /
`hive.isar.community` umbrella). It is API-compatible with classic Hive
(`Hive.initFlutter()`, `Hive.openBox()`, `box.get`/`box.put`), just under the
`package:hive_ce/hive_ce.dart` and `package:hive_ce_flutter/hive_ce_flutter.dart`
import paths, so it was a drop-in choice with an active release history.

`HiveClient` (`lib/core/storage/hive_client.dart`) is the only class allowed
to talk to Hive directly — everything else goes through it, so the storage
engine could be swapped later without touching call sites.

## Alternatives considered

- **`shared_preferences`**: simpler, but backed by platform-native prefs
  storage with no in-memory caching layer and weaker typed-value ergonomics;
  `hive_ce` is a better fit as the app's storage needs grow past trivial
  flags.
- **`drift` / `sqflite`**: full SQL — significant overhead for what this
  starter kit needs out of the box (a handful of KV pairs). A feature that
  genuinely needs relational storage can add one of these later without
  displacing `HiveClient`.

## Consequences

- No custom Hive `TypeAdapter`s are registered in Layer 0 — the shared box
  only stores primitives (`String`, `bool`, etc.) via `Box<dynamic>`. A
  feature that needs to persist a custom object either serializes it to
  JSON first or adds `hive_ce_generator` + a registered adapter — not
  required for the example feature.
