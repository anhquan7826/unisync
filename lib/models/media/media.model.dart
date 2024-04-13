import 'package:freezed_annotation/freezed_annotation.dart';

part 'media.model.freezed.dart';
part 'media.model.g.dart';

@freezed
class Media with _$Media {
  const factory Media({
    required int id,
    required String name,
    required int size,
    required String mimeType,
  }) = _Media;

  factory Media.fromJson(Map<String, dynamic> json) =>
      _$MediaFromJson(json);
}
