import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unisync/app/overview/devices_status/devices_status.state.dart';
import 'package:unisync/models/device_info/device_info.model.dart';
import 'package:unisync/repository/pairing.repository.dart';
import 'package:unisync/utils/configs.dart';

class DevicesStatusCubit extends Cubit<DevicesStatusState> {
  DevicesStatusCubit(BuildContext context) : super(const DevicesStatusInitializing()) {
    pairingRepository = RepositoryProvider.of<PairingRepository>(context);
    initialize();
  }

  late DeviceInfo info;
  late final PairingRepository pairingRepository;

  late final DeviceStateCallback _callback = DeviceStateCallback(
    onDeviceConnected: (device) async {
      if (await pairingRepository.isDevicePaired(device)) {
        connectedDevices.add(device);
      } else {
        unpairedDevices.add(device);
      }
      emit(OnDeviceConnectedState(device));
    },
    onDeviceDisconnected: (device) async {
      if (await pairingRepository.isDevicePaired(device)) {
        connectedDevices.removeWhere((element) => element.id == device.id);
        disconnectedDevices.add(device);
      } else {
        unpairedDevices.removeWhere((element) => element.id == device.id);
      }
      emit(OnDeviceDisconnectedState(device));
    },
  );

  late List<DeviceInfo> connectedDevices;
  late List<DeviceInfo> disconnectedDevices;
  late List<DeviceInfo> unpairedDevices;

  Future<void> initialize() async {
    info = await ConfigUtil.device.getDeviceInfo();
    pairingRepository.addDeviceStateListener(_callback);
    await loadDevices();
    emit(const DevicesStatusInitialized());
  }

  Future<void> loadDevices() async {
    unpairedDevices = await pairingRepository.getUnpairedDevices();
    final pairedDevices = await pairingRepository.getPairedDevices();
    connectedDevices = pairedDevices.where((element) => element.ip.isNotEmpty).toList();
    disconnectedDevices = pairedDevices.where((element) => element.ip.isEmpty).toList();
  }

  @override
  Future<void> close() {
    pairingRepository.removeDeviceStateListener(_callback);
    return super.close();
  }
}
