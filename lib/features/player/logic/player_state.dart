import 'package:freezed_annotation/freezed_annotation.dart';

part 'player_state.freezed.dart';

@freezed
sealed class PlayerState with _$PlayerState {
  const factory PlayerState.loading() = PlayerLoading;

  const factory PlayerState.ready({
    required Duration position,
    required Duration duration,
    required bool isPlaying,
    required bool isBuffering,
    required double speed,
  }) = PlayerReady;

  const factory PlayerState.error() = PlayerError;
}
