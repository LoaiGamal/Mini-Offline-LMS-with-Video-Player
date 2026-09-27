import 'package:thaheen_task/features/player/data/local/player_settings_local_source.dart';

class PlayerSettingsRepo {
  const PlayerSettingsRepo(this._localSource);

  final PlayerSettingsLocalSource _localSource;

  double? loadSpeed() {
    try {
      return _localSource.readSpeed();
    } catch (_) {
      return null;
    }
  }

  Future<void> saveSpeed(double speed) => _localSource.writeSpeed(speed);
}
