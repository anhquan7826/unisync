// ignore_for_file: close_sinks

import 'dart:io';

import 'package:unisync_backend/core/device.dart';
import 'package:unisync_backend/core/device_connection.dart';
import 'package:unisync_backend/notification/event_notifier.dart';
import 'package:unisync_backend/notification/events/device_connected.event.dart';
import 'package:unisync_backend/utils/logger.dart';

import '../models/device_info/device_info.model.dart';
import '../notification/events/device_disconnected.event.dart';

class DeviceProvider {
  DeviceProvider._();

  static final _devices = <DeviceInfo, Device>{};

  static List<DeviceInfo> get devices => _devices.values.map((e) => e.info).toList();

  static void create({required DeviceInfo info, required SecureSocket socket}) {
    if (_devices.containsKey(info)) {
      socket.close();
    } else {
      _devices[info] = Device(DeviceConnection(socket, info));
      infoLog('Connected to ${info.name} (${info.ip}).');
      UnisyncEventNotifier.publish(DeviceConnectedEvent(info));
    }
  }

  static void remove(DeviceInfo info) {
    _devices.remove(info.id);
    UnisyncEventNotifier.publish(DeviceDisconnectedEvent(info));
  }
}
