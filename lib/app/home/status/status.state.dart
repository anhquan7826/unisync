import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:unisync/components/enums/status.dart';

part 'status.state.freezed.dart';

@freezed
class StatusState with _$StatusState {
  const factory StatusState({
    @Default(Status.idle) Status status,
    @Default(-1) int batteryLevel,
    @Default(false) bool isCharging,
    @Default(null) Uint8List? wallpaper,
  }) = _StatusState;
}
