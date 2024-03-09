import 'package:unisync/core/plugins/base_plugin.dart';
import 'package:unisync/models/device_message/device_message.model.dart';

import '../device.dart';

class BatteryPlugin extends UnisyncPlugin {
  BatteryPlugin(Device device) : super(device, type: DeviceMessage.Type.BATTERY);

  @override
  void onReceive(Map<String, dynamic> data) {
    notifier.add(data);
  }

  void getBatteryInfo() {
    send({'request': 'get_info'});
  }
}
