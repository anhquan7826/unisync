import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unisync/app/home/home.state.dart';
import 'package:unisync/core/device.dart';
import 'package:unisync/core/pairing_handler.dart';
import 'package:unisync/utils/configs.dart';
import 'package:unisync/utils/extensions/cubit.ext.dart';
import 'package:unisync/utils/extensions/list.ext.dart';

class HomeCubit extends Cubit<HomeState> with BaseCubit {
  HomeCubit(Device device)
      : super(HomeState(
          timestamp: DateTime.now().millisecondsSinceEpoch,
          currentDevice: device,
        )) {
    _load();
  }

  Future<void> _load() async {
    final myDevice = await ConfigUtil.device.getDeviceInfo();
    final devices = (await ConfigUtil.device.getAllPairedDevices()).map((e) => Device(e));
    safeEmit(state.copyWith(
      myDevice: myDevice,
      pairedDevices: devices.toList()..remove(state.currentDevice),
    ));
    for (final device in devices) {
      _subscriptions[device] = device.notifier.listen((event) {
        if (event.pairState == PairState.unpaired) {
          safeEmit(state.copyWith(
            timestamp: DateTime.now().millisecondsSinceEpoch,
            pairedDevices: state.pairedDevices.minus(device),
          ));
          _subscriptions[device]?.cancel();
          _subscriptions.remove(device);
        } else {
          safeEmit(state.copyWith(
            timestamp: DateTime.now().millisecondsSinceEpoch,
          ));
        }
      });
    }
  }

  final Map<Device, StreamSubscription> _subscriptions = {};

  void setDevice(Device value) {
    safeEmit(state.copyWith(
        timestamp: DateTime.now().millisecondsSinceEpoch,
        currentDevice: value,
        pairedDevices: state.pairedDevices
          ..remove(value)
          ..insert(0, state.currentDevice)));
  }
}
