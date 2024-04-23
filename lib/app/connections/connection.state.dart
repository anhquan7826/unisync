import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:unisync/components/enums/status.dart';
import 'package:unisync/core/device.dart';
import 'package:unisync/models/device_info/device_info.model.dart';

part 'connection.state.freezed.dart';

@freezed
class DeviceConnectionState with _$DeviceConnectionState {
  const factory DeviceConnectionState({
    @Default([]) List<Device> availableDevices,
    @Default([]) List<Device> pairedDevices,
    @Default([]) List<Device> requestedDevices,
  }) = _DeviceConnectionState;
}
