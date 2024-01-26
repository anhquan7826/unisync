import 'package:equatable/equatable.dart';
import 'package:unisync_backend/models/device_info/device_info.model.dart';

abstract class DeviceConnectionState extends Equatable {
  const DeviceConnectionState();
}

class InitialDevicePairState extends DeviceConnectionState {
  const InitialDevicePairState();

  @override
  List<Object?> get props => [];
}

class GetAllDeviceState extends DeviceConnectionState {
  const GetAllDeviceState(this.devices);

  final List<DeviceInfo> devices;

  @override
  List<Object?> get props => devices;
}

class OnDeviceAddState extends DeviceConnectionState {
  const OnDeviceAddState(this.device);

  final DeviceInfo device;

  @override
  List<Object?> get props => [device];
}

class OnDeviceRemoveState extends DeviceConnectionState {
  const OnDeviceRemoveState(this.device);

  final DeviceInfo device;

  @override
  List<Object?> get props => [device];
}
