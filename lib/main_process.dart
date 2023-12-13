import 'dart:async';
import 'dart:io';

import 'package:unisync/constants/device_types.dart';
import 'package:unisync/models/device_info/device_info.model.dart';
import 'package:unisync/plugin/socket_plugin.dart';
import 'package:unisync/plugin/unisync_plugin.dart';
import 'package:unisync/utils/configs.dart';
import 'package:unisync/utils/id_gen.dart';
import 'package:unisync/utils/logger.dart';

import 'plugin/mdns_plugin.dart';

abstract class MainProcess {
  Future<void> initialize();
  Future<void> start();
}

class LinuxProcess extends MainProcess {
  factory LinuxProcess() {
    _instance ??= LinuxProcess._();
    return _instance!;
  }
  LinuxProcess._();

  static LinuxProcess? _instance;

  late final MdnsPlugin _mdns;
  late final SocketPlugin _socket;

  @override
  Future<void> initialize() async {
    infoLog('Initializing Linux process.');
    if (!(await ConfigUtil.device.hasSetDeviceInfo())) {
      await ConfigUtil.device.setDeviceInfo(DeviceInfo(
          id: generateId(), name: Platform.localHostname, deviceType: DeviceTypes.linux, publicKey: ConfigUtil.authentication.getPublicKeyString()));
    }
    infoLog('Linux process initialized.');
  }

  @override
  Future<void> start() async {
    infoLog('Starting Linux process.');
    UnisyncPlugin.startPlugin();
    infoLog('Linux process started.');
  }
}

class WindowsProcess extends MainProcess {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> start() async {}
}
