// ignore_for_file: close_sinks

import 'dart:io';
import 'dart:typed_data';

import 'package:rxdart/rxdart.dart';

import '../models/device_info/device_info.model.dart';
import '../notification/event_notifier.dart';
import '../notification/events/device_connected.event.dart';
import '../notification/events/device_disconnected.event.dart';
import '../utils/logger.dart';
import 'device.dart';
import 'device_connection.dart';

class DeviceProvider {
  DeviceProvider._();

  static final _devices = <DeviceInfo, Device>{};

  static List<DeviceInfo> get devices => _devices.values.map((e) => e.info).toList();

  static void create({required DeviceInfo info, required SecureSocket socket, required Stream<Uint8List> inputStream}) {
    if (_devices.containsKey(info)) {
      socket.close();
    } else {
      _devices[info] = Device(DeviceConnection(socket, inputStream, info));
      infoLog('Connected to ${info.name} (${info.ip}).');
      UnisyncEventNotifier.publish(DeviceConnectedEvent(info));
    }
  }

  static void remove(DeviceInfo info) {
    _devices.remove(info);
    UnisyncEventNotifier.publish(DeviceDisconnectedEvent(info));
  }

  static Device? get(DeviceInfo info) {
    return _devices[info];
  }

  static BehaviorSubject<DeviceInfo> currentRequestedDevices = BehaviorSubject();

  static List<DeviceInfo> get connectedDevices => _devices.keys.toList();
}
