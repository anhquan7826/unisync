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

class DevicesStatusAvailableDevicesFetched extends DevicesStatusState {
  const DevicesStatusAvailableDevicesFetched(this.devices);

  final List<DeviceInfo> devices;

  @override
  List<Object?> get props => [...devices];
}
