import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unisync/app/overview/devices_status/devices_status.state.dart';
import 'package:unisync/constants/device_types.dart';
import 'package:unisync/models/device_info/device_info.model.dart';
import 'package:unisync/repository/pairing.repository.dart';
import 'package:unisync/utils/configs.dart';

class DevicesStatusCubit extends Cubit<DevicesStatusState> {
  DevicesStatusCubit() : super(const DevicesStatusInitializing());

  bool _isInitialized = false;

  late DeviceInfo info;
  late final PairingRepository pairingRepository;
  late final Timer _timer;

  Future<void> initialize(PairingRepository pairingRepository) async {
    if (_isInitialized) {
      return;
    }
    this.pairingRepository = pairingRepository;
    info = await AppConfig.device.getDeviceInfo();
    emit(const DevicesStatusInitialized());
    await loadDevices();
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      loadDevices();
    });
    _isInitialized = true;
  }

  List<DeviceInfo> connectedDevices = [
    DeviceInfo(id: 'asdfasd', name: 'asfdasd', deviceType: DeviceTypes.android, ip: '127.0.0.1'),
    DeviceInfo(id: 'asdfasd', name: 'asfdasd', deviceType: DeviceTypes.android, ip: '127.0.0.1'),
    DeviceInfo(id: 'asdfasd', name: 'asfdasd', deviceType: DeviceTypes.android, ip: '127.0.0.1'),
    DeviceInfo(id: 'asdfasd', name: 'asfdasd', deviceType: DeviceTypes.android, ip: '127.0.0.1'),
    DeviceInfo(id: 'asdfasd', name: 'asfdasd', deviceType: DeviceTypes.android, ip: '127.0.0.1'),
    DeviceInfo(id: 'asdfasd', name: 'asfdasd', deviceType: DeviceTypes.android, ip: '127.0.0.1'),
    DeviceInfo(id: 'asdfasd', name: 'asfdasd', deviceType: DeviceTypes.android, ip: '127.0.0.1'),
    DeviceInfo(id: 'asdfasd', name: 'asfdasd', deviceType: DeviceTypes.android, ip: '127.0.0.1'),
    DeviceInfo(id: 'asdfasd', name: 'asfdasd', deviceType: DeviceTypes.android, ip: '127.0.0.1'),
    DeviceInfo(id: 'asdfasd', name: 'asfdasd', deviceType: DeviceTypes.android, ip: '127.0.0.1'),
    DeviceInfo(id: 'asdfasd', name: 'asfdasd', deviceType: DeviceTypes.android, ip: '127.0.0.1'),
    DeviceInfo(id: 'asdfasd', name: 'asfdasd', deviceType: DeviceTypes.android, ip: '127.0.0.1'),
    DeviceInfo(id: 'asdfasd', name: 'asfdasd', deviceType: DeviceTypes.android, ip: '127.0.0.1'),
    DeviceInfo(id: 'asdfasd', name: 'asfdasd', deviceType: DeviceTypes.android, ip: '127.0.0.1'),
  ];
  List<DeviceInfo> disconnectedDevices = [
    DeviceInfo(id: 'asdfasd', name: 'asfdasd', deviceType: DeviceTypes.android, ip: '127.0.0.1'),
  ];
  List<DeviceInfo> unpairedDevices = [];

  Future<void> loadDevices() async {
    unpairedDevices = await pairingRepository.getDiscoveredDevices();
    emit(DevicesStatusAvailableDevicesFetched(unpairedDevices));
  }

  @override
  Future<void> close() {
    _timer.cancel();
    return super.close();
  }
}
