import 'package:freezed_annotation/freezed_annotation.dart';

part 'media_metadata.model.g.dart';
part 'media_metadata.model.freezed.dart';

@freezed
class MediaMetadata with _$MediaMetadata {
  const factory MediaMetadata({
    String? id,
    String? title,
    String? artist,
    String? album,
    int? duration,
}) = _MediaMetadata;

  factory MediaMetadata.fromJson(Map<String, dynamic> json) =>
      _$MediaMetadataFromJson(json);
}