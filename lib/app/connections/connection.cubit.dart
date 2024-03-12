import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:unisync/core/device.dart';
import 'package:unisync/core/pairing_handler.dart';
import 'package:unisync/models/device_info/device_info.model.dart';
import 'package:unisync/utils/configs.dart';
import 'package:unisync/utils/extensions/cubit.ext.dart';
import 'package:unisync/utils/extensions/list.ext.dart';

import 'connection.state.dart';

class ConnectionCubit extends Cubit<DeviceConnectionState> with BaseCubit {
  ConnectionCubit() : super(const DeviceConnectionState()) {
    load();
  }

  final _subscriptions = CompositeSubscription();

  Future<void> load() async {
    (await Device.getAllDevices()).forEach(_listenDeviceChange);

    Device.instanceNotifier.listen((event) {
      if (event.added) {
        _listenDeviceChange(event.instance);
      }
    }).addTo(_subscriptions);
    // _subscription = DeviceProvider.notifier.listen((value) {
    //   final available = <Device>[];
    //   final requested = <Device>[];
    //   for (final info in value) {
    //     final device = Device(info);
    //     switch (device.pairState) {
    //       case PairState.unpaired:
    //         available.add(device);
    //         break;
    //       case PairState.pairRequested:
    //         requested.add(device);
    //         break;
    //       default:
    //         break;
    //     }
    //   }
    //   safeEmit(DeviceConnectionState(
    //     availableDevices: available,
    //     requestedDevices: requested,
    //   ));
    // });
  }

  void _listenDeviceChange(Device device) {
    device.notifier.listen((event) {
      safeEmit(state.copyWith(
        availableDevices: state.availableDevices.minus(device),
        requestedDevices: state.requestedDevices.minus(device),
        pairedDevices: state.pairedDevices.minus(device),
      ));
      if (event.connected) {
        switch (event.pairState) {
          case PairState.unpaired:
            safeEmit(state.copyWith(
              availableDevices: state.availableDevices.plus(device),
            ));
            break;
          case PairState.paired:
            safeEmit(state.copyWith(
              pairedDevices: state.pairedDevices.plus(device),
            ));
            break;
          case PairState.pairRequested:
            safeEmit(state.copyWith(
              requestedDevices: state.requestedDevices.plus(device),
            ));
            break;
          default:
            break;
        }
      } else {
        if (event.pairState == PairState.paired) {
          safeEmit(state.copyWith(
            pairedDevices: state.pairedDevices.plus(device),
          ));
        }
      }
    }).addTo(_subscriptions);
  }

  void acceptPair(Device device) {
    device.pairOperation.acceptPair();
  }

  void rejectPair(Device device) {
    device.pairOperation.rejectPair();
  }

  Future<DeviceInfo?> getLastConnected() {
    return ConfigUtil.device.getLastUsedDevice();
  }

  @override
  Future<void> close() {
    _subscriptions.cancel();
    return super.close();
  }
}
