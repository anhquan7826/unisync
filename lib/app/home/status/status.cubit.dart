import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unisync/app/home/status/status.state.dart';
import 'package:unisync/components/enums/status.dart';
import 'package:unisync/core/device_provider.dart';
import 'package:unisync/core/plugins/battery.plugin.dart';
import 'package:unisync/core/plugins/ring_phone.plugin.dart';
import 'package:unisync/models/device_info/device_info.model.dart';
import 'package:unisync/utils/extensions/cubit.ext.dart';

class StatusCubit extends Cubit<StatusState> with BaseCubit {
  StatusCubit(this.deviceInfo) : super(const StatusState(status: Status.loading)) {
    _listen();
  }

  final DeviceInfo deviceInfo;

  BatteryPlugin get _statusPlugin => DeviceProvider.get(deviceInfo)!.getPlugin<BatteryPlugin>();

  RingPhonePlugin get _ringPhonePlugin => DeviceProvider.get(deviceInfo)!.getPlugin<RingPhonePlugin>();

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
