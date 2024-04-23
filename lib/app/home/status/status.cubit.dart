import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unisync/app/home/status/status.state.dart';
import 'package:unisync/core/device.dart';
import 'package:unisync/core/plugins/clipboard/clipboard.plugin.dart';
import 'package:unisync/core/plugins/ring_phone/ring_phone.plugin.dart';
import 'package:unisync/core/plugins/status/status.plugin.dart';
import 'package:unisync/utils/extensions/cubit.ext.dart';
import 'package:unisync/utils/extensions/scope.ext.dart';

class StatusCubit extends Cubit<StatusState> with BaseCubit {
  StatusCubit(this.device) : super(const StatusState()) {
    device.getPlugin<StatusPlugin>().apply((it) {
      subscription = it.notifier.listen((value) {
        onStatus(
          isCharging: value['isCharging'],
          level: value['level'],
          wallpaper: value['wallpaper'],
        );
      });
      it.sendStatusRequest();
    });
  }

  final Device device;
  late final StreamSubscription subscription;

  void onStatus({required bool isCharging, required int level, Uint8List? wallpaper,}) {
    safeEmit(state.copyWith(
      batteryLevel: level,
      isCharging: isCharging,
      wallpaper: wallpaper,
    ));
  }

  void ringMyPhone() {
    device.getPlugin<RingPhonePlugin>().ringMyPhone();
  }

  void sendClipboard() {
    device.getPlugin<ClipboardPlugin>().onClipboardChanged();
  }

  @override
  Future<void> close() {
    subscription.cancel();
    return super.close();
  }
}
