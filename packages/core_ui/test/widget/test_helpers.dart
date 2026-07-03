import 'package:flutter/material.dart';

/// Bungkus widget dengan MaterialApp+Scaffold minimal supaya
/// Theme.of/Directionality/dll tersedia di context saat testing.
Widget wrapWithApp(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme,
    home: Scaffold(body: child),
  );
}
