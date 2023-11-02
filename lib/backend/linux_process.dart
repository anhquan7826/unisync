import 'dart:async';
import 'dart:io';

import 'package:unisync/backend/socket/socket.dart';
import 'package:unisync/constants/device_types.dart';
import 'package:unisync/models/device_info/device_info.model.dart';
import 'package:unisync/utils/configs.dart';
import 'package:unisync/utils/id_gen.dart';
import 'package:unisync/utils/logger.dart';

import 'avahi/avahi.dart';

class LinuxProcess {
  factory LinuxProcess() {
    _instance ??= LinuxProcess._();
    return _instance!;
  }
  LinuxProcess._();

  static LinuxProcess? _instance;

  late final Avahi _avahi;
  late final AppSocket _socket;

  Future<void> initialize() async {
    infoLog('Initializing Linux process.');
    if (!(await ConfigUtil.device.hasSetDeviceInfo())) {
      await ConfigUtil.device.setDeviceInfo(DeviceInfo(
          id: generateId(),
          name: Platform.localHostname,
          deviceType: DeviceTypes.linux,
          publicKey: await ConfigUtil.authentication.getPublicKeyString()));
    }
    _avahi = Avahi();
    _socket = AppSocket();
    infoLog('Linux process initialized.');
  }

  Future<void> start() async {
    infoLog('Starting Linux process.');
    await _avahi.register();
    await _socket.start();
    infoLog('Linux process started.');
  }
}
