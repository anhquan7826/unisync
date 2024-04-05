import 'package:unisync/core/plugins/base_plugin.dart';
import 'package:unisync/models/device_message/device_message.model.dart';

import '../../device.dart';

class StatusPlugin extends UnisyncPlugin {
  StatusPlugin(Device device) : super(device, type: DeviceMessage.Type.STATUS);

  @override
  void onReceive(Map<String, dynamic> data, DeviceMessagePayload? payload) {
    notifier.add(data);
  }

  void getBatteryInfo() {
    send({'get_info': 'request'});
  }
}
