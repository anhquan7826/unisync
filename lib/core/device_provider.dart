// ignore_for_file: close_sinks

import 'dart:io';
import 'dart:typed_data';

import 'package:rxdart/rxdart.dart';

import '../models/device_info/device_info.model.dart';
import '../utils/logger.dart';
import 'device.dart';
import 'device_connection.dart';

class DeviceProvider {
  DeviceProvider._();

  static final _devices = <DeviceInfo, Device>{};

  static List<DeviceInfo> get devices => _devices.values.map((e) => e.info).toList();

  static void create({required DeviceInfo info, required SecureSocket socket, required Stream<Uint8List> inputStream}) {
    if (_devices.containsKey(info)) {
      infoLog('DeviceProvider: Duplicate connection to ${info.name}@${info.ip}. Closing connection...');
      socket.close();
    } else {
      _devices[info] = Device(DeviceConnection(socket, inputStream, info));
      infoLog('DeviceProvider: Connected to ${info.name}@${info.ip}.');
    }
  }

  static void remove(DeviceInfo info) {
    _devices.remove(info);
  }

  static Device? get(DeviceInfo info) {
    return _devices[info];
  }

  static BehaviorSubject<DeviceInfo> currentRequestedDevices = BehaviorSubject();

  static List<DeviceInfo> get connectedDevices => _devices.keys.toList();
}
