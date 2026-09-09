import 'package:flutter/material.dart';

import 'app_color_scheme.dart';
import 'app_spacing.dart';

/// Wires the placeholder [ColorScheme] and the [AppSpacing] scale into a
/// [ThemeData]. The colour scheme is a replaceable placeholder; the
/// spacing scale is a valueless mechanism. See the files in this
/// directory and `docs/decisions/ADR-0013-spacing-scaffold.md`.
ThemeData buildAppTheme({required Brightness brightness}) {
  return ThemeData(
    colorScheme: appColorScheme(brightness: brightness),
    extensions: const [AppSpacing.standard()],
    fontFamily: 'Roboto',
    useMaterial3: true,
  );
}
