import 'package:flutter/material.dart';

/// Warm, bookish palette: a terracotta seed keeps the "neighborly" feel.
const _seed = Color(0xFFB5603A);

ThemeData buildTheme(Brightness brightness) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: _seed, brightness: brightness),
  );
}
