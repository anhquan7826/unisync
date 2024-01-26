import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unisync/repository/devices/devices.repo.dart';
import 'package:unisync_backend/models/device_info/device_info.model.dart';

import 'connection.state.dart';

class ConnectionCubit extends Cubit<DeviceConnectionState> implements DevicesRepositoryConnectionListener {
  ConnectionCubit(this._devicesRepo) : super(const InitialDevicePairState()) {
    load();
  }

  final DevicesRepository _devicesRepo;

  Future<void> load() async {
    final devices = await _devicesRepo.getConnectedDevices();
    emit(GetAllDeviceState(devices));
    _devicesRepo.registerConnectionListener(this);
  }

  void connectToIp(String ip) {}

  @override
  Future<void> close() {
    _devicesRepo.unregisterConnectionListener(this);
    return super.close();
  }

  @override
  void onConnected(DeviceInfo device) {
    emit(OnDeviceAddState(device));
  }

  @override
  void onDisconnected(DeviceInfo device) {
    emit(OnDeviceRemoveState(device));
  }
}
