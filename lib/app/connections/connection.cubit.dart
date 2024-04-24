import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unisync/core/device.dart';
import 'package:unisync/core/pairing_handler.dart';
import 'package:unisync/models/device_info/device_info.model.dart';
import 'package:unisync/utils/configs.dart';
import 'package:unisync/utils/extensions/cubit.ext.dart';

import 'connection.state.dart';

class ConnectionCubit extends Cubit<DeviceConnectionState> with BaseCubit {
  ConnectionCubit() : super(const DeviceConnectionState()) {
    load();
  }

  late final StreamSubscription _deviceSubscription;

  Future<void> load() async {
    _deviceSubscription = Device.instanceNotifier.listen(_updateList);
    await Device.getAllDevices();
  }

  void _updateList(List<Device> devices) {
    final requestedDevices = <Device>[];
    final pairedDevices = <Device>[];
    for (final device in devices) {
      if (device.pairState == PairState.paired) {
        pairedDevices.add(device);
      } else if (device.pairState == PairState.pairRequested) {
        requestedDevices.add(device);
      }
    }
    safeEmit(DeviceConnectionState(
      pairedDevices: pairedDevices,
      requestedDevices: requestedDevices,
    ));
  }

  void acceptPair(Device device) {
    device.pairOperation.acceptPair();
  }

  void rejectPair(Device device) {
    device.pairOperation.rejectPair();
  }

  void unpair(Device device) {
    device.pairOperation.unpair();
  }

  Future<DeviceInfo?> getLastConnected() {
    return ConfigUtil.device.getLastUsedDevice();
  }

  @override
  Future<void> close() {
    _deviceSubscription.cancel();
    return super.close();
  }
}
