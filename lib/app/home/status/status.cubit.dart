import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unisync/app/home/status/status.state.dart';
import 'package:unisync/components/enums/status.dart';
import 'package:unisync/core/device.dart';
import 'package:unisync/core/plugins/battery.plugin.dart';
import 'package:unisync/core/plugins/ring_phone.plugin.dart';
import 'package:unisync/utils/extensions/cubit.ext.dart';

class StatusCubit extends Cubit<StatusState> with BaseCubit {
  StatusCubit(this.deviceId) : super(const StatusState(status: Status.loading)) {
    _listen();
  }

  final String deviceId;
  late final Device device = Device.fromId(deviceId);

  BatteryPlugin get _statusPlugin => device.getPlugin<BatteryPlugin>();

  RingPhonePlugin get _ringPhonePlugin => device.getPlugin<RingPhonePlugin>();

  void getStatus() {
    _statusPlugin.getBatteryInfo();
  }

  void ringMyPhone() {
    _ringPhonePlugin.ringMyPhone();
  }

  StreamSubscription? _subscription;

  void _listen() {
    _subscription = _statusPlugin.notifier.listen((value) {
      safeEmit(state.copyWith(
        status: Status.loaded,
        batteryLevel: value['level'],
        isCharging: value['isCharging'],
      ));
    });
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
