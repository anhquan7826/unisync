import 'dart:async';
import 'dart:io';

import 'package:unisync/core/device_discovery.dart';
import 'package:unisync/handlers/connection.plugin.dart';
import 'package:unisync/models/device_info/device_info.model.dart';
import 'package:unisync/utils/configs.dart';
import 'package:unisync/utils/constants/device_types.dart';
import 'package:unisync/utils/id_gen.dart';

class MainProcess {
  Future<void> initialize() async {
    if (!(await ConfigUtil.device.hasSetDeviceInfo())) {
      await ConfigUtil.device.setDeviceInfo(
        DeviceInfo(
          id: generateId(),
          name: Platform.localHostname,
          deviceType: DeviceTypes.linux,
          publicKey: ConfigUtil.authentication.getPublicKeyString(),
        ),
      );
    }
  }

  Future<void> start() async {
    await DeviceDiscovery.start();
  }

  Future<void> _configurePlugin() async {
    ConnectionPlugin();
  }
}
