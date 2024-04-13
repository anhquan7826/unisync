import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unisync/app/home/home.state.dart';
import 'package:unisync/core/device.dart';
import 'package:unisync/core/pairing_handler.dart';
import 'package:unisync/utils/configs.dart';
import 'package:unisync/utils/extensions/cubit.ext.dart';
import 'package:unisync/utils/extensions/list.ext.dart';
import 'package:unisync/utils/extensions/scope.ext.dart';

class HomeCubit extends Cubit<HomeState> with BaseCubit {
  HomeCubit(Device device)
      : super(HomeState(
          timestamp: DateTime.now().millisecondsSinceEpoch,
          currentDevice: device,
        )) {
    _load();
  }

  StreamSubscription? _currentDeviceSubscription;

  Future<void> _load() async {
    final myDevice = await ConfigUtil.device.getDeviceInfo();
    safeEmit(state.copyWith(
      myDevice: myDevice,
    ));
    Device.instanceNotifier.listen((devices) {
      devices.forEach(_listenNewDevice);
      _subscriptions.removeWhere((key, value) {
        final toRemove = !devices.contains(key);
        if (toRemove) {
          value.cancel();
        }
        return toRemove;
      });
    });
    Device.getAllDevices();
  }

  final Map<Device, StreamSubscription> _subscriptions = {};

  void _listenNewDevice(Device device) {
    if (_subscriptions.containsKey(device)) {
      return;
    }
    _subscriptions[device] = device.notifier.listen((event) {
      if (event.pairState == PairState.unpaired) {
        safeEmit(state.copyWith(
          timestamp: DateTime.now().millisecondsSinceEpoch,
          pairedDevices: state.pairedDevices.minus(device),
        ));
      } else if (event.pairState == PairState.paired) {
        safeEmit(state.copyWith(
          timestamp: DateTime.now().millisecondsSinceEpoch,
          pairedDevices: state.pairedDevices.let((it) {
            if (it.contains(device)) {
              return it;
            }
            return it.plus(device);
          }),
        ));
      }
    });
  }

  void setDevice(Device value) {
    if (state.currentDevice == value) {
      return;
    }
    safeEmit(state.copyWith(
      timestamp: DateTime.now().millisecondsSinceEpoch,
      currentDevice: value,
    ));
    ConfigUtil.device.setLastUsedDevice(value.info);
    _currentDeviceSubscription?.cancel();
    _currentDeviceSubscription = value.notifier.listen((event) {
      safeEmit(state.copyWith(
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ));
    });
  }

  Future<void> renameMyDevice(String newName) async {
    final newDeviceInfo = state.myDevice!.copy(
      name: newName,
    );
    await ConfigUtil.device.setDeviceInfo(newDeviceInfo);
    safeEmit(state.copyWith(
      myDevice: newDeviceInfo,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    ));
  }
}
