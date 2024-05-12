import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:unisync/core/device.dart';
import 'package:unisync/models/device_info/device_info.model.dart';

part 'home.state.freezed.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    required int timestamp,
    @Default(false) bool reload,
    @Default(null) DeviceInfo? myDevice,
    required Device currentDevice,
    @Default([]) List<Device> pairedDevices,
  }) = _HomeState;
}
