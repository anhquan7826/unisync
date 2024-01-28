import 'dart:async';
import 'dart:io';

import 'package:unisync/utils/id_gen.dart';

import 'core/device_discovery.dart';
import 'database/unisync_database.dart';
import 'models/device_info/device_info.model.dart';
import 'utils/configs.dart';
import 'utils/constants/device_types.dart';

class MainProcess {
  Future<void> initialize() async {
    await ConfigUtil.authentication.prepareCryptography();
    await UnisyncDatabase.initialize();
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
}
