// ignore_for_file: close_sinks

import 'dart:io';
import 'dart:typed_data';

import 'package:rxdart/rxdart.dart';
import 'package:unisync/core/pairing_handler.dart';

import '../models/device_info/device_info.model.dart';
import '../utils/logger.dart';
import 'device.dart';
import 'device_connection.dart';

class DeviceProvider {
  DeviceProvider._();

  static final _devices = <DeviceInfo>{};

  static List<DeviceInfo> get connectedDevices => _devices.toList();

  static void create({required DeviceInfo info, required SecureSocket socket, required Stream<Uint8List> inputStream}) {
    if (_devices.contains(info)) {
      socket.close();
    } else {
      _devices.add(info);
      final connection = DeviceConnection(socket, inputStream, () {
        _devices.remove(info);
      });
      Device(info).connection = connection;
    }
  }

  static final notifier = BehaviorSubject<List<DeviceInfo>>()..add(connectedDevices);

  static void providerNotify() {
    notifier.add(connectedDevices);
  }
}
