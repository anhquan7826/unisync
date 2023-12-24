import 'package:equatable/equatable.dart';
import 'package:unisync/models/device_info/device_info.model.dart';

abstract class DevicePairState extends Equatable {
  const DevicePairState();
}

class InitialDevicePairState extends DevicePairState {
  const InitialDevicePairState();

  @override
  List<Object?> get props => [];
}

class GetAllDeviceState extends DevicePairState {
  const GetAllDeviceState(this.devices);

  final List<DeviceInfo> devices;

  @override
  List<Object?> get props => devices;
}

class OnDeviceAddState extends DevicePairState {
  const OnDeviceAddState(this.device);

  final DeviceInfo device;

  @override
  List<Object?> get props => [device];
}

class OnDeviceRemoveState extends DevicePairState {
  const OnDeviceRemoveState(this.device);

  final DeviceInfo device;

  @override
  List<Object?> get props => [device];
}