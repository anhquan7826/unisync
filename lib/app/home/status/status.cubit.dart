import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unisync/app/home/status/status.state.dart';
import 'package:unisync/core/device.dart';
import 'package:unisync/core/plugins/battery.plugin.dart';
import 'package:unisync/core/plugins/ring_phone.plugin.dart';
import 'package:unisync/utils/extensions/cubit.ext.dart';

class StatusCubit extends Cubit<StatusState> with BaseCubit {
  StatusCubit(this.device) : super(StatusState(info: device.info)) {
    _listen();
  }

  final Device device;

  StreamSubscription? _deviceSubscription;
  StreamSubscription? _statusSubscription;

  void _listen() {
    _deviceSubscription = device.notifier.listen((value) {
      safeEmit(state.copyWith(
        isOnline: value.connected,
        ipAddress: device.ipAddress,
      ));
      if (value.connected) {
        _statusSubscription = device.getPlugin<StatusPlugin>().notifier.listen((status) {
          safeEmit(state.copyWith(
            batteryLevel: status['level'],
            isCharging: status['isCharging'],
          ));
        });
      }
    });
  }

  void ringMyPhone() {
    device.getPlugin<RingPhonePlugin>().ringMyPhone();
  }

  @override
  Future<void> close() async {
    await _deviceSubscription?.cancel();
    await _statusSubscription?.cancel();
    return super.close();
  }
}
