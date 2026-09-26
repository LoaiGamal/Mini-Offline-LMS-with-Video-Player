import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _seedColor = Color(0xFF0F766E);

  static ThemeData get light => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: _seedColor),
  );
}
