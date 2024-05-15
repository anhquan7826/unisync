// ignore_for_file: constant_identifier_names
import 'package:freezed_annotation/freezed_annotation.dart';

part 'media_playback_state.g.dart';

part 'media_playback_state.freezed.dart';

@freezed
class MediaPlaybackState with _$MediaPlaybackState {
  const factory MediaPlaybackState({
    @Default(6) int? state,
    int? position,
  }) = _MediaPlaybackState;

  factory MediaPlaybackState.fromJson(Map<String, dynamic> json) =>
      _$MediaPlaybackStateFromJson(json);

  static const STATE_BUFFERING = 6;
  static const STATE_PAUSED = 2;
  static const STATE_PLAYING = 3;
  static const STATE_STOPPED = 1;
}
