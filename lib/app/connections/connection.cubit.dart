import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unisync/core/device.dart';
import 'package:unisync/core/pairing_handler.dart';
import 'package:unisync/models/device_info/device_info.model.dart';
import 'package:unisync/utils/configs.dart';
import 'package:unisync/utils/extensions/cubit.ext.dart';
import 'package:unisync/utils/extensions/list.ext.dart';
import 'package:unisync/utils/logger.dart';

import 'connection.state.dart';

class ConnectionCubit extends Cubit<DeviceConnectionState> with BaseCubit {
  ConnectionCubit() : super(const DeviceConnectionState()) {
    load();
  }

  late final StreamSubscription _deviceSubscription;
  final _subscriptions = <Device, StreamSubscription>{};

  Future<void> load() async {
    _deviceSubscription = Device.instanceNotifier.listen((event) {
      for (final device in event) {
        if (_subscriptions.containsKey(device)) {
          continue;
        } else {
          _listenDeviceChange(device);
        }
      }
      _subscriptions.removeWhere((key, value) {
        final toRemove = !event.contains(key);
        if (toRemove) {
          value.cancel();
        }
        return toRemove;
      });
    });
    await Device.getAllDevices();
  }

  void _listenDeviceChange(Device device) {
    _subscriptions[device] = device.notifier.listen((event) {
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
    });
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
    _subscriptions.forEach((key, value) {
      value.cancel();
    });
    _deviceSubscription.cancel();
    return super.close();
  }
}
