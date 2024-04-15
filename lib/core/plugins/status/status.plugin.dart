import 'package:unisync/core/device.dart';
import 'package:unisync/core/device_connection.dart';
import 'package:unisync/core/plugins/base_plugin.dart';
import 'package:unisync/models/device_message/device_message.model.dart';

class StatusPlugin extends UnisyncPlugin {
  StatusPlugin(Device device) : super(device, type: DeviceMessage.Type.STATUS);

  @override
  void onReceive(Map<String, dynamic> data, Payload? payload) {
    super.onReceive(data, payload);
    notifier.add(data);
  }

  void sendStatusRequest() {
    send({});
  }
}
