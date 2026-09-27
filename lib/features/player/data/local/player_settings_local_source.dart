import 'package:shared_preferences/shared_preferences.dart';

class PlayerSettingsLocalSource {
  const PlayerSettingsLocalSource(this._prefs);

  static const String _speedKey = 'playback_speed';

  final SharedPreferences _prefs;

  double? readSpeed() => _prefs.getDouble(_speedKey);

  Future<void> writeSpeed(double speed) async {
    await _prefs.setDouble(_speedKey, speed);
  }
}
