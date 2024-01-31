import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unisync/app/home/status/status.state.dart';
import 'package:unisync/core/device_provider.dart';
import 'package:unisync/core/plugins/battery.plugin.dart';
import 'package:unisync/models/device_info/device_info.model.dart';
import 'package:unisync/utils/constants/load_state.dart';
import 'package:unisync/utils/extensions/cubit.ext.dart';

class StatusCubit extends Cubit<StatusState> with BaseCubit {
  StatusCubit(this.deviceInfo) : super(const StatusState(loadState: LoadState.loading)) {
    _listen();
  }

  final DeviceInfo deviceInfo;

  BatteryPlugin get plugin => DeviceProvider.get(deviceInfo)!.getPlugin<BatteryPlugin>();

  void getStatus() {
    plugin.getBatteryInfo();
  }

  StreamSubscription? _subscription;

  void _listen() {
    _subscription = plugin.notifier.listen((value) {
      safeEmit(state.copyWith(
        loadState: LoadState.loaded,
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
