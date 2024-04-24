import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:unisync/core/device.dart';

part 'connection.state.freezed.dart';

@freezed
class DeviceConnectionState with _$DeviceConnectionState {
  const factory DeviceConnectionState({
    @Default([]) List<Device> pairedDevices,
    @Default([]) List<Device> requestedDevices,
  }) = _DeviceConnectionState;
}
