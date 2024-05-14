import 'package:freezed_annotation/freezed_annotation.dart';

part 'media_playback.model.g.dart';
part 'media_playback.model.freezed.dart';

@freezed
class MediaPlayback with _$MediaPlayback {
  const factory MediaPlayback() = _MediaPlayback;

  factory MediaPlayback.fromJson(Map<String, dynamic> json) =>
      _$MediaPlaybackFromJson(json);
}
