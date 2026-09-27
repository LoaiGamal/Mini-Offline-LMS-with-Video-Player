import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thaheen_task/core/theme/theme_cubit.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  test('follows the system theme until the user picks one', () async {
    final ThemeCubit cubit = ThemeCubit(await SharedPreferences.getInstance());
    expect(cubit.state, ThemeMode.system);
  });

  test('toggling saves the choice and it survives a restart', () async {
    final ThemeCubit cubit = ThemeCubit(await SharedPreferences.getInstance());
    await cubit.toggle(Brightness.light);
    expect(cubit.state, ThemeMode.dark);

    final ThemeCubit restarted = ThemeCubit(
      await SharedPreferences.getInstance(),
    );
    expect(restarted.state, ThemeMode.dark);
  });

  test('toggling from a dark system theme switches to light', () async {
    final ThemeCubit cubit = ThemeCubit(await SharedPreferences.getInstance());
    await cubit.toggle(Brightness.dark);
    expect(cubit.state, ThemeMode.light);
  });
}
