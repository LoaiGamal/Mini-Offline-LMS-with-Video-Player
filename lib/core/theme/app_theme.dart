import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const String _bodyFont = 'IBMPlexSansArabic';
  static const String _headingFont = 'ReadexPro';

  static const Color _highlight = Color(0xFF0F4F49);
  static const Color _highlightTrack = Color(0xFF2B6B64);
  static const Color _onHighlightMuted = Color(0xFFCFE6E2);

  static const ColorScheme _lightColors = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF0F6B63),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFE3F1EF),
    onPrimaryContainer: Color(0xFF0F6B63),
    primaryFixed: _highlight,
    primaryFixedDim: _highlightTrack,
    onPrimaryFixed: Color(0xFFFFFFFF),
    onPrimaryFixedVariant: _onHighlightMuted,
    secondary: Color(0xFFF4B860),
    onSecondary: Color(0xFF3A2604),
    tertiary: Color(0xFFB45309),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFFDF1E3),
    onTertiaryContainer: Color(0xFF92400E),
    error: Color(0xFFB42318),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFBE9E7),
    onErrorContainer: Color(0xFFB42318),
    surface: Color(0xFFF6F5F1),
    onSurface: Color(0xFF1B1F1E),
    onSurfaceVariant: Color(0xFF5B6461),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerHighest: Color(0xFFEFEDE7),
    outline: Color(0xFF6B7370),
    outlineVariant: Color(0xFFE3E1DA),
    inverseSurface: Color(0xFF1B1F1E),
    onInverseSurface: Color(0xFFFFFFFF),
  );

  static const ColorScheme _darkColors = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF4FB3A8),
    onPrimary: Color(0xFF0B1F1C),
    primaryContainer: Color(0xFF16403B),
    onPrimaryContainer: Color(0xFFCFE6E2),
    primaryFixed: _highlight,
    primaryFixedDim: _highlightTrack,
    onPrimaryFixed: Color(0xFFFFFFFF),
    onPrimaryFixedVariant: _onHighlightMuted,
    secondary: Color(0xFFF4B860),
    onSecondary: Color(0xFF3A2604),
    tertiary: Color(0xFFF4B860),
    onTertiary: Color(0xFF3A2604),
    tertiaryContainer: Color(0xFF3A2A12),
    onTertiaryContainer: Color(0xFFF4B860),
    error: Color(0xFFF97066),
    onError: Color(0xFF3B1A17),
    errorContainer: Color(0xFF3B1A17),
    onErrorContainer: Color(0xFFF97066),
    surface: Color(0xFF111615),
    onSurface: Color(0xFFE8ECEA),
    onSurfaceVariant: Color(0xFF9AA5A1),
    surfaceContainerLowest: Color(0xFF1A2120),
    surfaceContainerHighest: Color(0xFF26302E),
    outline: Color(0xFF9AA5A1),
    outlineVariant: Color(0xFF2A3331),
    inverseSurface: Color(0xFFE8ECEA),
    onInverseSurface: Color(0xFF111615),
  );

  static const TextTheme _textTheme = TextTheme(
    headlineMedium: TextStyle(fontFamily: _headingFont, fontSize: 26, fontWeight: FontWeight.w700),
    headlineSmall: TextStyle(fontFamily: _headingFont, fontSize: 24, fontWeight: FontWeight.w700),
    titleLarge: TextStyle(fontFamily: _headingFont, fontSize: 20, fontWeight: FontWeight.w700),
    titleMedium: TextStyle(fontFamily: _headingFont, fontSize: 17, fontWeight: FontWeight.w600),
    titleSmall: TextStyle(fontFamily: _headingFont, fontSize: 16, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(fontSize: 15, height: 1.6),
    bodyMedium: TextStyle(fontSize: 14, height: 1.5),
    bodySmall: TextStyle(fontSize: 13, height: 1.5),
    labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
    labelMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
  );

  static ThemeData get light => _build(_lightColors);

  static ThemeData get dark => _build(_darkColors);

  static ThemeData _build(ColorScheme colors) {
    return ThemeData(
      colorScheme: colors,
      fontFamily: _bodyFont,
      textTheme: _textTheme,
      scaffoldBackgroundColor: colors.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      dividerTheme: DividerThemeData(color: colors.outlineVariant, thickness: 1, space: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.inverseSurface,
        contentTextStyle: TextStyle(
          fontFamily: _bodyFont,
          fontSize: 14,
          height: 1.5,
          color: colors.onInverseSurface,
        ),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
      ),
    );
  }
}
