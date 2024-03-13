import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unisync/app/home/notification/notification.state.dart';
import 'package:unisync/core/device.dart';
import 'package:unisync/core/plugins/notification/notification_plugin.dart';
import 'package:unisync/utils/extensions/cubit.ext.dart';

class NotificationCubit extends Cubit<NotificationState> with BaseCubit {
  NotificationCubit() : super(const NotificationState());

  Device? _device;

  Device? get device => _device;

  set device(Device? value) {
    if (_device != value) {
      _deviceSubscription?.cancel();
      _notificationSubscription?.cancel();
    }
    _device = value;
    if (_device != null) {
      safeEmit(state.copyWith(device: _device));
      _listen();
    }
  }

  StreamSubscription? _deviceSubscription;
  StreamSubscription? _notificationSubscription;

  void _listen() {
    _deviceSubscription = device!.notifier.listen((value) {
      safeEmit(state.copyWith(
        isOnline: value.connected,
      ));
      if (value.connected) {
        _notificationSubscription = device!.getPlugin<NotificationPlugin>().notifier.listen((value) {
          safeEmit(state.copyWith(notifications: value['notifications']));
        });
      }
    });
  }

  void delete(NotificationData notification) {
    device!.getPlugin<NotificationPlugin>().clearNotification(notification);
  }

  void clearAll() {
    device!.getPlugin<NotificationPlugin>().clearNotification();
  }
}
