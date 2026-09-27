import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thaheen_task/features/player/data/local/player_settings_local_source.dart';
import 'package:thaheen_task/features/player/data/repo/player_settings_repo.dart';

Future<PlayerSettingsRepo> createRepo() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return PlayerSettingsRepo(PlayerSettingsLocalSource(prefs));
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  test('has no saved speed on first launch', () async {
    expect((await createRepo()).loadSpeed(), isNull);
  });

  test('the saved speed survives an app restart', () async {
    await (await createRepo()).saveSpeed(1.5);
    expect((await createRepo()).loadSpeed(), 1.5);
  });

  test('a corrupt saved value is ignored', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'playback_speed': 'fast',
    });
    expect((await createRepo()).loadSpeed(), isNull);
  });
}
