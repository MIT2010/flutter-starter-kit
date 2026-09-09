import 'package:flutter/material.dart';

/// Placeholder colour scheme — a starting point, not a final visual identity.
///
/// This starter kit ships no design system and no opinion on your palette.
/// Replace the seed colour (or this whole function) freely; nothing else
/// in the app depends on these specific values.
///
/// Derive the whole scheme from one seed via [ColorScheme.fromSeed], as
/// below. Don't hand-assign a partial `ColorScheme` — that leaves half the
/// Material 3 roles on Flutter's defaults, and the mismatch only shows up
/// on the screens that happen to use those roles.
ColorScheme appColorScheme({required Brightness brightness}) {
  return ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: brightness);
}
