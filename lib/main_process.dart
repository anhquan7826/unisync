import 'dart:async';
import 'dart:io';

import 'package:unisync/database/database.dart';
import 'package:unisync/utils/constants/device_types.dart';
import 'package:unisync/utils/id_gen.dart';
import 'package:unisync/utils/push_notification.dart';

import 'core/device_discovery.dart';
import 'models/device_info/device_info.model.dart';
import 'utils/configs.dart';

class MainProcess {
  Future<void> initialize() async {
    await ConfigUtil.authentication.prepareCryptography();
    await ConfigUtil.initialize();
    if (!(await ConfigUtil.device.hasSetDeviceInfo())) {
      await ConfigUtil.device.setDeviceInfo(
        DeviceInfo(
          id: generateId(),
          name: Platform.localHostname,
          deviceType: DeviceTypes.linux,
        ),
      );
    }
    await PushNotification.setup();
  }

  Future<void> start() async {
    await DeviceDiscovery.start();
  }
}
