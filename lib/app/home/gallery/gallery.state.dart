import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:unisync/core/device.dart';
import 'package:unisync/models/media/media.model.dart';

part 'gallery.state.freezed.dart';

@freezed
class GalleryState with _$GalleryState {
  const factory GalleryState({
    Device? device,
    @Default([]) List<(Media, Uint8List?)> media,
  }) = _GalleryState;
}
