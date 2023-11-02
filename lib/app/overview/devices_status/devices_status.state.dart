import 'package:equatable/equatable.dart';
import 'package:unisync/models/device_info/device_info.model.dart';

abstract class DevicesStatusState extends Equatable {
  const DevicesStatusState();
}

class DevicesStatusInitializing extends DevicesStatusState {
  const DevicesStatusInitializing();

  @override
  List<Object?> get props => [];
}

class DevicesStatusInitialized extends DevicesStatusState {
  const DevicesStatusInitialized();

  @override
  List<Object?> get props => [];
}

class OnDeviceConnectedState extends DevicesStatusState {
  const OnDeviceConnectedState(this.device);

  final DeviceInfo device;

  @override
  List<Object?> get props => [device];
}

class OnDeviceDisconnectedState extends DevicesStatusState {
  const OnDeviceDisconnectedState(this.device);

  final DeviceInfo device;

  @override
  List<Object?> get props => [device];
}
