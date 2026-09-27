import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._prefs) : super(_readThemeMode(_prefs));

  static const String _themeModeKey = 'theme_mode';

  final SharedPreferences _prefs;

  static ThemeMode _readThemeMode(SharedPreferences prefs) {
    final String? saved = prefs.getString(_themeModeKey);
    return ThemeMode.values.asNameMap()[saved] ?? ThemeMode.system;
  }

  Future<void> toggle(Brightness currentBrightness) async {
    final ThemeMode next = currentBrightness == Brightness.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    emit(next);
    try {
      await _prefs.setString(_themeModeKey, next.name);
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
  }
}
