import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unisync/components/enums/status.dart';
import 'package:unisync/core/device_provider.dart';
import 'package:unisync/core/pairing_handler.dart';
import 'package:unisync/models/device_info/device_info.model.dart';
import 'package:unisync/utils/extensions/cubit.ext.dart';
import 'package:unisync/utils/logger.dart';

import 'connection.state.dart';

class ConnectionCubit extends Cubit<DeviceConnectionState> with BaseCubit {
  ConnectionCubit() : super(const DeviceConnectionState()) {
    load();
  }

  late StreamSubscription<DeviceNotification> _subscription;

  Future<void> load() async {
    final available = DeviceProvider.devices.where((element) {
      final device = DeviceProvider.get(element);
      return device?.pairState == PairState.unpaired;
    }).toSet();
    final requested = DeviceProvider.devices.where((element) {
      final device = DeviceProvider.get(element);
      return device?.pairState == PairState.pairRequested;
    }).toSet();
    safeEmit(state.copyWith(
      status: Status.loaded,
      requestedDevices: requested,
      availableDevices: available,
    ));
    _registerListener();
  }

  void _registerListener() {
    _subscription = DeviceProvider.deviceNotifier.listen((value) {
      debugLog(value.device.name);
      debugLog(value.connected);
      debugLog(value.pairState);
      if (!value.connected) {
        safeEmit(state.copyWith(
          requestedDevices: {...state.requestedDevices}..remove(value.device),
          availableDevices: {...state.availableDevices}..remove(value.device),
        ));
      } else {
        switch (value.pairState!) {
          case PairState.pairRequested:
            safeEmit(state.copyWith(
              requestedDevices: {...state.requestedDevices, value.device},
              availableDevices: {...state.availableDevices}..remove(value.device),
            ));
          case PairState.paired:
            safeEmit(state.copyWith(
              requestedDevices: {...state.requestedDevices}..remove(value.device),
              availableDevices: {...state.availableDevices}..remove(value.device),
            ));
          case PairState.unpaired:
            safeEmit(state.copyWith(
              requestedDevices: {...state.requestedDevices}..remove(value.device),
              availableDevices: {...state.availableDevices, value.device},
            ));
        }
      }
    });
  }

  void acceptPair(DeviceInfo device) {
    DeviceProvider.get(device)?.pairOperation.acceptPair();
  }

  void rejectPair(DeviceInfo device) {
    DeviceProvider.get(device)?.pairOperation.rejectPair();
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
