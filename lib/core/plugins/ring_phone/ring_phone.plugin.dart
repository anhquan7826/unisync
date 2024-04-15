import 'package:unisync/core/device.dart';
import 'package:unisync/core/plugins/base_plugin.dart';
import 'package:unisync/models/device_message/device_message.model.dart';

class RingPhonePlugin extends UnisyncPlugin {
  RingPhonePlugin(Device device) : super(device, type: DeviceMessage.Type.RING_PHONE);

  void ringMyPhone() {
    send({});
  }
}
