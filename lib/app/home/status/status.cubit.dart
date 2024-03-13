import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unisync/app/home/status/status.state.dart';
import 'package:unisync/core/device.dart';
import 'package:unisync/core/plugins/ring_phone/ring_phone.plugin.dart';
import 'package:unisync/core/plugins/status/status.plugin.dart';
import 'package:unisync/utils/extensions/cubit.ext.dart';

class StatusCubit extends Cubit<StatusState> with BaseCubit {
  StatusCubit() : super(const StatusState());

  Device? _device;

  Device? get device => _device;

  set device(Device? value) {
    if (_device != value) {
      _deviceSubscription?.cancel();
      _statusSubscription?.cancel();
    }
    _device = value;
    if (_device != null) {
      safeEmit(state.copyWith(device: _device));
      _listen();
    }
  }

  StreamSubscription? _deviceSubscription;
  StreamSubscription? _statusSubscription;

  void _listen() {
    _deviceSubscription = device!.notifier.listen((value) {
      safeEmit(state.copyWith(
        isOnline: value.connected,
        ipAddress: device!.ipAddress,
      ));
      if (value.connected) {
        _statusSubscription = device!.getPlugin<StatusPlugin>().notifier.listen((status) {
          safeEmit(state.copyWith(
            batteryLevel: status['level'],
            isCharging: status['isCharging'],
          ));
        });
      }
    });
  }

  void ringMyPhone() {
    device?.getPlugin<RingPhonePlugin>().ringMyPhone();
  }

  @override
  Future<void> close() async {
    await _deviceSubscription?.cancel();
    await _statusSubscription?.cancel();
    return super.close();
  }
}
