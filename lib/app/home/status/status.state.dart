import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'status.state.freezed.dart';

@freezed
class StatusState with _$StatusState {
  const factory StatusState({
    @Default(-1) int batteryLevel,
    @Default(false) bool isCharging,
    @Default(null) Uint8List? wallpaper,
  }) = _StatusState;
}
