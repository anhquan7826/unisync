import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:unisync/core/device.dart';
import 'package:unisync/models/device_info/device_info.model.dart';

part 'status.state.freezed.dart';

@freezed
class StatusState with _$StatusState {
  const factory StatusState({
    @Default(null) Device? device,
    @Default(false) bool isOnline,
    @Default(null) String? ipAddress,
    @Default(-1) int batteryLevel,
    @Default(false) bool isCharging,
    @Default(null) Uint8List? wallpaper,
  }) = _StatusState;
}
